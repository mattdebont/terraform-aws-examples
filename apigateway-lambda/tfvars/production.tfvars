envname = "production"
envtype = "production"

s3_artefact_bucket = "lambda_artefacts_bucket"
s3_lambda_function_path = "hello_world_example/hello_world_example_0.0.1.zip"

subdomain = "apigateway_lambda_prod_template"
cert_subdomain = "*"
hosted_zone = "example.com"
function_name = "apigateway_lambda"

default_tags = {
    Project = "apigateway_lambda"
    BusinessOwner = "responsible@example.com"
    TechnicalOwner = "technical@example.com"
    Role = "lambda"
    Environment = "production"
}