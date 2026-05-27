resource "aws_instance" "ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "Terraform-EC2"
  }
}