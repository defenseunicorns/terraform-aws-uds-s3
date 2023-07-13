variable "name_prefix" {
  description = "Name prefix for all resources that use a randomized suffix"
  type        = string
  validation {
    condition     = length(var.name_prefix) <= 37
    error_message = "Name Prefix may not be longer than 37 characters."
  }
}

variable "create_irsa" {
  description = "If true, create the IAM role and policy to be used in IRSA"
  type        = bool
  default     = true
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role to be used in the S3 bucket policy"
  default     = ""
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = ""
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary_arn" {
  description = "IAM permissions boundary ARN for IRSA roles"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN e.g., arn:aws:iam::<ACCOUNT-ID>:oidc-provider/<var.eks_oidc_provider>"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for IRSA"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account for IRSA"
  type        = string
  default     = "default"
}

// TODO: Evaluate whether we need this to be a variable
variable "policy_name_suffix" {
  description = "IAM Policy name suffix"
  type        = string
  default     = "irsa-policy"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN to use for encryption"
}

variable "access_logging_enabled" {
  description = "If true, set up access logging of the S3 bucket to a different S3 bucket, provided by the variables `logging_bucket_id` and `logging_bucket_path`. Caution: Enabling this will likely cause LOTS of access logs, as one is generated each time the bucket is accessed and Loki will be hitting the bucket a lot!"
  type        = bool
  default     = false
}

variable "access_logging_bucket_id" {
  description = "The ID of the S3 bucket to which access logs are written"
  type        = string
  default     = null
}

variable "access_logging_bucket_prefix" {
  description = "The prefix to use for all log object keys. Ex: 'logs/'"
  type        = string
  default     = "s3-irsa-bucket-access-logs/"
}

variable "force_destroy" {
  description = "If true, destroys all objects in the bucket when the bucket is destroyed so that the bucket can be destroyed without error. Objects that are destroyed in this way are NOT recoverable."
  type        = bool
  default     = false
}

variable "create_bucket_lifecycle" {
  description = "If true, create a bucket lifecycle"
  type        = bool
  default     = false
}

variable "transition_days" {
  description = "Requires create_bucket_lifecycle; number of days before transitioning to cold storage"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Requires create_bucket_lifecycle; number of days before bucket data expires"
  type        = number
  default     = 365
}