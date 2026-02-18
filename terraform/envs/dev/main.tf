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
  enable_nat_gateway  = var.enable_nat_gateway
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

#########################################################
# AKS Cluster
#########################################################

module "aks" {
  source = "../../modules/aks"

  cluster_name        = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_dns_prefix

  kubernetes_version = var.aks_kubernetes_version
  sku_tier           = var.aks_sku_tier

  private_cluster_enabled = var.aks_private_cluster_enabled

  vnet_subnet_id = module.network.aks_subnet_id

  system_node_pool_name = var.aks_system_node_pool_name
  system_node_vm_size   = var.aks_system_node_vm_size
  system_node_max_pods  = var.aks_system_node_max_pods
  node_pool_max_surge   = var.aks_node_pool_max_surge

  enable_auto_scaling  = var.enable_auto_scaling
  initial_node_count   = var.initial_node_count
  min_node_count       = var.min_node_count
  max_node_count       = var.max_node_count

  network_plugin = var.aks_network_plugin
  network_policy = var.aks_network_policy
  outbound_type  = var.aks_outbound_type

  api_server_authorized_ip_ranges = var.aks_api_server_authorized_ip_ranges

  oidc_issuer_enabled       = var.aks_oidc_issuer_enabled
  workload_identity_enabled = var.aks_workload_identity_enabled

  tags = local.common_tags
}

#########################################################
# Workload Identity (Product-Level)
#########################################################

module "workload_identity" {
  source = "../../modules/workload_identity"

  identity_name        = local.workload_identity_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  oidc_issuer_url      = module.aks.oidc_issuer_url
  namespace            = var.environment
  service_account_name = var.workload_identity_service_account_name
  tags                 = local.common_tags
}
