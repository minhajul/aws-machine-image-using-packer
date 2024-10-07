packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ami_prefix" {
  type        = string
  description = "Prefix for the AMI name"
  default     = "new-ubuntu-machine-image"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "infra_env" {
  type        = string
  description = "Environment for the AMI (e.g., dev, staging, prod)"
  default     = "dev"
}

source "amazon-ebs" "ubuntu" {
  ami_name        = "${var.ami_prefix}-${local.timestamp}"
  ami_description = "AMI for ${var.ami_prefix} in ${var.infra_env} environment"
  instance_type   = "t2.micro"
  region          = "ap-southeast-1"
  ssh_username    = "ubuntu"

  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = false
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
  }

  tags = {
    "Name"        = "${var.ami_prefix}-${var.infra_env}"
    "Environment" = var.infra_env
    "Role"        = "baked-ami",
    "Unique"      = "baked-ami-{{timestamp}}",
    "ManagedBy"   = "packer",
    "Component"   = "app"
  }
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    script = "./scripts/base.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "ansible/playbook.yml"
    role_paths    = [
      "ansible/roles/base",
      "ansible/roles/php",
      "ansible/roles/nginx",
      "ansible/roles/app"
    ]
    group_vars = "ansible/group_vars"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}