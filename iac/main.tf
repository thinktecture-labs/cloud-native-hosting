locals {
  root_name = "tt-cn-hosting"
  location  = "germanywestcentral"
  tags = {
    "com.thinktecture.owner" = "thorsten.hans@thinktecture.com"
    "com.thinktecture.scope" = "Individual"
  }
}

module "rg" {
  source    = "./modules/resource_group"
  root_name = local.root_name
  location  = local.location
  tags      = local.tags
}

module "law" {
  source = "./modules/monitor/log_analytics_workspace"

  root_name  = local.root_name
  group_name = module.rg.name
  location   = local.location
  tags       = local.tags
}

module "acr" {
  source     = "./modules/acr"
  root_name  = local.root_name
  group_name = module.rg.name
  location   = local.location
  tags       = local.tags
}


module "msi_webapp" {
  source = "./modules/user_assigned_identity"

  root_name  = "${local.root_name}-webapp"
  group_name = module.rg.name
  location   = local.location

  acr_resource_id = module.acr.resource_id
  tags            = local.tags
}


module "msi_aci" {
  source = "./modules/user_assigned_identity"

  root_name  = "${local.root_name}-aci"
  group_name = module.rg.name
  location   = local.location

  acr_resource_id = module.acr.resource_id
  tags            = local.tags
}

module "msi_aca" {
  source          = "./modules/user_assigned_identity"
  root_name       = "${local.root_name}-aca"
  group_name      = module.rg.name
  acr_resource_id = module.acr.resource_id
  location        = local.location
  tags            = local.tags
}

module "service_plan_windows" {
  source = "./modules/app_services/plan"

  root_name = local.root_name
  os_type   = "Windows"

  group_name = module.rg.name
  location   = local.location
  tags       = local.tags
}

module "service_plan_linux" {
  source = "./modules/app_services/plan"

  root_name  = local.root_name
  os_type    = "Linux"
  group_name = module.rg.name
  location   = local.location
  tags       = local.tags
}

module "web_app_linux" {
  source = "./modules/app_services/webapp"

  root_name               = local.root_name
  service_plan_id         = module.service_plan_linux.resource_id
  pull_identity_client_id = module.msi_webapp.client_id
  group_name              = module.rg.name
  location                = local.location
  tags                    = local.tags
}

module "web_app_windows" {
  source = "./modules/app_services/webapp_windows"

  root_name       = local.root_name
  service_plan_id = module.service_plan_windows.resource_id
  group_name      = module.rg.name
  location        = local.location
  tags            = local.tags
}

module "cgroup" {
  source = "./modules/aci"

  root_name                 = local.root_name
  group_name                = module.rg.name
  acr_name                  = module.acr.name
  pull_identity_resource_id = module.msi_aci.resource_id
  location                  = local.location
  tags                      = local.tags
}

module "aks" {
  source     = "./modules/aks"
  root_name  = local.root_name
  group_name = module.rg.name
  location   = local.location
  tags       = local.tags
}

module "aca_env" {
  source    = "./modules/container_app/environment"
  root_name = local.root_name
  group_id  = module.rg.resource_id
  location  = local.location
  log_analytics = {
    workspace_id = module.law.workspace_id
    shared_key   = module.law.shared_key
  }
  tags = local.tags
}

module "aca" {
  source                                = "./modules/container_app/app"
  acr_name                              = module.acr.name
  container_app_environment_resource_id = module.aca_env.resource_id
  msi_resource_id                       = module.msi_aca.resource_id
  group_id                              = module.rg.resource_id
  root_name                             = local.root_name
  location                              = local.location
  tags                                  = local.tags
}
