terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {}
}

# -------------------------------
# Management / Root Account
# -------------------------------
provider "aws" {
  alias  = "management"
  region = var.aws_region

  # Optional: if you have a dedicated management role instead of root credentials
  assume_role {
    role_arn = var.management_role_arn
  }
}

# -------------------------------
# Child Account (Dev / Prod)
# -------------------------------
provider "aws" {
  alias  = "child"
  region = var.aws_region

  assume_role {
    role_arn = module.iam_role.role_arn
  }
}

# -------------------------------
# Organization Home Region Provider
# -------------------------------

provider "aws" {
  alias  = "org_home"
  region = "ap-northeast-1"

  assume_role {
    role_arn = var.management_role_arn
  }
}

# -------------------------------
# Default AWS provider
# -------------------------------
provider "aws" {
  region = var.aws_region
}

locals {
  child_role_arn = "arn:aws:iam::${module.account.account_id}:role/OrganizationAccountAccessRole"
}

data "aws_caller_identity" "org_home" {
  provider = aws.org_home
}

data "aws_organizations_organization" "org" {
  provider = aws.management
}

# --------------------------
# 1️⃣ Organization (Root Account)
# --------------------------
module "organization" {
  providers = {
    aws = aws.management
  }
  source = "./modules/organization"
}

# --------------------------
# 2️⃣ Infra OU
# --------------------------
module "infra_ou" {
  source = "./modules/ou"
  providers = {
    aws = aws.management
  }
  name      = "Infra"
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# --------------------------
# 3️⃣ Org-level SCPs (minimal guardrails)
# --------------------------
module "org_scp" {
  source = "./modules/scp"
  providers = {
    aws = aws.management
  }
  # Example: SCPs for Org-level minimal guardrails
  target_id = module.infra_ou.ou_id
  depends_on = [module.organization]
}

# --------------------------
# 4️⃣ Org-level CloudTrail
# --------------------------
module "cloudtrail" {
  source = "./modules/cloudtrail_org"
  providers = {
    aws = aws.org_home
  }
  name               = "org-cloudtrail"
  data_events        = [] # Disabled by default
  enable_cloudwatch  = false
  enable_data_events = false
  s3_bucket_name     = "org-cloudtrail-logs-${data.aws_caller_identity.org_home.account_id}"
}

# --------------------------
# 5️⃣ AWS Account (Dev / Prod)
# --------------------------
module "account" {
  source = "./modules/account"
  providers = {
    aws = aws.management
  }
  name      = var.account_name
  email     = var.account_email
  parent_id = module.infra_ou.ou_id
}

# --------------------------
# 6️⃣ Account-level SCPs (deny delete for critical)
# --------------------------
module "scp" {
  source = "./modules/scp"
  providers = {
    aws = aws.management
  }
  target_id = module.account.account_id
  depends_on = [module.organization]
}

# --------------------------
# 7️⃣ IAM Role (Least Privilege)
# --------------------------
module "iam_role" {
  source = "./modules/iam-role"
  providers = {
    aws = aws.child
  }
  role_name   = "${var.account_name}-LeastPrivRole"
  github_sub  = var.github_sub
  policy_json = file("${path.module}/modules/iam-role/access.json")
}

# --------------------------
# 9️⃣ GuardDuty
# --------------------------
module "guardduty" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.child
  }
  enable_malware_scan = var.enable_malware_scan
  malware_feed_url    = var.malware_feed_url
}

# --------------------------
# 🔟 Budget
# --------------------------
module "budget" {
  source = "./modules/budget"
  providers = {
    aws = aws.child
  }
  name            = "${var.account_name}-Budget"
  limit           = var.budget
  alert_threshold = 80
  email           = var.account_email
}
