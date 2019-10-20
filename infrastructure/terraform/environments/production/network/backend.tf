terraform {
  required_version = "0.12.10"

  backend "s3" {
    bucket = "ochiai-basecamp"
    key    = "production/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}