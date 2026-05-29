resource "aws_instance" "ec2" {
  count = 2
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"
  key_name = "three-tier-key"

  # First instance -> Public subnet
  # Second instance -> Private subnet
  subnet_id = element([
    aws_subnet.public_1.id,
    aws_subnet.private_app_1.id
  ], count.index)

  # 🔥 FIX: separate security groups properly
  vpc_security_group_ids = count.index == 0 ? [
    aws_security_group.frontend_sg.id
  ] : [
    aws_security_group.backend_sg.id
  ]

  # Public IP only for public instance
  associate_public_ip_address = count.index == 0 ? true : false

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from EC2 $(hostname)" > /var/www/html/index.nginx-debian.html
              EOF

  tags = {
    Name = count.index == 0 ? "Public-Server" : "Private-Server"
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