resource "aws_db_subnet_group" "database" {
  name = var.sg-name

  subnet_ids = [
    data.aws_subnet.private-subnet1.id,
    data.aws_subnet.private-subnet2.id
  ]

  tags = {
    Name = var.sg-name
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "two-tier-aurora-cluster"
  engine             = "aurora-postgresql"

  master_username = var.rds-username
  master_password = var.rds-pwd
  database_name   = var.db-name
  port            = 5432

  backup_retention_period = 1
  skip_final_snapshot     = true
  storage_encrypted       = true

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [data.aws_security_group.db-sg.id]

  tags = {
    Name = var.rds-name
  }
}

resource "aws_rds_cluster_instance" "primary" {
  identifier         = "two-tier-aurora-primary"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora.engine
}
