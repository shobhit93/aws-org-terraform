variable "account_name" {}
variable "account_email" {}
variable "github_sub" {
  type = list(string)
}
variable "budget" {
  type = number
}
variable "enable_malware_scan" {
  type    = bool
  default = false
}
variable "malware_feed_url" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "management_role_arn" {
  description = "Optional role ARN in management account if not using root credentials"
  type        = string
  default     = ""
}
