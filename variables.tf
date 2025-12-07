# AWS Account
variable "github_role_name" {
  description = "Name of the GitHub OIDC role to create in the child account"
}
variable "notification_email" {
  description = "Email address for notifications"
}
variable "account_name" {
  description = "Name of the AWS account to create"
}

# Region for child accounts
variable "region" {
  description = "AWS region for the child account resources"
  default     = "us-east-1"
}

# CloudTrail bucket
variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
}
