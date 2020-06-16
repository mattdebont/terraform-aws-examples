# CodeBuild Step Example

Example of a CodeBuild project to create an artifact for a lambda
function, the build output of which is pushed to S3. This example 
presumes that several pieces already exist;

## Cloudwatch Log Group

A Cloudwatch Log Group to put build logs into, you can create one
per build project or group them up, very much up to you on that.

## S3 Artifact Bucket

An S3 bucket to store built artifacts into.

## S3 Statefile Bucket

All of these scripts attempt to store their state into an S3 bucket, 
which must exist before you run this script.

## Github Access Token in AWS Secrets Manager

I have created a personal access token in a read only account for
GitHub, stored this in the AWS Secrets Manager as a plaintext secret
called `github-token` in this case, but that is configurable.

# Running the pipeline

The pipeline is configured to take in an environment paramenter via
a makefile, each environment is then linked to a file in tfvars / backend
by that name i.e. development -> `backend/backend.development.tfvars` / 
`tfvars/development.tfvars`. To run this from thid folder run the 
following;

    make apply ENVTYPE=development ENVNAME=development

The makefile understands `init`, `plan`, `apply` and `destroy`