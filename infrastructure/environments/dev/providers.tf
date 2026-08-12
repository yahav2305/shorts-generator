terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57.0"
    }
  }

  backend "s3" {
    bucket       = "shorts-generator-tfstate-dev-552952090397-us-east-1-an"
    key          = "dev/terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}