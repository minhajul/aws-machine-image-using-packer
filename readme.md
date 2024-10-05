### Packer Configuration For Creating an AMI

Packer is a free and open source tool for creating golden images for multiple platforms from a single source configuration.

### Use Cases
- Automated image builds
- Golden image pipeline
- Image compliance
- Integrate with Terraform

### Getting Started
After cloning this project, you can start editing the configurations by modifying `machine-image.json`.

After changing the configuration, run the below command to validate the configuration:

```bash
packer validate machine-image.json
```

Then, run the below command to create an image to your configured provider account.

```bash
packer build -var "infra_env=staging" -var "vault_pass=secret" machine-image.json
```
You can to change `infra_env` and `vault_pass` whatever you want.

Check out our [Official Documentation](https://www.packer.io/) for more details.