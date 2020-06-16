provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias = "us_east_1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
  }
}