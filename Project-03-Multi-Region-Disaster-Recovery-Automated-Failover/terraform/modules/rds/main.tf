locals {
  name_prefix = substr(
    "${var.project_name}-${var.environment}-${lower(var.region_role)}",
    0,
    40
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-db-subnets"
  }
}

resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-mysql"

  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage + 10
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = var.backup_retention_period
  backup_window           = "18:00-19:00"
  maintenance_window      = "sun:19:30-sun:20:30"

  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = true

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name       = "${local.name_prefix}-mysql"
    RegionRole = var.region_role
  }
}