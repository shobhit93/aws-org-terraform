resource "aws_budgets_budget" "budget" {
  name        = var.name
  budget_type = "COST"
  limit_amount = var.limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = var.alert_threshold
    threshold_type      = "PERCENTAGE"
    subscriber_email_addresses = [var.email]
  }
}
