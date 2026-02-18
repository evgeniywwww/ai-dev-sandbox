#########################################################
# Environment: dev - Outputs
#########################################################
#
# PURPOSE:
#   Exposes key infrastructure identifiers for external reference
#   and integration (CI/CD, other Terraform workspaces, etc.).
#
# LAYER RESPONSIBILITY:
#   - Export network resource IDs
#   - Minimal exposure (only what's needed externally)
#
# MUST NOT CONTAIN:
#   - Sensitive data without `sensitive = true`
#   - Raw resource objects (expose specific attributes only)
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "vnet_id" {
  description = "ID of the virtual network for the dev environment."
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network for the dev environment."
  value       = module.network.vnet_name
}

output "public_subnet_id" {
  description = "ID of the public subnet for the dev environment."
  value       = module.network.public_subnet_id
}

output "aks_subnet_id" {
  description = "ID of the private (AKS) subnet for the dev environment."
  value       = module.network.aks_subnet_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster for the dev environment."
  value       = module.aks.cluster_name
}

output "aks_kube_config" {
  description = "Kubernetes configuration for kubectl access to the dev AKS cluster. Treat as sensitive."
  value       = module.aks.kube_config
  sensitive   = true
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity integration."
  value       = module.aks.oidc_issuer_url
}

output "aks_managed_identity_principal_id" {
  description = "Principal ID of the AKS cluster's managed identity for RBAC assignments."
  value       = module.aks.managed_identity_principal_id
}

output "workload_identity_client_id" {
  description = "Client ID of the product workload identity. Use in Kubernetes ServiceAccount annotation: azure.workload.identity/client-id."
  value       = module.workload_identity.client_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault for application configuration."
  value       = module.key_vault.key_vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = module.key_vault.key_vault_name
}
