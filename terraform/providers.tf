terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "taylor-shift-tfstate-819109475304"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "taylor-shift-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}