variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "github_sub" {
  description = "Allowed GitHub OIDC subject(s)"
  type        = list(string)
}

variable "policy_json" {
  description = "IAM policy JSON for least privilege access"
  type        = string
}
