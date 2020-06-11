variable "envtype" {}
variable "envname" {}
variable "s3_artefact_bucket" {}
variable "s3_lambda_function_path" {}
variable "subdomain" {}
variable "cert_subdomain" {}
variable "hosted_zone" {}
variable "function_name" {}
variable "default_tags" {
  type = "map"
  default = {}
}

