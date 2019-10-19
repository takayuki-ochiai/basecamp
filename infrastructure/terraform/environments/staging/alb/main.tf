data "aws_route53_zone" "zone" {
  name = "${var.project_name}.com"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/acm/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

module "http_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "${var.project_name}-${var.env}-http-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = "80"
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "${var.project_name}-${var.env}-https-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = "443"
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "${var.project_name}-${var.env}-http-redirect-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = "8080"
  cidr_blocks = ["0.0.0.0/0"]
}

// https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "alb" {
  name = "${var.project_name}-${var.env}-alb"

  // ロードバランサーの種類。albの場合applicationを選択。
  load_balancer_type = "application"

  // インターネットに公開していない内部サーバー用のロードバランサーの場合,trueにする
  // 今回は一般的なインターネットロードバランサーとして使うためfalse
  internal = false

  // タイムアウトする秒数
  idle_timeout = 60

  // 削除保護
  enable_deletion_protection = false

  // ALBが所属するサブネット
  // 異なるアベイラビリティーゾーンのサブネットを指定してクロスゾーン負荷分散する
  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_1_id,
    data.terraform_remote_state.network.outputs.public_subnet_2_id
  ]

  // アクセスログにバケット名を指定するとアクセスログの保存が有効になる
  access_logs {
    bucket  = data.terraform_remote_state.s3.outputs.alb_log_id
    enabled = true
  }

  // 付与するセキュリティグループ
  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]

  tags = {
    Name      = "${var.project_name}-${var.env}-alb"
    ManagedBy = "Terraform"
  }
}

// どのポートのどのリクエストを受け付けるか設定するリスナーを定義する
// https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80

  // TCP, TLS, UDP, TCP_UDP, HTTP and HTTPS から選択可能
  protocol = "HTTP"

  // デフォルトのルールが一番優先順位が低い
  default_action {
    // forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc
    // forward -> リクエストを別のターゲットグループに転送
    // fixed-response -> 固定の HTTPレスポンスを応答
    // redirect -> 別のURLにリダイレクト
    type = "fixed-response"

    // typeがfixed-responseだった場合、設定必須
    fixed_response {
      content_type = "text/plain"
      message_body = "This is HTTP"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443

  // TCP, TLS, UDP, TCP_UDP, HTTP and HTTPS から選択可能
  protocol = "HTTPS"

  // 証明書のarn
  certificate_arn = data.terraform_remote_state.acm.outputs.certificate_arn

  // 2019-03時点で、このセキュリティポリシーの使用が推奨されている
  ssl_policy = "ELBSecurityPolicy-2016-08"

  // デフォルトのルールが一番優先順位が低い
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is HTTPS!!"
      status_code  = "200"
    }
  }
}

// HTTPをHTTPSにリダイレクト
resource "aws_alb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080

  // デフォルトのルールが一番優先順位が低い
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

// リクエストフォワーディング
// 任意のターゲットにリクエストをフォワードさせる
//resource "aws_lb_target_group" "forward_to_ecs" {
//  name   = "${var.project_name}-${var.env}-to-ecs"
//  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
//
//  // ターゲットの種類の指定
//  // EC2インスタンスやIPアドレス、Lambda関数などが指定できる
//  // 今回はFargate使用の前提なのでipを指定
//  target_type = "ip"
//
//  port = 80
//
//  // HTTPSの終端はALBのため、protocolはHTTPとなる
//  protocol = "HTTP"
//
//  // ターゲット登録解除までにALBが待機する時間（秒）
//  deregistration_delay = 300
//
//  tags = {
//
//  }
//
//  // ヘルスチェックの設定
//  health_check {
//    // ヘルスチェックで確認するパス
//    path = "/"
//
//    // 正常判定を行うまでのヘルスチェック実行回数
//    healthy_threshold = 5
//
//    // 異常判定を行うまでのヘルスチェック実行回数
//    unhealthy_threshold = 2
//
//    // ヘルスチェックのタイムアウト時間（秒）
//    timeout = 5
//
//    // ヘルスチェックの間隔（秒）
//    interval = 30
//
//    // 正常かどうか判定するために使うHTTPステータスコード
//    matcher = "200"
//
//    // ヘルスチェック時に使うポート
//    port = "traffic-port"
//
//    // ヘルスチェック時に使うプロトコル
//    protocol = "HTTP"
//  }
//
//  depends_on = [aws_lb.alb]
//}
//
//resource "aws_lb_listener_rule" "https" {
//  listener_arn = aws_lb_listener.https.arn
//
//  // 優先度。数値が低いほど優先されるルールとなる
//  priority = 100
//
//  action {
//    type             = "forward"
//    target_group_arn = aws_lb_target_group.forward_to_ecs.arn
//  }
//
//  condition {
//    field  = "path-pattern"
//    values = ["/*"]
//  }
//}
