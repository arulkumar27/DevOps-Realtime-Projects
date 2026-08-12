variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region_role" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "ssh_allowed_cidr" {
  description = "Trusted IP allowd to SSH to the Ansible controller"
  type        = string
}