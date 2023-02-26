terraform {
    # backend "remote" {
    #   hostname = "app.terraform.io"
    #   organization = "abrasham"

    #   workspaces {
    #     name = "getting-started"
    #   }
    # }
    
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.55.0"
    }
  }
}