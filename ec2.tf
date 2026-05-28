# Public EC2 Instance
resource "aws_instance" "public_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "Public-EC2"
  }
}

# Private EC2 Instance
resource "aws_instance" "private_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name = aws_key_pair.deployer_key.key_name
  tags = {
    Name = "Private-EC2"
  }
}