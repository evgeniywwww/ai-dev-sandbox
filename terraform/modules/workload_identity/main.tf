#########################################################
# Workload Identity Module
#########################################################
#
# PURPOSE:
#   Creates Azure User Assigned Identity and federates it
#   with AKS OIDC for pod-to-Azure authentication.
#
# LAYER RESPONSIBILITY:
#   - User Assigned Identity creation
#   - Federated Identity Credential (OIDC binding)
#
# MUST NOT CONTAIN:
#   - Hardcoded namespace or service account names
#   - Environment-specific logic
#   - RBAC assignments (handled separately)
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (deterministic, explicit inputs)
#   Section 23.2: AKS Identity Model (workload identity)
#
# RELATION TO OTHER MODULES:
#   - AKS module provides oidc_issuer_url
#   - Root defines namespace (uses environment name)
#
#########################################################

resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "${var.identity_name}-federated"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  
  issuer   = var.oidc_issuer_url
  subject  = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
  audience = ["api://AzureADTokenExchange"]
}
