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

variable "vpc_id" {
  type        = string
  default     = "vpc-0c4783b07aa53d0d5"
  description = "VPC ID for the build instance"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-0f4ef02cbb5d89edd"
  description = "Subnet ID for the build instance"
}