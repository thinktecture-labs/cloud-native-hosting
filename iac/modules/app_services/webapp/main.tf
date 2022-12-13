resource "azurerm_linux_web_app" "main" {
  name                = "as-${var.root_name}-linux-webapp"
  resource_group_name = var.group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    always_on                                     = true
    http2_enabled                                 = true
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.pull_identity_client_id
  }

}
