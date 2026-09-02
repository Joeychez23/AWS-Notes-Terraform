provider "aws" {
  region = "us-west-1"
}


data "aws_vpc" "main" { 
    default = true
}

data "aws_internet_gateway" "gateway" {
  filter {
    name   = "tag:Name"
    values = ["default-gateway"]
  }
}

data "aws_route_table" "table" {
  vpc_id = data.aws_vpc.main.id
}


resource "aws_subnet" "us-west-1a" {
    vpc_id = data.aws_vpc.main.id
    cidr_block = "172.31.0.0/20"
    map_public_ip_on_launch = true
    availability_zone = "us-west-1a"
    tags = {
        Name = "us-west-1a"
    }
}

resource "aws_subnet" "us-west-1b" {
    vpc_id = data.aws_vpc.main.id
    cidr_block = "172.31.16.0/20"
    map_public_ip_on_launch = true
    availability_zone = "us-west-1b"
    tags = {
        Name = "us-west-1b"
    }
}



resource "aws_default_route_table" "route-table" {
    default_route_table_id = data.aws_route_table.table.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = data.aws_internet_gateway.gateway.id
    }

    tags = {
        Name = "default-route-table"
    }
}

