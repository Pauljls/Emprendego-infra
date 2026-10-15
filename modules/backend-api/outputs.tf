output "api_url" {
  description = "URL base del API Gateway HTTP (para VITE_API_URL)."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "function_name" {
  description = "Nombre de la funcion Lambda."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN de la funcion Lambda."
  value       = aws_lambda_function.this.arn
}

output "alias_arn" {
  description = "ARN del alias 'live'."
  value       = aws_lambda_alias.live.arn
}

output "log_group_name" {
  description = "Nombre del log group en CloudWatch."
  value       = aws_cloudwatch_log_group.lambda.name
}
