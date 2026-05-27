resource "aws_instance" "ec2" {
  count = 2

  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  subnet_id = element([
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ], count.index)

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from EC2 $(hostname)" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "App-Server-${count.index}"
  }
}