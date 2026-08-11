output "sns_topic_arn" {
  description = "SNS topic ARN used by infrastructure alarms"
  value       = aws_sns_topic.infrastructure_alerts.arn
}

output "cloudwatch_alarm_names" {
  description = "Names of the infrastructure CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.alb_server_errors.alarm_name,
    aws_cloudwatch_metric_alarm.no_instances_in_service.alarm_name
  ]
}