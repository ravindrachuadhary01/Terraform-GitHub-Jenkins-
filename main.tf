locals {
  frontend_user_data = <<-EOF
#!/bin/bash
set -ex
exec > /var/log/user-data.log 2>&1

apt update -y
apt install -y docker.io awscli

systemctl enable docker
systemctl start docker

# wait for docker
until systemctl is-active --quiet docker; do
  sleep 2
done

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

docker rm -f frontend || true

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

docker run -d --restart always \
  --name frontend \
  -p 8080:80 \
  192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest
EOF

}
  locals {
  frontend_user_data = <<-EOF
#!/bin/bash
set -ex
exec > /var/log/user-data.log 2>&1

apt update -y
apt install -y docker.io awscli

systemctl enable docker
systemctl start docker

# wait for docker
until systemctl is-active --quiet docker; do
  sleep 2
done

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

docker rm -f frontend || true

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

docker run -d --restart always \
  --name frontend \
  -p 8080:80 \
  192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest
EOF
}
resource "aws_instance" "ec2" {
  count         = 2
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"
  key_name      = "three-tier-key"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

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
    security_groups = [aws_security_group.alb_sg.id]
    
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

resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

