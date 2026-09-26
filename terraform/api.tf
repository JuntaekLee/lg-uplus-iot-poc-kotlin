resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# --- GET /status ---
resource "aws_apigatewayv2_integration" "get_status" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_status.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_status" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /status"
  target    = "integrations/${aws_apigatewayv2_integration.get_status.id}"
}

resource "aws_lambda_permission" "apigw_get_status" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- POST /command ---
resource "aws_apigatewayv2_integration" "set_command" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.set_command.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "set_command" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /command"
  target    = "integrations/${aws_apigatewayv2_integration.set_command.id}"
}

resource "aws_lambda_permission" "apigw_set_command" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.set_command.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- GET /device-metadata ---
resource "aws_apigatewayv2_integration" "get_device_metadata" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_device_metadata.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_device_metadata" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /device-metadata"
  target    = "integrations/${aws_apigatewayv2_integration.get_device_metadata.id}"
}

resource "aws_lambda_permission" "apigw_get_device_metadata" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_device_metadata.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

output "api_base_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
