output "lambda_function_source_code_size" {
  value = aws_lambda_function.lambda_function.source_code_size
}
output "lambda_layer_source_code_size" {
  value = aws_lambda_layer_version.lambda_layer.source_code_size
}