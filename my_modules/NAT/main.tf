terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_eip" "eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [var.igw_id]
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = var.public_subnet_id_2

  tags = {
    Name = "gw NAT 2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [var.igw_id]
}

