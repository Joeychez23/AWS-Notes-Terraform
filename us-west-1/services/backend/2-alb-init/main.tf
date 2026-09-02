provider "aws" {
  region = "us-west-1"
}


data "aws_vpc" "main" {
  default = true
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

data "aws_security_group" "AWS-PRAC-SEC" {
  filter {
    name   = "tag:Name"
    values = ["AWS-PRAC-SEC"]
  }
}



resource "aws_lb" "test" {
  name               = "PRAC-BALANCE"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.AWS-PRAC-SEC.id]
  subnets = [data.aws_subnet.us-west-1a.id, data.aws_subnet.us-west-1b.id]

  enable_deletion_protection = true

  tags = {
    Name = "PRAC-BALANCE"
  }
}
