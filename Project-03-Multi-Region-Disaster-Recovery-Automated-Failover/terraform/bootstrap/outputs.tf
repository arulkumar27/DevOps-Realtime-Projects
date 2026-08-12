output "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_region" {
  description = "Region of the Terraform state bucket"
  value       = var.primary_region
}