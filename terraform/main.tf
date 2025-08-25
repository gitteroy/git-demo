provider "aws" {
  region = var.aws_region
}

resource "aws_secretsmanager_secret" "bot_token" {
  name = "timetosaygoodbye-telegram-bot-token"
}

module "s3_website" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

module "telegram_bot_lambda" {
  source           = "./modules/lambda"
  function_name    = var.lambda_function_name
  secret_arn       = aws_secretsmanager_secret.bot_token.arn
  source_code_path = "${path.root}/lambda"
}

module "api_gateway" {
  source               = "./modules/apigateway"
  api_name             = "telegram-bot-api"
  lambda_invoke_arn    = module.telegram_bot_lambda.invoke_arn
  lambda_function_name = module.telegram_bot_lambda.function_name
}
