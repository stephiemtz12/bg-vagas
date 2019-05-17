terraform {
  required_version = "= 0.11.8"
}

provider "aws" {
  version    = "~> 1.24"
  region     = "sa-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_availability_zones" "available" {}
