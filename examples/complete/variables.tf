variable "create_bucket_lifecycle" {
  description = "If true, create a bucket lifecycle"
  type        = bool
  default     = false
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}
