data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

// Redisの設定はElastiCacheパラメータグループで行う
resource "aws_elasticache_parameter_group" "parameter_group" {
  name   = "${var.project_name}-${var.env}-redis"
  family = "redis5.0"

  // クラスタモードを無効にする
  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

// RDSのサブネットグループと同様プライベートサブネットを指定して異なるAZを含むようにする
resource "aws_elasticache_subnet_group" "subnet_group" {
  name = "${var.project_name}-${var.env}-redis"

  subnet_ids = [
    data.terraform_remote_state.network.outputs.private_subnet_1_id,
    data.terraform_remote_state.network.outputs.private_subnet_2_id
  ]
}

module "redis_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "redis-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = 6379
  cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
}

// レプリケーショングループ（クラスタのこと）
// ElastiCache のクラスタには、クラスタモード無効と、クラスタモード有効の 2 種類ある
// Redis (クラスタモード有効) は、クラスタ 1 つにシャード 1〜15 個持つことができる。 Redis (クラスタモード無効) は、クラスタ 1 つにシャード 1 個持つことができる
resource "aws_elasticache_replication_group" "elasticache_replication_group" {
  // エンドポイントで使う識別子
  replication_group_id          = "${var.project_name_short}-${var.env}"
  replication_group_description = "Cluster Disabled"
  engine                        = "Redis"
  engine_version                = "5.0.3"

  // ノード数の指定
  // プライマリノードとスレーブノードの合計数
  number_cache_clusters = 3

  node_type = "cache.m3.medium"

  // スナップショット作成のタイミング
  snapshot_window = "09:10-10:10"

  // スナップショットを何日分保持するか
  snapshot_retention_limit = 7

  // メンテナンスウィンドウの時間帯
  maintenance_window = "Mon:10:10-Mon:11:10"

  // マルチAZ化している場合、自動フェイルオーバーを有効化できる
  automatic_failover_enabled = true
  port                       = 6379

  // 設定変更のタイミングには「即時」と「メンテナンスウィンドウ」がある。一部の設定変更は再起動が伴うので予期せぬダウンタイムが発生する。
  // それを避けるため即時反映を避けるオプション
  apply_immediately = false

  security_group_ids   = [
    module.redis_sg.security_group_id
  ]
  parameter_group_name = aws_elasticache_parameter_group.parameter_group.name
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name

  // クラスタモード有効の場合はこのオプションをつける
  //  cluster_mode {
  //    nodeグループ（シャード）あたりのレプリカノードの数
  //    replicas_per_node_group = 1
  //    シャードの数
  //    num_node_groups         = 2
  //  }
}
