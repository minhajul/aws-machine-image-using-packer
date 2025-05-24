### Packer Configuration For Creating an AMI

Packer is a free and open source tool for creating golden images for multiple platforms from a single source configuration.

### Use Cases
- Automated image builds
- Integrate with Terraform

### Getting Started
After cloning this project, you can start editing the configurations by modifying ```machine-image.pkr.hcl```.

To proceed, you need to specify your ```vpc_id``` and ```subnet_id```. You can retrieve these values using the AWS CLI:

```bash
aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --region ap-southeast-1

aws ec2 describe-subnets --filters Name=vpc-id,Values=<your-vpc-id> --query 'Subnets[].SubnetId' --region ap-southeast-1
```
These commands will return your VPC and subnet IDs. After obtaining them, update the ```machine-image.pkr.hcl``` file accordingly.

```bash 
variable "vpc_id" {
  type        = string
  description = "Target VPC ID for building the AMI"
  default     = "vpc-****" # Replace with your VPC ID
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for temporary instance"
  default     = "subnet-****" # Replace with your public subnet ID
}
```

Once you've made the changes, validate your configuration using:

```bash
packer init machine-image.pkr.hcl
```
Then 

```bash
packer validate machine-image.pkr.hcl
```

Then, run the below command to create an image to your configured provider account.

```bash
packer build -var "infra_env=staging" machine-image.pkr.hcl
```
You can change `infra_env` whatever you want.

Check out our [Official Documentation](https://www.packer.io/) for more details.