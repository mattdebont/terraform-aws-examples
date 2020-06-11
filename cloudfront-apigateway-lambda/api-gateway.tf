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

data "aws_route53_zone" "parent_zone" {
  name  = "${var.hosted_zone}."
}

resource "aws_acm_certificate" "cert" {
  provider          = "aws.us-east-1"
  domain_name       = "${var.subdomain}.${var.hosted_zone}"
  validation_method = "DNS"

  tags              = "${var.default_tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.parent_zone.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = "aws.us-east-1"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_cloudfront_distribution" "api_fronting" {
  aliases                 = ["${var.subdomain}.${var.hosted_zone}"]
  enabled                 = true

  origin {
    domain_name           = "${aws_apigatewayv2_api.api.api_endpoint}"
    origin_id             = "${aws_apigatewayv2_api.api.name}-origin"
    origin_path           = "/${aws_apigatewayv2_stage.stage.name}"
    
    custom_origin_config {
      http_port               = "80"
      https_port              = "443"
      origin_protocol_policy  = "https-only"
      origin_ssl_protocols    = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_apigatewayv2_api.api.name}-origin"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }  

  viewer_certificate {
    cloudfront_default_certificate  = false
    acm_certificate_arn             = "${aws_acm_certificate_validation.cert.certificate_arn}"
    minimum_protocol_version        = "TLSv1.2_2018"
    ssl_support_method              = "sni-only"

  }

  restrictions {
    geo_restriction {
      restriction_type  = "none"
    }
  }  

  http_version            = "http2"
  tags                    = "${var.default_tags}"
}

resource "aws_route53_record" "api_record" {
  name    = "${var.subdomain}.${var.hosted_zone}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.parent_zone.id}"

  alias {
    evaluate_target_health  = false
    name                    = "${aws_cloudfront_distribution.api_fronting.domain_name}"
    zone_id                 = "${aws_cloudfront_distribution.api_fronting.hosted_zone_id}"
  }
}
