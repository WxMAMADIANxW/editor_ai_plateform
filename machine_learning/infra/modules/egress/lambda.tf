## Create me a aws_lambda_function resource for the s3-presigned-url function in Python
#resource "aws_lambda_function" "s3-egress-presigned-url-python" {
#  function_name    = "s3-egress-presigned-url-python"
#  filename         = "${path.cwd}/../egress/lambda_s3_egress_presigned_url.py.zip"
#  handler          = "lambda_s3_egress_presigned_url.lambda_handler"
#  source_code_hash = filebase64sha256("${path.cwd}/../egress/lambda_s3_egress_presigned_url.py.zip")
#  role             = aws_iam_role.lambda-s3-role.arn
#  runtime          = "python3.8"
#  environment {
#    variables = {
#      BUCKET_NAME = var.bucket_name
#      REGION      = var.region
#    }
#  }
#}
#
#variable "lambda_assume_role_policy_document" {
#  type        = string
#  description = "assume role policy document"
#  default     = <<-EOF
#   {
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Action": "sts:AssumeRole",
#          "Principal": {
#            "Service": "lambda.amazonaws.com"
#          },
#          "Effect": "Allow"
#        }
#      ]
#   }
#  EOF
#}
#resource "aws_iam_policy" "my-lambda-iam-policy" {
#  name        = "my-lambda-iam-policy"
#  path        = "/"
#  description = "My lambda policy - base"
#  policy      = <<-EOF
#    {
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Action": [
#            "logs:CreateLogGroup",
#            "logs:CreateLogStream",
#            "logs:PutLogEvents"
#          ],
#          "Effect": "Allow",
#          "Resource": "*"
#        }
#      ]
#    }
#  EOF
#}
#
#resource "aws_iam_role" "lambda-s3-role" {
#  name               = "my_lambda_iam_s3_role"
#  assume_role_policy = var.lambda_assume_role_policy_document
#}
#
#resource "aws_iam_role_policy_attachment" "base-role" {
#  role       = aws_iam_role.lambda-s3-role.name
#  policy_arn = aws_iam_policy.my-lambda-iam-policy.arn
#}
#
#data "aws_iam_policy" "s3-admin-policy" {
#  name = "AmazonS3FullAccess"
#}
#
#resource "aws_iam_role_policy_attachment" "s3-role" {
#  role       = aws_iam_role.lambda-s3-role.name
#  policy_arn = data.aws_iam_policy.s3-admin-policy.arn
#}
#
#resource "aws_lambda_permission" "apigw-permission" {
#  statement_id  = "AllowAPIInvoke"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.s3-egress-presigned-url-python.function_name
#  principal     = "apigateway.amazonaws.com"
#  # The /*/*/* part allows invocation from any stage, method and resource path
#  source_arn    = "${aws_apigatewayv2_api.s3download.execution_arn}/*/*/*"
#}