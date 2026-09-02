provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "main" { 
    default = true
}

data "aws_route_table" "table" {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_default_route_table" "route-table" {
    default_route_table_id = data.aws_route_table.table.id
    tags = {
        Name = "default-route-table"
    }
}

resource "aws_internet_gateway" "default-gateway" {
  vpc_id = data.aws_vpc.main.id
      tags = {
        Name = "default-gateway"
    }
}