terraform {
  required_version = "0.12.10"

  backend "s3" {
    bucket = "ochiai-basecamp"
    key    = "production/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}