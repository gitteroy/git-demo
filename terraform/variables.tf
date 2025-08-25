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