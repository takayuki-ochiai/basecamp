data "aws_route53_zone" "zone" {
  name = "${var.project_name}.com"
}

resource "aws_acm_certificate" "certificate" {
  domain_name = "*.${var.project_name}.com"
  // ドメイン名を追加したい場合はsubject_alternative_namesの配列の中に追加したいドメインを記載する
  subject_alternative_names = []

  // SSL証明書の検証方法。自動更新ができるDNS方式を採用
  validation_method = "DNS"

  // 新しい証明書を作ってから古い証明書と差し替える
  lifecycle {
    create_before_destroy = true
  }
}

// apply時にSSLの検証が終わるまで待機してくれるリソース
resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_record.fqdn]
}

resource "aws_route53_record" "certificate_record" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  zone_id = data.aws_route53_zone.zone.id

  depends_on = [aws_acm_certificate.certificate]
  ttl     = 60
}

