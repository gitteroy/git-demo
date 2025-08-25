# Specify the required AWS provider version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "website" {
  bucket = var.s3_bucket_name
}

# Configure the S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

# Unblock public access to the bucket.
# This is required to allow a public bucket policy.
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# A data source to create the public read policy document
data "aws_iam_policy_document" "public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"] # Represents everyone/anonymous
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"] # Policy applies to all objects in the bucket
  }
}

# Apply the public read policy to the bucket
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json

  # This ensures the public access block is configured before the policy is applied
  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Output the website URL so you can easily access it
output "website_endpoint" {
  description = "The public URL for the S3 website."
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}