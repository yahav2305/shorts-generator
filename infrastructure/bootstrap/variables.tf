variable "environment" {
  type        = string
  description = "The environment that resources are created in"

  validation {
    condition     = contains(["dev", "prod", "shared-svcs"], var.environment)
    error_message = "The environment variable must be one of: dev, prod, shared-svcs"
  }
}

variable "org_name" {
  type        = string
  description = "The organization name (will be prefixed in resource names)"
}

variable "aws_region" {
  type        = string
  description = "The AWS region resources are deployed in"
}

variable "github_org" {
  type        = string
  description = "The Github organization that OIDC will provide access keys to"
}

variable "github_repo" {
  type        = string
  description = "The Github repository in the Github organization that OIDC will provide access keys to"
}