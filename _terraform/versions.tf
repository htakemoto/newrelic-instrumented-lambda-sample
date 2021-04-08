# Install Terraform AWS Plugin

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.aws_region
}