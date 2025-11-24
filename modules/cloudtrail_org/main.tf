resource "aws_s3_bucket" "trail_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "trail_bucket_acl" {
  bucket = aws_s3_bucket.trail_bucket.id
  acl    = "private"
}

resource "aws_cloudtrail" "org_trail" {
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  is_organization_trail         = true
  include_global_service_events = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    dynamic "data_resource" {
      for_each = var.enable_data_events ? var.data_events : []
      content {
        type   = data_resource.value.type
        values = data_resource.value.values
      }
    }
  }

  cloud_watch_logs_group_arn = var.enable_cloudwatch ? var.cloudwatch_log_group_arn : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch ? var.cloudwatch_role_arn : null
}
