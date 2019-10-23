resource "aws_instance" "application_ec2" {
  ami           = var.image_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group]

  root_block_device {
    volume_type = var.primary_ebs_volume_type
    volume_size = var.primary_ebs_volume_size
    delete_on_termination = var.delete_on_termination
  }

 /* ebs_block_device {
    device_name           = var.device_name
    delete_on_termination = var.delete_on_termination
  }*/

  #add db dependency
  depends_on = []
  #add s3 dependency
  depends_on = []
}