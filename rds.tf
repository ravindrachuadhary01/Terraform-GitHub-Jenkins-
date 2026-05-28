########################################
# DB SUBNET GROUP
########################################
resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "main-db-subnet-group"
  }
}

########################################
# RDS MYSQL INSTANCE
########################################
resource "aws_db_instance" "mysql" {
  identifier = "my-rds-db"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = "Admin12345"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false

  skip_final_snapshot = true
  deletion_protection  = false

  backup_retention_period = 0

  tags = {
    Name = "mysql-rds"
  }
}