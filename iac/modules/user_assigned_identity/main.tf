resource "azurerm_user_assigned_identity" "main" {
  name                = "id-${var.root_name}"
  resource_group_name = var.group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name = "AcrPull"
  scope                = var.acr_resource_id
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}
