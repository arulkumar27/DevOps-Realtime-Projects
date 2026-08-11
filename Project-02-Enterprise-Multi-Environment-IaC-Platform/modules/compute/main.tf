# Defines the secure EC2 configuration used by Auto Scaling.
resource "aws_launch_template" "application" {
  name_prefix   = "${var.name_prefix}-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [var.application_security_group_id]
  }

  # Enforces IMDSv2 and disables unnecessary metadata exposure.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  # Enables detailed one-minute CloudWatch instance metrics.
  monitoring {
    enabled = true
  }

  # Encrypts the EC2 root volume.
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = true
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  user_data = var.application_user_data != null ? base64encode(var.application_user_data) : null

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-application"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-application-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Maintains application capacity across private subnets.
resource "aws_autoscaling_group" "application" {
  name_prefix = "${var.name_prefix}-asg-"

  min_size         = var.minimum_capacity
  desired_capacity = var.desired_capacity
  max_size         = var.maximum_capacity

  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

# Publishes one-minute Auto Scaling group metrics to CloudWatch.
  metrics_granularity = "1Minute"

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }

  # Replaces instances gradually when the launch template changes.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = var.health_check_grace_period
    }

    triggers = ["tag"]
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-application"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true

    precondition {
      condition = (
        var.minimum_capacity <= var.desired_capacity &&
        var.desired_capacity <= var.maximum_capacity
      )
      error_message = "Capacity must follow minimum <= desired <= maximum."
    }
  }
}