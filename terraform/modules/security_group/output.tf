output "app_security_group" {
  value = aws_security_group.app_security_group
}

output "vpc_endpoint_security_group" {
  value = aws_security_group.vpc_endpoint_sg
}