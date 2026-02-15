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

variable "aks_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the future AKS cluster in this dev environment (for example, 1.29.0)."
}

variable "aks_admin_group_object_ids" {
  type        = list(string)
  description = "List of Azure AD group object IDs that will have admin access to the future AKS cluster."
}

variable "aks_api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "List of authorized IP ranges for the AKS API server in the dev environment. Restrict to trusted office/VPN ranges."
  default     = []
}

variable "log_analytics_retention_in_days" {
  type        = number
  description = "Retention period in days for future Log Analytics used by this environment."

  validation {
    condition     = var.log_analytics_retention_in_days >= 30
    error_message = "Log Analytics retention for dev must be at least 30 days to remain operationally useful."
  }
}

variable "aks_system_node_vm_size" {
  type        = string
  description = "VM size for the dev AKS system node pool (capacity decision)."
}

variable "aks_system_node_max_pods" {
  type        = number
  description = "Maximum pods per node for the dev AKS system node pool (capacity decision)."

  validation {
    condition     = var.aks_system_node_max_pods >= 30
    error_message = "The maximum pods per node should be at least 30 for AKS system nodes."
  }
}

variable "aks_node_pool_max_surge" {
  type        = string
  description = "Max surge during dev AKS node pool upgrades (for example, 33% or 1)."
}

variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Whether the future dev AKS cluster uses a private API endpoint (exposure strategy)."
}

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
