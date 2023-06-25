output "bucket_id" {
  value = module.bucket.s3_bucket
}

module "bucket" {
  source = "../../"

  name_prefix           = var.name_prefix
  create_irsa           = var.create_irsa
  force_destroy         = var.force_destroy
  tags                  = var.tags
  eks_oidc_provider_arn = "arn::blank::test"
}

