output "launch_template_id" {
  description = "ID of the application launch template"
  value       = aws_launch_template.application.id
}

output "launch_template_latest_version" {
  description = "Latest application launch-template version"
  value       = aws_launch_template.application.latest_version
}

output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group"
  value       = aws_autoscaling_group.application.name
}

output "autoscaling_group_arn" {
  description = "ARN of the application Auto Scaling Group"
  value       = aws_autoscaling_group.application.arn
}