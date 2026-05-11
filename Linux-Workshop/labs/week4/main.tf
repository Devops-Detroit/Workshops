terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.1"
    }
  }
  backend "s3" {
    bucket  = "cloud-pathway-terraformstate-webbase"
    key     = "week4.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {}

module "Network" {
  source              = "../../../my_modules/Network"
  vpc_name            = "Devops-Detroit-VPC"
  vpc_cidr            = "10.0.0.0/16"
  availability_zone_1 = "us-east-1a"
}

resource "aws_security_group" "web_sg" {
  name        = "week4-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = module.Network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_instance" "primary" {
  ami                         = "ami-0b75f821522bcff85"
  instance_type               = "t2.micro"
  subnet_id                   = module.Network.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = "Devops-Detroit-Linux-Workshop"
  user_data                   = file("${path.module}/user_data_primary.sh")

  tags = {
    Name = "Linux_Primary_Server"
  }
}

resource "aws_instance" "secondary" {
  ami                         = "ami-0b75f821522bcff85"
  instance_type               = "t2.micro"
  subnet_id                   = module.Network.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = "Devops-Detroit-Linux-Workshop"
  user_data                   = file("${path.module}/user_data_secondary.sh")

  tags = {
    Name = "Linux_Secondary_Server"
  }
}

#############ROUTE 53########################
data "aws_route53_zone" "public" {
  name         = "devops-detroit-workshop.click"
  private_zone = false
}

resource "aws_route53_health_check" "primary" {
  ip_address        = aws_instance.primary.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "primary-health-check"
  }
}

resource "aws_route53_health_check" "secondary" {
  ip_address        = aws_instance.secondary.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "secondary-health-check"
  }
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "www.devops-detroit-workshop.click"
  type    = "A"
  ttl     = 60

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id
  records         = [aws_instance.primary.public_ip]
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "www.devops-detroit-workshop.click"
  type    = "A"
  ttl     = 60

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.secondary.id
  records         = [aws_instance.secondary.public_ip]
}
