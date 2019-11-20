variable "image_id" {
  description = "The AMI ID to be used to build the EC2 Instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type e.g. 't2.micro"
  type        = string
  default     = "t2.micro"
}

variable "primary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = string
  default     = "gp2"
}

variable "primary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = string
  default     = "20"
}

variable "disable_api_termination" {
  description = "Specifies that an instance should not be able to be deleted via the API. true or false. This option must be toggled to false to allow Terraform to destroy the resource."
  type        = string
  default     = false
}

variable "delete_on_termination" {
  description = "Volume should be destroyed on instance termination"
  type        = string
  default     = true
}

variable "device_name" {
  description = "The name of the block device to mount on the instance"
  type        = string
  default     = "/dev/sdf"
}

variable "security_group" {
  description = "Security Group assigned to resource"
  type        = string
}

variable "webapp_security_group" {
  description = "Security Group assigned to webapp"
  type        = string
}

variable "vpcId" {
  description = "VPC ID for EC2 Instance(s)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them."
  type        = string
}

variable "subnet_id2" {
  description = "Subnet ID for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them."
  type        = string
}

variable "subnet_id3" {
  description = "Subnet ID for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them."
  type        = string
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
}

variable "subnetGroupName" {
  description = "Name of Subnet Group."
  type        = string
  default     = "csye6225-dbsubnetgroup"
}

variable "storage" {
  description = "Storage capacity."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type."
  type        = string
  default     = "gp2"
}

variable "identifier" {
  description = "rds instance name."
  type        = string
  default     = "csye6225-fall2019"
}

variable "engine" {
  description = "db engine name."
  type        = string
  default     = "mariadb"
}

variable "engine_version" {
  description = "db version."
  type        = string
  default     = "10.2"
}

variable "instance_class" {
  description = "instance type."
  type        = string
  default     = "db.t2.micro"
}

variable "multi_az" {
  description = "availability zone."
  type        = string
  default     = "false"
}

variable "db_name" {
  description = "db name."
  type        = string
  default     = "csye6225"
}

variable "db_username" {
  description = "db name."
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "db name."
  type        = string
  default     = "28041992"
}

variable "parameter_group_name" {
  description = "parameter_group_name."
  type        = string
  default     = "default.mariadb10.2"
}

variable "publicly_accessible" {
  description = "publicly_accessible."
  type        = string
  default     = "true"
}

variable "port" {
  description = "port number."
  type        = string
  default     = "3306"
}

variable "skip_final_snapshot" {
  description = "skip_final_snapshot."
  type        = string
  default     = "true"
}


variable "billing_mode" {
  description = "skip_final_snapshot."
  type        = string
  default     = "PROVISIONED"
}

variable "read_capacity" {
  description = "read capacity"
  type        = number
  default     = 20
}

variable "write_capacity" {
  description = "write capacity"
  type        = number
  default     = 20
}

variable "hash_key" {
  description = "hash value"
  type        = string
  default     = "id"
}

variable "attribute_name" {
  description = "attribute name value"
  type        = string
  default     = "id"
}

variable "attribute_type" {
  description  = "Attribute Type"
  type         = string
  default      = "S"
}

variable "security_group_list" {
  description = "group of security ids"
  type        = list(string)
}

variable "dynamo_db_name" {
  description = "db name."
  type        = string
  default     = "dynamo_csye6225"
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
  description = "Name of code deploy s3 bucket"
}

variable "domain_name" {
  description = "Name of code deploy s3 bucket"
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
