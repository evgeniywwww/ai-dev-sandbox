module "network" {
  source = "../../modules/network"

  vnet_name           = local.network_policy.vnet_name
  address_space       = var.vnet_address_space
  public_subnet_name  = local.network_policy.public_subnet_name
  public_subnet_cidr  = var.public_subnet_cidr
  aks_subnet_name     = local.network_policy.aks_subnet_name
  aks_subnet_cidr     = var.aks_subnet_cidr
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}
