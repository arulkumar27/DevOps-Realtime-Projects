variable "project_name" {
  description = "Name used to identify process resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS primary region"
}

variable "vpc_cidr" {
  description = "CIDR range assigned to primary VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the primary environment"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR ranges for private application subnets"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR ranges for private database subnets"
  type        = list(string)
}

variable "ssh_allowed_cidr" {
  description = "Trusted public IP allowed to access the Ansible controller"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR."
  }
}

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key-pair name in the primary region"
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

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS storage size in GB"
  type        = number
}

variable "db_name" {
  description = "Initial application database name"
  type        = string
}

variable "db_username" {
  description = "RDS administrator username"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
}

variable "dr_region" {
  description = "AWS disaster-recovery region"
  type        = string
}

variable "backup_schedule" {
  description = "AWS Backup cron schedule in UTC"
  type        = string
}

variable "backup_retention_days" {
  description = "Number of days to retain recovery points"
  type        = number
}

variable "ec2_cpu_alarm_threshold" {
  description = "EC2 CPU percentage that triggers an alarm"
  type        = number
}

variable "rds_cpu_alarm_threshold" {
  description = "RDS CPU percentage that triggers an alarm"
  type        = number
}

variable "controller_instance_type" {
  description = "EC2 instance type for the Ansible controller"
  type        = string
}