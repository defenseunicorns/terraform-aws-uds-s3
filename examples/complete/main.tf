output "bucket_id" {
  value = module.bucket.s3_bucket
}

module "bucket" {
  source = "../../"

  name_prefix                       = var.name_prefix
  create_irsa                       = var.create_irsa
  irsa_iam_role_name                = var.irsa_iam_role_name
  irsa_iam_permissions_boundary_arn = var.irsa_iam_permissions_boundary_arn
  eks_oidc_provider_arn             = var.eks_oidc_provider_arn
  kms_key_arn                       = module.kms_key.key_arn
  force_destroy                     = var.force_destroy
}

module "kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"
}
