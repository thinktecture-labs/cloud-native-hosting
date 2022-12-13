resource "azurerm_windows_web_app" "main" {
  name                = "as-${var.root_name}-windows-webapp"
  resource_group_name = var.group_name
  service_plan_id     = var.service_plan_id
  location            = var.location

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_connection_string
  }
  site_config {
    always_on         = true
    http2_enabled     = true
    use_32_bit_worker = false
    application_stack {
      dotnet_version = "v6.0"
    }
  }
  tags = var.tags
}
