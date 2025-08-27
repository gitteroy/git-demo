//====== Route Tables ======\\

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = var.main_route_table_id

  tags = {
    Name = "${var.project_name}-${var.project_env}-default-rt"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-public-rt"
  }
}

//===== Route Table Associations =====\\

resource "aws_route_table_association" "alb_subnet_1a_public_route_table_association" {
  subnet_id      = var.public_subnet_1a_id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "alb_subnet_1b_public_route_table_association" {
  subnet_id      = var.public_subnet_1b_id
  route_table_id = aws_route_table.public_route_table.id
}
