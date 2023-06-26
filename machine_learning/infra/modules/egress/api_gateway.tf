resource "aws_apigatewayv2_api" "s3download" {
  name          = "s3download"
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_stage" "v1" {
  api_id      = aws_apigatewayv2_api.s3download.id
  name        = "v1"
  auto_deploy = true
}
resource "aws_apigatewayv2_integration" "s3download" {
  api_id             = aws_apigatewayv2_api.s3download.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "s3download presign url"
  integration_method = "GET"
  integration_uri    = aws_lambda_function.s3-egress-presigned-url-python.invoke_arn
}
resource "aws_apigatewayv2_route" "s3download" {
  api_id         = aws_apigatewayv2_api.s3download.id
  operation_name = "s3download"
  route_key      = "GET /url"
  target         = "integrations/${aws_apigatewayv2_integration.s3download.id}"
}