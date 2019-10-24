resource "aws_instance" "application_ec2" {
  ami           = var.image_id
  subnet_id     = var.subnet_id2
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group]
  key_name = var.key_pair

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
  depends_on = [aws_db_instance.rdsInstanceId, aws_s3_bucket.bucket]
  #add s3 dependency
  # depends_on = [aws_s3_bucket.bucket]
}

resource "aws_db_subnet_group" "dbSubnetGroupId" {
  #name       = var.subnetGroupName
  subnet_ids = [var.subnet_id2,var.subnet_id3]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "rdsInstanceId" {
	allocated_storage = var.storage
	storage_type = var.storage_type
	identifier = var.identifier
	engine = var.engine
	engine_version = var.engine_version
	instance_class = var.instance_class
	multi_az = var.multi_az
	name = var.db_name
	username = var.db_username
	password = var.db_password
	parameter_group_name = var.parameter_group_name
	db_subnet_group_name = aws_db_subnet_group.dbSubnetGroupId.id
	vpc_security_group_ids = var.security_group_list #[aws_security_group.database.id]
	publicly_accessible = var.publicly_accessible
	port = var.port
	skip_final_snapshot = "true"
  final_snapshot_identifier = "delete-me"
}

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.dynamo_db_name
  billing_mode   = var.billing_mode 
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key

  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl = "private"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  force_destroy = true

  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}