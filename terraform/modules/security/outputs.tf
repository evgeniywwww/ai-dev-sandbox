#########################################################
# Security Module - Outputs
#########################################################
#
# PURPOSE:
#   Exposes created security rule IDs for reference and tracking.
#
# LAYER RESPONSIBILITY:
#   - Export map of rule names to Azure resource IDs
#
# STANDARDS ALIGNMENT:
#   Section 15: Module Philosophy (minimal exposure)
#
#########################################################

output "security_rule_ids" {
  description = "Map of rule name to Azure resource ID for each created security rule."
  value       = { for k, r in azurerm_network_security_rule.this : k => r.id }
}
