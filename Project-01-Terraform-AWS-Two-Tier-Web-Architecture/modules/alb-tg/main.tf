resource "aws_lb" "web-elb" {
  name               = var.alb-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.web-alb-sg.id]

  subnets = [
    data.aws_subnet.public-subnet1.id,
    data.aws_subnet.public-subnet2.id
  ]

  tags = {
    Name = var.alb-name
  }
}

resource "aws_lb_target_group" "web-tg" {
  name        = var.tg-name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = var.tg-name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}
