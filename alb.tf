# -------------------------
# APPLICATION LOAD BALANCER
# -------------------------


resource "aws_lb" "alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  security_groups = [aws_security_group.sg.id]
}



# -------------------------
# FRONTEND TARGET GROUP (React - Podman 8080)
# -------------------------


resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


# -------------------------
# BACKEND TARGET GROUP (Flask - 5000)
# -------------------------


resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



# -------------------------
# FRONTEND ATTACHMENT
# -------------------------
resource "aws_lb_target_group_attachment" "frontend_attach" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.ec2[0].id
  port             = 8080
}



# -------------------------
# BACKEND ATTACHMENT
# -------------------------
resource "aws_lb_target_group_attachment" "backend_attach" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.ec2[1].id
  port             = 5000
}



# -------------------------
# LISTENER (ALB :80)
# -------------------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ALB is running"
      status_code  = "200"
    }
  }
}


# -------------------------
# ROUTE: FRONTEND (/)
# -------------------------
resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}



# -------------------------
# ROUTE: BACKEND (/api/*)
# -------------------------
resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}