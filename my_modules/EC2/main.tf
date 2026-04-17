terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }
  }
}

data "aws_key_pair" "key_pair" {
    key_name = var.key_pair_name
}

data "aws_iam_role" "SSM_role" {
    name = "AmazonEC2RoleForSSM"
  
}

resource "aws_iam_instance_profile" "instance_profile" {
    role = data.aws_iam_role.SSM_role.name
  
}
resource "aws_instance" "EC2_instance" {
  ami                         = "ami-0b75f821522bcff85"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  key_name                    = data.aws_key_pair.key_pair.key_name
  security_groups             = [aws_security_group.EC2_SG.id]

  depends_on = [var.public_subnet_id]
  tags = {
    "Name" : var.instance_name
  }
}

resource "aws_ebs_volume" "extra_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  encrypted         = true
  tags = {
    "Name" : "${var.instance_name}-ebs"
  }
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.extra_volume.id
  instance_id = aws_instance.EC2_instance.id
}


resource "aws_security_group" "EC2_SG" {
    name = "EC2_Security_Group"
    description = "Allows SSH and HTTPS traffic"
    vpc_id = var.vpc_id
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = toset(var.sg_ports)
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.key
  ip_protocol       = "tcp"
  to_port           = each.key
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}