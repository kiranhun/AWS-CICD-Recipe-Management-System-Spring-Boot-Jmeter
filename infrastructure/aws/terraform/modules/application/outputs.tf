//output "ec2instance_private_ip" {
//  description = "Private IP of the ec2 instance"
//  value       = aws_instance.application_ec2.*.private_ip
//}
//
//output "ec2instance_public_ip" {
//  description = "Public IP of the ec2 instance"
//  value = aws_instance.application_ec2.*.public_ip
//}

output "rds_enpoint_url"{
  description = "RDS instance enpoint url"
  value = aws_db_instance.rdsInstanceId.*.endpoint
}