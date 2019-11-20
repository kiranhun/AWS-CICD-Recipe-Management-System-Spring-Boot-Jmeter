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
  security_groups = [var.security_group]
  //  depends_on = [aws_security_group.loadBalancerSecurityGroup]
}

resource "aws_lb_target_group" "awsLbTargetGroup" {
  name = "awsLbTargetGroup"
  target_type = "instance"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpcId
  depends_on = [aws_lb.loadBalanceV2]
}

resource "aws_lb_listener" "awsLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalanceV2.arn
  port = 443
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.awsLbTargetGroup.arn
  }
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn
  protocol = "HTTPS"
  depends_on = [aws_lb.loadBalanceV2]
}



resource "aws_launch_configuration" "autoScaleConfig" {
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_pair
  associate_public_ip_address = true
  ebs_block_device {
    device_name           = var.device_name
    delete_on_termination = var.delete_on_termination
    volume_size = 8
    volume_type = "gp2"
  }
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
  //  security_groups = [var.security_group]
  //  security_groups = [aws_security_group.webappSecurityGroup.id]
  security_groups = [var.webapp_security_group]
  depends_on = [aws_db_instance.rdsInstanceId, aws_s3_bucket.bucket, aws_iam_instance_profile.ec2instanceprofile]
}
resource "aws_autoscaling_group" "autoScalingGroup" {
  name = "autoScalingGroup"
  max_size = 10
  min_size = 3
  default_cooldown = 60
  launch_configuration = aws_launch_configuration.autoScaleConfig.name
  desired_capacity = 3
//  availability_zones = ["us-east-1a"]
  target_group_arns = [aws_lb_target_group.awsLbTargetGroup.arn]
  vpc_zone_identifier = [var.subnet_id2,var.subnet_id3,var.subnet_id]
  tag {
    key = "env"
    propagate_at_launch = true
    value = "prod"
  }
  depends_on = [aws_lb_target_group.awsLbTargetGroup]
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
    AutoScalingGroupName = "${aws_autoscaling_group.autoScalingGroup.name}"
  }

  alarm_actions = [aws_autoscaling_policy.awsAutoScalingPolicyUp.arn]
  alarm_description = "Scale-up if CPU > 5%"
  period = 60
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
    AutoScalingGroupName = aws_autoscaling_group.autoScalingGroup.name
  }
  alarm_actions = [aws_autoscaling_policy.awsAutoScalingPolicyDown.arn]
  alarm_description = "Scale-down if CPU < 3%"
  period = 60
}

