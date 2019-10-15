
resource "aws_s3_bucket" "alb_log" {
  bucket = "${var.project_name}-${var.env}-alb-log"

  // 180日経過したログを自動削除するライフサイクルルールを追加
  lifecycle_rule {
    enabled = true

    expiration {
      days = 180
    }
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-alb-log"
    ManagedBy = "Terraform"
  }
}

// alb_logバケットのなかのオブジェクトに対してPutObjectを許可するバケットポリシー
data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      // ALBの場合はAWSが管理しているアカウントからこのログバケットに書き込みされる
      // 自分のAWSアカウントのidを記入するのではないので注意！
      identifiers = ["582318560864"]

      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}