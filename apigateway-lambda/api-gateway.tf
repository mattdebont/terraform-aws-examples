resource "aws_apigatewayv2_api" "api" {
  name          = "${var.function_name}-${var.envtype}-api-gateway"
  description   = "Terraform controlled API Gateway for ${var.function_name}-${var.envtype} lambda"
  protocol_type = "HTTP"
  tags          = "${var.default_tags}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                    = "${aws_apigatewayv2_api.api.id}"
  integration_type          = "AWS_PROXY"
  connection_type           = "INTERNET"

  description               = "Terraform controlled API Gateway for ${var.function_name}-${var.envtype} lambda"
  integration_method        = "POST"
  integration_uri           = "${aws_lambda_function.lambda.invoke_arn}"
  passthrough_behavior      = "WHEN_NO_MATCH"  
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/$default"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = "${aws_apigatewayv2_api.api.id}"
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = "${aws_apigatewayv2_route.route.api_id}"
  description = "Terraform Deployment"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id        = "${aws_apigatewayv2_api.api.id}"
  name          = "${var.envtype}"
  deployment_id = "${aws_apigatewayv2_deployment.deployment.id}"
  tags          = "${var.default_tags}"

  # Temporary fix to bypass issued fixed in 
  # https://github.com/terraform-providers/terraform-provider-aws/pull/12904
  # fixed but not pulled into master release
  lifecycle {
    ignore_changes = [deployment_id, default_route_settings]
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  api_id      = "${aws_apigatewayv2_api.api.id}"
  domain_name = "${aws_apigatewayv2_domain_name.api_domain.id}"
  stage       = "${aws_apigatewayv2_stage.stage.id}"
}

data "aws_acm_certificate" "valid_cert" {
  domain   = "${var.cert_subdomain}.${var.hosted_zone}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "parent_zone" {
  name  = "${var.hosted_zone}."
}

resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name   = "${var.subdomain}.${var.hosted_zone}"
  tags          = "${var.default_tags}"

  domain_name_configuration {
    certificate_arn = "${data.aws_acm_certificate.valid_cert.arn}"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
