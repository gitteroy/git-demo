locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region

  vpc_id                   = "vpc-0c4783b07aa53d0d5"    # created in console
  subnet_id                = "subnet-0f4ef02cbb5d89edd" # created in console

  associate_public_ip_address = true
  ssh_interface               = "public_ip"
  ssh_username                = "ubuntu"
  ssh_timeout                 = "15m"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*" # latest Ubuntu LTS
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]  # Canonical
  }
}

build {
  name    = "build-app-image"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "./scripts/setup.sh"
  }

  provisioner "file" {
    source      = "./app"
    destination = "/home/ubuntu/app"
  }

  provisioner "shell" {
    inline = [
      "export NVM_DIR=\"$HOME/.nvm\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"",
      "cd /home/ubuntu/app",
      "npm install"
    ]
  }

  # Copy CloudWatch Agent config into the AMI
  provisioner "file" {
    source      = "files/amazon-cloudwatch-agent.json"
    destination = "/tmp/amazon-cloudwatch-agent.json"
  }

  # Install and enable CloudWatch Agent
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y wget unzip",
      "wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i amazon-cloudwatch-agent.deb",
      "sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc",
      "sudo mv /tmp/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "sudo systemctl enable amazon-cloudwatch-agent",
      "sudo systemctl start amazon-cloudwatch-agent"
    ]
  }
}