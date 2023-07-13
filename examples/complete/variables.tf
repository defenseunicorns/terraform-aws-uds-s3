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
  default     = true
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role to be used in the S3 bucket policy"
  default     = ""
}

variable "irsa_iam_role_name" {
  description = "IRSA role name."
  type        = string
  default     = "ex-complete-irsa-role"
}

variable "irsa_iam_permissions_boundary_arn" {
  description = "IAM permissions boundary ARN."
  type        = string
  default     = ""
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  type        = string
  default     = ""
}

# variable "kms_key_arn" {
#   description = "KMS key ARN."
#   type        = string
#   default     = ""
# }

variable "force_destroy" {
  description = "Whether or not to destroy items in the bucket when removing the bucket."
  type        = bool
  default     = true
}

variable "create_bucket_lifecycle" {
  description = "If true, create a bucket lifecycle"
  type        = bool
  default     = false
}