output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Route 53 zone ID of the Application Load Balancer"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.application.arn
}

output "listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.application.arn
}

output "load_balancer_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch metrics"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target-group ARN suffix used by CloudWatch metrics"
  value       = aws_lb_target_group.application.arn_suffix
}