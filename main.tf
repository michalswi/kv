locals {
  tags                       = var.tags
  name                       = var.name
  location                   = var.location
  rg_name                    = var.rg_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  sku_name                   = var.sku_name
  enable_logs                = var.enable_logs

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
}

data "azurerm_client_config" "current" {}

# diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.enable_logs == "true" ? 1 : 0

  name                       = "${local.name}-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = local.location
  resource_group_name = local.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = local.sku_name

  enabled_for_deployment          = local.enabled_for_deployment
  enabled_for_disk_encryption     = local.enabled_for_disk_encryption
  enabled_for_template_deployment = local.enabled_for_template_deployment
  enable_rbac_authorization       = local.enable_rbac_authorization
  purge_protection_enabled        = local.purge_protection_enabled

  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = data.azurerm_client_config.current.object_id

  #   key_permissions = [
  #     "Get",
  #     "List",
  #     "Delete",
  #     "Create",
  #     "Purge",
  #   ]

  #   secret_permissions = [
  #     "Get",
  #     "List",
  #     "Delete",
  #     "Set",
  #     "Purge",
  #   ]

  #   storage_permissions = [
  #     "Get",
  #   ]

  #   certificate_permissions = [
  #     "Get",
  #     "List",
  #     "Delete",
  #     "Create",
  #     "Purge",
  #   ]
  # }

  tags = local.tags
}

# resource "azurerm_key_vault_secret" "secret" {
#   name         = "secretname"
#   value        = "secretvalue"
#   key_vault_id = azurerm_key_vault.this.id
# }

# Managed Identity
resource "azurerm_user_assigned_identity" "this" {
  name                = "${local.name}-mi"
  resource_group_name = local.rg_name
  location            = local.location
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.this.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}

# RBAC
resource "azurerm_role_assignment" "secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "certifcates_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# todo
# resource "azurerm_key_vault_certificate" "ag_cert" {}
