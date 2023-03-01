data "aws_ami" "east-amazon-linux-2" {
  # provider = aws.east
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# data "aws_ami" "west-amazon-linux-2" {
#   provider = aws.west
#   most_recent = true
#   owners = ["amazon"]
#   filter {
#     name = "owner-alias"
#     values = ["amazon"]
#   }
#   filter {
#     name = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

# resource "aws_instance" "my_west_server" {
#   count = 1
#   ami = data.aws_ami.west-amazon-linux-2.id
#   instance_type = var.instance_type
#   provider = aws.west
#   key_name = "${aws_key_pair.deployer.key_name}"
#   vpc_security_group_ids = [aws_security_group.sg_my_server_west.id]
#   tags = {
#     #Name = "${local.project_name}-server-${count.index}"
#     Name = "Server-West"
#   }
#   # depends_on = [
#   #   aws_security_group.sg_my_server_west
#   # ]
# }

resource "aws_instance" "my_east_ssh_server" {
  count = 1
  ami = data.aws_ami.east-amazon-linux-2.id
  instance_type = var.instance_type
  # provider = aws.east
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_my_ssh_server_east.id]
  tags = {
    Name = "${local.project_name}-ssh-server-${count.index}-${terraform.workspace}"
  }
  # depends_on = [
  #   aws_security_group.sg_my_ssh_server_east
  # ]

  # # to run need to turn off remote backend in main.tf
  # provisioner "local-exec" {
  #   command = "echo ${self.private_ip} >> ./private_ips.txt"
  # }

  # provisioner "file" {
  #   content = "ami used: ${self.ami}"
  #   destination = "/home/ec2-user/ami.txt"
  #   connection {
  #     type = "ssh"
  #     user = "ec2-user"
  #     host = "${self.public_ip}"
  #     private_key = file(pathexpand(var.ssh_private_key_location))
  #   }
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt",
  #     "ansible-playbook --version",
  #     "ansible-playbook /home/user/config_deploy_del_rm_test/hw.yml"
  #   ]
  #   connection {
  #     type = "ssh"
  #     user = "ec2-user"
  #     host = "${self.public_ip}"
  #     private_key = file(pathexpand(var.ssh_private_key_location))
  #   }
  # }
}

#waits for instance status checks to complete
# resource "null_resource" "status" {
#   provisioner "local-exec" {
#     command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.my_server.id}"
#   }
#   depends_on = [
#     aws_instance.my_server
#   ]
# }

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key-1"
  public_key = var.ssh_public_key
}

data "aws_vpc" "vpc_east" {
  id = var.vpc_id
}

# data "aws_vpc" "vpc_west" {
#   id = var.vpd_id_west
# }

resource "aws_security_group" "sg_my_ssh_server_east" {
  name        = "sg_my_ssh_server_east"
  description = "MyServer security group"
  vpc_id      = data.aws_vpc.vpc_east.id

  dynamic "ingress" {
    for_each = local.ingress
    content {
      description      = ingress.value.description
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = ingress.value.protocol
      cidr_blocks      = [var.ip_with_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  }

  # ingress {
  #   description      = "SSH"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = [var.ip_with_cidr]
  #   ipv6_cidr_blocks = []
  #   prefix_list_ids = []
  #   security_groups = []
  #   self = false
  # }
  # ingress {
  #   description      = "HTTP"
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = []
  #   prefix_list_ids = []
  #   security_groups = []
  #   self = false
  # }

  egress {
    description = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }
}

# resource "aws_security_group" "sg_my_server_west" {
#   name        = "sg_my_server"
#   description = "MyServer security group"
#   vpc_id      = data.aws_vpc.vpc_west.id

#   ingress {
#     description      = "SSH"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = [var.ip_with_cidr]
#     ipv6_cidr_blocks = []
#     prefix_list_ids = []
#     security_groups = []
#     self = false
#   }

#   egress {
#     description = "outgoing traffic"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#     prefix_list_ids = []
#     security_groups = []
#     self = false
#   }
# }

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
# #   providers = {
# #     aws = aws.eu
# #    }
#   name = "my-vpc"
#   cidr = "10.0.0.0/16"

#   azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

locals {
  project_name = "personal"
}

locals {
  ingress = [{
    port = 443
    description = "Port 443"
    protocol = "tcp"
  },
  {
    port = 80
    description = "Port 80"
    protocol = "tcp"
    
  },
  {
    port = 22
    description = "Port 22"
    protocol = "tcp"
  }]
}
