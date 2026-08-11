# Display the generated S3 bucket name after deployment.
output "state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

# Display the bucket ARN for IAM policy configuration.
output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

# Display the AWS region where the backend was created.
output "backend_region" {
  description = "AWS region containing the Terraform state bucket"
  value       = var.aws_region
}