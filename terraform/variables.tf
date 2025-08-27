variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
  default     = "elroy-git-demo-bucket-0000"
}

variable "lambda_function_name" {
  description = "The name of the Lambda Function."
  type        = string
  default     = "lambda-python-function"
}

## networking variable

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "packer-terraform"
}
variable "project_env" {
  description = "The environment of the project (e.g., dev, prod)."
  type        = string
  default     = "dev"
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

## ec2 variable

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
  default     = "ami-0435fcf800fb5418d"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}
