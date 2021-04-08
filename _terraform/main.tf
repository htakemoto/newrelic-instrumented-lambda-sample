# Variables

locals {
  app_name = var.app_name
  lambda_name = local.app_name
  lambda_runtime = var.lambda_runtime
  lambda_role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.lambda_role_name}"
  newrelic_account_id = var.newrelic_account_id
}

# Layer Prep

resource "null_resource" "layer_prep" {
  triggers = {
    "always_run" = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ./layer/nodejs/*
      mkdir -p ./layer/nodejs
      cp ../package.json ../package-lock.json ./layer/nodejs
      npm --prefix ./layer/nodejs ci --production
    EOT
  }
}

# Lambda Code Prep

data "archive_file" "lambda_layer_zip" {
  type = "zip"
  source_dir = "./layer"
  output_path = "./layer.zip"

  depends_on = [
    null_resource.layer_prep
  ]
}

data "archive_file" "lambda_function_zip" {
  type = "zip"
  source_dir = "../src"
  output_path = "./function.zip"
}

# Lambda

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "${local.lambda_name}-layer"
  filename = data.archive_file.lambda_layer_zip.output_path
  source_code_hash = filebase64sha256("../package-lock.json")
  compatible_runtimes = [local.lambda_runtime]
}

resource "aws_lambda_function" "lambda_function" {
  function_name = local.lambda_name
  filename = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]
  handler = "newrelic-lambda-wrapper.handler"
  memory_size = 128
  runtime = local.lambda_runtime
  timeout = 3
  role = local.lambda_role_arn

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
      NEW_RELIC_ACCOUNT_ID = local.newrelic_account_id
      NEW_RELIC_LAMBDA_HANDLER = "index.handler"
    }
  }
}

resource "aws_cloudwatch_log_group" "newrelic_instrumented_sample_log_group" {
  name = "/aws/lambda/${local.lambda_name}"
  # Lambda functions will auto-create their log group on first execution, but it retains logs forever, which can get expensive.
  retention_in_days = 7
}