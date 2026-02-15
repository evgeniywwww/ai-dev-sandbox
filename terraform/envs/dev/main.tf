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

module "security_public" {
  source = "../../modules/security"

  nsg_id               = module.network.public_nsg_id
  resource_group_name  = var.resource_group_name
  security_rules       = var.security_rules_public
}

module "security_private" {
  source = "../../modules/security"

  nsg_id               = module.network.private_nsg_id
  resource_group_name  = var.resource_group_name
  security_rules       = var.security_rules_private
}
