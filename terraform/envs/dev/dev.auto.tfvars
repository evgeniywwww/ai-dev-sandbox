#########################################################
# Environment: dev - Policy Values (Single Source of Truth)
#########################################################
#
# PURPOSE:
#   Defines all environment-specific policy values for the dev environment.
#   This is the ONLY place where dev policy is defined.
#
# LAYER RESPONSIBILITY:
#   - Environment identity (project, location, etc.)
#   - Network topology policy (CIDRs)
#   - Security policy (NSG rules)
#   - Capacity decisions (VM sizes, scaling, retention)
#   - Tagging policy
#
# MUST NOT CONTAIN:
#   - Hardcoded credentials or secrets
#   - Logic or conditionals
#   - References to other environments
#
# STANDARDS ALIGNMENT:
#   Section 2.2: tfvars = Single Source of Truth
#   Section 12:  Security Module Architecture (rules defined here)
#   Section 13:  Azure Naming Governance (raw project_name sanitized in locals)
#
# NOTES:
#   - project_name may contain spaces/special chars; sanitized in locals.tf
#   - All values here are passed to modules via root main.tf
#   - Security rules are applied via security module
#
#########################################################

#############################
# Project & Environment
#############################

project_name = "Leads Market EKS Platform"
environment  = "dev"
location     = "westeurope"
resource_group_name = "rg-dev-aks"

#############################
# Networking
#############################

vnet_address_space = ["10.20.0.0/16"]
public_subnet_cidr = "10.20.0.0/24"
aks_subnet_cidr    = "10.20.1.0/24"

enable_nat_gateway = false

#############################
# Security (NSG rules)
#############################

security_rules_public = [
  {
    name                       = "allow-vnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  },
  {
    name                       = "allow-azure-lb-in"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  },
  {
    name                       = "allow-vnet-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "allow-internet-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
]

security_rules_private = [
  {
    name                       = "allow-vnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  },
  {
    name                       = "allow-azure-lb-in"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  },
  {
    name                       = "allow-vnet-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "allow-internet-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
]

#############################
# AKS Capacity
#############################

# Cluster Identity
aks_cluster_name            = "leads-market-aks-dev"
aks_dns_prefix              = "leads-market-dev"
aks_system_node_pool_name   = "system"
aks_kubernetes_version      = "1.29"

# Cost-Optimized SKU for Dev
aks_sku_tier = "Free"

# Public Cluster (Cost-Efficient Dev Setup)
aks_private_cluster_enabled = false

# API Access Restrictions
aks_api_server_authorized_ip_ranges = [
  "1.2.3.4/32",
]

# Node Pool Configuration (Budget-Friendly)
aks_system_node_vm_size   = "Standard_B2s"
aks_system_node_max_pods  = 110
aks_node_pool_max_surge   = "33%"

# Autoscaling
enable_auto_scaling  = true
min_node_count       = 1
max_node_count       = 2
initial_node_count   = 1

# Networking
aks_network_plugin = "azure"
aks_network_policy = "azure"
aks_outbound_type  = "loadBalancer"

# Modern Identity (Workload Identity)
aks_oidc_issuer_enabled       = true
aks_workload_identity_enabled = true

#############################
# Logging
#############################

log_analytics_retention_in_days = 60

#############################
# Tagging
#############################

common_tags = {
  owner       = "Yevhen Kutsolabskyi-team"
  managed_by  = "terraform"
}
