# Security group assigned to the public Application Load Balancer.
resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  description = "Controls inbound traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allows approved clients to reach the load balancer.
resource "aws_vpc_security_group_ingress_rule" "alb_application" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "Allow client traffic to the load balancer"
  cidr_ipv4         = each.value
  from_port = var.listener_port
  to_port   = var.listener_port
  ip_protocol       = "tcp"
}

# Security group assigned to private application instances.
resource "aws_security_group" "application" {
  name_prefix = "${var.name_prefix}-app-"
  description = "Controls traffic to private application instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-app-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Only the load balancer can reach the application instances.
resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow application traffic only from the ALB"
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"
}

# The load balancer can forward traffic only to the application instances.
resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.application.id
  description                  = "Forward traffic from the ALB to application instances"
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"
}

# Allows private instances to reach HTTPS services inside the VPC.
resource "aws_vpc_security_group_egress_rule" "application_https" {
  security_group_id = aws_security_group.application.id
  description       = "Allow HTTPS traffic within the VPC"
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Retrieves the VPC CIDR instead of requiring it as another input.
data "aws_vpc" "selected" {
  id = var.vpc_id
}