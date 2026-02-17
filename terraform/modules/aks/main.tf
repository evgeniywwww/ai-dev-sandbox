#########################################################
# AKS Module - Kubernetes Cluster
#########################################################
#
# PURPOSE:
#   Defines Azure Kubernetes Service cluster with modern identity,
#   networking, and scaling configuration.
#
# LAYER RESPONSIBILITY:
#   - AKS cluster creation
#   - Node pool configuration
#   - Workload identity setup
#   - Network integration
#
# MUST NOT CONTAIN:
#   - Hardcoded capacity values
#   - Environment-specific logic
#   - Security policy (NSG rules)
#   - Naming logic (names passed from root)
#
# STANDARDS ALIGNMENT:
#   Section 8:  AKS Network Model
#   Section 14: Autoscaling Rules
#   Section 15: Module Philosophy (deterministic, explicit inputs)
#
# RELATION TO OTHER MODULES:
#   - Network module provides subnet IDs
#   - Root module passes all configuration
#
#########################################################

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  sku_tier = var.sku_tier

  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name                 = var.system_node_pool_name
    vm_size              = var.system_node_vm_size
    vnet_subnet_id       = var.vnet_subnet_id
    orchestrator_version = var.kubernetes_version
    type                 = "VirtualMachineScaleSets"
    
    # In azurerm v4.x, autoscaling is controlled by min_count and max_count only.
    # If both are set, autoscaling is enabled. If only node_count is set, autoscaling is disabled.
    node_count = var.enable_auto_scaling ? null : var.initial_node_count
    min_count  = var.enable_auto_scaling ? var.min_node_count : null
    max_count  = var.enable_auto_scaling ? var.max_node_count : null
    max_pods   = var.system_node_max_pods

    upgrade_settings {
      max_surge = var.node_pool_max_surge
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    load_balancer_sku = "standard"
    outbound_type     = var.outbound_type
  }

  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  tags = var.tags
}
