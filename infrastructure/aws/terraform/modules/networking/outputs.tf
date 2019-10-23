output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "subnet_id1" {
  value = aws_subnet.subnet1.id
  description = "Subnet Id"
}

output "subnet_2" {
  value = aws_subnet.subnet2.*.id
  description = "Subnet Id"
}

output "subnet_3" {
  value = aws_subnet.subnet3.*.id
  description = "Subnet Id"
}