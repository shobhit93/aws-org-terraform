variable "name" {}
variable "s3_bucket_name" {}
variable "enable_cloudwatch" { 
    type = bool
    default = false 
}
variable "cloudwatch_log_group_arn" { default = null }
variable "cloudwatch_role_arn" { default = null }
variable "enable_data_events" { 
    type = bool
    default = false 
}
variable "data_events" {
  type    = list(object({ type = string, values = list(string) }))
  default = []
}
