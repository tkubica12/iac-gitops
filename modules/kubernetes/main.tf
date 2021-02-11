# Providers
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    flux = {
      source = "fluxcd/flux"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.10.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Configure Flux v2 bootstrapper
provider "flux" {}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.demo.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.demo.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.cluster_ca_certificate)
}

variable "GIT_PRIVATE_KEY" {}
variable "GIT_PUBLIC_KEY" {}
