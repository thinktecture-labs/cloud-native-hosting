locals {
  sku_name = "P1v2"
}

resource "azurerm_service_plan" "main" {
  name                = "asp-${var.root_name}-${lower(var.os_type)}"
  os_type             = var.os_type
  resource_group_name = var.group_name
  location            = var.location
  sku_name            = local.sku_name
  tags                = var.tags
}
