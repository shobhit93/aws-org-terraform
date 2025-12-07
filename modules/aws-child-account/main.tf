provider "aws" {
  alias  = "child"
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.child_account_id}:role/OrganizationAccountAccessRole"
    session_name = "TerraformChildAccount"
  }
}

# GuardDuty
resource "aws_guardduty_detector" "default" {
  provider = aws.child
  enable   = true
}

# GitHub OIDC Role
resource "aws_iam_role" "github_role" {
  provider = aws.child
  name     = var.github_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.child_account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  })
}

# IAM Policy: create/update only, no delete
resource "aws_iam_role_policy" "deploy_policy" {
  provider = aws.child
  role     = aws_iam_role.github_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "*:Create*",
        "*:Put*",
        "*:Associate*",
        "*:Attach*",
        "*:Update*",
        "*:Start*",
        "*:Stop*",
        "*:Invoke*",
        "*:Describe*",
        "*:List*",
        "*:Get*",
        "*:Tag*"
      ],
      Resource = "*"
    }]
  })
}

# Budget $50 / month
resource "aws_budgets_budget" "monthly_budget" {
  provider     = aws.child
  name         = "monthly-limit"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}
