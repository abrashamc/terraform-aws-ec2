variable "instance_type" {
  type = string
  description = "The size of the instance."
  validation {
    condition = can(regex("^t2.", var.instance_type))
    error_message = "The instance must be a t2 type EC2 instance"
  }
}

variable "ssh_public_key" {
  type = string
  description = "SSH public key"
  sensitive = true
}

variable "ssh_private_key_location" {
  type = string
  description = "Location of ssh private key file"
  sensitive = true
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "ip_with_cidr" {
  type = string
  description = "IP with CIDR (e.g. 10.0.0.4/32)"
}