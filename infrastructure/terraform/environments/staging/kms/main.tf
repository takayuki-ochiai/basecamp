// KMSに関する設定ファイル
// KMS自体の説明は下記の記事を参照
// https://dev.classmethod.jp/cloud/aws/cm-advent-calendar-2015-aws-relearning-key-management-service/
resource "aws_kms_key" "customer_master_key" {
  description = "${var.project_name}-${var.env} Customer Master Key"

  // マスターキーに対して、1年ごとのローテーションをするかしないかを設定できる
  // ローテーション以降のすべてのリクエストは、新規に生成されたマスターキーに向けられる。
  // しかし、例外として、以前のマスターキーを使って生成したデータキーからの復号のリクエストだけは、古いマスターキーに向けられる。
  enable_key_rotation = true

  // 有効化するか。当たり前だがしないと使えない
  is_enabled = true

  // カスタマーマスターキーの削除待機期間
  // 待機期間中であればいつでも削除を取り消せる
  deletion_window_in_days = 30
}

// マスターキーにはUUIDが割り当てられるが、わかりにくいのでエイリアスをつけることができる
resource "aws_kms_alias" "sandbox" {
  // エイリアスでつける名前にはalias/というプレフィックスが必要
  name          = "alias/${var.project_name}-${var.env}"
  target_key_id = aws_kms_key.customer_master_key.id
}
