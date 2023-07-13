# Examples Complete

Example of how to use this S3 module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.62.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket"></a> [bucket](#module\_bucket) | ../../ | n/a |
| <a name="module_irsa"></a> [irsa](#module\_irsa) | github.com/defenseunicorns/terraform-aws-uds-irsa | v0.0.1 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | terraform-aws-modules/kms/aws | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.test_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_bucket_lifecycle"></a> [create\_bucket\_lifecycle](#input\_create\_bucket\_lifecycle) | If true, create a bucket lifecycle | `bool` | `false` | no |
| <a name="input_create_irsa"></a> [create\_irsa](#input\_create\_irsa) | If true, create the IAM role and policy to be used in IRSA | `bool` | `true` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | EKS OIDC provider ARN. | `string` | `""` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether or not to destroy items in the bucket when removing the bucket. | `bool` | `true` | no |
| <a name="input_irsa_iam_permissions_boundary_arn"></a> [irsa\_iam\_permissions\_boundary\_arn](#input\_irsa\_iam\_permissions\_boundary\_arn) | IAM permissions boundary ARN. | `string` | `""` | no |
| <a name="input_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#input\_irsa\_iam\_role\_name) | IRSA role name. | `string` | `"ex-complete-irsa-role"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to use when naming resources. | `string` | `"ex-complete"` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role to be used in the S3 bucket policy | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
<!-- END_TF_DOCS -->