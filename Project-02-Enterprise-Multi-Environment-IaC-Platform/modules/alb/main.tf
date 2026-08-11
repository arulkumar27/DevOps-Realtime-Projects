# Creates an internet-facing Application Load Balancer across two AZs.
resource "aws_lb" "this" {
  name                       = "${trim(substr(var.name_prefix, 0, 24), "-")}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  drop_invalid_header_fields = true
  desync_mitigation_mode     = "defensive"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb"
    }
  )
}

# Groups the private application instances behind the ALB.
resource "aws_lb_target_group" "application" {
  name        = "${trim(substr(var.name_prefix, 0, 24), "-")}-app-tg"
  port        = var.application_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${trim(substr(var.name_prefix, 0, 24), "-")}-app-tg"
    }
  )
}

# Uses HTTPS when an ACM certificate is supplied; otherwise uses HTTP.
resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.certificate_arn != null ? "HTTPS" : "HTTP"
  certificate_arn   = var.certificate_arn
  ssl_policy        = var.certificate_arn != null ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}