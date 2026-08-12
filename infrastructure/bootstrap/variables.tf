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

variable "github_org_name" {
  type        = string
  description = "The Github organization name that OIDC will provide access keys to"
}

variable "github_org_id" {
  type        = string
  description = "The Github organization ID that OIDC will provide access keys to. Can be searched by `curl -Ss https://api.github.com/repos/yahav2305/shorts-generator | jq .owner.id`"
}

variable "github_repo_name" {
  type        = string
  description = "The Github repository name in the Github organization that OIDC will provide access keys to"
}

variable "github_repo_id" {
  type        = string
  description = "The Github repository ID in the Github organization that OIDC will provide access keys to. Can be searched by `curl -Ss https://api.github.com/repos/yahav2305/shorts-generator | jq .id`"
}