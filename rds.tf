############################################
# RDS SUBNET GROUP
############################################

resource "aws_db_subnet_group" "db_subnet" {
  name = "app-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]

  tags = {
    Name = "app-db-subnet-group"
  }
}

############################################
# RDS SECURITY GROUP
############################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access from App EC2 only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"

    # ONLY EC2/App servers can access RDS
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

############################################
# RDS MYSQL INSTANCE
############################################

resource "aws_db_instance" "mysql" {

  identifier = "app-mysql-db"

  #################################
  # ENGINE
  #################################

  engine         = "mysql"
  engine_version = "8.0"

  #################################
  # INSTANCE
  #################################

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  #################################
  # DATABASE
  #################################

  db_name  = "mydb"
  username = "admin"
  password = "Admin12345"

  #################################
  # NETWORKING
  #################################

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false

  #################################
  # HIGH AVAILABILITY
  #################################

  multi_az = false

  #################################
  # BACKUP
  #################################

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  #################################
  # MONITORING
  #################################

  monitoring_interval = 0

  #################################
  # PERFORMANCE
  #################################

  apply_immediately = true

  #################################
  # TAGS
  #################################

  tags = {
    Name = "App-RDS"
  }
}

############################################
# OUTPUTS
############################################

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.mysql.db_name
}

output "rds_username" {
  value = aws_db_instance.mysql.username
}