terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }
  }
}

resource "aws_key_pair" "key_pair" {
    key_name = "developer-key"
    public_key = file("~/.ssh/id_rsa.pub")
  
}

data "aws_iam_role" "SSM_role" {
    name = "AmazonEC2RoleForSSM"
  
}

resource "aws_iam_instance_profile" "instance_profile" {
    role = data.aws_iam_role.SSM_role.name
  
}
resource "aws_instance" "EC2_instance" {
  ami                     = "ami-0a232144cf20a27a5"
  instance_type           = "t2.micro"
  associate_public_ip_address = true
  subnet_id = var.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  security_groups = [ aws_security_group.EC2_SG.id]

  depends_on = [ var.public_subnet_id ]
  tags = {
    "Name":var.instance_name
  }
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