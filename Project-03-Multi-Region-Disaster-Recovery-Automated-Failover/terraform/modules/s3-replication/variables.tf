variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "force_destroy" {
  description = "Allow Terraform to remove non-empty lab buckets"
  type        = bool
  default     = false
}