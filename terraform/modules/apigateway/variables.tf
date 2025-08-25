variable "api_name" {
  description = "The name for the HTTP API Gateway."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN to be used for invoking the Lambda function."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}