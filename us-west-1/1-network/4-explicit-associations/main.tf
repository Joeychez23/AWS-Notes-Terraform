provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "main" { 
    default = true
}

data "aws_route_table" "table" {
  vpc_id = data.aws_vpc.main.id
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



resource "aws_route_table_association" "subnet-ass-1" {
    subnet_id = "${data.aws_subnet.us-west-1a.id}"
    route_table_id = data.aws_route_table.table.id
}



resource "aws_route_table_association" "subnet-ass-2" {
    subnet_id = "${data.aws_subnet.us-west-1b.id}"
    route_table_id = data.aws_route_table.table.id
}



