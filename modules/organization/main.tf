resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
}

