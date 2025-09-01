terraform {
  backend "s3" {
    bucket       = "your-s3-bucket-name"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}