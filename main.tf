resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
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
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
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
resource "aws_instance" "ec2" {
  count         = 2
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"

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

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx -y

systemctl start nginx
systemctl enable nginx

echo "OK - $(hostname)" > /var/www/html/index.html
EOF

  tags = {
    Name = count.index == 0 ? "Public-Server" : "Private-Server"
  }
}
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