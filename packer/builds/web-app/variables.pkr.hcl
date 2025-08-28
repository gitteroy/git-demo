variable "ami_prefix" {
  type        = string
  description = "Base name for the generated AMI"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for building"
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "packer_vpc_id" {
  type        = string
  description = "VPC ID for the build instance"
}

variable "packer_subnet_id" {
  type        = string
  description = "Subnet ID for the build instance"
}