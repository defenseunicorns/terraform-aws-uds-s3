output "bucket_id" {
  value = module.bucket.s3_bucket
}

data "aws_partition" "current" {}

module "bucket" {
  source = "../../"

  name_prefix                       = var.name_prefix
  create_irsa                       = var.create_irsa
  role_arn                          = var.create_irsa ? 0 : module.irsa[0].role_arn
  irsa_iam_role_name                = var.irsa_iam_role_name
  irsa_iam_permissions_boundary_arn = var.irsa_iam_permissions_boundary_arn
  eks_oidc_provider_arn             = var.eks_oidc_provider_arn
  kms_key_arn                       = module.kms_key.key_arn
  force_destroy                     = var.force_destroy
  create_bucket_lifecycle           = var.create_bucket_lifecycle
}

module "kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"
}

# The S3 bucket policy needs a real IAM role ARN to create successfully, so when create_irsa is set to false
# we need to create the IRSA resources via the IRSA module.
module "irsa" {
  count                         = var.create_irsa ? 0 : 1 // Only create when create_irsa = false
  source                        = "github.com/defenseunicorns/terraform-aws-uds-irsa?ref=v0.0.1"
  name                          = "create_irsa_false_role"
  provider_url                  = "oidc.eks.us-west-2.amazonaws.com/id/dummy-oidc-provider"
  oidc_fully_qualified_subjects = ["system:serviceaccount:logging:logging-loki"]
  policy_arns                   = [aws_iam_policy.loki_policy.arn]
}

resource "aws_iam_policy" "loki_policy" {
  name        = var.name_prefix
  path        = "/"
  description = "IAM policy for Loki to have necessary permissions to use S3 for storing logs."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:${data.aws_partition.current.partition}:s3:::${module.bucket.s3_bucket}"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:*Object"]
        Resource = ["arn:${data.aws_partition.current.partition}:s3:::${module.bucket.s3_bucket}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = [module.kms_key.key_arn]
      }
    ]
  })
}
