resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_target_group_attachment" "app_attach" {
  count = 2

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2[count.index].id
  port             = 5000
}