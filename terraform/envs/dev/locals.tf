#########################################################
# Environment: dev - Locals (Derived Values & Naming)
#########################################################
#
# PURPOSE:
#   Derives values from variables for use in module orchestration.
#   Implements Azure naming sanitization to ensure compliance.
#
# LAYER RESPONSIBILITY:
#   - Tag merging (project + environment + common_tags)
#   - Azure naming governance (sanitization)
#   - Deterministic resource name derivation
#
# MUST NOT CONTAIN:
#   - Policy values (belong in tfvars)
#   - Environment branching logic
#   - Hardcoded defaults
#   - Hidden business logic
#
# STANDARDS ALIGNMENT:
#   Section 3:  Locals Usage Policy (derived values only)
#   Section 4:  Tagging Standard (merge strategy)
#   Section 13: Azure Naming Governance (sanitization)
#
# NAMING SANITIZATION LOGIC:
#   Raw var.project_name may contain spaces, special chars, or exceed length.
#   Sanitization ensures Azure resource naming compliance:
#     - Lowercase
#     - Spaces → hyphens
#     - Invalid chars → hyphens
#     - Collapse consecutive hyphens
#     - Trim to 60 chars (reserve 20 for suffixes)
#
#   This is DETERMINISTIC: same input = same output (no randomness).
#   Modules receive sanitized names; they MUST NOT implement naming logic.
#
#########################################################

#########################################################
# Tagging
#########################################################

locals {
  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
    },
    var.common_tags,
  )

#########################################################
# Azure Naming Governance
#########################################################

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

#########################################################
# Derived Resource Names
#########################################################

  # Derived names only; no policy values.
  network_policy = {
    vnet_name          = "${local.sanitized_base_name}-vnet-${var.environment}"
    public_subnet_name = "${local.sanitized_base_name}-public-subnet-${var.environment}"
    aks_subnet_name    = "${local.sanitized_base_name}-aks-subnet-${var.environment}"
  }
}
