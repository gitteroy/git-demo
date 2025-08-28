resource "aws_instance" "web_app" {
  ami                         = data.aws_ami.packer_ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.ec2_security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "packer-terraform-dev-instance"
  }
}

data "aws_ami" "packer_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_prefix}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}