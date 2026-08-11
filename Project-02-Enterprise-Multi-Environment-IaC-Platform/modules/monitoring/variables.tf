variable "name_prefix" {
  description = "Prefix added to monitoring resource names"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target-group ARN suffix used by CloudWatch"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Application Auto Scaling Group name"
  type        = string
}

variable "notification_emails" {
  description = "Email addresses subscribed to infrastructure alarms"
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to monitoring resources"
  type        = map(string)
  default     = {}
}