# Organization outputs
output "org_root_id" {
  value = local.root_id
}

output "scp_deny_delete_id" {
  value = aws_organizations_policy.deny_delete.id
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.org_trail.arn
}

# Child account outputs
output "dev_github_role_arn" {
  value = module.dev_account.github_role_arn
}

output "prod_github_role_arn" {
  value = module.prod_account.github_role_arn
}
