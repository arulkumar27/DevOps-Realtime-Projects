variable "aws_region" {
  description = "AWS region used to create the Terraform backend"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "Enter a valid AWS region, such as ap-south-1."
  }
}

variable "project_name" {
  description = "Name used to identify project resources"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) >= 3
    error_message = "Project name must contain at least three characters."
  }
}

variable "common_tags" {
  description = "Tags applied to backend resources"
  type        = map(string)
  default     = {}
}