locals {
  enable_logs = var.enable_logs

  tags                       = var.tags
  name                       = var.name
  location                   = var.location
  rg_name                    = var.rg_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  sku_name                   = var.sku_name
  retention_days             = var.retention_days

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
}

data "azurerm_client_config" "current" {}

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
  name                = local.name
  location            = local.location
  resource_group_name = local.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = local.sku_name

  purge_protection_enabled   = local.purge_protection_enabled
  soft_delete_retention_days = local.retention_days

  enabled_for_deployment          = local.enabled_for_deployment
  enabled_for_disk_encryption     = local.enabled_for_disk_encryption
  enabled_for_template_deployment = local.enabled_for_template_deployment
  enable_rbac_authorization       = local.enable_rbac_authorization

  public_network_access_enabled = true

  # to consider:
  # network_acls {
  #   default_action = "Deny"
  #   bypass         = "AzureServices"
  # }

  tags = local.tags
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

# resource "azurerm_key_vault_certificate" "this" {
#   name         = "default"
#   key_vault_id = azurerm_key_vault.this.id

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = true
#     }

#     lifetime_action {
#       action {
#         action_type = "AutoRenew"
#       }

#       trigger {
#         days_before_expiry = 30
#       }
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }

#     x509_certificate_properties {
#       subject            = "CN=example-cert"
#       validity_in_months = 12
#       key_usage = [
#         "keyEncipherment",
#         "digitalSignature",
#       ]
#     }
#   }
# }
