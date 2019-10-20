data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/kms/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

// MySQLのmy.cnfに設定するようなデータベースの定義をDBパラメータグループに記述する
resource "aws_db_parameter_group" "mysql" {
  // エンジン名とバージョンを含めたものを記載する
  family = "mysql8.0"
  name   = "${var.project_name}-${var.env}-mysql"

  // 設定パラメーターと値のペアを設定する
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

// DBオプショングループ
// DBにオプション機能を追加します
resource "aws_db_option_group" "option_group" {
  name                 = "${var.project_name}-${var.env}-mysql"
  engine_name          = "mysql"
  major_engine_version = "8.0"

  // MARIADBの監査プラグインを追加している。監査プラグインはユーザーのログオンや実行したクエリなどのアクティビティを記録するプラグイン
  // option {
  //   option_name = "MARIADB_AUDIT_PLUGIN"
  //}
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "${var.project_name}-${var.env}-mysql"

  subnet_ids = [
    data.terraform_remote_state.network.outputs.private_subnet_1_id,
    data.terraform_remote_state.network.outputs.private_subnet_2_id
  ]
}

module "mysql_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "mysql-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = 3306
  cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
}

resource "aws_db_instance" "mysql" {
  // データベースのエンドポイントで使う識別子
  identifier = "${var.project_name}-${var.env}"

  // エンジン名
  engine = "mysql"

  // パッチバージョンまで含めたバージョン
  engine_version = "8.0.16"

  // インスタンスクラス
  instance_class = "db.t3.small"

  // ディスク容量
  // 単位はgibibytes
  allocated_storage = 20

  // 汎用SSDかプロビジョンドIOPSを設定
  // gp2は汎用SSD、io1はプロビジョンドIOPS
  storage_type = "gp2"

  // 暗号化するかどうか。言わずもがな
  storage_encrypted = true

  // ディスク暗号化に使用するkmsを指定する
  kms_key_id = data.terraform_remote_state.kms.outputs.kms_key_arn

  // マスターユーザーの名前とパスワード
  username = "admin"
  password = "dummyPassword"

  // multi AZ配置するか
  // 今回はNAT gatewayの費用がかさむので、single AZ配置で許容する
  multi_az = false

  // VPC外からのアクセスを遮断するためにはfalseにする
  publicly_accessible = false

  // RDSは毎日バックアプが作成される。バックアップのタイミングを指定する
  // メンテナンスウィンドウの前にバックアップのタイミングを設定しておくと安心感が増す
  backup_window = "09:10-09:40"

  // バックアップの保持期間（日）
  backup_retention_period = 30

  // メンテナンスウィンドウ
  // メンテナンスにはOSやデータベースエンジンの更新が含まれるためメンテナンス自体を無効化することはできない
  maintenance_window = "Mon:10:10-Mon:10:40"

  // マイナーバージョンアップグレード（再起動）を自動実行するか？
  auto_minor_version_upgrade = false

  // 削除防止オプション
  deletion_protection = true

  // インスタンス削除時にスナップショットを保存するかどうか
  skip_final_snapshot = false
  port                = 3306

  // 設定変更のタイミングには「即時」と「メンテナンスウィンドウ」がある。一部の設定変更は再起動が伴うので予期せぬダウンタイムが発生する。
  // それを避けるため即時反映を避けるオプション
  apply_immediately = false

  vpc_security_group_ids = [module.mysql_sg.security_group_id]
  parameter_group_name   = aws_db_parameter_group.mysql.name
  option_group_name      = aws_db_option_group.option_group.name
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name

  // パスワードはあとで変更する前提でignore_changesに加える
  lifecycle {
    ignore_changes = ["password"]
  }
}
