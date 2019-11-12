resource "aws_iam_instance_profile" "ec2instanceprofile" {
  name = "ec2instanceprofile"
  depends_on = [aws_iam_role_policy_attachment.EC2ServiceRole_CRUD_policy_attach]
  role = var.ec2RoleName
}

resource "aws_iam_policy" "s3Bucket-CRUD-Policy" {
  name        = "s3Bucket-CRUD-Policy"
  description = "A Upload policy"
  depends_on = [aws_s3_bucket.bucket]
  policy = <<EOF
{
          "Version" : "2012-10-17",
          "Statement": [
            {
              "Sid": "AllowGetPutDeleteActionsOnS3Bucket",
              "Effect": "Allow",
              "Action": ["s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:GetBucketAcl",
                "s3:GetObjectAcl",
                "s3:GetObjectVersionAcl",
                "s3:ListAllMyBuckets",
                "s3:ListBucket"],
              "Resource": ["${aws_s3_bucket.bucket.arn}","${aws_s3_bucket.bucket.arn}/*"]
            }
          ]
        }
EOF
}

resource "aws_iam_role_policy_attachment" "EC2ServiceRole_CRUD_policy_attach" {
  role       = var.ec2RoleName
  policy_arn = "${aws_iam_policy.s3Bucket-CRUD-Policy.arn}"
}

//resource "aws_instance" "application_ec2" {
//  ami           = var.image_id
//  subnet_id     = var.subnet_id2
//  instance_type = var.instance_type
//  vpc_security_group_ids = [var.security_group]
//  key_name = var.key_pair
//  iam_instance_profile = "${aws_iam_instance_profile.ec2instanceprofile.name}"
//  user_data = "${templatefile("${path.module}/user_data.sh",
//                                    {
//                                      aws_db_endpoint = "${aws_db_instance.rdsInstanceId.endpoint}",
//                                      bucketName = var.bucket_name,
//                                      dbName = var.db_name,
//                                      dbUserName = var.db_username,
//                                      dbPassword = var.db_password
//                                    })}"
//
//  tags = {
//    Name = "Web Server"
//  }
//
// /* ebs_block_device {
//    device_name           = var.device_name
//    delete_on_termination = var.delete_on_termination
//  }*/
//  #add db dependency
//  depends_on = [aws_db_instance.rdsInstanceId, aws_s3_bucket.bucket, aws_iam_instance_profile.ec2instanceprofile ]
//}

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
  depends_on= [aws_db_instance.rdsInstanceId]
  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}


resource "aws_lb" "loadBalanceV2" {
  name = "loadBalanceV2"
  load_balancer_type = "application"
  subnets = [var.subnet_id2,var.subnet_id3]
}

resource "aws_lb_target_group" "awsLbTargetGroup" {
  name = "awsLbTargetGroup"
  target_type = "instance"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpcId
}

resource "aws_launch_configuration" "autoScaleConfig" {
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_pair
  associate_public_ip_address = true
  user_data = "${templatefile("${path.module}/user_data.sh",
                                    {
                                      aws_db_endpoint = "${aws_db_instance.rdsInstanceId.endpoint}",
                                      bucketName = var.bucket_name,
                                      dbName = var.db_name,
                                      dbUserName = var.db_username,
                                      dbPassword = var.db_password
                                    })}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2instanceprofile.name}"
  name = "asg_launch_config"
  security_groups = [var.security_group]
  depends_on = [aws_db_instance.rdsInstanceId, aws_s3_bucket.bucket, aws_iam_instance_profile.ec2instanceprofile]
}


resource "aws_autoscaling_group" "autoScalingGroup" {
  name = "autoScalingGroup"
  max_size = 10
  min_size = 3
  default_cooldown = 60
  launch_configuration = aws_launch_configuration.autoScaleConfig.name
  desired_capacity = 3
  availability_zones = ["us-east-1a"]
  target_group_arns = [aws_lb_target_group.awsLbTargetGroup.arn]
  vpc_zone_identifier = [var.subnet_id2,var.subnet_id3,var.subnet_id]
  tag {
    key = "env"
    propagate_at_launch = true
    value = "prod"
  }
  depends_on = [aws_lb.loadBalanceV2]
}

resource "aws_autoscaling_policy" "awsAutoScalingPolicyUp" {
  autoscaling_group_name = aws_autoscaling_group.autoScalingGroup.name
  name = "awsAutoScalingPolicyUp"
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  scaling_adjustment = 1
}

resource "aws_autoscaling_policy" "awsAutoScalingPolicyDown" {
  autoscaling_group_name = aws_autoscaling_group.autoScalingGroup.name
  name = "awsAutoScalingPolicyDown"
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  scaling_adjustment = -1
}

resource "aws_cloudwatch_metric_alarm" "CPUAlarmHigh" {
  alarm_name = "CPUAlarmHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  threshold = 5
  metric_name = "CPUUtilization"
  statistic = "Average"
  namespace = "AWS/EC2"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_policy.awsAutoScalingPolicyUp.name}"
  }

  alarm_actions = [aws_autoscaling_policy.awsAutoScalingPolicyUp.arn]
  alarm_description = "Scale-up if CPU > 5%"
  period = 300
}

resource "aws_cloudwatch_metric_alarm" "CPUAlarmLow" {
  alarm_name = "CPUAlarmLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  threshold = 3
  metric_name = "CPUUtilization"
  statistic = "Average"
  namespace = "AWS/EC2"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_policy.awsAutoScalingPolicyDown.name
  }
  alarm_actions = [aws_autoscaling_policy.awsAutoScalingPolicyDown.arn]
  alarm_description = "Scale-up if CPU < 3%"
  period = 300
}
