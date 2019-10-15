data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [var.identifier]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags {
    Name      = var.name
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "policy" {
  name   = var.name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.role.name
}
