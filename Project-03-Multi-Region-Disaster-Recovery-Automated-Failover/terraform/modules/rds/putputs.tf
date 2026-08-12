output "db_instance_identifier" {
  value = aws_db_instance.this.identifier
}

output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "master_user_secret_arn" {
  value     = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
  sensitive = true
}

output "db_arn" {
  value = aws_db_instance.this.arn
}