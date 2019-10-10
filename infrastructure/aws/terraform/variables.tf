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