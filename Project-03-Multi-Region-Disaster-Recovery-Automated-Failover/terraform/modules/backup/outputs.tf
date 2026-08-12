output "primary_backup_vault_name" {
  value = aws_backup_vault.primary.name
}

output "dr_backup_vault_name" {
  value = aws_backup_vault.dr.name
}

output "backup_plan_id" {
  value = aws_backup_plan.this.id
}

output "backup_role_arn" {
  value = aws_iam_role.backup.arn
}