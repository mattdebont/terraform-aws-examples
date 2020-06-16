data "aws_iam_policy_document" "lambda_exec_assume_role_policy" {
  statement {
    sid     = "AllowLambdaToAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name                = "lambda-${var.function_name}-${var.envtype}-executor-role"
  tags                = var.default_tags
  assume_role_policy  = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}

resource "aws_lambda_function" "lambda" {
  function_name   = "${var.function_name}-${var.envtype}"

  s3_bucket       = var.s3_artefact_bucket
  s3_key          = var.s3_lambda_function_path

  handler         = var.lambda_handler
  runtime         = var.lambda_runtime

  role            = aws_iam_role.lambda_exec_role.arn
  tags            = var.default_tags
}

# resource "aws_kms_key" "a" {
#   description             = "Log Group KMS key for ${aws_lambda_function.lambda.function_name}"
#   deletion_window_in_days = 10
# }


resource "aws_cloudwatch_log_group" "lambda-log-group" {
  name                = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days   = "7"
  # kms_key_id          = 
  tags                = var.default_tags
}

data "aws_iam_policy_document" "log-group-access" {
  statement {
    sid       = "WriteToLogGroup"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda-log-group.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda-log-group-policy" {
  name        = "${var.function_name}-${var.envname}-log-group-policy"
  description = "Log Group permissions for ${var.function_name}-${var.envname}"
  policy      = data.aws_iam_policy_document.log-group-access.json
}

resource "aws_iam_role_policy_attachment" "log_group_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda-log-group-policy.arn
}
