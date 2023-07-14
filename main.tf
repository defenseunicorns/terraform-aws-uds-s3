data "aws_kms_key" "default" {
  key_id = var.kms_key_arn
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.10.1"

  bucket_prefix           = var.name_prefix
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = var.force_destroy
  lifecycle_rule = var.create_bucket_lifecycle ? [
    {
      id     = "ten-year-expiration"
      status = "enabled"

      transition = {
        days          = var.transition_days
        storage_class = "GLACIER"
      }

      expiration = {
        days = var.expiration_days
      }
    }
  ] : []

  tags = var.tags
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_key.default.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = module.s3_bucket.s3_bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = var.access_logging_enabled ? 1 : 0

  bucket        = module.s3_bucket.s3_bucket_id
  target_bucket = var.access_logging_bucket_id
  target_prefix = var.access_logging_bucket_prefix

  depends_on = [module.s3_bucket.s3_bucket_id]

  lifecycle {
    precondition {
      condition     = var.access_logging_bucket_id != null && var.access_logging_bucket_prefix != null
      error_message = "access_logging_bucket_id and access_logging_bucket_path must be set to enable access logging."
    }
  }
}
