data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

resource "aws_instance" "application_ec2" {
  ami           = var.image_id
  subnet_id     = var.subnet_id2
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group]
  key_name = var.key_pair
  iam_instance_profile = "${aws_iam_instance_profile.ec2instanceprofile.name}"
  user_data = "${templatefile("${path.module}/user_data.sh",
                                    {
                                      aws_db_endpoint = "${aws_db_instance.rdsInstanceId.endpoint}",
                                      bucketName = var.bucket_name,
                                      dbName = var.db_name,
                                      dbUserName = var.db_username,
                                      dbPassword = var.db_password
                                    })}"

  tags = {
    Name = "Web Server"
  }

 /* ebs_block_device {
    device_name           = var.device_name
    delete_on_termination = var.delete_on_termination
  }*/
  #add db dependency
  depends_on = [aws_db_instance.rdsInstanceId, aws_s3_bucket.bucket, aws_iam_instance_profile.ec2instanceprofile ]
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
  depends_on= [aws_db_instance.rdsInstanceId]
  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}

#vee
resource "aws_iam_role" "CodeDeployLambdaServiceRole" {
  name           = "iam_for_lambda_with_sns"
  path           = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "CodeDeployLambdaServiceRole"
  }
}

resource "aws_lambda_function" "lambdaFunction" {
  s3_bucket       = var.codedeploy_lambda_s3_bucket
  s3_key          = "index.zip"
  function_name   = "csye6225"
  role            = "${aws_iam_role.CodeDeployLambdaServiceRole.arn}"
  handler         = "index.handler"
  runtime         = "java8"
  memory_size     = 256
  timeout         = 180
  reserved_concurrent_executions  = 5
  environment  {
    variables = {
      domain = var.domain_name
      table  = aws_dynamodb_table.dynamodb-table.name
    }
  }
  tags = {
    Name = "Lambda Email"
  }
}

resource "aws_sns_topic" "EmailNotificationRecipeEndpoint" {
  name          = "EmailNotificationRecipeEndpoint"
}

resource "aws_sns_topic_subscription" "topicId" {
  topic_arn       = "${aws_sns_topic.EmailNotificationRecipeEndpoint.arn}"
  protocol        = "lambda"
  endpoint        = "${aws_lambda_function.lambdaFunction.arn}"
  depends_on      = [aws_lambda_function.lambdaFunction]
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.EmailNotificationRecipeEndpoint.arn}"
  function_name = "${aws_lambda_function.lambdaFunction.function_name}"
  depends_on    = [aws_lambda_function.lambdaFunction]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda"
  depends_on = [aws_sns_topic.topic]
  policy =  <<EOF
{
          "Version" : "2012-10-17",
          "Statement": [
            {
              "Sid": "LambdaDynamoDBAccess",
              "Effect": "Allow",
              "Action": ["dynamodb:GetItem", 
              "dynamodb:PutItem", 
              "dynamodb:UpdateItem"],
              "Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/csye6225"
            },
            {
              "Sid": "LambdaSESAccess",
              "Effect": "Allow",
              "Action": ["ses:VerifyEmailAddress",
              "ses:SendEmail",
              "ses:SendRawEmail"],
              "Resource": "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/*"
            },
            {
              "Sid": "LambdaS3Access",
              "Effect": "Allow",
              "Action": ["s3:GetObject"],
              "Resource": "arn:aws:s3:::${var.codedeploy_lambda_s3_bucket}/*"
            },
            {
              "Sid": "LambdaSNSAccess",
              "Effect": "Allow",
              "Action": ["sns:ConfirmSubscription"],
              "Resource": "${aws_sns_topic.EmailNotificationRecipeEndpoint.arn}"
            }
          ]
        }
EOF
}

resource "aws_iam_policy" "topic_policy" {
  name        = "Topic"
  description = ""
  depends_on  = [aws_sns_topic.EmailNotificationRecipeEndpoint]
  policy      = <<EOF
{
          "Version" : "2012-10-17",
          "Statement": [
            {
              "Sid": "AllowEC2ToPublishToSNSTopic",
              "Effect": "Allow",
              "Action": ["sns:Publish", 
              "sns:CreateTopic"],
              "Resource": "${aws_sns_topic.EmailNotificationRecipeEndpoint.arn}"
            }
          ]
        }
EOF
}

resource "aws_iam_policy" "CircleCI-update-lambda-To-S3" {
  name        = "CircleCI-update-lambda-To-S3"
  description = "A Upload policy"
  depends_on = [aws_lambda_function.lambdaFunction]
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ActionsWhichSupportResourceLevelPermissions",
            "Effect": "Allow",
            "Action": [
                "lambda:AddPermission",
                "lambda:RemovePermission",
                "lambda:CreateAlias",
                "lambda:UpdateAlias",
                "lambda:DeleteAlias",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration",
                "lambda:PutFunctionConcurrency",
                "lambda:DeleteFunctionConcurrency",
                "lambda:PublishVersion"
            ],
            "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:csye6225"
        }
}
EOF
}
resource "aws_iam_policy_attachment" "circleci-update-policy-attach" {
  name       = "circleci-policy"
  users      = ["circleci"]
  policy_arn = "${aws_iam_policy.CircleCI-update-lambda-To-S3.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach_predefinedrole" {
  role       = "${aws_iam_role.CodeDeployLambdaServiceRole.name}"
  depends_on = [aws_iam_role.CodeDeployLambdaServiceRole]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach_role" {
  role       = "${aws_iam_role.CodeDeployLambdaServiceRole.name}"
  depends_on = [aws_iam_role.CodeDeployLambdaServiceRole]
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "topic_policy_attach_role" {
  role       = "${aws_iam_role.CodeDeployLambdaServiceRole.name}"
  depends_on = [aws_iam_role.CodeDeployLambdaServiceRole]
  policy_arn = "${aws_iam_policy.topic_policy.arn}"
}

// resource "aws_iam_policy_attachment" "circleci-policy-attach" {
//   name       = "circleci-policy"
//   users      = ["circleci"]
//   policy_arn = "${aws_iam_policy.circleci-ec2-ami.arn}"
// }