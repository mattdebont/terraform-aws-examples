# cloudfront-apigateway-lambda

Example Lambda deployment with an api-gateway being fronted by a cloudfront to enable
http -> https redirects plus some caching (not really configured in this example) as
API Gateway doesn't support http traffic.

## Input Variables

The input variables are stored in the `tfvars` folder (one for each environment);

The first lines define the environment name and type (envtype is used to name things
at present probably should switch over at some point).

    envname = "production"
    envtype = "production"

The script needs an s3 bucket source of the lambda code (this example is a simple
hello world that just returns `Hello World`). Source for this is under the `artefacts` 
folder, this script does not set up the bucket or permissions (assumes it already exists)

    s3_artefact_bucket = "lambda_artefacts_bucket"
    s3_lambda_function_path = "hello_world_example/hello_world_example_0.0.1.zip"

The following block defines some domain and ssl settings, this script assumes the cert
already exists as a *.example.com cert and the hosted zone has already been set up

    subdomain = "apigateway_lambda_prod_template"
    cert_subdomain = "*"
    hosted_zone = "example.com"
    function_name = "apigateway_lambda"

A default set of tags to apply to any resource that is capable of being tagged, you
can modify this on the fly in the script by merging but I haven't put an example of 
this in here;

    default_tags = {
        Project = "apigateway_lambda"
        BusinessOwner = "responsible@example.com"
        TechnicalOwner = "technical@example.com"
        Role = "lambda"
        Environment = "production"
    }

## Backend Remote State

You can set the backend remote state (stored in s3 for example) by modifying 
the make file to point to a backend.tfvars file in the working folder, i.e.

    init:
        rm -rf .terraform
        terraform get
        terraform init --backend-config=backend/backend.tfvars \

You can configure this to work with different environments by using an envname 
parameter, i.e.

    terraform init --backend-config=backend/backend.production.tfvars

Where in this case the envname would be production, so you would start the process using;

    make apply --ENVNAME production --ENVTYPE production

or a similar.

N.B. You will need to have a blank backend providers block in your terraform code, this will be in the providers.tf file i.e.;

    terraform {
        backend "s3" {
        }
    }