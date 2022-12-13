resource "azurerm_container_registry" "main" {
  name                = replace(var.root_name, "-", "")
  resource_group_name = var.group_name
  location            = var.location
  admin_enabled       = false
  sku                 = "Premium"
  tags                = var.tags
}

resource "azurerm_container_registry_token" "main" {
  name                    = "GitHubActions"
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = var.group_name
  enabled                 = true
  scope_map_id            = data.azurerm_container_registry_scope_map.main.id
}

data "azurerm_container_registry_scope_map" "main" {
  name                    = "_repositories_pull"
  resource_group_name     = var.group_name
  container_registry_name = azurerm_container_registry.main.name
}
