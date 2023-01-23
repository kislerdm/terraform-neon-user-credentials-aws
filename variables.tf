variable "region" {
  description = "AWS Region to provision the secrets and lambda function"
  type        = string
}

variable "rotate_after_days" {
  description = "How many days shall lapse to rotate the secret since the moment of its creation"
  type        = number
  default     = 1
  validation {
    condition     = var.rotate_after_days > 0
    error_message = "rotate_after_days shall be positive"
  }
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default     = {}
}

variable "user_credentials" {
  description = <<EOT
Neon user's access credential
Example:
  [{
  project_id = "myproject"
  branch_id  = "br-mybranch"
  host       = "myendpointuri
  dbname     = "mydb"
  user       = "myuser"
  password   = "foobarbaz"
}]
EOT

  type = list(object({
    # Neon project id, see details: https://neon.tech/docs/manage/projects/
    project_id = string
    # Neon branch, see details: https://neon.tech/docs/introduction/branching/
    branch_id = string
    # Endpoint URI to access database, see details: https://neon.tech/docs/manage/endpoints/
    host     = string
    dbname   = string
    user     = string
    password = string
    })
  )

  validation {
    condition     = length(var.user_credentials) > 0
    error_message = "at least one user's credentials must be provided"
  }
}

variable "token_arn" {
  description = <<EOT
    ARN of the secret with the Neon token to use to rotate the user's access credentials
    Note that the secret shall be of the format {"token": "API-TOKEN"}
  EOT
  type        = string
}

variable "kms_key_id" {
  description = "ARN of the KMS key to encrypt the secrets defined by var.user_credentials"
  type        = string
  default     = ""
}

variable "kms_key_arn_admin" {
  description = "ARN of the KMS key used to encrypt the admin secret specified by var.token_arn"
  type        = string
  default     = ""
}

variable "debug_mode" {
  description = "Activate debug level logs"
  type        = bool
  default     = false
}
