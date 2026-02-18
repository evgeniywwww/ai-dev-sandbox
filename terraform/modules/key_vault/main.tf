#########################################################
# Key Vault Module
#########################################################
#
# PURPOSE:
#   Creates Azure Key Vault with RBAC authorization model.
#   Does not create secrets, access policies, or network rules.
#
# LAYER RESPONSIBILITY:
#   - Key Vault resource creation
#   - RBAC authorization configuration
#   - Soft delete and purge protection settings
#
# MUST NOT CONTAIN:
#   - Hardcoded SKUs or retention periods
#   - Access policies (use RBAC)
#   - Environment-specific logic
#   - Secret creation
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (deterministic, explicit inputs)
#   Section 25: Key Vault Governance (RBAC model)
#
# RELATION TO OTHER MODULES:
#   - Root assigns RBAC roles to workload identities
#   - No direct module dependencies
#
#########################################################

resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  enable_rbac_authorization  = var.enable_rbac_authorization
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days

  tags = var.tags
}
