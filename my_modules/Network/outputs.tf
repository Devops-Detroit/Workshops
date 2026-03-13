output "public_subnet_id" {
  value = aws_subnet.Public_Subnet.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
  
}
output "internet_gw_id" {
  value = aws_internet_gateway.IGW.id
  
}