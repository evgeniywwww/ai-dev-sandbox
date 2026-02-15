#########################################################
# AKS Module - Outputs
#########################################################
#
# PURPOSE:
#   Exposes AKS cluster identifiers and credentials for
#   external integration and configuration.
#
# LAYER RESPONSIBILITY:
#   - Export cluster identifiers
#   - Export OIDC issuer for workload identity
#   - Export managed identity principal for RBAC
#   - Export kubeconfig (sensitive)
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "cluster_id" {
  description = "ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes configuration for kubectl access. Treat as sensitive."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "managed_identity_principal_id" {
  description = "Principal ID of the AKS cluster's managed identity for RBAC assignments."
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity for additional RBAC scenarios."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
