variable "project_name" {
  type = string
}

variable "aws_region" {
  description = "Region used for AWS provider operations"
  type        = string
}

variable "hosted_zone_name" {
  description = "Existing Route 53 public hosted-zone name"
  type        = string
}

variable "record_name" {
  description = "Failover DNS record"
  type        = string
}