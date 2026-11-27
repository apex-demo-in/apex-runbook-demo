data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# One customer-managed KMS key for the stack, reused by ECS Exec and CloudWatch Logs.
resource "aws_kms_key" "stack" {
  description             = "KMS key for the ${var.cluster_name} stack"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.name}.amazonaws.com" }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "stack" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.stack.key_id
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.0"

  cluster_name = var.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = aws_kms_key.stack.arn
      logging    = "OVERRIDE"
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = "/aws/ecs/${var.cluster_name}"
      }
    }
  }

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = var.log_retention_in_days
  cloudwatch_log_group_kms_key_id        = aws_kms_key.stack.arn

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  # Cluster only; services can be added later.
  services = {}
}
