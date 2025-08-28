locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region

  vpc_id                   = "vpc-0c4783b07aa53d0d5"
  subnet_id                = "subnet-0f4ef02cbb5d89edd"

  associate_public_ip_address = true
  ssh_interface               = "public_ip"
  ssh_username                = "ubuntu"
  ssh_timeout                 = "15m"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
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

  # Run your setup script first (e.g. install nvm, node, etc.)
  provisioner "shell" {
    script = "./scripts/setup.sh"
  }

  # OS Hardening
  provisioner "shell" {
    inline = [
      "# Update system packages",
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "# Install security updates",
      "sudo unattended-upgrade -d",
      "# Configure automatic security updates",
      "echo 'Unattended-Upgrade::Automatic-Reboot \"false\";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades"
    ]
  }

  # Upload the whole app folder
  provisioner "file" {
    source      = "./app"
    destination = "/home/ubuntu/app"
  }

  # Install dependencies inside the uploaded app
  provisioner "shell" {
    inline = [
      "export NVM_DIR=\"$HOME/.nvm\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"",
      "cd /home/ubuntu/app",
      "npm install"
    ]
  }

  # Create systemd service for the app
  provisioner "shell" {
    inline = [
      "echo '[Unit]' | sudo tee /etc/systemd/system/myapp.service",
      "echo 'Description=My Express App' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo '' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo '[Service]' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'ExecStart=/usr/bin/node /home/ubuntu/app/index.js' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'WorkingDirectory=/home/ubuntu/app' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'User=ubuntu' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'Group=ubuntu' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo '' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo '[Install]' | sudo tee -a /etc/systemd/system/myapp.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service"
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