resource "aws_route53_record" "csye-dns" {
  zone_id = var.route53ZoneId
  name = var.dnsName
  type    = "A"
  alias {
    name                   = "${aws_lb.loadBalanceV2.dns_name}"
    zone_id                = "${aws_lb.loadBalanceV2.zone_id}"
    evaluate_target_health = true
  }

}
resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "CodeDeployServiceRole"
  }
}
resource "aws_iam_role_policy_attachment" "CodeDeployServiceRole_policy_attach" {
  role       = "${aws_iam_role.CodeDeployServiceRole.name}"
  depends_on = [aws_iam_role.CodeDeployServiceRole]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
resource "aws_codedeploy_app" "csye6225-webapp" {
  compute_platform = "Server"
  name             = "csye6225-webapp"
}
resource "aws_iam_policy" "CircleCI-Code-Deploy" {
  name        = "CircleCI-Code-Deploy"
  description = "A Upload policy"
  depends_on = [aws_codedeploy_deployment_group.csye6225-webapp-deployment]
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision",
        "codedeploy:ListApplicationRevisions"
      ],
      "Resource": [
        "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application:${aws_codedeploy_app.csye6225-webapp.name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${aws_codedeploy_app.csye6225-webapp.name}/${aws_codedeploy_deployment_group.csye6225-webapp-deployment.deployment_group_name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}
resource "aws_codedeploy_deployment_group" "csye6225-webapp-deployment" {
  app_name              = "${aws_codedeploy_app.csye6225-webapp.name}"
  deployment_group_name = "csye6225-webapp-deployment"
  depends_on = [aws_iam_role.CodeDeployServiceRole,aws_autoscaling_group.autoScalingGroup]
  service_role_arn      = "${aws_iam_role.CodeDeployServiceRole.arn}"
  autoscaling_groups = ["autoScalingGroup"]
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Web Server"
    }
  }
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  auto_rollback_configuration {
    enabled = true
    events  = [
      "DEPLOYMENT_FAILURE"
    ]
  }
  # alarm_configuration {
  #   alarms  = ["my-alarm-name"]
  #   enabled = true
  # }
}
resource "aws_iam_policy_attachment" "CircleCI-Code-Deploy-policy-attach" {
  name       = "CircleCI-Code-Deploy"
  users      = ["circleci"]
  policy_arn = "${aws_iam_policy.CircleCI-Code-Deploy.arn}"
}
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
handler         = "com.neu.LambdaFunc.EmailEvent::handleRequest"
runtime         = "java8"
memory_size     = 256
timeout         = 180
reserved_concurrent_executions  = 5
environment  {
variables = {
DOMAIN_NAME = var.domain_name
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
depends_on = [aws_sns_topic.EmailNotificationRecipeEndpoint]
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
              "Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/dynamo_csye6225"
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

resource "aws_iam_role_policy_attachment" "topic_policy_attach" {
  role       = var.ec2RoleName
  depends_on = [aws_iam_policy.topic_policy]
  policy_arn = "${aws_iam_policy.topic_policy.arn}"
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
]
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
resource "aws_cloudformation_stack" "waf" {
name = "waf-stack"
depends_on=[aws_lb.loadBalanceV2]
    # parameters = {
    # ALB = "${aws_lb.loadBalance.arn}"
    # }
  

   #template_body = "${file("${path.module}/waf.yml")}"
   template_body=<<STACK
   {
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "AWS WAF Basic OWASP Example Rule Set",
    
    "Resources": {
        "wafrSQLiSet": {
            "Type": "AWS::WAFRegional::SqlInjectionMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-detect-sqli"
                },
                "SqlInjectionMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    }
                ]
            }
        },
        "wafrSQLiRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "mitigatesqli",
                "Name": {
                    "Fn::Sub": "WAF-mitigate-sqli"
                },
                "Predicates": [
                    {
                        "Type": "SqlInjectionMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrSQLiSet"
                        }
                    }
                ]
            }
        },
        "wafrAuthTokenStringSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-auth-tokens"
                },
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "example-session-id",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "authorization"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ",
                        "TextTransformation": "URL_DECODE"
                    }
                ]
            }
        },
        "wafrAuthTokenRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "badauthtokens",
                "Name": {
                    "Fn::Sub": "WAF-detect-bad-auth-tokens"
                },
                "Predicates": [
                    {
                        "Type": "ByteMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrAuthTokenStringSet"
                        }
                    }
                ]
            }
        },
        "wafrXSSSet": {
            "Type": "AWS::WAFRegional::XssMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-detect-xss"
                },
                "XssMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    }
                ]
            }
        },
        "wafrXSSRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "mitigatexss",
                "Name": {
                    "Fn::Sub": "WAF-mitigate-xss"
                },
                "Predicates": [
                    {
                        "Type": "XssMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrXSSSet"
                        }
                    }
                ]
            }
        },
        "wafrPathsStringSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-rfi-lfi-traversal"
                },
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "../",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "../",
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "../",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "../",
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "://",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "://",
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "://",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "PositionalConstraint": "CONTAINS",
                        "TargetString": "://",
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    }
                ]
            }
        },
        "wafrPathsRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "detectrfilfi",
                "Name": {
                    "Fn::Sub": "WAF-detect-rfi-lfi-traversal"
                },
                "Predicates": [
                    {
                        "Type": "ByteMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrPathsStringSet"
                        }
                    }
                ]
            }
        },
        "wafrAdminUrlStringSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-admin-url"
                },
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "STARTS_WITH",
                        "TargetString": "/admin",
                        "TextTransformation": "URL_DECODE"
                    }
                ]
            }
        },
        "wafrAdminRemoteAddrIpSet": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-admin-remote-ip"
                },
                "IPSetDescriptors": [
                    {
                        "Type": "IPV4",
                        "Value": "127.0.0.1/32"
                    }
                ]
            }
        },
        "wafrAdminAccessRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "detectadminaccess",
                "Name": {
                    "Fn::Sub": "WAF-detect-admin-access"
                },
                "Predicates": [
                    {
                        "Type": "ByteMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrAdminUrlStringSet"
                        }
                    },
                    {
                        "Type": "IPMatch",
                        "Negated": true,
                        "DataId": {
                            "Ref": "wafrAdminRemoteAddrIpSet"
                        }
                    }
                ]
            }
        },
        "wafrSizeRestrictionSet": {
            "Type": "AWS::WAFRegional::SizeConstraintSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-size-restrictions"
                },
                "SizeConstraints": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": 512
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": 1024
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": 1048575
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": 4096
                    }
                ]
            }
        },
        "wafrSizeRestrictionRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "restrictsizes",
                "Name": {
                    "Fn::Sub": "WAF-restrict-sizes"
                },
                "Predicates": [
                    {
                        "Type": "SizeConstraint",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrSizeRestrictionSet"
                        }
                    }
                ]
            }
        },
        "wafrCSRFMethodStringSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-csrf-method"
                },
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "METHOD"
                        },
                        "PositionalConstraint": "EXACTLY",
                        "TargetString": "post",
                        "TextTransformation": "LOWERCASE"
                    }
                ]
            }
        },
        "wafrCSRFTokenSizeConstraint": {
            "Type": "AWS::WAFRegional::SizeConstraintSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-csrf-token"
                },
                "SizeConstraints": [
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "x-csrf-token"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "EQ",
                        "Size": 36
                    }
                ]
            }
        },
        "wafrCSRFRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "enforcecsrf",
                "Name": {
                    "Fn::Sub": "WAF-enforce-csrf"
                },
                "Predicates": [
                    {
                        "Type": "ByteMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrCSRFMethodStringSet"
                        }
                    },
                    {
                        "Type": "SizeConstraint",
                        "Negated": true,
                        "DataId": {
                            "Ref": "wafrCSRFTokenSizeConstraint"
                        }
                    }
                ]
            }
        },
        "wafrServerSideIncludeStringSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-ssi"
                },
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "STARTS_WITH",
                        "TargetString": "/includes",
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".cfg",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".conf",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".config",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".ini",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".log",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".bak",
                        "TextTransformation": "LOWERCASE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "PositionalConstraint": "ENDS_WITH",
                        "TargetString": ".backup",
                        "TextTransformation": "LOWERCASE"
                    }
                ]
            }
        },
        "wafrServerSideIncludeRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "detectssi",
                "Name": {
                    "Fn::Sub": "WAF-detect-ssi"
                },
                "Predicates": [
                    {
                        "Type": "ByteMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrServerSideIncludeStringSet"
                        }
                    }
                ]
            }
        },
        "wafrBlacklistIpSet": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": {
                    "Fn::Sub": "WAF-match-blacklisted-ips"
                },
                "IPSetDescriptors": [
                    {
                        "Type": "IPV4",
                        "Value": "192.168.1.1/32"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "192.168.1.1/32"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "169.254.0.0/16"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "172.16.0.0/16"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "127.0.0.1/32"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "10.110.123.223/32"
                    }
                ]
            }
        },
        "wafrBlacklistIpRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "MetricName": "blacklistedips",
                "Name": {
                    "Fn::Sub": "WAF-detect-blacklisted-ips"
                },
                "Predicates": [
                    {
                        "Type": "IPMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrBlacklistIpSet"
                        }
                    }
                ]
            }
        },
        "wafrOwaspACL": {
            "Type": "AWS::WAFRegional::WebACL",
            "Properties": {
                "MetricName": "owaspacl",
                "Name": {
                    "Fn::Sub": "WAF-owasp-acl"
                },
                "DefaultAction": {
                    "Type": "ALLOW"
                },
                "Rules": [
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 10,
                        "RuleId": {
                            "Ref": "wafrSizeRestrictionRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 20,
                        "RuleId": {
                            "Ref": "wafrBlacklistIpRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 30,
                        "RuleId": {
                            "Ref": "wafrAuthTokenRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 40,
                        "RuleId": {
                            "Ref": "wafrSQLiRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 50,
                        "RuleId": {
                            "Ref": "wafrXSSRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 60,
                        "RuleId": {
                            "Ref": "wafrPathsRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "ALLOW"
                        },
                        "Priority": 70,
                        "RuleId": {
                            "Ref": "wafrCSRFRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 80,
                        "RuleId": {
                            "Ref": "wafrServerSideIncludeRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 90,
                        "RuleId": {
                            "Ref": "wafrAdminAccessRule"
                        }
                    }
                ]
            }
        },
        "MyWebACLAssociation": {
            "Type": "AWS::WAFRegional::WebACLAssociation",
            "DependsOn": "wafrOwaspACL",
            "Properties": {
                "WebACLId": {
                    "Ref": "wafrOwaspACL"
                },
                "ResourceArn": "${aws_lb.loadBalanceV2.arn}"
            }
        }
    }
}
STACK
}