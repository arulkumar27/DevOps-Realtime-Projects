output "vpc_id" {
  description = "Development VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Development public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Development private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "load_balancer_dns_name" {
  description = "Public DNS address of the development application"
  value       = module.alb.load_balancer_dns_name
}

output "autoscaling_group_name" {
  description = "Development Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

output "sns_topic_arn" {
  description = "Development infrastructure alert topic"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_alarm_names" {
  description = "Development CloudWatch alarms"
  value       = module.monitoring.cloudwatch_alarm_names
}