resource "azurerm_frontdoor" "frontdoor1" {
  name                                         = "tomasdoor123"
  resource_group_name                          = azurerm_resource_group.net.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "project1-web-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["front1"]
    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = "pool1"
    }
  }

  backend_pool_load_balancing {
    name = "lbsettings1"
  }

  backend_pool_health_probe {
    name                = "helthprobe1"
    interval_in_seconds = 5
  }

  backend_pool {
    name = "pool1"
    backend {
      host_header = "project1-aks-we.westeurope.cloudapp.azure.com"
      address     = "project1-aks-we.westeurope.cloudapp.azure.com"
      http_port   = 80
      https_port  = 443
    }
    backend {
      host_header = "project1-aks-ne.northeurope.cloudapp.azure.com"
      address     = "project1-aks-ne.northeurope.cloudapp.azure.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "lbsettings1"
    health_probe_name   = "helthprobe1"
  }

  frontend_endpoint {
    name      = "front1"
    host_name = "tomasdoor123.azurefd.net"
  }
}
