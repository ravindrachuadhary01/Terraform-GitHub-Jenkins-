# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name = "app-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]

  tags = {
    Name = "DBSubnetGroup"
  }
}

# RDS Security Group (IMPORTANT FIX)
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  # Allow MySQL ONLY from App EC2 SG
  ingress {
    description     = "MySQL from app servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  # optional but safe
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier        = "app-mysql-db"
  allocated_storage = 20
  storage_type      = "gp2"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  username = "admin"
  password = "Admin12345"

  publicly_accessible = false

  skip_final_snapshot = true
  multi_az            = false

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "App-RDS"
  }
}