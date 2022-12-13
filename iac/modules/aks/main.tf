resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-${var.root_name}"
  location            = var.location
  resource_group_name = var.group_name
  node_resource_group = "${var.group_name}-aks"
  dns_prefix          = "cnhostingaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
