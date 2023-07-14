output "bucket_name" {
  description = "S3 Bucket Name"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "S3 Bucket ARN"
  value       = module.s3_bucket.s3_bucket_arn
}
