terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57.0"
    }
  }

  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}