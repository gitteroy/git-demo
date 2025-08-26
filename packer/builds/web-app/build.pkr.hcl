locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region

  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  associate_public_ip_address = true
  ssh_interface = "public_ip"
  ssh_username  = "ubuntu"
  ssh_timeout   = "10m"
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # canonical
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

    # Install and configure CloudWatch Agent
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y wget unzip",
      "wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i amazon-cloudwatch-agent.deb",
      "sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc",

      "cat > amazon-cloudwatch-agent.json <<'EOF'\n" +
      "{\n" +
      "  \"metrics\": {\n" +
      "    \"metrics_collected\": {\n" +
      "      \"cpu\": {\n" +
      "        \"measurement\": [\n" +
      "          { \"name\": \"cpu_usage_idle\", \"rename\": \"CPU_IDLE\", \"unit\": \"Percent\" },\n" +
      "          { \"name\": \"cpu_usage_user\", \"rename\": \"CPU_USER\", \"unit\": \"Percent\" },\n" +
      "          { \"name\": \"cpu_usage_system\", \"rename\": \"CPU_SYSTEM\", \"unit\": \"Percent\" }\n" +
      "        ],\n" +
      "        \"metrics_collection_interval\": 60,\n" +
      "        \"totalcpu\": true\n" +
      "      },\n" +
      "      \"mem\": {\n" +
      "        \"measurement\": [\n" +
      "          { \"name\": \"mem_used_percent\", \"unit\": \"Percent\" }\n" +
      "        ],\n" +
      "        \"metrics_collection_interval\": 60\n" +
      "      },\n" +
      "      \"disk\": {\n" +
      "        \"measurement\": [\n" +
      "          { \"name\": \"disk_used_percent\", \"unit\": \"Percent\" }\n" +
      "        ],\n" +
      "        \"metrics_collection_interval\": 60,\n" +
      "        \"resources\": [ \"*\" ]\n" +
      "      },\n" +
      "      \"net\": {\n" +
      "        \"measurement\": [\n" +
      "          \"bytes_sent\",\n" +
      "          \"bytes_recv\"\n" +
      "        ],\n" +
      "        \"metrics_collection_interval\": 60,\n" +
      "        \"resources\": [ \"*\" ]\n" +
      "      }\n" +
      "    }\n" +
      "  },\n" +
      "  \"logs\": {\n" +
      "    \"logs_collected\": {\n" +
      "      \"journald\": {\n" +
      "        \"collect_list\": [\n" +
      "          {\n" +
      "            \"unit\": \"myapp.service\",\n" +
      "            \"log_group_name\": \"/my-app/ec2\",\n" +
      "            \"log_stream_name\": \"{instance_id}-app\"\n" +
      "          }\n" +
      "        ]\n" +
      "      }\n" +
      "    }\n" +
      "  }\n" +
      "}\n" +
      "EOF",

      "sudo mv amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "sudo systemctl enable amazon-cloudwatch-agent",
      "sudo systemctl start amazon-cloudwatch-agent"
    ]
  }
}