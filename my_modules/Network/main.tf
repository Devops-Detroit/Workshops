terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }
  }
}



resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = var.vpc_name
    }

  
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id
  
}


resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    "Name": "Public_RT" 
  }
}



resource "aws_subnet" "Public_Subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0) 
  availability_zone = var.availability_zone_1
    tags = {
      "Name": "Public_subnet"
    }

}


resource "aws_route_table_association" "Public_RT_assocation" {
  subnet_id = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Public.id
  depends_on = [ aws_route_table.Public]
}
