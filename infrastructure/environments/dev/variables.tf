variable "org_name" {
  type        = string
  description = "The organization name (will be prefixed in resource names)"
}

variable "aws_region" {
  type        = string
  description = "The AWS region resources are deployed in"
}

variable "environment" {
  type        = string
  description = "The environment that the infrastructure will be deployed into"
}