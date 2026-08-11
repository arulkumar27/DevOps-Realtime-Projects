variable "name_prefix" {
  description = "Prefix added to networking resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Enter a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private subnets"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags applied to networking resources"
  type        = map(string)
  default     = {}
}