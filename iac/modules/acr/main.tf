resource "azurerm_container_registry" "main" {
  name                = replace(var.root_name, "-", "")
  resource_group_name = var.group_name
  location            = var.location
  admin_enabled       = false
  sku                 = "Standard"
  tags                = var.tags
}
