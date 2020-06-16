variable "envtype" {}
variable "envname" {}
variable "region" {}

variable "s3_artefact_bucket" {}
variable "s3_lambda_function_path" {}

variable "lambda_handler" {}
variable "lambda_runtime" {}

variable "subdomain" {}
variable "hosted_zone" {}

variable "function_name" {}

variable "default_tags" {
  type    = map
  default = {}
}

