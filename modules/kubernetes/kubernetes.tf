resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  number  = true
}

# Azure Monitor
resource "azurerm_log_analytics_workspace" "demo" {
  name                = "logs-${var.name}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
}

# AKS
resource "azurerm_kubernetes_cluster" "demo" {
  name                = "aks-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "aks-${var.name}"
  node_resource_group = "${var.resource_group}-aksresources"
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  default_node_pool {
    name                = "default"
    vm_size             = "Standard_B2ms"
    enable_auto_scaling = true
    max_count           = 10
    min_count           = 3
    node_count          = 3
    availability_zones  = [1,2,3]
    vnet_subnet_id      = var.subnet_id
    max_pods            = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    dns_service_ip     = "192.168.0.10"
    service_cidr       = "192.168.0.0/22"
    docker_bridge_cidr = "192.168.10.1/24"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.admin_group_id]
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.demo.id
    }
    azure_policy {
      enabled = true
    }
  }
}