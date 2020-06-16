envname = "production"
envtype = "production"
region = "eu-west-1"

s3_artefact_bucket = "lambda-artefacts-bucket"
s3_lambda_function_path = "hello-world-example/hello-world-example-0.0.1.zip"

function_name = "example-lambda-function"

codebuild_log_group = "/aws/codebuild"
ssm_github_credential_name = "github-token"
github_url = "https://github.com/example/repo.git"
github_buildspec_path = "buildspec.yml"
github_branch = "master"

default_tags = {
    Project = "codebuild"
    BusinessOwner = "responsible@example.com"
    TechnicalOwner = "technical@example.com"
    Role = "codebuild"
    Environment = "production"
}