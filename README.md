# AWS Landing Zone Terraform Setup

This repository provisions a **cost-optimized AWS Landing Zone** using Terraform, creating an AWS Organization with Dev and Prod child accounts, applying SCPs, enabling CloudTrail and GuardDuty, creating GitHub OIDC roles for CI/CD, and setting a $50 monthly budget per child account.

---

## ✅ Features

- **AWS Organization** creation (root account automatically)
- **Dev and Prod child accounts**
- **Service Control Policies (SCPs)** to deny delete operations
- **Organization-wide CloudTrail**
- **GuardDuty** enabled in child accounts
- **GitHub OIDC IAM roles** for CI/CD deployments
- **Budget alert**: $50/month per account
- **Cost-optimized setup**, high-value security features only

---

## 📂 File Structure

aws-org-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── environments/
│   └── landing-zone.tfvars
├── modules/
│   └── aws-child-account/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf


other option --> WIP

terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── backend.tf
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
├── modules/
│   ├── account/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cloudtrail/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam_role/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf

Setup should look like this.
Root (shobhit93 AWS Organization) --> create it in github-web-identity repo
└── OU: Environments --> this here
    ├── Account: dev
    └── Account: prod



---

## 🏗 Architecture Description

- **Root Account**
  - Holds the **AWS Organization**.
  - **SCPs** applied at root level to deny delete actions.
  - **CloudTrail** S3 bucket for organization-wide logging.

- **Dev Account (Child)**
  - **GuardDuty** enabled
  - **GitHub OIDC IAM Role** for CI/CD
  - **$50 Monthly Budget** alert
  - Can create/update resources but cannot delete (SCP + IAM restrictions)

- **Prod Account (Child)**
  - **GuardDuty** enabled
  - **GitHub OIDC IAM Role** for CI/CD
  - **$50 Monthly Budget** alert
  - Can create/update resources but cannot delete (SCP + IAM restrictions)

---

## 🖼 Visual Diagram

                  ┌───────────────────────────┐
                  │       Root Account        │
                  │ (AWS Organization Master)│
                  │---------------------------│
                  │ SCPs: DenyDelete          │
                  │ CloudTrail (org-wide)     │
                  └─────────┬─────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
    ┌───────────────┐                 ┌───────────────┐
    │   Dev Account │                 │   Prod Account│
    │  (Child)      │                 │  (Child)      │
    │---------------│                 │---------------│
    │ GuardDuty     │                 │ GuardDuty     │
    │ GitHub OIDC   │                 │ GitHub OIDC   │
    │ IAM Role      │                 │ IAM Role      │
    │ Budget $50/mo │                 │ Budget $50/mo │
    │ Create/Update │                 │ Create/Update │
    │ No Delete     │                 │ No Delete     │
    └───────────────┘                 └───────────────┘
