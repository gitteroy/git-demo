//====== Internet Gateway ======\\

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project_name}-${var.project_env}-igw"
  }
}

//====== Elastic IP addresses ======\\

resource "aws_eip" "eip_az_a" {
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "${var.project_name}-${var.project_env}-eip-az-a"
  }
}

resource "aws_eip" "eip_az_b" {
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "${var.project_name}-${var.project_env}-eip-az-b"
  }
}
