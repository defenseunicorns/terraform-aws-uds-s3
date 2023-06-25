# data "aws_kms_key" "default" {
#   key_id = var.kms_key_arn
# }

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
  # server_side_encryption_configuration = {
  #   rule = {
  #     apply_server_side_encryption_by_default = {
  #       kms_master_key_id = data.aws_kms_key.default.arn
  #       sse_algorithm     = "aws:kms"
  #     }
  #   }
  # }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.create_irsa ? 1 : 0
  bucket = module.s3_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Principal = {
          AWS = module.irsa[0].iam_role_arn
        }
        Resource = [
          module.s3_bucket.s3_bucket_arn,
          "${module.s3_bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })
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

data "aws_iam_policy_document" "irsa_policy" {
  count = var.create_irsa ? 1 : 0
  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket.s3_bucket_arn]
  }
  statement {
    actions   = ["s3:*Object"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
  }
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    # resources = [data.aws_kms_key.default.arn]
    resources = ["test::blank::arn"]
  }
}

module "irsa_policy" {
  count   = var.create_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.18.0"

  description = "IAM Policy for IRSA"
  name_prefix = "${var.name_prefix}-${var.policy_name_suffix}"
  policy      = data.aws_iam_policy_document.irsa_policy[0].json
}

module "irsa" {
  count   = var.create_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.18.0"

  role_name        = try(coalesce(var.irsa_iam_role_name, format("%s-%s-%s", var.name_prefix, trim(var.kubernetes_service_account, "-*"), "irsa")), null)
  role_description = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = [format("%s:%s", var.kubernetes_namespace, var.kubernetes_service_account)]
    }
  }

  role_path                     = var.irsa_iam_role_path
  force_detach_policies         = true
  role_permissions_boundary_arn = var.irsa_iam_permissions_boundary_arn

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count      = var.create_irsa ? 1 : 0
  policy_arn = module.irsa_policy[0].arn
  role       = module.irsa[0].iam_role_name
}
