terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.26.0"
    }
  }
}

provider "aws" {
		alias = "networking"
		region = var.region
		access_key = var.access_key
		secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  
  tags = {
    Name = "My-VPC"
  }
}

# Create a Web subnet in AZ 1A
resource "aws_subnet" "Web_Subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Web_Subnet_1a"
  }
}

# Create a App subnet in AZ 1A
resource "aws_subnet" "App_Subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "App_Subnet_1a"
  }
}

# Create a Web subnet in AZ 1B
resource "aws_subnet" "Web_Subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.30.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Web_Subnet_1b"
  }
}

# Create a App subnet in AZ 1B
resource "aws_subnet" "App_Subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.40.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "App_Subnet_1b"
  }
}

# Create a Internet Gateway for My-VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IGW"
  }
}

# Create a Custom Route Table for Web Subnet
resource "aws_route_table" "Web-Route-Table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "WEB_Route_Table"
  }
}

# Create Route Table Association for Web Subnets
resource "aws_route_table_association" "a" {
  subnet_id      = [aws_subnet.Web_Subnet_1a.id,aws_subnet.Web_Subnet_1b.id]
  route_table_id = aws_route_table.Web-Route-Table.id
}

# Create HTTP Security Group
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

# Create SSH Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}





# Create a S3 Bucket
resource "aws_s3_bucket" "finance" {
		bucket = "my-demo-bucket"
		tags = {
			Description = "My Demo Bucket created with Terraform"
			}
}