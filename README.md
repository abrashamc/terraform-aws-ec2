Terraform module to provision an EC2 instance with ssh capabilities.

- Log in: `ssh ec2-user@$(terraform output -raw public_ip) -i ~/
.ssh/terraform`\

Not intented for production use.

```hcl
terraform {
}

provider "aws" {
  #profile = "default"
  region = "us-east-1"
  alias  = "east"
}

module "terraform-aws-ec2" {
  source = "./modules/terraform-aws-ec2"
  instance_type = "t2.micro"
  ssh_public_key = ${ssh_public_key}
  ssh_private_key_location = ${ssh_private_key_location}
  vpc_id = "vpc-000000"
  ip_with_cidr = "${MY_IP_ADDRESS}/32"
}
```


### TODO
Add capability to run from MacOS menu bar
