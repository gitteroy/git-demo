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