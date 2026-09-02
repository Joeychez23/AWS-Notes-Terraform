provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "main" {
  default = true
}

resource "aws_lb_target_group" "http" {
  name     = "http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  tags = {
    Name = "http-tg"
  }
  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    matcher             = "404"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "20"
  }

}

resource "aws_lb_target_group" "https" {
  name     = "https-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = data.aws_vpc.main.id
  tags = {
    Name = "https-tg"
  }
  health_check {
    path                = "/J3boN6i0YKMf1u4eyrunPd8ocHzTyK"
    protocol            = "HTTPS"
    matcher             = "302"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "20"
  }
}
