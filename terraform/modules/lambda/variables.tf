variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "secret_arn" {
  description = "The ARN of the Secrets Manager secret for the bot token."
  type        = string
}

variable "filename" {
  description = "The file path to the Lambda function's zip"
  type        = string
}