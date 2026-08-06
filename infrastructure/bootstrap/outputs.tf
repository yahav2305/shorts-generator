output "tf_state_bucket_name" {
  description = "Name of the created S3 state bucket"
  value       = aws_s3_bucket.tf_state_bucket.id
}

output "backend_config_snippet" {
  description = "Pre-formatted backend configuration block"
  value       = <<EOF
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.tf_state_bucket.id}"
    key            = "workloads/terraform.tfstate"
    use_lockfile   = true
    region         = "${var.aws_region}"
    encrypt        = true
  }
}
EOF
}