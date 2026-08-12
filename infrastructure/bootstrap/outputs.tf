output "tf_state_bucket_name" {
  description = "Name of the created S3 state bucket"
  value       = aws_s3_bucket.tf_state_bucket.id
}

output "cicd_role_arn" {
  description = "ARN for the CI/CD deployment role"
  value       = aws_iam_role.cicd_deployer.arn
}