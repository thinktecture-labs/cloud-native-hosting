resource "azurerm_container_group" "main" {
  name                = "cg-${var.root_name}"
  location            = var.location
  resource_group_name = var.group_name
  ip_address_type     = "Public"
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.pull_identity_resource_id]
  }

  exposed_port = [{
    port     = 5000
    protocol = "TCP"
  }]

  container {
    name   = "main"
    image  = var.image
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  image_registry_credential {
    user_assigned_identity_id = var.pull_identity_resource_id
    server                    = "${var.acr_name}.azurecr.io"
  }

  tags = var.tags
}

