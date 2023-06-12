################ Policies ################

# Create the Lambda IAM policy
data "aws_iam_policy_document" "policy_lambda_iam" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create the S3 IAM role
data "aws_iam_policy_document" "policy_s3" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:*",
      "ses:*",
    ]
  }
}

# Create the IAM Role for the Cloudwatch logs
resource "aws_iam_policy" "process_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Create the IAM Role for the Cloudwatch attachment logs
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.lambda_iam.id
  policy_arn = aws_iam_policy.process_logging_policy.arn
}
