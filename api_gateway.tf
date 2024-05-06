#API Gateway erstellen
resource "aws_api_gateway_rest_api" "gaestebuch_api" {
  name = "gaestebuch-api-${var.env}"
}

# API Gateway Resourcen erstellen
resource "aws_api_gateway_resource" "gaeste_erstellen" {
  parent_id = aws_api_gateway_rest_api.gaestebuch_api.root_resource_id
  path_part = "erstellen"
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
}

# API Gateway Resourcen erstellen
resource "aws_api_gateway_resource" "gaeste_loeschen" {
  parent_id = aws_api_gateway_rest_api.gaestebuch_api.root_resource_id
  path_part = "loeschen"
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
}

# API Gateway Methoden erstellen
resource "aws_api_gateway_method" "create_gast" {
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
  resource_id = aws_api_gateway_resource.gaeste_erstellen.id
  http_method = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "delete_gast" {
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
  resource_id = aws_api_gateway_resource.gaeste_loeschen.id
  http_method = "POST"
  authorization = "AWS_IAM"
  # request_parameters = {
  #   "method.request.querystring.id" = true
  # }
}

#API Gateway Integrationen erstellen
resource "aws_api_gateway_integration" "create_gast_integration" {
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
  resource_id = aws_api_gateway_resource.gaeste_erstellen.id
  http_method = aws_api_gateway_method.create_gast.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.gaestebuch_api.invoke_arn
}

resource "aws_api_gateway_integration" "delete_gast_integration" {
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
  resource_id = aws_api_gateway_resource.gaeste_loeschen.id
  http_method = aws_api_gateway_method.delete_gast.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.gaestebuch_api.invoke_arn
}

#API Gateway Deployment erstellen
resource "aws_api_gateway_deployment" "gaestebuch_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gaestebuch_api.id
  stage_name = var.env
  depends_on = [ aws_api_gateway_integration.create_gast_integration, aws_api_gateway_integration.delete_gast_integration]
}