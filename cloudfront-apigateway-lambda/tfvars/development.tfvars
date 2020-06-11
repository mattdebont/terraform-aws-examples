envname = "development"
envtype = "development"

s3_artefact_bucket = "lambda-artefacts-bucket"
s3_lambda_function_path = "hello-world-example/hello-world-example-0.0.1.zip"

subdomain = "dev-template"
cert_subdomain = "*"
hosted_zone = "example.com"
function_name = "cloudfront_apigateway_lambda"

default_tags = {
    Project = "cloudfront_apigateway_lambda"
    BusinessOwner = "responsible@example.com"
    TechnicalOwner = "technical@example.com"
    Role = "lambda"
    Environment = "development"
}