data "aws_route53_zone" "zone" {
  name = "${var.project_name}.com"
}

data "terraform_remote_state" "staging_alb" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "staging/alb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

//// DNSレコードの登録
resource "aws_route53_record" "staging" {
  name    = "staging.${data.aws_route53_zone.zone.name}"
  zone_id = data.aws_route53_zone.zone.zone_id

  // ALIASレコードで、通常のAレコードとは異なることに注意
  type = "A"

  alias {
    name                   = data.terraform_remote_state.staging_alb.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.staging_alb.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
