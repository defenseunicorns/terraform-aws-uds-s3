output "bucket_name" {
  value = module.bucket.bucket_name
}

module "bucket" {
  source = "../../"

  name_prefix             = "uds-s3-test"
  kms_key_arn             = module.kms_key.key_arn
  force_destroy           = true
  create_bucket_lifecycle = var.create_bucket_lifecycle
}

module "kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"
}
