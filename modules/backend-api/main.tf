locals {
  base_env = {
    ENVIRONMENT       = "prod"
    DB_DRIVER         = "dsql"
    DSQL_HOST         = var.dsql_host
    DSQL_REGION       = "sa-east-1"
    DSQL_USER         = "admin"
    DEV_DB            = "postgres"
    CORS_ORIGINS      = var.frontend_url
    STREAK_TIMEZONE   = "America/Lima"
    SECRET_KEY        = var.secret_key
    GOOGLE_CLIENT_IDS = var.google_client_ids
  }

  environment_variables = merge(local.base_env, var.environment_variables)
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "dsql_connect" {
  statement {
    sid       = "ConnectToDsql"
    actions   = ["dsql:DbConnectAdmin"]
    resources = [var.dsql_cluster_arn]
  }
}

resource "aws_iam_role_policy" "dsql_connect" {
  name   = "${var.name}-dsql-connect"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.dsql_connect.json
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = aws_iam_role.lambda.arn
  handler          = "handler.handler"
  runtime          = var.runtime
  filename         = var.lambda_zip
  source_code_hash = filebase64sha256(var.lambda_zip)
  memory_size      = var.memory_size
  timeout          = var.timeout
  architectures    = [var.architecture]
  publish          = true

  reserved_concurrent_executions = var.reserved_concurrency

  snap_start {
    apply_on = var.enable_snap_start ? "PublishedVersions" : "None"
  }

  environment {
    variables = local.environment_variables
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.dsql_connect,
  ]
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  description      = "Alias estable que apunta a la ultima version publicada."
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_alias.live.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = var.timeout * 1000
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  qualifier     = aws_lambda_alias.live.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
