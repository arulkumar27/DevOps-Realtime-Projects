variable "aws_region" {
  description = "AWS region used for deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "Enter a valid AWS region."
  }
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) >= 3
    error_message = "Project name must contain at least three characters."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      lower(var.environment)
    )
    error_message = "Environment must be dev, staging or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Enter a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the environment"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private application subnets"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required."
  }
}

variable "common_tags" {
  description = "Additional tags applied to AWS resources"
  type        = map(string)
  default     = {}
}

variable "listener_port" {
  description = "Public port exposed by the load balancer"
  type        = number
}

variable "application_port" {
  description = "Port used by the private application"
  type        = number
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed to access the load balancer"
  type        = list(string)
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN"
  type        = string
  default     = null
  nullable    = true
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_volume_size" {
  description = "EC2 root-volume size in GiB"
  type        = number
}

variable "minimum_capacity" {
  description = "Minimum Auto Scaling capacity"
  type        = number
}

variable "desired_capacity" {
  description = "Desired Auto Scaling capacity"
  type        = number
}

variable "maximum_capacity" {
  description = "Maximum Auto Scaling capacity"
  type        = number
}

variable "health_check_grace_period" {
  description = "Time allowed for new instances to become healthy"
  type        = number
}

variable "notification_emails" {
  description = "Email recipients for infrastructure alarms"
  type        = set(string)
  default     = []
}