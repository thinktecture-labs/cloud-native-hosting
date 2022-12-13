output "resource_id" {
  value = azurerm_user_assigned_identity.main.id
}

output "name" {
  value = azurerm_user_assigned_identity.main.name
}

output "client_id" {
  value = azurerm_user_assigned_identity.main.client_id
}
