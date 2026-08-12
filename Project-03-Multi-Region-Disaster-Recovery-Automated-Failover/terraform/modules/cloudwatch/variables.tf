variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region_role" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "autoscaling_group_name" {
  type = string
}

variable "db_instance_identifier" {
  type = string
}

variable "ec2_cpu_threshold" {
  type = number
}

variable "rds_cpu_threshold" {
  type = number
}