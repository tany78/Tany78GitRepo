terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}


resource "aws_subnet" "web-east1a" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "priv"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "app-east1a" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "priv_tgw"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "web-east1b" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "pub"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "app-east1b" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "mgmt"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_route_table" "web_rt" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "pub"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${each.value.name}"
  }
}

resource "aws_route_table" "app_rt" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "priv_tgw"}

  tags = {
    Name = "${each.value.name}"
  }
}

resource "aws_route_table_association" "as_pub" {  
  count = length([for network in var.networks: null if network.ntype == "pub"])

  route_table_id = values(aws_route_table.rt_pub)[0].id
  subnet_id      = values(aws_subnet.public_subnet)[count.index].id

}

resource "aws_route_table_association" "as_priv" {
  count = length([for network in var.networks: null if network.ntype == "priv"])

  route_table_id = values(aws_route_table.rt_priv)[count.index].id
  subnet_id      = values(aws_subnet.private_subnet)[count.index].id

}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.subnet_vpc_id

  tags = {
    Name = "${var.igw_name}"
  }
}

