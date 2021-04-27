provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    instance_tenancy = "default"

    tags = {
        Name = "dev-vpc"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/26"

    tags = {
        Name = "subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.128/26"

    tags = {
        Name = "subnet2"
    }
}
