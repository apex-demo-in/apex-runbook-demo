# Public download bucket: anyone on the internet can read (GET) objects.
# Note: objects use SSE-S3 (AES256) rather than the stack KMS key, because
# anonymous readers cannot call KMS to decrypt SSE-KMS objects.

locals {
  public_bucket_name = "${var.public_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
}

data "aws_iam_policy_document" "public_downloads" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["arn:aws:s3:::${local.public_bucket_name}/*"]
  }
}

module "public_downloads" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket = local.public_bucket_name

  # Allow a public bucket policy (ACLs stay blocked; access is granted by policy).
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.public_downloads.json
  attach_deny_insecure_transport_policy = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "expire-noncurrent-versions"
      enabled = true

      noncurrent_version_expiration = {
        days = 90
      }

      abort_incomplete_multipart_upload_days = 7
    }
  ]
}
