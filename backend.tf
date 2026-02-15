terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev"
    storage_account_name = "lmtfdevstate"
    container_name       = "terraform-state"
    key                  = "aks/dev/terraform.tfstate"
  }
}

