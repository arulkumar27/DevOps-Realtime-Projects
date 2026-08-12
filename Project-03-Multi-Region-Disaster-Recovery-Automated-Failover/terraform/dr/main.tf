module "networking" {
  source = "../modules/networking"

  project_name             = var.project_name
  environment              = var.environment
  region_role              = "Disaster-Recovery"
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "security" {
  source = "../modules/security"

  project_name     = var.project_name
  environment      = var.environment
  region_role      = "Disaster-Recovery"
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = module.networking.vpc_cidr
  ssh_allowed_cidr = var.controller_public_cidr
}

module "alb" {
  source = "../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  region_role           = "Disaster-Recovery"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  health_check_path     = "/health"
}

module "autoscaling" {
  source = "../modules/autoscaling"

  project_name                  = var.project_name
  environment                   = var.environment
  region_role                   = "Disaster-Recovery"
  subnet_ids                    = module.networking.public_subnet_ids
  application_security_group_id = module.security.application_security_group_id
  target_group_arn              = module.alb.target_group_arn
  instance_type                 = var.instance_type
  key_name                      = var.key_name
  minimum_size                  = var.asg_minimum_size
  desired_capacity              = var.asg_desired_capacity
  maximum_size                  = var.asg_maximum_size
  health_check_type             = "ELB"
}