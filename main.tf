# Providers
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    flux = {
      source = "fluxcd/flux"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Configure Flux v2 bootstrapper
provider "flux" {}

# Store state in Azure Blob Storage
terraform {
  backend "azurerm" {
    resource_group_name  = "shared-services"
    storage_account_name = "tomuvstore"
    container_name       = "tstate-gitops"
    key                  = "terraform.tfstate"
  }
}
