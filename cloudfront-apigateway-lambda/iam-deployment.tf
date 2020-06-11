data "aws_iam_policy_document" "deployment-role-policy" {
  statement {
    sid       = "PublishLayer"
    actions   = [
      "lambda:PublishLayerVersion"
    ]
    resources = [
      "${aws_lambda_function.lambda.arn}"
    ]
  }

  statement {
    sid       = "ManageLayerVersions"
    actions   = [
      "lambda:GetLayerVersion",
      "lambda:DeleteLayerVersion"
    ]
    resources = [
      "${aws_lambda_function.lambda.arn}:*"
    ]
  }

  statement {
    sid       = "ReadAndWriteToS3"
    actions   = [
      "s3:GetObject",
      "s3:PutObject"      
    ]
    resources = [
      "arn:aws:s3:::${var.s3_artefact_bucket}/${var.function_name}/${var.envtype}/*"
    ]
  }

  statement {
    sid       = "ReadS3BootstrapFunction"
    actions   = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_artefact_bucket}/${var.s3_lambda_function_path}"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.function_name}-${var.envname}-deployment-policy"
  description = "Assume role policy to deploy ${var.function_name}-${var.envname}"
  policy      = "${data.aws_iam_policy_document.deployment-role-policy.json}"
}

data "aws_iam_policy_document" "deployment-role-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "deployment-role" {
  name = "${var.function_name}-${var.envname}-deployment-role"
  assume_role_policy = "${data.aws_iam_policy_document.deployment-role-assume-policy.json}"

  tags = "${var.default_tags}"
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = "${aws_iam_role.deployment-role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
