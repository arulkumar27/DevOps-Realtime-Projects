output "unhealthy_targets_alarm_name" {
  value = aws_cloudwatch_metric_alarm.unhealthy_targets.alarm_name
}

output "alb_5xx_alarm_name" {
  value = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "ec2_cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name
}

output "rds_cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.rds_cpu.alarm_name
}