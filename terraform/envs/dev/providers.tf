#########################################################
# Environment: dev - Provider Configuration
#########################################################
#
# PURPOSE:
#   Defines Terraform and provider version constraints.
#   Configures the Azure Resource Manager provider.
#
# LAYER RESPONSIBILITY:
#   - Terraform version requirements
#   - Provider version pinning
#   - Provider feature configuration
#
# MUST NOT CONTAIN:
#   - Hardcoded subscription or tenant IDs
#   - Environment-specific provider aliases
#   - Conditional provider logic
#
# STANDARDS ALIGNMENT:
#   Section 5: Backend Strategy (provider authentication)
#
# NOTES:
#   - Provider uses Azure CLI or Managed Identity authentication
#   - No explicit credentials required
#
#########################################################

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
