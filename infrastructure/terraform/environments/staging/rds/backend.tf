terraform {
  required_version = "0.12.10"

  backend "s3" {
    bucket = "ochiai-basecamp"
    key    = "staging/rds/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
