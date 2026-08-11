output "application_role_name" {
  description = "Name of the application EC2 IAM role"
  value       = aws_iam_role.application.name
}

output "application_role_arn" {
  description = "ARN of the application EC2 IAM role"
  value       = aws_iam_role.application.arn
}

output "application_instance_profile_name" {
  description = "Instance profile name used by the EC2 launch template"
  value       = aws_iam_instance_profile.application.name
}

output "application_instance_profile_arn" {
  description = "Instance profile ARN used by application instances"
  value       = aws_iam_instance_profile.application.arn
}