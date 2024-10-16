```
locals {
  location = "East US"
  tags = {
    Environment = "dev"
    Project     = "dev"
  }
}

resource "azurerm_resource_group" "kv_rg" {
  name     = "test"
  location = local.location
  tags     = local.tags
}

# resource "azurerm_management_lock" "rg-level-lock" {
#   count = var.resourcegroup_lock ? 1 : 0
#   name = "rg-level-lock"
#   scope = azurerm_resource_group.kv_rg.id
#   lock_level = "CanNotDelete"
# }

# module "log_analytics" {
#     (todo)
# }

module "key_vault" {
  source = "git::git@github.com:michalswi/kv.git?ref=main"

  location = local.location
  rg_name  = azurerm_resource_group.kv_rg.name
  tags     = local.tags

  # log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  # OR >> todo, remove later on
  enable_logs = false

  # todo - change to 'true' for prod
  purge_protection_enabled = false

  # todo - set number
  retention_days = 0

  # [optional] - [default]
  # enabled_for_deployment - false
  # enabled_for_disk_encryption - false
  # enabled_for_template_deployment - false
  # enable_rbac_authorization - true
  # purge_protection_enabled - true
}
```
