resource "aws_api_gateway_rest_api" "apiGateway" {
  name               = "${var.app_name}-ingress-s3-proxy"
  description        = "${var.app_name} s3 proxy"
  binary_media_types = var.supported_binary_media_types
}

resource "aws_api_gateway_deployment" "s3-proxy-api-deployment-example" {
  depends_on = [
    "aws_api_gateway_integration.itemPutMethod-ApiProxyIntegration",
    "aws_api_gateway_integration.itemGetMethod-ApiProxyIntegration",
    "aws_api_gateway_integration.itemOptionsMethod-ApiProxyIntegration",
  ]

  rest_api_id = aws_api_gateway_rest_api.apiGateway.id

  stage_name = "${var.app_name}-stage"
}

resource "aws_api_gateway_usage_plan" "s3-proxy-usage-plan" {
  name        = "s3-proxy-ingress-${var.app_name}"
  description = "usage plan for s3 proxy"

  api_stages {
    api_id = aws_api_gateway_rest_api.apiGateway.id
    stage  = aws_api_gateway_deployment.s3-proxy-api-deployment-example.stage_name
  }
}

resource "aws_api_gateway_api_key" "s3-api-key" {
  name = "s3-proxy-ingress-apikey-${var.app_name}"

#  stage_key = {
#    rest_api_id = aws_api_gateway_rest_api.apiGateway.id
#    stage_name  = aws_api_gateway_deployment.s3-proxy-api-deployment-example.stage_name
#  }
}

resource "aws_api_gateway_usage_plan_key" "s3-proxy-usage-plan-key" {
  key_id        = aws_api_gateway_api_key.s3-api-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.s3-proxy-usage-plan.id
}