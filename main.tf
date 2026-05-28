# =========================
# FRONTEND EC2 INSTANCE
# =========================

resource "aws_instance" "frontend" {
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = "t3.micro"

  subnet_id              = aws_subnet.public_1.id

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  associate_public_ip_address = true

  key_name = "your-key-name"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y

              systemctl start docker
              systemctl enable docker

              docker run -d -p 80:80 nginx
              EOF

  tags = {
    Name = "frontend-ec2"
  }
}

# =========================
# BACKEND EC2 INSTANCE
# =========================

resource "aws_instance" "backend" {
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = "t3.micro"

  subnet_id              = aws_subnet.private_app_1.id

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  key_name = "your-key-name"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io awscli -y

              systemctl start docker
              systemctl enable docker

              docker run -d -p 5000:5000 nginx
              EOF

  tags = {
    Name = "backend-ec2"
  }
}

# RDS Security Group (FIXED)
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  # Allow ONLY app security group (EC2/ASG)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance (FIXED connectivity settings)
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