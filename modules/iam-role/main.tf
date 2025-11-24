# -------------------------------------------------
# GitHub Actions OIDC Provider
# -------------------------------------------------
# NOTE:
# This is account-level and safe to create once per account.
# If it already exists, Terraform will manage it.
# -------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# -------------------------------------------------
# Least Privilege IAM Role for GitHub Actions
# -------------------------------------------------
resource "aws_iam_role" "this" {
  name = var.role_name

  description = "Least privilege role assumed by GitHub Actions via OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "GitHubOIDCTrust",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_sub
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# -------------------------------------------------
# Inline Least Privilege Policy
# -------------------------------------------------
resource "aws_iam_role_policy" "this" {
  name   = "${var.role_name}-policy"
  role  = aws_iam_role.this.id
  policy = var.policy_json
}
