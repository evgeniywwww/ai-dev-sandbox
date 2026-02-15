#########################################################
# Environment: dev - Cross-Variable Validation
#########################################################
#
# PURPOSE:
#   Enforces cross-variable validation rules that cannot be
#   expressed in individual variable validation blocks.
#
# LAYER RESPONSIBILITY:
#   - Cross-variable assertions
#   - Autoscaling bounds validation
#
# MUST NOT CONTAIN:
#   - Policy logic (validation only)
#   - Resource creation
#   - Environment branching
#
# STANDARDS ALIGNMENT:
#   Section 14: Autoscaling Rules (check blocks for cross-var)
#
# VALIDATION RULES:
#   min_node_count <= initial_node_count <= max_node_count
#
# NOTE:
#   Variable validation blocks cannot reference other variables.
#   Check blocks (Terraform 1.5+) run at plan/apply and can reference
#   any configuration value.
#
#########################################################

check "autoscaling_bounds" {
  assert {
    condition     = var.min_node_count <= var.initial_node_count && var.initial_node_count <= var.max_node_count
    error_message = "Autoscaling bounds must satisfy min_node_count <= initial_node_count <= max_node_count."
  }
}
