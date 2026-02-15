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
