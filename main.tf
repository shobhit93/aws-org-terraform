terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.37"
    }
  }
}

# ----------------------------------------
# Root account provider
# ----------------------------------------
provider "aws" {
  alias  = "root"
  region = "us-east-1"
}

# ----------------------------------------
# 1️⃣ Create AWS Organization
# ----------------------------------------
resource "aws_organizations_organization" "org" {
  provider    = aws.root
  feature_set = "ALL"
}

# Fetch root ID dynamically
data "aws_organizations_organization" "current" {
  provider = aws.root
}

locals {
  root_id = data.aws_organizations_organization.current.roots[0].id
}

# ----------------------------------------
# 2️⃣ SCP to deny delete actions
# ----------------------------------------
resource "aws_organizations_policy" "deny_delete_iam" {
  provider = aws.root
  name     = "DenyDeleteIAM"
  type     = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Deny"
      Action   = [
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DeleteGroup",
        "iam:DeleteGroupPolicy",
        "iam:DeletePolicy",
        "iam:DeleteAccessKey",
        "iam:DeleteSigningCertificate",
        "iam:DeleteLoginProfile",
        "iam:DeleteAccountAlias",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:RemoveUserFromGroup"
      ]
      Resource = "*"
    }]
  })
}


resource "aws_organizations_policy_attachment" "attach_root" {
  provider  = aws.root
  policy_id = aws_organizations_policy.deny_delete_iam.id
  target_id = local.root_id
}

# ----------------------------------------
# 3️⃣ Organization-wide CloudTrail
# ----------------------------------------
resource "aws_s3_bucket" "trail_bucket" {
  provider = aws.root
  bucket   = var.cloudtrail_bucket_name
}

resource "aws_cloudtrail" "org_trail" {
  provider                      = aws.root
  name                          = "org-trail"
  is_organization_trail         = true
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
}

# ----------------------------------------
# 4️⃣ Create account
# ----------------------------------------
resource "aws_organizations_account" "account" {
  provider  = aws.root
  name      = var.account_name
  email     = var.notification_email
  role_name = "OrganizationAccountAccessRole"
}

# ----------------------------------------
# 5️⃣ Deploy child account resources via modules
# ----------------------------------------
module "aws_account" {
  source           = "./modules/aws-child-account"
  child_account_id = aws_organizations_account.account.id
  github_role_name = var.github_role_name
  notification_email = var.notification_email
}
