variable "name_prefix" {
  description = "Prefix added to ALB resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the load balancer"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the load balancer"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires at least two public subnets."
  }
}

variable "security_group_ids" {
  description = "Security groups assigned to the load balancer"
  type        = list(string)
}

variable "listener_port" {
  description = "Port exposed by the load balancer"
  type        = number
}

variable "application_port" {
  description = "Port used by application instances"
  type        = number
}

variable "health_check_path" {
  description = "Application endpoint used for target health checks"
  type        = string

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "Health-check path must start with a forward slash."
  }
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN used for HTTPS"
  type        = string
  default     = null
  nullable    = true
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion"
  type        = bool
}

variable "tags" {
  description = "Additional tags applied to ALB resources"
  type        = map(string)
  default     = {}
}