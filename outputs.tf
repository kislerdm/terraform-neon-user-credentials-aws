output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "ARN of the AWS Lambda used to rotate credentials"
}

output "user_credentials" {
  value       = {for i in aws_secretsmanager_secret.this : i.name => i.arn}
  description = <<EOT
Map of the users credentials
{ "{{ .project_id }}-{{ .branch_id }}-{{ .dbname }}-{{ .user }}" : {{ .credentials_arn }} }
EOT
}
