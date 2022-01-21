# main.tf

# Specifies provider and acess details

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "flask-devops-tfstate"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}