resource "azurerm_resource_group" "main" {
  name     = "rg-${var.root_name}"
  location = var.location
  tags     = var.tags
}
