output "vpc_id" {
  value = module.networking.vpc_id
}

//output "public_ipv4" {
//  value = module.ec2_host.ec2instance_public_ip
//}
//
//output "private_ipv4" {
//  value = module.ec2_host.ec2instance_private_ip
//}

output "rds_endpoint" {
  value = module.ec2_host.rds_enpoint_url
}