
resource "azapi_resource" "main" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = "acaenv-${var.root_name}"
  parent_id = var.group_id
  location  = var.location
  tags      = var.tags
  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.log_analytics.workspace_id
          sharedKey  = var.log_analytics.shared_key
        }
      }
    }
  })
}

