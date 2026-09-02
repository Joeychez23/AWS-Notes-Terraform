provider "aws" {
    region = "us-west-1"
}

resource "aws_default_vpc" "default-vpc" {
    tags = {
        Name = "default"
    }
}







