variable "vpcname" {
  type = string
}

variable "vpccidr" {
    type = "string"
}

variable "default_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "subnet1" {
  type = "string"
}

variable "subnet2" {
  type = "string"
}

variable "subnet3" {
  type = "string"
}

variable "destinationCIDRblock" {
   default = "0.0.0.0/0"
}

variable "region" {
  type= string
}