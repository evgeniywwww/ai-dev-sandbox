#########################################################
# Security Module - Security Policy Application
#########################################################
#
# PURPOSE:
#   Applies security rules to existing Network Security Groups.
#   This module implements security policy defined in the root layer.
#
# LAYER RESPONSIBILITY:
#   - Accept NSG ID and rule list from root
#   - Dynamically create security rules
#   - Apply rules to existing NSG resources
#
# MUST NOT CONTAIN:
#   - NSG creation (handled by network module)
#   - Hardcoded security rules
#   - Environment-specific logic
#   - Security policy decisions
#
# STANDARDS ALIGNMENT:
#   Section 11: Network Security Groups (explicit rules required)
#   Section 12: Security Module Architecture (separation of concerns)
#   Section 15: Module Philosophy (deterministic, explicit inputs)
#
# RELATION TO OTHER MODULES:
#   - Network module creates NSGs and exports IDs
#   - Root module defines all rules in tfvars
#   - This module applies rules dynamically
#
#########################################################

# NSG name is derived from the resource ID; rules are created from root-supplied list.
locals {
  nsg_name = one(regexall("[^/]+$", var.nsg_id))
}

resource "azurerm_network_security_rule" "this" {
  for_each = { for r in var.security_rules : r.name => r }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  destination_address_prefix   = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = local.nsg_name
}
