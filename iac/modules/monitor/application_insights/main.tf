resource "azurerm_application_insights" "main" {
  name                = "ai-${var.root_name}"
  resource_group_name = var.group_name
  location            = var.location
  workspace_id        = var.log_analytics_workspace_resource_id
  tags                = var.tags
  application_type    = "web"
}
