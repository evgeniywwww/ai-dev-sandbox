#########################################################
# Environment: dev - Input Variables (Contract)
#########################################################
#
# PURPOSE:
#   Defines the contract for all dev environment inputs.
#   All values are supplied via dev.auto.tfvars.
#
# LAYER RESPONSIBILITY:
#   - Type definitions
#   - Self-contained validation
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default values (policy decisions belong in tfvars)
#   - Environment-specific logic
#   - Hardcoded values
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 2.2: tfvars = Single Source of Truth
#
# NOTES:
#   - Security rules are defined in tfvars and passed to security module
#   - Cross-variable validation uses check blocks (checks.tf)
#
#########################################################

#########################################################
# Environment Identity
#########################################################

variable "location" {
  type        = string
  description = "Azure region for the dev environment (for example, westeurope or eastus)."
}

variable "environment" {
  type        = string
  description = "Environment name (for example, dev, test, prod). Used for naming and tagging."
}

variable "project_name" {
  type        = string
  description = "Short identifier for the project or platform, used in resource names and tags."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing Azure Resource Group where all dev resources will be deployed."
}

variable "common_tags" {
  type        = map(string)
  description = "Tags applied to all resources in the dev environment. Must include owner and any environment-specific tags."
}

#########################################################
# Networking
#########################################################

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network in CIDR notation."
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR prefix dedicated for the public subnet that provides internet-facing connectivity."

  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "The public subnet CIDR must be a valid IPv4 CIDR prefix."
  }
}

variable "aks_subnet_cidr" {
  type        = string
  description = "CIDR prefix dedicated for the private subnet that will host AKS node pools."

  validation {
    condition     = can(cidrnetmask(var.aks_subnet_cidr))
    error_message = "The AKS subnet CIDR must be a valid IPv4 CIDR prefix."
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT Gateway for private subnet outbound connectivity. Required for production AKS; optional for dev/test."
}

#########################################################
# Security Policy (NSG Rules)
#########################################################

variable "security_rules_public" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "Security rules applied to the public subnet NSG. Defined in tfvars per environment."
}

variable "security_rules_private" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "Security rules applied to the private (AKS) subnet NSG. Defined in tfvars per environment."
}

#########################################################
# AKS Configuration (future)
#########################################################

variable "aks_cluster_name" {
  type        = string
  description = "Name of the AKS cluster for this environment."
}

variable "aks_dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS API server endpoint."
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the AKS cluster."
}

variable "aks_sku_tier" {
  type        = string
  description = "SKU tier for the AKS cluster (Free for dev, Standard/Premium for prod)."
}

variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Whether to create a private AKS cluster. False enables public API endpoint."
}

variable "aks_system_node_vm_size" {
  type        = string
  description = "VM size for the AKS system node pool (capacity decision)."
}

variable "aks_system_node_max_pods" {
  type        = number
  description = "Maximum pods per node for the AKS system node pool (capacity decision)."

  validation {
    condition     = var.aks_system_node_max_pods >= 30
    error_message = "The maximum pods per node should be at least 30 for AKS system nodes."
  }
}

variable "aks_node_pool_max_surge" {
  type        = string
  description = "Max surge during AKS node pool upgrades (for example, 33% or 1)."
}

variable "aks_network_plugin" {
  type        = string
  description = "Network plugin for AKS (azure or kubenet)."
}

variable "aks_network_policy" {
  type        = string
  description = "Network policy for AKS (azure, calico, cilium)."
}

variable "aks_outbound_type" {
  type        = string
  description = "Outbound routing method for AKS (loadBalancer, userDefinedRouting, managedNATGateway)."
}

variable "aks_api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "List of authorized IP ranges for the AKS API server. Restrict to trusted office/VPN ranges."
  default     = []
}

variable "aks_oidc_issuer_enabled" {
  type        = bool
  description = "Enable OIDC issuer for workload identity."
}

variable "aks_workload_identity_enabled" {
  type        = bool
  description = "Enable Azure AD Workload Identity for pod authentication."
}

variable "log_analytics_retention_in_days" {
  type        = number
  description = "Retention period in days for future Log Analytics used by this environment."

  validation {
    condition     = var.log_analytics_retention_in_days >= 30
    error_message = "Log Analytics retention for dev must be at least 30 days to remain operationally useful."
  }
}

#########################################################
# Autoscaling
#########################################################

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable autoscaling for the AKS system node pool."
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes in the AKS system node pool when autoscaling is enabled."

  validation {
    condition     = var.min_node_count >= 1
    error_message = "min_node_count must be at least 1."
  }
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes in the AKS system node pool when autoscaling is enabled."

  validation {
    condition     = var.max_node_count >= 1
    error_message = "max_node_count must be at least 1."
  }
}

variable "initial_node_count" {
  type        = number
  description = "Initial number of nodes in the AKS system node pool at create time."

  validation {
    condition     = var.initial_node_count >= 1
    error_message = "initial_node_count must be at least 1."
  }
}
