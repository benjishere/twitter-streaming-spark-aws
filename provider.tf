provider "aws" {
    region = "eu-central-1"
}

resource "aws_route53_zone" "primary" {
  name = "brodewicz.tech"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "dev-vpc"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main.id
    availability_zone = "eu-central-1a"
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.main.id
    availability_zone = "eu-central-1b"
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "subnet2"
    }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

module "kafka" {
  source                 = "github.com/cloudposse/terraform-aws-msk-apache-kafka-cluster.git?ref=master"
  namespace              = "brodewicz.tech"
  stage                  = "dev"
  name                   = "streaming-app"
  vpc_id                 = aws_vpc.main.id
  zone_id                = aws_route53_zone.primary.id
  security_groups        = [aws_security_group.allow_http.id]
  subnet_ids             = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  kafka_version          = "2.4.1.1"
  number_of_broker_nodes = 2
  broker_instance_type   = "kafka.m5.large"
}
