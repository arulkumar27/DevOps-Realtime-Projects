output "application_url" {
  value = "http://${var.record_name}"
}

output "primary_health_check_id" {
  value = aws_route53_health_check.primary.id
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}