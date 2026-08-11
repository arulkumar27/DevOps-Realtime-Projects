variable "name_prefix" {
  description = "Prefix added to compute resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI used by application instances"
  type        = string

  validation {
    condition     = can(regex("^ami-[a-f0-9]+$", var.ami_id))
    error_message = "Enter a valid AMI ID."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets used by the Auto Scaling Group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required."
  }
}

variable "application_security_group_id" {
  description = "Security group assigned to application instances"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile assigned to application instances"
  type        = string
}

variable "target_group_arns" {
  description = "ALB target groups connected to the Auto Scaling Group"
  type        = list(string)
}

variable "application_user_data" {
  description = "Optional startup configuration supplied to instances"
  type        = string
  default     = null
  nullable    = true
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "Root volume must be at least 8 GiB."
  }
}

variable "minimum_capacity" {
  description = "Minimum number of application instances"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of application instances"
  type        = number
}

variable "maximum_capacity" {
  description = "Maximum number of application instances"
  type        = number
}

variable "health_check_grace_period" {
  description = "Time allowed for new instances to become healthy"
  type        = number
}

variable "tags" {
  description = "Additional tags applied to compute resources"
  type        = map(string)
  default     = {}
}