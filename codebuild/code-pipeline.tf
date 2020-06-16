data "aws_cloudwatch_log_group" "codebuild_log_group" {
  name  = var.codebuild_log_group
}

data "aws_s3_bucket" "artifacts_bucket" {
  bucket  = var.s3_artifact_bucket
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid       = "CloudwatchLoggingPermissions"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${data.aws_cloudwatch_log_group.codebuild_log_group.arn}:${var.function_name}/*"
    ]
  }

  statement {
    sid       = "S3ArtifactBucketPermissions"
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = [
      "${data.aws_s3_bucket.artifacts_bucket.arn}/lambda/${var.function_name}/${var.envname}/*"
    ]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid       = "AllowCodeBuildToAssumeRole"
    actions   = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_secretsmanager_secret" "github_credential" {
  name  = var.secrets_github_credential_name
}

data "aws_secretsmanager_secret_version" "github_credential" {
  secret_id = data.aws_secretsmanager_secret.github_credential.id
}

resource "aws_iam_role" "build_role" {
  name                = "${var.function_name}-build-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "build_policy" {
  name        = "${var.function_name}-${var.envname}-build-policy"
  description = "CodeBuild permissions for ${var.function_name}-${var.envname}"
  policy      = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "build_policy_attachement" {
  role       = aws_iam_role.build_role.name
  policy_arn = aws_iam_policy.build_policy.arn
}

resource "aws_codebuild_source_credential" "github_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_secretsmanager_secret_version.github_credential.secret_string
}

resource "aws_codebuild_project" "build_steps" {
  name            = "${var.function_name}-build"
  description     = "CodeBuild project for ${var.function_name}"
  build_timeout   = "5"
  service_role    = aws_iam_role.build_role.arn
  source_version  = var.github_branch
  tags            = var.default_tags

  artifacts {
    type      = "S3"
    name      = "${var.function_name}.zip"
    location  = data.aws_s3_bucket.artifacts_bucket.id
    path      = "/lambda/${var.function_name}/${var.envname}/"
    packaging = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = data.aws_cloudwatch_log_group.codebuild_log_group.name
      stream_name = var.function_name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_url
    git_clone_depth = 1
    buildspec       = var.github_buildspec_path
    auth {
      type      = "OAUTH"
      resource  = aws_codebuild_source_credential.github_credential.arn
    }    
  }
}
