variable "aws_profile" {
  type = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type = string
}

variable "cidr_range" {
    description = "CIDR range for VPC"
    type = "string"
}

variable "subnetcidr1" {
  type = "string"
}

variable "subnetcidr2" {
  type = "string"
}

variable "subnetcidr3" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "image_id" {
  description = "The AMI ID to be used to build the EC2 Instance."
  type        = string
}

variable "key_pair" {
  description = "Your aws keypair used to ssh into the machine. Needed if you want to be able to ssh into the created instance."
  default     = "csye6225"
}

variable "bucket_name" {
  description = "Bucket name."
  type        = string
}

variable "ec2RoleName" {
  description = "ec2 role name."
  type        = string
}

variable "codedeploy_lambda_s3_bucket" {
  description = "codeDeploy Lambda s3 Bucket."
  type        = string
}

variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "dnsName" {
  description = "Name of dns, example: prod.xxxxxxxx.me"
}

variable "route53ZoneId" {
  description = "route53 zone id"
}

variable "certificate_arn" {
  description = "Certificate arn"
}
