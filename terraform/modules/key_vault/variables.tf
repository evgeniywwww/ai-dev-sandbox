#########################################################
# Key Vault Module - Input Variables
#########################################################
#
# PURPOSE:
#   Defines the contract for Azure Key Vault creation.
#
# LAYER RESPONSIBILITY:
#   - Type definitions
#   - Input validation
#   - Documentation
#
# MUST NOT CONTAIN:
#   - Default values (policy decisions)
#   - Environment-specific logic
#   - Hardcoded SKUs or access policies
#
# STANDARDS ALIGNMENT:
#   Section 2.1: variables.tf = Contract Only
#   Section 15:  Module Philosophy (explicit inputs)
#
#########################################################

variable "name" {
  type        = string
  description = "Name of the Key Vault. Must be globally unique, 3-24 characters, alphanumeric and hyphens only."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric and hyphens only."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the Key Vault will be created."
}

variable "sku_name" {
  type        = string
  description = "SKU name for Key Vault (standard or premium)."

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for the Key Vault."
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Enable RBAC authorization for Key Vault (recommended over access policies)."
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection for Key Vault (prevents permanent deletion during retention period)."
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted Key Vault (7-90 days)."

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Key Vault."
}
