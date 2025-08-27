variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID where the instance will be deployed"
  type        = string
}

variable "ec2_security_group_id" {
  description = "The Security Group ID to associate with the instance"
  type        = string
}