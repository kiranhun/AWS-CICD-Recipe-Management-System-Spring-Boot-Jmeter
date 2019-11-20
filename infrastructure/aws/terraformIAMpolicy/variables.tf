variable "code_deploy_s3_bucket" {
  description = "Name of code deploy s3 bucket"
}

variable "aws_profile" {
  type = "string"
}

variable "region" {
  type = "string"
}


variable "codedeploy_lambda_s3_bucket" {
  description = "Name of code deploy s3 bucket"
  #default     = "codedeploylambda.veenaiyer.me"
}