variable "name_prefix" {
  description = "Prefix added to IAM resource names"
  type        = string
}

variable "tags" {
  description = "Additional tags applied to IAM resources"
  type        = map(string)
  default     = {}
}