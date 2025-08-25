source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
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
    owners      = ["099720109477"]
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
}