resource "azapi_resource" "aca" {
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = var.group_id
  location  = var.location
  name      = var.root_name
  identity {
    type         = "UserAssigned"
    identity_ids = [var.msi_resource_id]
  }
  body = jsonencode({
    properties : {
      managedEnvironmentId = var.container_app_environment_resource_id
      configuration = {
        registries = [
          {
            identity = var.msi_resource_id
            server   = "${var.acr_name}.azurecr.io"
          }
        ]
        ingress = {
          external   = true
          targetPort = 5000
        }
      }
      template = {
        containers = [
          {
            name  = "main"
            image = "nginx:alpine"
            resources = {
              cpu    = 0.5
              memory = "1.0Gi"
            }
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
        }
      }
    }
  })
  tags = var.tags
}
