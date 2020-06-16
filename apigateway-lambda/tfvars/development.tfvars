envname = "development"
envtype = "development"
region = "eu-west-1"

s3_artefact_bucket = "lambda-artefacts-bucket"
s3_lambda_function_path = "hello-world-example/hello-world-example-0.0.1.zip"

lambda_handler = "app.lambdaHandler"
lambda_runtime = "nodejs12.x"

subdomain = "dev-template"
cert_subdomain = "*"
hosted_zone = "example.com"
function_name = "apigateway_lambda"

default_tags = {
    Project = "apigateway_lambda"
    BusinessOwner = "responsible@example.com"
    TechnicalOwner = "technical@example.com"
    Role = "lambda"
    Environment = "development"
}