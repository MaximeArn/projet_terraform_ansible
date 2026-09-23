terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.5"
    }
  }

  backend "s3" {
    bucket       = "taylor-shift-tfstate-819109475304"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "ansible" {}