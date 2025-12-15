# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql"

  # Database Configuration
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  # Database Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Backup Configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Other Settings
  skip_final_snapshot        = true
  final_snapshot_identifier  = "${var.project_name}-mysql-final-snapshot"
  deletion_protection        = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
