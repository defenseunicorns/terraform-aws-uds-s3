variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix to use when naming resources."
  type        = string
  default     = "ex-complete"
  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
}

variable "create_irsa" {
  description = "If true, create the IAM role and policy to be used in IRSA"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Whether or not to destroy items in the bucket when removing the bucket."
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "bucket tags"
}

variable "access_logging_enabled" {
  description = "If true, set up access logging of the S3 bucket to a different S3 bucket, provided by the variables `logging_bucket_id` and `logging_bucket_path`. Caution: Enabling this will likely cause LOTS of access logs, as one is generated each time the bucket is accessed and Loki will be hitting the bucket a lot!"
  type        = bool
  default     = false
}
