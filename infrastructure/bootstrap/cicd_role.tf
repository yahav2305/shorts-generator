data "aws_iam_policy_document" "cicd_assume_role" {
  dynamic "statement" {
    for_each = var.environment != "dev" ? [1] : []

    content {
      sid     = "AllowEnvironmentDeployments"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github.arn]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.github_org_name}@${var.github_org_id}/${var.github_repo_name}@${var.github_repo_id}:environment:${var.environment}"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:ref"
        values   = ["refs/heads/main"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.environment == "dev" ? [1] : []

    content {
      sid     = "AllowEphemeralPRBuilds"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github.arn]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.github_org_name}@${var.github_org_id}/${var.github_repo_name}@${var.github_repo_id}:pull_request"]
      }
    }
  }
}

data "aws_iam_policy_document" "cicd_scoped_permissions" {
  statement {
    sid    = "AllowGeneralResourceManagement"
    effect = "Allow"
    actions = [
      "s3:*",
      "dynamodb:*",
      "ec2:*",
      "ecs:*",
      "ecr:*",
      "lambda:*",
      "logs:*",
      "iam:*",
      "route53:*",
      "cloudwatch:*",
      "events:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyAccountLevelSecurityChanges"
    effect = "Deny"
    actions = [
      "organizations:*",
      "account:*",
      "aws-portal:*",
      "budgets:*",
      "iam:DeleteAccountPasswordPolicy",
      "iam:CreateAccountAlias"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PreventSelfEscalation"
    effect = "Deny"
    actions = [
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePermissionsBoundary",
      "iam:UpdateAssumeRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy"
    ]

    resources = [
      aws_iam_role.cicd_deployer.arn,
      "arn:aws:iam::*:oidc-provider/*"
    ]
  }

  statement {
    sid    = "DenyRoleCreationWithoutBoundary"
    effect = "Deny"
    actions = [
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:AttachRolePolicy"
    ]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "iam:PermissionsBoundary"
      values   = [aws_iam_policy.cicd_workload_boundary.arn]
    }
  }
}

data "aws_iam_policy_document" "cicd_workload_boundary" {
  statement {
    sid    = "AllowStandardWorkloads"
    effect = "Allow"
    actions = [
      "s3:*",
      "dynamodb:*",
      "ec2:*",
      "ecs:*",
      "ecr:*",
      "lambda:*",
      "route53:*",
      "cloudwatch:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowIAMAndAccountAdmin"
    effect = "Deny"
    actions = [
      "iam:*",
      "organizations:*",
      "account:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cicd_deployer" {
  name               = "${var.environment}-cicd-deployer-${var.github_org_name}-${var.github_repo_name}"
  assume_role_policy = data.aws_iam_policy_document.cicd_assume_role.json
}

resource "aws_iam_policy" "cicd_workload_boundary" {
  name        = "${var.environment}-cicd-workload-boundary-${var.github_org_name}-${var.github_repo_name}"
  description = "Maximum permissions ceiling for workload roles created by the CI/CD deployer role"
  policy      = data.aws_iam_policy_document.cicd_workload_boundary.json
}

resource "aws_iam_policy" "cicd_scoped_policy" {
  name        = "${var.environment}-cicd-policy-${var.github_org_name}-${var.github_repo_name}"
  description = "Scoped deployment permissions for Terraform CI/CD"
  policy      = data.aws_iam_policy_document.cicd_scoped_permissions.json
}