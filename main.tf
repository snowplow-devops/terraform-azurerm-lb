locals {
  probe_name                      = var.name
  frontend_ip_configuration_name  = var.name
  backend_address_pool_name       = var.name
  backend_http_settings_name      = var.name
  http_frontend_port_name         = "${var.name}-http"
  https_frontend_port_name        = "${var.name}-https"
  http_listener_name              = "${var.name}-http"
  https_listener_name             = "${var.name}-https"
  http_request_routing_rule_name  = "${var.name}-http"
  https_request_routing_rule_name = "${var.name}-https"
  ssl_certificate_name            = var.name
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "random_uuid" "ip_domain_name_label" {}

resource "azurerm_public_ip" "ip" {
  name = var.name

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.rg.location

  allocation_method = "Dynamic"
  sku               = "Basic"
  sku_tier          = "Regional"
  ip_version        = "IPv4"

  # Ensures no clashes with other deployments
  domain_name_label = "${var.name}-${random_uuid.ip_domain_name_label.result}"

  tags = var.tags
}

resource "azurerm_application_gateway" "agw" {
  name = var.name

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.rg.location
  enable_http2        = true

  tags = var.tags

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "${var.name}-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  probe {
    name                = local.probe_name
    interval            = 30
    protocol            = "Http"
    path                = var.probe_path
    timeout             = 30
    unhealthy_threshold = 3

    pick_host_name_from_backend_http_settings = true

    match {
      status_code = var.probe_match_status_codes
    }
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = var.egress_port
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.probe_name

    pick_host_name_from_backend_address = true

    connection_draining {
      enabled           = true
      drain_timeout_sec = 300
    }
  }

  frontend_port {
    name = local.http_frontend_port_name
    port = 80
  }

  dynamic "frontend_port" {
    for_each = var.ssl_certificate_enabled ? toset([1]) : toset([])

    content {
      name = local.https_frontend_port_name
      port = 443
    }
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.http_frontend_port_name
    protocol                       = "Http"
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_enabled ? toset([1]) : toset([])

    content {
      name     = local.ssl_certificate_name
      data     = var.ssl_certificate_data
      password = var.ssl_certificate_password
    }
  }

  dynamic "http_listener" {
    for_each = var.ssl_certificate_enabled ? toset([1]) : toset([])

    content {
      name                           = local.https_listener_name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.https_frontend_port_name
      protocol                       = "Https"
      require_sni                    = false
      ssl_certificate_name           = local.ssl_certificate_name
    }
  }

  request_routing_rule {
    name                       = local.http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_enabled ? toset([1]) : toset([])

    content {
      name                       = local.https_request_routing_rule_name
      rule_type                  = "Basic"
      http_listener_name         = local.https_listener_name
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.backend_http_settings_name
    }
  }
}
