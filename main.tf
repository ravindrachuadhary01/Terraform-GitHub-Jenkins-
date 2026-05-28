resource "aws_instance" "ec2" {
  count = 2

  # Ubuntu 22.04 AMI (ap-south-1)
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"

  # First instance -> Public subnet
  # Second instance -> Private subnet
  subnet_id = element([
    aws_subnet.public_1.id,
    aws_subnet.private_1.id
  ], count.index)

  vpc_security_group_ids = [aws_security_group.sg.id]

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