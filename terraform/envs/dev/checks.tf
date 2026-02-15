# Cross-variable validation: Terraform variable blocks cannot reference other variables.
# Check blocks (Terraform 1.5+) run at plan/apply and can reference any configuration.

check "autoscaling_bounds" {
  assert {
    condition     = var.min_node_count <= var.initial_node_count && var.initial_node_count <= var.max_node_count
    error_message = "Autoscaling bounds must satisfy min_node_count <= initial_node_count <= max_node_count."
  }
}
