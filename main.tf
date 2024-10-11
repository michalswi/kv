locals {
  tags                       = var.tags
  name                       = var.name
  location                   = var.location
  rg_name                    = var.rg_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  sku_name                   = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
}

data "azurerm_client_config" "current" {}

# diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "this" {
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

# RBAC
resource "azurerm_role_assignment" "secrets" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "certifcates" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Certificates"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "secretname"
  value        = "secretvalue"
  key_vault_id = azurerm_key_vault.this.id
}
