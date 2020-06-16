variable "envtype" {}
variable "envname" {}
variable "region" {}

variable "s3_artifact_bucket" {}
variable "s3_lambda_function_path" {}

variable "function_name" {}

variable "codebuild_log_group" {}
variable "ssm_github_credential_name" {}
variable "github_url" {}
variable "github_branch" {}
variable "github_buildspec_path" {}

variable "default_tags" {
  type    = map
  default = {}
}

