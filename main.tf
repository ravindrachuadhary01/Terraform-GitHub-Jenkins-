resource "aws_launch_template" "lt" {
  name_prefix   = "app-template"
  image_id      = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.sg.id]
   update_default_version = true

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Hello from ASG $(hostname)" > /usr/share/nginx/html/index.html
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}