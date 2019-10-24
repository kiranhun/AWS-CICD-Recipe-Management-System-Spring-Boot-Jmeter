output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "subnet_id1" {
  value = aws_subnet.subnet1.id
  description = "Subnet 1 Id"
}

output "subnet_id2" {
  value = aws_subnet.subnet2.id
  description = "Subnet 2 Id"
}

output "subnet_id3" {
  value = aws_subnet.subnet3.id
  description = "Subnet 3 Id"
}

# output "subnet_ids" {
#   value   = aws_subnet.subnet2.*.id
# }