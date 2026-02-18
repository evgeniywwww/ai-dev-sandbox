#########################################################
# Workload Identity Module - Outputs
#########################################################
#
# PURPOSE:
#   Exposes identity attributes for Kubernetes service account
#   annotation and external reference.
#
# LAYER RESPONSIBILITY:
#   - Export identity client ID (for K8s SA annotation)
#   - Export principal ID (for additional RBAC if needed)
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "identity_id" {
  description = "Resource ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the User Assigned Identity. Use this in Kubernetes ServiceAccount annotation: azure.workload.identity/client-id."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Principal ID of the User Assigned Identity for additional RBAC assignments."
  value       = azurerm_user_assigned_identity.this.principal_id
}
