resource "aws_db_subnet_group" "database" {
  name       = "taylor-shift-db-${var.environment}"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name        = "taylor-shift-db-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_db_instance" "database" {
  identifier = "taylor-shift-db-${var.environment}"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = "gp3"
  storage_encrypted   = true
  publicly_accessible = false
  port                = var.database_port

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [var.database_security_group_id]

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "taylor-shift-db-${var.environment}"
    Environment = var.environment
  }
}