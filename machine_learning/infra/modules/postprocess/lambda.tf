################ Lambda ################

# Create the Lambda IAM resource
resource "aws_iam_role" "postprocess_lambda_iam" {
  #  name               = var.lambda_role_name
  name               = "${var.app_name}-postprocess-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.policy_lambda_iam.json
}

# Create the Lambda function
resource "aws_lambda_function" "postprocess_lambda" {
  depends_on = [
    null_resource.postprocess_ecr_image
  ]
  function_name = local.function_name_pipeline
  role          = aws_iam_role.postprocess_lambda_iam.arn
  image_uri     = "${aws_ecr_repository.postprocess_repo.repository_url}@${data.aws_ecr_image.postprocess_lambda_image.id}"
  package_type  = "Image"
  memory_size   = "10240"
  timeout       = "300"

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids = var.subnet_ids
  }

  environment {
    variables = {
      INPUT_BUCKET   = var.input_bucket_name
      OUTPUT_BUCKET  = local.final_bucket_name
      REGION         = var.region
      REDIS_HOST     = var.redis_host
      REDIS_PORT     = var.redis_port
      REDIS_PASSWORD = var.redis_password
      REDIS_USERNAME = var.redis_username
    }
  }
}

# Create the trigger from the S3 bucket to the Lambda function
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  depends_on = [
    aws_lambda_function.postprocess_lambda
  ]
  bucket = local.final_bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.postprocess_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mp4"
  }
}

# Create the Lambda function permissions
resource "aws_lambda_permission" "process-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postprocess_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.final_bucket_name}"
}

# Create an IAM Role for the S3 function
resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = local.lambda_iam_policy_name_pipeline
  role = aws_iam_role.postprocess_lambda_iam.id

  policy = data.aws_iam_policy_document.policy_s3.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.postprocess_lambda_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}