terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      configuration_aliases = [
        aws.primary,
        aws.dr
      ]
    }
  }
}

locals {
  name_prefix = substr(
    "${var.project_name}-${var.environment}",
    0,
    40
  )
}

resource "aws_backup_vault" "primary" {
  provider = aws.primary

  name = "${local.name_prefix}-primary-vault"

  tags = {
    RegionRole = "Primary"
  }
}

resource "aws_backup_vault" "dr" {
  provider = aws.dr

  name = "${local.name_prefix}-dr-vault"

  tags = {
    RegionRole = "Disaster-Recovery"
  }
}

resource "aws_iam_role" "backup" {
  provider = aws.primary

  name = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "backup.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  provider = aws.primary

  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  provider = aws.primary

  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  provider = aws.primary

  name = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily-rds-cross-region-backup"
    target_vault_name = aws_backup_vault.primary.name
    schedule          = var.backup_schedule

    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.retention_days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.dr.arn

      lifecycle {
        delete_after = var.retention_days
      }
    }
  }

  tags = {
    Purpose = "Disaster-Recovery"
  }
}

resource "aws_backup_selection" "rds" {
  provider = aws.primary

  name         = "${local.name_prefix}-rds-selection"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [var.rds_arn]

  depends_on = [
    aws_iam_role_policy_attachment.backup,
    aws_iam_role_policy_attachment.restore
  ]
}