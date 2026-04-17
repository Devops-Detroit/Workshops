variable "public_subnet_id" {}
variable "instance_name" {}
variable "vpc_id" {}
variable "sg_ports" {}
variable "key_pair_name" {}
variable "availability_zone" {}
variable "ebs_volume_size" {
  default = 20
}