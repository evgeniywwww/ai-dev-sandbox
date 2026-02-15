#########################################################
# Network Module - Outputs
#########################################################
#
# PURPOSE:
#   Exposes minimal required attributes for root module
#   orchestration and security module integration.
#
# LAYER RESPONSIBILITY:
#   - Export VNet/subnet IDs for wiring
#   - Export NSG IDs for security module
#
# MUST NOT CONTAIN:
#   - Raw resource objects (expose specific attributes only)
#   - Internal implementation details
#
# STANDARDS ALIGNMENT:
#   Section 12: Security Module Architecture (NSG IDs for security module)
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = azurerm_subnet.public.id
}

output "aks_subnet_id" {
  description = "ID of the AKS (private) subnet."
  value       = azurerm_subnet.aks.id
}

output "public_nsg_id" {
  description = "ID of the public subnet NSG."
  value       = azurerm_network_security_group.public.id
}

output "private_nsg_id" {
  description = "ID of the private (AKS) subnet NSG."
  value       = azurerm_network_security_group.private.id
}
