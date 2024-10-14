output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "azurerm_user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.id
}

# todo
# output "azurerm_key_vault_certificate_id" {
#   value = azurerm_key_vault_certificate.ag_cert.id
# }