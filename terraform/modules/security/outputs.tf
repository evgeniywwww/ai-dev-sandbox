output "security_rule_ids" {
  description = "Map of rule name to Azure resource ID for each created security rule."
  value       = { for k, r in azurerm_network_security_rule.this : k => r.id }
}
