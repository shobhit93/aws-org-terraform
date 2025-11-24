output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.trail_bucket.bucket
}

output "cloudtrail_id" {
  value = aws_cloudtrail.org_trail.id
}
