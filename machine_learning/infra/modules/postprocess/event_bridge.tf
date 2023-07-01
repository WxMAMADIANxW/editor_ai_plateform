resource "aws_cloudwatch_event_rule" "post_process_lambda_event_rule" {
  name = "postprocess-event-rule"
  description = "retry scheduled every 10 min"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "post_process_lambda_target" {
  arn = aws_lambda_function.postprocess_lambda.arn
  rule = aws_cloudwatch_event_rule.post_process_lambda_event_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_rw_fallout_retry_step_deletion_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postprocess_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.post_process_lambda_event_rule.arn
}