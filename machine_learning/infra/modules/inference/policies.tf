resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#data "aws_iam_policy_document" "foopolicy" {
#  statement {
#    sid    = "new policy"
#    effect = "Allow"
#
#    principals {
#      type        = "AWS"
#      identifiers = ["123456789012"]
#    }
#
#    actions = [
#      "ecr:GetDownloadUrlForLayer",
#      "ecr:BatchGetImage",
#      "ecr:BatchCheckLayerAvailability",
#      "ecr:PutImage",
#      "ecr:InitiateLayerUpload",
#      "ecr:UploadLayerPart",
#      "ecr:CompleteLayerUpload",
#      "ecr:DescribeRepositories",
#      "ecr:GetRepositoryPolicy",
#      "ecr:ListImages",
#      "ecr:DeleteRepository",
#      "ecr:BatchDeleteImage",
#      "ecr:SetRepositoryPolicy",
#      "ecr:DeleteRepositoryPolicy",
#    ]
#  }
#}
#
#resource "aws_iam_role_policy_attachment" "foopolicy" {
#  role = aws_ecr_repository.foo.name
#  policy_arn     = data.aws_iam_policy_document.foopolicy.json
#}