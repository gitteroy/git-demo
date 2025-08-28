provider "aws" {
  region = var.aws_region
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_secretsmanager_secret" "bot_token" {
  name = "timetosaygoodbye-telegram-bot-token"
}

module "s3_website" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda"
  output_path = "${path.root}/../lambda.zip"
}

module "telegram_bot_lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_function_name
  secret_arn    = aws_secretsmanager_secret.bot_token.arn
  filename      = data.archive_file.lambda_zip.output_path
}

module "api_gateway" {
  source               = "./modules/apigateway"
  api_name             = "telegram-bot-api"
  lambda_invoke_arn    = module.telegram_bot_lambda.invoke_arn
  lambda_function_name = module.telegram_bot_lambda.function_name
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-vpc"
  }
}

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "a" {
  vpc_id                              = aws_vpc.vpc.id
  cidr_block                          = "10.10.1.0/24"
  availability_zone                   = "ap-southeast-1a"
  private_dns_hostname_type_on_launch = "ip-name"
  map_public_ip_on_launch             = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "b" {
  vpc_id                              = aws_vpc.vpc.id
  cidr_block                          = "10.10.2.0/24"
  availability_zone                   = "ap-southeast-1b"
  private_dns_hostname_type_on_launch = "ip-name"
  map_public_ip_on_launch             = true

  tags = {
    Name = "public-subnet-1b"
  }
}

module "gateways" {
  source = "./modules/gateways"

  project_name = var.project_name
  project_env  = var.project_env
  vpc_id       = aws_vpc.vpc.id

  public_subnet_1a_id = aws_subnet.a.id
  public_subnet_1b_id = aws_subnet.b.id
}

module "route_table" {
  source = "./modules/route_table"

  project_name        = var.project_name
  project_env         = var.project_env
  vpc_id              = aws_vpc.vpc.id
  main_route_table_id = aws_vpc.vpc.default_route_table_id
  internet_gateway_id = module.gateways.internet_gateway_id
  public_subnet_1a_id = aws_subnet.a.id
  public_subnet_1b_id = aws_subnet.b.id
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  project_name                   = var.project_name
  project_env                    = var.project_env
  vpc_endpoint_security_group_id = module.security_group.vpc_endpoint_security_group.id

  vpc_id              = aws_vpc.vpc.id
  public_subnet_1a_id = aws_subnet.a.id
  public_subnet_1b_id = aws_subnet.b.id
}

module "security_group" {
  source = "./modules/security_group"

  project_name = var.project_name
  project_env  = var.project_env
  vpc_id       = aws_vpc.vpc.id
  my_ip        = data.http.my_ip.response_body
}

module "ec2_instance" {
  source = "./modules/ec2"

  instance_type         = var.instance_type
  ami_id                = var.ami_id # "ami-0cfd1ec17e8c33b53"
  ec2_security_group_id = module.security_group.app_security_group.id
  subnet_id             = aws_subnet.a.id
  vpc_id                = aws_vpc.vpc.id
  # user_data       = file("${path.root}/../scripts/user_data.sh")
}