// タスクを実行するためのタスク実行ロールを作成
// 「タスク実行ロール」はタスクを実行するためのロールで（そのまんま）、 ECR からイメージを Pull したり、
// ログを CloudWatchLogs に記録するために使用する。
// AmazonECSTaskExecutionRolePolicyというAWSが管理しているできあいのロールポリシーがあるので利用する
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  // AmazonECSTaskExecutionRolePolicyを継承してさらに権限を追加する。
  // SSM パラメータストアと ECS の統合で必要な権限を付与
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_definition_role" {
  source     = "../../../modules/aws/iam/role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy" "ec2_container_service_for_ec2_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "ec2_container_service" {
  source_json = data.aws_iam_policy.ec2_container_service_for_ec2_role.policy
}

module "ec2_container_instance_role" {
  source     = "../../../modules/aws/iam/role"
  name       = "ec2-container-instance"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.ec2_container_service.json
}
