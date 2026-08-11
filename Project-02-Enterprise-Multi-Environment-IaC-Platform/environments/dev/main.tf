# Retrieves the current Amazon Linux 2023 AMI from AWS.
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Creates the development VPC and subnets.
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.common_tags
}

# Creates security groups for the ALB and private application instances.
module "security" {
  source = "../../modules/security"

  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  listener_port         = var.listener_port
  application_port      = var.application_port
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  tags                  = var.common_tags
}

# Creates the application EC2 role and instance profile.
module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  tags        = var.common_tags
}

# Creates the Application Load Balancer and target group.
module "alb" {
  source = "../../modules/alb"

  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  security_group_ids         = [module.security.alb_security_group_id]
  listener_port              = var.listener_port
  application_port           = var.application_port
  health_check_path          = "/health.html"
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.common_tags
}

# Creates the launch template and application Auto Scaling Group.
module "compute" {
  source = "../../modules/compute"

  name_prefix                   = local.name_prefix
  ami_id                        = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type                 = var.instance_type
  private_subnet_ids            = module.vpc.private_subnet_ids
  application_security_group_id = module.security.application_security_group_id
  instance_profile_name         = module.iam.application_instance_profile_name
  target_group_arns             = [module.alb.target_group_arn]

  application_user_data = templatefile(
    "${path.root}/../../application/bootstrap.sh.tftpl",
    {
      application_port = var.application_port
      index_content    = base64encode(file("${path.root}/../../application/index.html"))
      health_content   = base64encode(file("${path.root}/../../application/health.html"))
    }
  )

  root_volume_size          = var.root_volume_size
  minimum_capacity          = var.minimum_capacity
  desired_capacity          = var.desired_capacity
  maximum_capacity          = var.maximum_capacity
  health_check_grace_period = var.health_check_grace_period
  tags                      = var.common_tags
}

# Creates CloudWatch alarms and the SNS notification topic.
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix              = local.name_prefix
  load_balancer_arn_suffix = module.alb.load_balancer_arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix
  autoscaling_group_name   = module.compute.autoscaling_group_name
  notification_emails      = var.notification_emails
  tags                     = var.common_tags
}