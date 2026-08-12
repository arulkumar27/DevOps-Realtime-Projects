variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "rds_arn" {
  type = string
}

variable "backup_schedule" {
  description = "AWS Backup cron schedule in UTC"
  type        = string
}

variable "retention_days" {
  description = "Recovery-point retention period"
  type        = number
}