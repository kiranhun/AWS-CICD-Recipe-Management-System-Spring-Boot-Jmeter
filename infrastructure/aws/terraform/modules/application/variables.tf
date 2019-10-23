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

variable "subnet_id" {
  description = "Subnet ID for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them."
  type        = string
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default     = ""
}