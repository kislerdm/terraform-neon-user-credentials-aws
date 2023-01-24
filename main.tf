terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  lambda_name = "neon"
  tag         = "v0.1.2"

  user_credentials = { for i in var.user_credentials : "${i.project_id}-${i.branch_id}-${i.dbname}-${i.user}" => i }
}

resource "aws_secretsmanager_secret" "this" {
  for_each                = local.user_credentials
  name                    = "neon/${each.value.project_id}/${each.value.branch_id}/${each.value.dbname}/${each.value.user}"
  recovery_window_in_days = 0
  kms_key_id              = var.kms_key_id
  tags = merge(var.default_tags, {
    database_provider = "neon"
  })
}

locals {
  secret_arns = [for i in aws_secretsmanager_secret.this : i.arn]
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = local.user_credentials
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode(each.value)
}

resource "aws_secretsmanager_secret_rotation" "this" {
  for_each            = local.user_credentials
  secret_id           = aws_secretsmanager_secret.this[each.key].id
  rotation_lambda_arn = aws_lambda_function.this.arn
  rotation_rules {
    automatically_after_days = var.rotate_after_days
  }
}

locals {
  kms_keys = concat([],
    var.kms_key_id == "" ? [] : [var.kms_key_id],
    var.kms_key_arn_admin == "" ? [] : [var.kms_key_arn_admin],
  )

  policy_kms_user = length(local.kms_keys) == 0 ? [] : [
    {
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]
      Resource = local.kms_keys
    }
  ]

  lambda_policy = {
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:DescribeSecret",
        ]
        Resource = local.secret_arns
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.token_arn]
      },
      ],
      local.policy_kms_user,
    )
  }
}

resource "aws_iam_policy" "this" {
  name   = "LambdaSecretRotation@neon-user"
  policy = jsonencode(local.lambda_policy)
}

resource "aws_iam_role" "this" {
  name = "secret-rotation@neon-user"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_neon" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 1
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "curl -SLo ${path.module}/lambda.zip https://github.com/kislerdm/aws-lambda-secret-rotation/releases/download/plugin%2F${local.lambda_name}%2F${local.tag}/aws-lambda-secret-rotation_${local.lambda_name}_${local.tag}.zip"
  }
}

data "local_file" "this" {
  filename   = "${path.module}/lambda.zip"
  depends_on = [null_resource.this]
}

resource "aws_lambda_function" "this" {
  function_name = local.lambda_name
  role          = aws_iam_role.this.arn

  filename         = data.local_file.this.filename
  source_code_hash = base64sha256(data.local_file.this.content_base64)
  runtime          = "go1.x"
  handler          = "lambda"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      NEON_TOKEN_SECRET_ARN = var.token_arn
      DEBUG                 = var.debug_mode ? "true" : "false"
    }
  }
}

resource "aws_lambda_permission" "secretsmanager" {
  for_each      = local.user_credentials
  statement_id  = "rotation-${local.lambda_name}-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.this[each.key].arn
}
