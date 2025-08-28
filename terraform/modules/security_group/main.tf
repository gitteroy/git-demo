resource "aws_security_group" "app_security_group" {
  name        = "${var.project_name}-${var.project_env}-app-sg"
  description = "Enable access from ALB Security Group on App ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["${chomp(var.my_ip)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["${chomp(var.my_ip)}/32"]
  }

  egress {
    description = "Egress to all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-app-sg"
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-${var.project_env}-vpc-endpoint-sg"
  description = "Enable HTTPS private connection between VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress from ALL via HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Egress from ALL via HTTPS port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-vpc-endpoint-sg"
  }
}