#############################
# Project & Environment
#############################

project_name = "platform"
environment  = "dev"
location     = "westeurope"
resource_group_name = "rg-dev-aks"

#############################
# Networking
#############################

vnet_address_space = ["10.20.0.0/16"]
public_subnet_cidr = "10.20.0.0/24"
aks_subnet_cidr    = "10.20.1.0/24"

#############################
# AKS Capacity
#############################

aks_kubernetes_version = "1.29.0"

aks_admin_group_object_ids = [
  "00000000-0000-0000-0000-000000000001",
]

aks_api_server_authorized_ip_ranges = [
  "1.2.3.4/32",
]

aks_system_node_vm_size   = "Standard_D4ds_v5"
aks_system_node_max_pods  = 110
aks_node_pool_max_surge   = "33%"
aks_private_cluster_enabled = true

enable_auto_scaling  = true
min_node_count       = 1
max_node_count       = 5
initial_node_count   = 2

#############################
# Logging
#############################

log_analytics_retention_in_days = 60

#############################
# Tagging
#############################

common_tags = {
  owner       = "platform-team"
  cost_center = "platform-dev"
  managed_by  = "terraform"
}
