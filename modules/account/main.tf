resource "aws_organizations_account" "this" {
  name      = var.name
  email     = var.email
  role_name = var.iam_role_name
  parent_id = var.parent_id
}
