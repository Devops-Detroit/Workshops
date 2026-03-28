terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }
  }
   backend "s3" {
    bucket = "cloud-pathway-terraformstate-webbase"
    key = "dev.tfstate"
    region = "us-east-1"
    encrypt = true

  }
}

provider "aws" {
  # Configuration options
}


module "Network" {
    vpc_name = "Devops-Detroit-VPC"
    source = "../my_modules/Network"
    vpc_cidr = "10.0.0.0/16"
    availability_zone_1 = "us-east-1a"

  
}

module "EC2" {
    source = "../my_modules/EC2"
    instance_name = "Linux_Server"
    public_subnet_id = module.Network.public_subnet_id
    vpc_id = module.Network.vpc_id
    sg_ports = ["22", "80"]
    key_pair_name = "Devops-Detroit-Linux-Workshop"



  
}