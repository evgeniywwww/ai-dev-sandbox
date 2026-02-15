#########################################################
# AKS Module - Input Variables
#########################################################
#
# PURPOSE:
#   Defines the contract for the AKS module.
#   All inputs are required unless explicitly optional.
#
# LAYER RESPONSIBILITY:
#   - Type definitions
#   - Input validation
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default values (policy decisions)
#   - Environment-specific logic
#   - Hardcoded values
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 15:  Module Philosophy (explicit inputs)
#
#########################################################

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster."
}

variable "location" {
  type        = string
  description = "Azure region for the AKS cluster."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where AKS will be created."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS API server."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the AKS cluster and system node pool."
}

variable "sku_tier" {
  type        = string
  description = "SKU tier for the AKS cluster. Use 'Free' for dev/test, 'Standard' or 'Premium' for production."

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be one of: Free, Standard, Premium."
  }
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Whether to create a private AKS cluster with private API endpoint. False allows public endpoint."
}

variable "system_node_vm_size" {
  type        = string
  description = "VM size for the system node pool."
}

variable "vnet_subnet_id" {
  type        = string
  description = "ID of the subnet where AKS nodes will be deployed."
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable autoscaling for the system node pool."
}

variable "initial_node_count" {
  type        = number
  description = "Initial number of nodes in the system node pool."

  validation {
    condition     = var.initial_node_count >= 1
    error_message = "initial_node_count must be at least 1."
  }
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes when autoscaling is enabled."

  validation {
    condition     = var.min_node_count >= 1
    error_message = "min_node_count must be at least 1."
  }
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes when autoscaling is enabled."

  validation {
    condition     = var.max_node_count >= 1
    error_message = "max_node_count must be at least 1."
  }
}

variable "system_node_max_pods" {
  type        = number
  description = "Maximum pods per node in the system node pool."

  validation {
    condition     = var.system_node_max_pods >= 30
    error_message = "system_node_max_pods should be at least 30."
  }
}

variable "node_pool_max_surge" {
  type        = string
  description = "Max surge during node pool upgrades (e.g., 33% or 1)."
}

variable "network_plugin" {
  type        = string
  description = "Network plugin for AKS (azure or kubenet)."

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "network_plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  type        = string
  description = "Network policy plugin for AKS (azure, calico, or cilium)."

  validation {
    condition     = contains(["azure", "calico", "cilium", "none"], var.network_policy)
    error_message = "network_policy must be one of: azure, calico, cilium, none."
  }
}

variable "outbound_type" {
  type        = string
  description = "Outbound routing method for AKS (loadBalancer, userDefinedRouting, or managedNATGateway)."

  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting", "managedNATGateway"], var.outbound_type)
    error_message = "outbound_type must be one of: loadBalancer, userDefinedRouting, managedNATGateway."
  }
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "List of authorized IP ranges for accessing the AKS API server. Empty list disables restriction (not recommended)."
  default     = []
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "Enable OIDC issuer for workload identity integration."
}

variable "workload_identity_enabled" {
  type        = bool
  description = "Enable Azure AD Workload Identity for pod authentication (modern approach)."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the AKS cluster."
}
