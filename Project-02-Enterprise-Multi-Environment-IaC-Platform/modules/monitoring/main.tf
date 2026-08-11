# Central notification topic used by CloudWatch alarms.
resource "aws_sns_topic" "infrastructure_alerts" {
  name              = "${var.name_prefix}-infrastructure-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-infrastructure-alerts"
    }
  )
}

# Creates one email subscription for every configured recipient.
resource "aws_sns_topic_subscription" "email" {
  for_each = var.notification_emails

  topic_arn = aws_sns_topic.infrastructure_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# Alerts when the ALB has unhealthy application targets.
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.name_prefix}-unhealthy-targets"
  alarm_description   = "Application Load Balancer has unhealthy targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 0
  treat_missing_data  = "breaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"
  period      = 60

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.infrastructure_alerts.arn]
  ok_actions    = [aws_sns_topic.infrastructure_alerts.arn]

  tags = var.tags
}

# Alerts when the load balancer returns server-side errors.
resource "aws_cloudwatch_metric_alarm" "alb_server_errors" {
  alarm_name          = "${var.name_prefix}-alb-5xx-errors"
  alarm_description   = "Application Load Balancer is returning HTTP 5xx errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 5
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"
  period      = 60

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }

  alarm_actions = [aws_sns_topic.infrastructure_alerts.arn]
  ok_actions    = [aws_sns_topic.infrastructure_alerts.arn]

  tags = var.tags
}

# Alerts when no application instances remain in service.
resource "aws_cloudwatch_metric_alarm" "no_instances_in_service" {
  alarm_name          = "${var.name_prefix}-no-instances-in-service"
  alarm_description   = "Auto Scaling Group has no healthy instances in service"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  treat_missing_data  = "breaching"

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"
  statistic   = "Minimum"
  period      = 60

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  alarm_actions = [aws_sns_topic.infrastructure_alerts.arn]
  ok_actions    = [aws_sns_topic.infrastructure_alerts.arn]

  tags = var.tags
}