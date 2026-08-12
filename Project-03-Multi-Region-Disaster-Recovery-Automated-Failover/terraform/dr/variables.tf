variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "private_db_subnet_cidrs" {
  type = list(string)
}

variable "controller_public_cidr" {
  description = "Primary Ansible controller public IP in CIDR format"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  description = "Existing EC2 key-pair name in Hyderabad"
  type        = string
}

variable "asg_minimum_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}

variable "asg_maximum_size" {
  type = number
}