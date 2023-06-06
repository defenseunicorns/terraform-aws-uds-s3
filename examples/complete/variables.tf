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
