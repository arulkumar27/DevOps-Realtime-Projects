output "primary_vpc_id" {
  value = module.networking.vpc_id
}

output "primary_alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "primary_target_group_arn" {
  value = module.alb.target_group_arn
}

output "primary_autoscaling_group_name" {
  value = module.autoscaling.autoscaling_group_name
}

output "primary_ubuntu_ami_id" {
  value = module.autoscaling.ubuntu_ami_id
}

output "primary_db_identifier" {
  value = module.rds.db_instance_identifier
}

output "primary_db_endpoint" {
  value = module.rds.db_endpoint
}

output "primary_db_secret_arn" {
  value     = module.rds.master_user_secret_arn
  sensitive = true
}

output "primary_application_bucket" {
  value = module.s3_replication.primary_bucket_name
}

output "dr_replica_bucket" {
  value = module.s3_replication.replica_bucket_name
}

output "primary_backup_vault" {
  value = module.backup.primary_backup_vault_name
}

output "dr_backup_vault" {
  value = module.backup.dr_backup_vault_name
}

output "backup_plan_id" {
  value = module.backup.backup_plan_id
}

output "primary_health_alarm" {
  value = module.cloudwatch.unhealthy_targets_alarm_name
}

output "primary_alb_5xx_alarm" {
  value = module.cloudwatch.alb_5xx_alarm_name
}

output "ansible_controller_instance_id" {
  value = module.ansible_controller.instance_id
}

output "ansible_controller_public_ip" {
  value = module.ansible_controller.public_ip
}

output "ansible_controller_private_ip" {
  value = module.ansible_controller.private_ip
}

output "primary_alb_zone_id" {
  value = module.alb.alb_zone_id
}