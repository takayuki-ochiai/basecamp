data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "global/iam/terraform.tfstate"
    region = "ap-northeast-1"
  }
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

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = var.project_name
    key    = "${var.env}/alb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

// ECSクラスタはDockerコンテナを実行するサーバーを論理的に束ねたリソース
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-${var.env}-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  // タスク定義名のprefix
  family = "${var.project_name}-${var.env}"

  // タスクが使用するリソースのサイズ
  // 1024 = 1vCPU
  // 設定できる値の組合せは決まっている。cpu=256の時はmemoryは512, 1024, 2048のいずれかからしか設定できない
  cpu    = "256"
  memory = "512"
  // ECSの起動タイプ。EC2かFARGATEを設定する
  // Fargateだとこれまで意識しなければならなかったクラスタを構成するEC2側のリソースキャパシティを考慮しないですむ
  // オートスケール時にコンテナインスタンスのことを考えずに適切なキャパシティを設定してくれる
  // 代償としてSpotFleetには対応していない
  requires_compatibilities = ["EC2"]

  // Fargate起動タイプの場合はネットワークタイプはawsvpc一択
  // 他にはnone, bridge, hostなどを選択可能らしい
  // https://dev.classmethod.jp/etc/ecs-networking-mode/
  // bridge -> いわゆるDockerのブリッジ
  //           ECSインスタンス（EC2）の任意のポートをコンテナのポートにマッピングして利用
  // host   -> いわゆるDockerのhost
  //           コンテナでexposeされたポートをECSインスタンス（EC2）でも利用します
  // awsvpc -> ENIがタスク（複数のコンテナの集合）ごとに直接アタッチされます
  //           タスク間でのポートマッピングの考慮不要で、ENIが独立しているため、ネットワークパフォーマンスの向上が見込める
  //           ENIごとにSecurityGroupを紐づけられ、ECSインスタンス本体とタスクでセキュリティグループを分けることも可能
  //           ALBとNLBにIPターゲットとして登録が可能
  //           VPC FlowLogで観測可能
  //           いろいろ便利だがECSインスタンス（EC2）のENI上限に達しないように注意が必要
  //           ある程度大きなECSインスタンス（EC2）でかつタスクを決まった個数起動させたい場合にあっている
  // none   -> タスク内のコンテナの外部接続がなくなり、ポートマッピングを指定することはできない.何に使うんだ？
  network_mode = "awsvpc"



  // タスクで実行するコンテナを定義するコンテナ定義。指定されたフォーマットのJSONで記述
  container_definitions = file("./container_definitions.json")
  // DockerコンテナがCloudWatch Logsのログを投げられるようにIAMロールを付与
  execution_role_arn = data.terraform_remote_state.iam.outputs.ecs_task_definition_role_arn
}


module "nginx_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "nginx-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = 80
  cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
}

// コンテナを起動しても処理が終わったらすぐ終了してはダメなので、ECSサービスを利用する
resource "aws_ecs_service" "backend_ecs_service" {
  name            = "${var.project_name}-${var.env}-backend"
  cluster         = aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.task_definition.arn

  // サービスが維持するタスク数
  desired_count = 1

  // サービスの起動タイプ
  // コスト削減のため、FARGATEじゃなくてEC2
  launch_type = "EC2"

  // プラットフォームのバージョン:カーネルとコンテナのランタイムバージョンの組み合わせ
  // 起動タイプがFARGATEの場合は必ず明示的に指定する
  // platform_version = "1.3.0"

  // タスク起動時のヘルスチェック猶予期間（秒）
  // タスクの起動に時間がかかる場合、十分な猶予期間を設定しておかないと再起動を繰り返してしまう。。。
  health_check_grace_period_seconds = 60

  network_configuration {
    // ロードバランサーからアクセスさせるのでパブリックIPは不要
    assign_public_ip = false

    security_groups = [module.nginx_sg.security_group_id]

    subnets = [
      data.terraform_remote_state.network.outputs.private_subnet_1_id
    ]
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.forward_to_ecs_arn
    container_name   = "backend"
    container_port   = 80
  }

  lifecycle {
    // デプロイのたびにタスク定義が更新されるため、plan時に差が出てしまう。
    // Terraformではリソース初回作成時以外、task_definitionの変更は無視するべき
    ignore_changes = ["task_definition"]
  }
}

// ecs用のコンテナインスタンスを作る
// インスタンスプロファイルとセキュリティグループ、キーペアなどが必要
resource "aws_iam_instance_profile" "ecs_container_instance_profile" {
  name = "${var.project_name}-${var.env}-ecs-container-instance-profile"
  role = data.terraform_remote_state.iam.outputs.ec2_container_instance_role_name
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.project_name}-${var.env}-key-pair"
  public_key = file(var.public_key_path)
}

module "ssh_sg" {
  source      = "../../../modules/aws/vpc/security_group"
  name        = "${var.project_name}-${var.env}-ssh-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  port        = "22"
  cidr_blocks = ["0.0.0.0/0"]
}

// https://woshidan.hatenablog.com/entry/2018/08/16/023246
resource "aws_instance" "ecs_container_instance" {
  ami                  = "ami-0041c416aa23033a2"
  instance_type        = "t3.small"
  subnet_id            = data.terraform_remote_state.network.outputs.public_subnet_1_id
  iam_instance_profile = aws_iam_instance_profile.ecs_container_instance_profile.name
  key_name             = aws_key_pair.auth.key_name
  vpc_security_group_ids = [
    module.ssh_sg.security_group_id
  ]

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.project_name}-${var.env}-cluster >> /etc/ecs/ecs.config
EOF

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-container-instance"
    ManagedBy = "Terraform"
  }
}

// ロギング
// Fargateではホストサーバーにログインできずログを確認できないので
// CloudWatch Logsを使ってロギングする
// CloudWatch Logsはあらゆるログを収集できるマネージドサービス
resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/example"

  // ログの保持期間
  retention_in_days = 30
}
