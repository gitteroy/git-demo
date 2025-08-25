output "website_endpoint" {
  description = "The public URL for the S3 website."
  value       = module.s3_website.website_endpoint
}

output "api_endpoint" {
  description = "The public URL for the API Gateway."
  value       = module.api_gateway.api_endpoint
}