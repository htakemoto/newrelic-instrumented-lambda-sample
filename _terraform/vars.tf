variable "aws_account_id" {
  default = "0000000000"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "newrelic_account_id" {
  default = "0000000"
}

variable "app_name" {
  default = "newrelic-instrumented-sample"
}

variable "lambda_runtime" {
  default = "nodejs14.x"
}

variable "lambda_role_name" {
  default = "AWSLambdaBasicExecutionRole"
}