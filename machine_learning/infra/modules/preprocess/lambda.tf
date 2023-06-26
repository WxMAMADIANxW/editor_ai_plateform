################ Lambda ################

# Create the Lambda IAM resource
resource "aws_iam_role" "lambda_iam" {
  #  name               = var.lambda_role_name
  name               = "${var.app_name}-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.policy_lambda_iam.json
}

# Create the Lambda function
resource "aws_lambda_function" "preprocess_lambda" {
  depends_on = [
    null_resource.preprocess_ecr_image
  ]
  function_name = local.function_name_pipeline
  role          = aws_iam_role.lambda_iam.arn
  image_uri     = "${aws_ecr_repository.preprocess_repo.repository_url}@${data.aws_ecr_image.preprocess_lambda_image.id}"
  package_type  = "Image"
  memory_size   = "1024"
  timeout       = "300"
  environment {
    variables = {
      OUTPUT_BUCKET = local.splitted_bucket_name
    }
  }
}

# Create the trigger from the S3 bucket to the Lambda function
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = local.raw_bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.preprocess_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mp4"
  }
}

# Create the Lambda function permissions
resource "aws_lambda_permission" "process-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.preprocess_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.raw_bucket_name}"
}

# Create an IAM Role for the S3 function
resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = local.lambda_iam_policy_name_pipeline
  role = aws_iam_role.lambda_iam.id

  policy = data.aws_iam_policy_document.policy_s3.json
}