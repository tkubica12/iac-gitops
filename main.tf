# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Store state in Azure Blob Storage
terraform {
  backend "azurerm" {
    resource_group_name  = "shared-services"
    storage_account_name = "tomuvstore"
    container_name       = "tstate-gitops"
    key                  = "terraform.tfstate"
  }
}