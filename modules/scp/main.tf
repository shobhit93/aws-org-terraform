resource "aws_organizations_policy" "deny_delete_tagged" {
  name        = "DenyDeletesWithoutTag-${var.target_id}"
  description = "Deny all delete actions across the organization unless the resource has tag nodelete"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Deny",
        Action   = [
          "s3:DeleteObject",
          "ec2:TerminateInstances",
          "rds:DeleteDBInstance",
          "dynamodb:DeleteTable",
          "lambda:DeleteFunction",
        ],
        Resource = "*",
        Condition = {
          Null = {
            "aws:RequestTag/nodelete" = true,
          },
        },
      },
    ],
  })
}

resource "aws_organizations_policy_attachment" "attach_deny_delete_tagged" {
  policy_id = aws_organizations_policy.deny_delete_tagged.id
  target_id = var.target_id
}
