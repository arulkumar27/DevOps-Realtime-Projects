resource "aws_launch_template" "web" {
  name          = var.launch-template-name
  image_id      = data.aws_ami.ami.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.instance-profile-name
  }

  vpc_security_group_ids = [
    data.aws_security_group.web-sg.id
  ]

  user_data = filebase64("${path.module}/deploy.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Two-Tier-Web-Server"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name = var.asg-name

  vpc_zone_identifier = [
    data.aws_subnet.public-subnet1.id,
    data.aws_subnet.public-subnet2.id
  ]

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [data.aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Two-Tier-Web-Server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu-target" {
  name                   = "CPU-Target-Tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}
