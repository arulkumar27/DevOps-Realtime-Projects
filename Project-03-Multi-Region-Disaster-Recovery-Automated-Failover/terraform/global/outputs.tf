output "blacktunes_failover_url" {
  value = module.route53.application_url
}

output "primary_health_check_id" {
  value = module.route53.primary_health_check_id
}