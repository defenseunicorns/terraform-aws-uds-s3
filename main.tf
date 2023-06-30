
local {
  create_irsa = var.create_irsa ? 1 : 0
}

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

module "irsa" {
  count                             = local.create_irsa
  source                            = "git@github.com:defenseunicorns/terraform-aws-uds-irsa?ref=irsa-migrate"
  bucket_arn                        = module.s3_bucket.s3_bucekt_arn
  bucket_id                         = module.s3_bucket.s3_bucekt_id
  irsa_iam_role_name                = var.irsa_iam_role_name
  irsa_iam_role_path                = var.irsa_iam_role_path
  irsa_iam_permissions_boundary_arn = var.irsa_iam_permissions_boundary_arn
  kubernetes_namespace              = var.kubernetes_namespace
  kubernetes_service_account        = var.kubernetes_service_account
  name_prefix                       = var.name_prefix
  policy_name_suffix                = var.policy_name_suffix
}
