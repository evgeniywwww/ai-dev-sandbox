#########################################################
# Key Vault Module - Outputs
#########################################################
#
# PURPOSE:
#   Exposes Key Vault attributes for RBAC assignment
#   and external reference.
#
# LAYER RESPONSIBILITY:
#   - Export Key Vault ID (for RBAC scope)
#   - Export Key Vault URI (for application configuration)
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "key_vault_id" {
  description = "Resource ID of the Key Vault for RBAC assignments."
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault for application configuration."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}
