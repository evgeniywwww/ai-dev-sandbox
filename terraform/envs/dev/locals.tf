# Derived tags: project and environment from root policy, merged with tfvars common_tags.
locals {
  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
    },
    var.common_tags,
  )

  # Azure naming hygiene: sanitize project_name for use in resource names.
  # Ensures compliance: alphanumeric start/end, only letters/numbers/hyphens/underscores/periods allowed, max 80 chars.
  # Deterministic and stable across applies.
  sanitized_project = lower(
    replace(
      replace(
        replace(var.project_name, " ", "-"),  # spaces → hyphens
        "/[^a-zA-Z0-9-_.]/", "-"              # invalid chars → hyphens
      ),
      "/--+/", "-"                             # collapse multiple hyphens
    )
  )

  # Trim to safe length: reserve 20 chars for suffixes like "-vnet-dev", "-public-rt", etc.
  base_name_max_length = 60
  sanitized_base_name = substr(local.sanitized_project, 0, local.base_name_max_length)

  # Derived names only; no policy values.
  network_policy = {
    vnet_name          = "${local.sanitized_base_name}-vnet-${var.environment}"
    public_subnet_name = "${local.sanitized_base_name}-public-subnet-${var.environment}"
    aks_subnet_name    = "${local.sanitized_base_name}-aks-subnet-${var.environment}"
  }
}

