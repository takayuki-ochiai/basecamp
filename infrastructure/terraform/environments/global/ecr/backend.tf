terraform {
  required_version = "0.12.10"

  backend "s3" {
    bucket = "ochiai-basecamp"
    key    = "global/ecr/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
