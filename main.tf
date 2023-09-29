provider "aws" {
  region = "us-west-2"
}

# ecr
resource "aws_ecr_repository" "ontra_repository" {
  name = var.name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ecr_access_policy"
  description = "Allows to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability"],
        Resource = aws_ecr_repository.ontra_repository.arn
      }
    ]
  })
}


# lambda
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# policy to allow lambda to write to cloudwatch
resource "aws_iam_policy" "lambda_cloudwatch_logs_policy" {
  name        = "LambdaCloudWatchLogsPolicy"
  description = "Allows Lambda to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_policy" {
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# add ecr access policy to the lambda
resource "aws_iam_role_policy_attachment" "attach_ecr_access_policy" {
  policy_arn = aws_iam_policy.ecr_access_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# add iam role to the lambda
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# create our lambda
resource "aws_lambda_function" "ontra_lambda" {
  function_name = var.name
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  architectures = ["arm64"]
  image_uri     = "${aws_ecr_repository.ontra_repository.repository_url}:${var.image_tag}"
}

# Create REST API
resource "aws_api_gateway_rest_api" "ontra_api" {
  name        = "OntraAPI"
  description = "API for Ontra Lambda Function"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create /time resource
resource "aws_api_gateway_resource" "time_resource" {
  rest_api_id = aws_api_gateway_rest_api.ontra_api.id
  parent_id   = aws_api_gateway_rest_api.ontra_api.root_resource_id
  path_part   = "time"
}

# Create GET method for /time resource
resource "aws_api_gateway_method" "time_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.ontra_api.id
  resource_id   = aws_api_gateway_resource.time_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrate GET method with Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.ontra_api.id
  resource_id = aws_api_gateway_resource.time_resource.id
  http_method = aws_api_gateway_method.time_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ontra_lambda.invoke_arn
}

# Deploy API
resource "aws_api_gateway_deployment" "ontra_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.ontra_api.id
  stage_name  = "v1"
}

# Grant API Gateway permissions to invoke Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ontra_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.ontra_api.execution_arn}/*/*"
}

