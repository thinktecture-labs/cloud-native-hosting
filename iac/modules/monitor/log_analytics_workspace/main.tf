resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.root_name}"
  resource_group_name = var.group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 60
  tags                = var.tags
}
