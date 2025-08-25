terraform {
  backend "s3" {
    bucket       = "console-ri-test-bucket"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashorp/aws"
      version = "~> 6.2.0"
    }
  }
}