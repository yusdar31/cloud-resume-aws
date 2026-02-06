# --- API Gateway Configuration ---
# Replaces Lambda Function URL to avoid browser blocking issues

# 1. REST API
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "visitor-counter-api"
  description = "API for visitor counter functionality"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# 2. Resource: /count
resource "aws_api_gateway_resource" "count" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "count"
}

# 3. Method: GET /count
resource "aws_api_gateway_method" "get_count" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.count.id
  http_method   = "GET"
  authorization = "NONE"
}

# 4. Method: OPTIONS /count (for CORS preflight)
resource "aws_api_gateway_method" "options_count" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.count.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# 5. Integration: GET -> Lambda
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = aws_api_gateway_resource.count.id
  http_method             = aws_api_gateway_method.get_count.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

# 6. Integration: OPTIONS -> Mock (for CORS)
resource "aws_api_gateway_integration" "options_mock" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count.id
  http_method = aws_api_gateway_method.options_count.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# 7. Method Response: OPTIONS 200
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count.id
  http_method = aws_api_gateway_method.options_count.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# 8. Integration Response: OPTIONS
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count.id
  http_method = aws_api_gateway_method.options_count.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_mock]
}

# 9. Lambda Permission: Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"
}

# 10. Deployment: Production Stage
resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id

  triggers = {
    # Redeploy when any of these resources change
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.count.id,
      aws_api_gateway_method.get_count.id,
      aws_api_gateway_integration.lambda_get.id,
      aws_api_gateway_method.options_count.id,
      aws_api_gateway_integration.options_mock.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_get,
    aws_api_gateway_integration.options_mock,
    aws_api_gateway_integration_response.options_integration_response,
  ]
}

# 11. Stage: prod
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  stage_name    = "prod"

  # Optional: Enable CloudWatch logging
  xray_tracing_enabled = false

  # Optional: Throttling settings
  # throttle_settings {
  #   rate_limit  = 100
  #   burst_limit = 200
  # }
}
