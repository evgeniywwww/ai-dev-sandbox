#########################################################
# Environment: dev - Root Orchestration
#########################################################
#
# PURPOSE:
#   Orchestrates module instantiation for the dev environment.
#   Wires together network topology and security policy modules.
#
# LAYER RESPONSIBILITY:
#   - Module instantiation
#   - Module wiring and dependency management
#   - Passing policy values from tfvars to modules
#
# MUST NOT CONTAIN:
#   - Resource definitions (belong in modules)
#   - Policy logic (belongs in tfvars)
#   - Environment branching
#   - Hardcoded values
#
# STANDARDS ALIGNMENT:
#   Section 12: Security Module Architecture (separation)
#   Section 13: Azure Naming Governance (sanitized names from locals)
#   Section 15: Module Philosophy (root controls orchestration)
#
# MODULE DEPENDENCIES:
#   security_public  → depends on network.public_nsg_id
#   security_private → depends on network.private_nsg_id
#
#########################################################

#########################################################
# Network Topology
#########################################################

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

#########################################################
# Security Policy Application
#########################################################

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
