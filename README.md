# Terraform module to manage credentials of Neon users using AWS Secretsmanager

The module provisions the secret, its initial version, and the rotation rule which relies of defined AWS Lambda
function.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_neon](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [null_resource.this](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [local_file.this](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_debug_mode"></a> [debug\_mode](#input\_debug\_mode) | Activate debug level logs | `bool` | `false` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags | `map(string)` | `{}` | no |
| <a name="input_kms_key_arn_admin"></a> [kms\_key\_arn\_admin](#input\_kms\_key\_arn\_admin) | ARN of the KMS key used to encrypt the admin secret specified by var.token\_arn | `string` | `""` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key to encrypt the secrets defined by var.user\_credentials | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to provision the secrets and lambda function | `string` | n/a | yes |
| <a name="input_rotate_after_days"></a> [rotate\_after\_days](#input\_rotate\_after\_days) | How many days shall lapse to rotate the secret since the moment of its creation | `number` | `1` | no |
| <a name="input_token_arn"></a> [token\_arn](#input\_token\_arn) | ARN of the secret with the Neon token to use to rotate the user's access credentials<br>    Note that the secret shall be of the format {"token": "API-TOKEN"} | `string` | n/a | yes |
| <a name="input_user_credentials"></a> [user\_credentials](#input\_user\_credentials) | Neon user's access credential<br>Example:<br>  [{<br>  project\_id = "myproject"<br>  branch\_id  = "br-mybranch"<br>  host       = "myendpointuri<br>  dbname     = "mydb"<br>  user       = "myuser"<br>  password   = "foobarbaz"<br>}] | <pre>list(object({<br>    # Neon project id, see details: https://neon.tech/docs/manage/projects/<br>    project_id = string<br>    # Neon branch, see details: https://neon.tech/docs/introduction/branching/<br>    branch_id = string<br>    # Endpoint URI to access database, see details: https://neon.tech/docs/manage/endpoints/<br>    host     = string<br>    dbname   = string<br>    user     = string<br>    password = string<br>    })<br>  )</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN of the AWS Lambda used to rotate credentials |
| <a name="output_user_credentials"></a> [user\_credentials](#output\_user\_credentials) | Map of the users credentials<br>{ "{{ .project\_id }}-{{ .branch\_id }}-{{ .dbname }}-{{ .user }}" : {{ .credentials\_arn }} } |
<!-- END_TF_DOCS -->