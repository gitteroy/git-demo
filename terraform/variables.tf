variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda Function."
  type        = string
}

## networking variable

variable "project_name" {
  description = "The name of the project."
  type        = string
}
variable "project_env" {
  description = "The environment of the project (e.g., dev, prod)."
  type        = string
  default     = "dev"
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/24"
}

## ec2 variable

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}
