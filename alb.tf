# Application Load Balancer
resource "aws_lb" "main_alb" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet.id
  ]

  tags = {
    Name = "Main-ALB"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "80"
  }

  tags = {
    Name = "Main-TG"
  }
}

# Attach Public EC2
resource "aws_lb_target_group_attachment" "public_ec2_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.public_ec2.id
  port             = 80
}

# Attach Private EC2
resource "aws_lb_target_group_attachment" "private_ec2_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.private_ec2.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb_sg.id]
}