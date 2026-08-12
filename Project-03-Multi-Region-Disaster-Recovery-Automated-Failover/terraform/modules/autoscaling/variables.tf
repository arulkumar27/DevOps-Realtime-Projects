variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region_role" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "application_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  description = "Existing EC2 key-pair name"
  type        = string
}

variable "minimum_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "maximum_size" {
  type = number
}

variable "health_check_type" {
  description = "Auto Scaling health-check type: EC2 during deployment, ELB after application validation"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "health_check_type must be EC2 or ELB."
  }
}