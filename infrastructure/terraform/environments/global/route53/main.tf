resource "aws_route53_zone" "zone" {
  name = "${var.project_name}.com"
}

