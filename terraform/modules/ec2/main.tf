resource "aws_instance" "web_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.ec2_security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "web-app-instance"
  }
}
