# Derived tags: project and environment from root policy, merged with tfvars common_tags.
locals {
  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
    },
    var.common_tags,
  )

  # Derived names only; no policy values.
  network_policy = {
    vnet_name          = "${var.project_name}-vnet-${var.environment}"
    public_subnet_name = "${var.project_name}-public-subnet-${var.environment}"
    aks_subnet_name   = "${var.project_name}-aks-subnet-${var.environment}"
  }
}
