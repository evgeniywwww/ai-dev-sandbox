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
