provider "aws" {
  region = "us-west-1"
}

data "aws_launch_template" "default-template" {
  filter {
    name   = "tag:Name"
    values = ["default-template"]
  }
}

data "aws_subnet" "us-west-1a" {
  filter {
    name   = "tag:Name"
    values = ["us-west-1a"]
  }
}

data "aws_subnet" "us-west-1b" {
  filter {
    name   = "tag:Name"
    values = ["us-west-1b"]
  }
}

data "aws_lb_target_group" "http-tg" {
  name = "http-tg"
}

data "aws_lb_target_group" "https-tg" {
  name = "https-tg"
}

resource "aws_autoscaling_group" "default-autoscaling-group" {
  name = "default-autoscaling-group"
  vpc_zone_identifier = [data.aws_subnet.us-west-1a.id, data.aws_subnet.us-west-1b.id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  health_check_type = "ELB"
  max_instance_lifetime = 604800
  target_group_arns = [data.aws_lb_target_group.http-tg.arn, data.aws_lb_target_group.https-tg.arn]

  launch_template {
    id      = data.aws_launch_template.default-template.id
    version = "$Default"
  }

}

