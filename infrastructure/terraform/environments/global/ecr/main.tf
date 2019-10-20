// ECRリポジトリ
resource "aws_ecr_repository" "ecr_repository" {
  name = var.project_name
}

// リポジトリに登録できるイメージには限りがあるので、ライフサイクルルールを設定
// 詳細はこちらを参照
// releaseというプレフィックスのタグがついたイメージを最大30個まで保存し、残りは期限切れとする
// ライフサイクルルールの設定方法は結構ややこしいので、必要に応じてドキュメントを読むこと
// https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/lifecycle_policy_examples.html
//{
//  "rules": [
//    {
//      "rulePriority": 1,
//      "description": "Keep last 30 release tagged images",
//      "selection": {
//        "tagStatus": "tagged",
//        "tagPrefixList": ["release"],
//        "countType": "imageCountMoreThan",
//        "countNumber": 30
//      },
//      "action": {
//        "type": "expire"
//       }
//    }
//  ]
//}
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = file("./aws_ecr_lifecycle_policy.json")
}
