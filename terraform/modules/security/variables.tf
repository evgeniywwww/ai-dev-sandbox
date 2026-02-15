#########################################################
# Security Module - Input Variables
#########################################################
#
# PURPOSE:
#   Defines the contract for the security policy application module.
#   All security rules are passed from root (tfvars).
#
# LAYER RESPONSIBILITY:
#   - Type definitions for NSG ID and rule list
#   - Input validation (where applicable)
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default security rules
#   - Hardcoded policy values
#   - Environment-specific logic
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 12:  Security Module Architecture (rules from root)
#   Section 15:  Module Philosophy (explicit inputs)
#
#########################################################

variable "nsg_id" {
  type        = string
  description = "ID of the existing Network Security Group to attach rules to."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the NSG."
}

variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "List of security rules to create on the NSG. Rule names must be unique within the list."
}
