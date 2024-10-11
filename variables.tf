variable "tags" {
  description = "List of the Key Vault tags."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Key Vault name."
  type        = string
  default     = "1ad-kv"
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "rg_name" {
  description = "The name of an existing resource group to create the Key Vault in."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace id."
  type        = string
}

variable "sku_name" {
  description = "Specifies whether the Key Vault is standard or premium vault."
  type        = string
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Specifies whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Purge Protection enabled for Key Vault."
  type        = bool
  default     = true
}
