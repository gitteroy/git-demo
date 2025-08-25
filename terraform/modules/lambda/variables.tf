variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "secret_arn" {
  description = "The ARN of the Secrets Manager secret for the bot token."
  type        = string
}

variable "source_code_path" {
  description = "The path to the Lambda function's source code."
  type        = string
}