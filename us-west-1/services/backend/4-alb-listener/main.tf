provider "aws" {
  region = "us-west-1"
}

data "aws_lb" "PRAC-BALANCE" {
  name = "PRAC-BALANCE"
}

data "aws_acm_certificate" "aws-prac" {
  domain   = "aws-prac.com"
  statuses = ["ISSUED"]
}

data "aws_lb_target_group" "http-tg" {
  name = "http-tg"
}

data "aws_lb_target_group" "https-tg" {
  name = "https-tg"

}


resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = data.aws_lb.PRAC-BALANCE.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.aws-prac.arn
  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.https-tg.arn
  }
  tags = {
    Name = "https-listener"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = data.aws_lb.PRAC-BALANCE.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.http-tg.arn
  }
  tags = {
    Name = "http-listener"
  }
}
