resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  subnet_ids = [
    var.public_subnet_1a_id,
    var.public_subnet_1b_id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-ssm-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  subnet_ids = [
    var.public_subnet_1a_id,
    var.public_subnet_1b_id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-ec2messages-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  subnet_ids = [
    var.public_subnet_1a_id,
    var.public_subnet_1b_id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-ssmmessages-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  subnet_ids = [
    var.public_subnet_1a_id,
    var.public_subnet_1b_id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-ecr-dkr-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  subnet_ids = [
    var.public_subnet_1a_id,
    var.public_subnet_1b_id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.project_env}-ecr-vpc-endpoint"
  }
}