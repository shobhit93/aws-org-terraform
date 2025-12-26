resource "aws_organizations_policy" "deny_delete_tagged" {
  name        = "DenytaggedDeletes"
  description = "Deny all delete actions across the organization with tags"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllDeletes"
        Effect   = "Deny"
        Action   = ["*:Delete*"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/priority": "critical"
          }
        }
      }
    ]
  })
}


resource "aws_organizations_policy_attachment" "attach_deny_delete_tagged" {
  policy_id = aws_organizations_policy.deny_delete_tagged.id
  target_id = var.target_id
}
