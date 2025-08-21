source "amazon-ebs" "ubuntu" {
  ami_name      = "raid-pkr-example"
  instance_type = "t2.micro"
  region        = "ap-southeast-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "build-app-image"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "file" {
    source = "./app/index"
    destination = "/home/ubuntu/app/index"
  }

  provisioner "file" {
    source = "./app/package.json"
    destination = "/home/ubuntu/app/package.json"
  }

  provisioner "shell" {
    inline = [
        "cd /home/ubuntu/app",
        "npm install"
    ]
  }
}