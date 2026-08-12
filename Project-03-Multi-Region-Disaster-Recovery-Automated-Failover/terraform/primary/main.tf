module "networking" {
  source = "../modules/networking"

  project_name             = var.project_name
  environment              = var.environment
  region_role              = "Primary"
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
  region_role      = "Primary"
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = module.networking.vpc_cidr
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "alb" {
  source = "../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  region_role           = "Primary"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  health_check_path     = "/health"
}

module "autoscaling" {
  source = "../modules/autoscaling"

  project_name                  = var.project_name
  environment                   = var.environment
  region_role                   = "Primary"
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

module "rds" {
  source = "../modules/rds"

  project_name               = var.project_name
  environment                = var.environment
  region_role                = "Primary"
  private_db_subnet_ids      = module.networking.private_db_subnet_ids
  database_security_group_id = module.security.database_security_group_id
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_name                    = var.db_name
  db_username                = var.db_username
  backup_retention_period    = var.db_backup_retention_period
}

module "s3_replication" {
  source = "../modules/s3-replication"

  providers = {
    aws.primary = aws
    aws.dr      = aws.dr
  }

  project_name  = var.project_name
  environment   = var.environment
  force_destroy = true
}

module "backup" {
  source = "../modules/backup"

  providers = {
    aws.primary = aws
    aws.dr      = aws.dr
  }

  project_name    = var.project_name
  environment     = var.environment
  rds_arn         = module.rds.db_arn
  backup_schedule = var.backup_schedule
  retention_days  = var.backup_retention_days
}

module "cloudwatch" {
  source = "../modules/cloudwatch"

  project_name            = var.project_name
  environment             = var.environment
  region_role             = "Primary"
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  autoscaling_group_name  = module.autoscaling.autoscaling_group_name
  db_instance_identifier  = module.rds.db_instance_identifier
  ec2_cpu_threshold       = var.ec2_cpu_alarm_threshold
  rds_cpu_threshold       = var.rds_cpu_alarm_threshold
}

module "ansible_controller" {
  source = "../modules/ansible-controller"

  project_name      = var.project_name
  environment       = var.environment
  region_role       = "Primary"
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.security.controller_security_group_id
  instance_type     = var.controller_instance_type
  key_name          = var.key_name
}