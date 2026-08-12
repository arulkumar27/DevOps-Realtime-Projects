variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "project03-multi-region-dr"
}

variable "primary_region" {
  description = "Region conatianing the terraform state bucket"
  type        = string
  default     = "ap-south-1"
}