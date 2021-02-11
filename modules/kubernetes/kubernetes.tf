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
    availability_zones  = [1, 2, 3]
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
    kube_dashboard {
      enabled = false
    }
  }
}

# Bootstrap Flux v2
# Note: mamaged GitOps for AKS as addon is in preview - plan to switch when available via Terraform
data "flux_install" "main" {
  target_path    = "cluster-baseline"
  network_policy = false
  version        = "latest"
}

data "flux_sync" "main" {
  target_path = data.flux_install.main.target_path
  url         = "ssh://git@github.com/tkubica12/iac-gitops.git"
  branch      = "master"
}

# Create flux-system namespace
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.demo]
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.apply]

  metadata {
    name      = data.flux_sync.main.name
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = base64decode(var.GIT_PRIVATE_KEY)
    "identity.pub" = base64decode(var.GIT_PUBLIC_KEY)
    known_hosts    = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
  }
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "apply" {
  content = data.flux_install.main.content
}

# Convert documents list to include parsed yaml data
locals {
  apply = [ for v in data.kubectl_file_documents.apply.documents : {
      data: yamldecode(v)
      content: v
    }
  ]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "apply" {
  for_each   = { for v in local.apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

# Convert documents list to include parsed yaml data
locals {
  sync = [ for v in data.kubectl_file_documents.sync.documents : {
      data: yamldecode(v)
      content: v
    }
  ]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}