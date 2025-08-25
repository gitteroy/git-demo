output "website_endpoint" {
  description = "The public URL for the S3 website."
  value       = aws_s3_bucket_website_configuration.this.website_endpoint
}