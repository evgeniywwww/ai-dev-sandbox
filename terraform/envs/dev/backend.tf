#########################################################
# Environment: dev - Backend Configuration
#########################################################
#
# PURPOSE:
#   Defines remote state backend configuration for the dev environment.
#
# LAYER RESPONSIBILITY:
#   - State storage location (Azure Storage Account)
#   - State key path for dev environment
#
# MUST NOT CONTAIN:
#   - Environment variables or interpolations
#   - Hardcoded credentials (use Azure AD auth)
#   - Logic or conditionals
#
# STANDARDS ALIGNMENT:
#   Section 5:  Backend Strategy (azurerm, state isolation)
#   Section 16: State Management Rules (one state per environment)
#
# NOTES:
#   - State locking uses Azure Blob leases automatically
#   - Authentication via Azure AD (no access keys)
#
#########################################################

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev"
    storage_account_name = "lmtfdevstate"
    container_name       = "terraform-state"
    key                  = "aks/dev/terraform.tfstate"
  }
}
