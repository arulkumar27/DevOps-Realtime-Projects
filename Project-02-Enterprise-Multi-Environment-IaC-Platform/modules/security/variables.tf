variable "name_prefix" {
  description = "Prefix added to security-group names"
  type        = string
}

variable "vpc_id" {
  description = "VPC where security groups are created"
  type        = string
}

variable "listener_port" {
  description = "Public port exposed by the load balancer"
  type        = number

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "Listener port must be between 1 and 65535."
  }
}

variable "application_port" {
  description = "Port used by the application"
  type        = number

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535
    error_message = "Application port must be between 1 and 65535."
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to access the load balancer"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.allowed_ingress_cidrs :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every ingress value must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Additional tags applied to security resources"
  type        = map(string)
  default     = {}
}