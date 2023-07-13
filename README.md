# UDS AWS S3

This module is provide a bucket for the needs of UDS. While the original intent is create a reusable module, the existance of this may become more specilized over time.



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.18.0 |
| <a name="module_irsa_policy"></a> [irsa\_policy](#module\_irsa\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.18.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | v3.10.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket_logging.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.bucket_policy_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logging_bucket_id"></a> [access\_logging\_bucket\_id](#input\_access\_logging\_bucket\_id) | The ID of the S3 bucket to which access logs are written | `string` | `null` | no |
| <a name="input_access_logging_bucket_prefix"></a> [access\_logging\_bucket\_prefix](#input\_access\_logging\_bucket\_prefix) | The prefix to use for all log object keys. Ex: 'logs/' | `string` | `"s3-irsa-bucket-access-logs/"` | no |
| <a name="input_access_logging_enabled"></a> [access\_logging\_enabled](#input\_access\_logging\_enabled) | If true, set up access logging of the S3 bucket to a different S3 bucket, provided by the variables `logging_bucket_id` and `logging_bucket_path`. Caution: Enabling this will likely cause LOTS of access logs, as one is generated each time the bucket is accessed and Loki will be hitting the bucket a lot! | `bool` | `false` | no |
| <a name="input_create_bucket_lifecycle"></a> [create\_bucket\_lifecycle](#input\_create\_bucket\_lifecycle) | If true, create a bucket lifecycle | `bool` | `false` | no |
| <a name="input_create_irsa"></a> [create\_irsa](#input\_create\_irsa) | If true, create the IAM role and policy to be used in IRSA | `bool` | `true` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | EKS OIDC Provider ARN e.g., arn:aws:iam::<ACCOUNT-ID>:oidc-provider/<var.eks\_oidc\_provider> | `string` | `""` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | Requires create\_bucket\_lifecycle; number of days before bucket data expires | `number` | `365` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | If true, destroys all objects in the bucket when the bucket is destroyed so that the bucket can be destroyed without error. Objects that are destroyed in this way are NOT recoverable. | `bool` | `false` | no |
| <a name="input_irsa_iam_permissions_boundary_arn"></a> [irsa\_iam\_permissions\_boundary\_arn](#input\_irsa\_iam\_permissions\_boundary\_arn) | IAM permissions boundary ARN for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#input\_irsa\_iam\_role\_name) | IAM role name for IRSA | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS Key ARN to use for encryption | `string` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace for IRSA | `string` | `"default"` | no |
| <a name="input_kubernetes_service_account"></a> [kubernetes\_service\_account](#input\_kubernetes\_service\_account) | Kubernetes service account for IRSA | `string` | `"default"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for all resources that use a randomized suffix | `string` | n/a | yes |
| <a name="input_policy_name_suffix"></a> [policy\_name\_suffix](#input\_policy\_name\_suffix) | IAM Policy name suffix | `string` | `"irsa-policy"` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role to be used in the S3 bucket policy | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_transition_days"></a> [transition\_days](#input\_transition\_days) | Requires create\_bucket\_lifecycle; number of days before transitioning to cold storage | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_role"></a> [irsa\_role](#output\_irsa\_role) | ARN of the IRSA Role |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | S3 Bucket Name |
<!-- END_TF_DOCS -->