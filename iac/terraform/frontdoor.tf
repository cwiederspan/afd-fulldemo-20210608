locals {
  afd_name                       = "${var.base_name}-afd"
  frontend_endpoint              = "${local.afd_name}-feep"
  backend_pool                   = "${local.afd_name}-bep"
  routing_rule                   = "${local.afd_name}-feep"
  probe_name                     = "${local.afd_name}-probe"
  load_balancer_name             = "${local.afd_name}-lb"
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.base_name}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  domain_name_label   = local.afd_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_frontdoor" "afd" {
  name                = local.afd_name
  resource_group_name = azurerm_resource_group.rg.name
  #location            = "Global"

  enforce_backend_pools_certificate_name_check = false

  frontend_endpoint {
    name      = "default"
    host_name = local.afd_fqdn
  }

  frontend_endpoint {
    name      = local.frontend_endpoint
    host_name = local.afd_www_dns_name
  }

  routing_rule {
    name               = local.routing_rule
    accepted_protocols = [ "Http", "Https" ]
    patterns_to_match  = [ "/*" ]
    frontend_endpoints = [ local.frontend_endpoint ]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = local.backend_pool
    }
  }

  backend_pool_load_balancing {
    name = local.load_balancer_name
  }

  backend_pool_health_probe {
    name = local.probe_name
  }

  backend_pool {
    name = local.backend_pool

    backend {
      host_header = "www.nfl.com"
      address     = "www.nfl.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = local.load_balancer_name
    health_probe_name   = local.probe_name
  }

  depends_on = [
    # azurerm_dns_cname_record.www
    azurerm_dns_cname_record.afdverify
  ]
}

resource "azurerm_frontdoor_custom_https_configuration" "default" {
  frontend_endpoint_id              = azurerm_frontdoor.afd.frontend_endpoints["default"]
  custom_https_provisioning_enabled = false
}

resource "azurerm_frontdoor_custom_https_configuration" "https" {
  frontend_endpoint_id              = azurerm_frontdoor.afd.frontend_endpoints[local.frontend_endpoint]
  custom_https_provisioning_enabled = true

  custom_https_configuration {
    certificate_source = "FrontDoor"
  }
}