variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
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

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
  default     = "ami-0435fcf800fb5418d"
}

variable "ami_prefix" {
  description = "AMI name prefix to search for the most recent AMI built by Packer"
  type        = string
}