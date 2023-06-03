################ Cloudwatch Events ################

# Create a Cloudwatch Log Group to get the logs of the lambda function
resource "aws_cloudwatch_log_group" "process_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.process_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}