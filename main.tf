locals {
  frontend_user_data = <<-EOF
#!/bin/bash
set -e

apt update -y
apt install -y docker.io awscli

systemctl start docker
systemctl enable docker

docker rm -f frontend || true

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

docker run -d \
--name frontend \
-p 8080:80 \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest
EOF


  backend_user_data = <<-EOF
#!/bin/bash
set -e

apt update -y
apt install -y docker.io awscli

systemctl start docker
systemctl enable docker

docker rm -f flask-app || true

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

docker run -d \
--name flask-app \
-p 5000:5000 \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest
EOF
}
resource "aws_instance" "ec2" {
  count         = 2
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"
  key_name      = "three-tier-key"

  subnet_id = element([
    aws_subnet.public_1.id,
    aws_subnet.private_app_1.id
  ], count.index)

  vpc_security_group_ids = count.index == 0 ? [
    aws_security_group.frontend_sg.id
  ] : [
    aws_security_group.backend_sg.id
  ]

  associate_public_ip_address = count.index == 0 ? true : false

  user_data = count.index == 0 ? local.frontend_user_data : local.backend_user_data

  tags = {
    Name = count.index == 0 ? "Public-Frontend" : "Private-Backend"
  }
}
# -------------------------
# FRONTEND SECURITY GROUP
# -------------------------
resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
}
ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# BACKEND SECURITY GROUP (FOR ALB -> FLASK)
# -------------------------
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# -------------------------
# RDS SECURITY GROUP (FIXED)
# -------------------------
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# RDS INSTANCE (WORKING)
# -------------------------
resource "aws_db_instance" "mysql" {
  identifier         = "app-mysql-db"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"

  allocated_storage  = 20

  username           = "admin"
  password           = "Admin12345"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false

  skip_final_snapshot = true
  multi_az            = false

  deletion_protection = false

  tags = {
    Name = "App-RDS"
  }
}
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}