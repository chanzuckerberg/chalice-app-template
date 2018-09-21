terraform {
  backend "s3" {
  }
}

data "external" "aws_config" {
  program = ["make", "get-config"]
}

provider "aws" {
  access_key = "${data.external.aws_config.result.access_key}"
  secret_key = "${data.external.aws_config.result.secret_key}"
  token = "${data.external.aws_config.result.token}"
  region = "${data.external.aws_config.result.region}"
}

resource "aws_cloudformation_stack" "lambda" {
  name = "my-lambda"
  capabilities = ["CAPABILITY_IAM"]
  parameters {
  }
  
  template_body = "${file("dist/cloudformation.json")}"
}
