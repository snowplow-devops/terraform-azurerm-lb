output "ip_address" {
  description = "The allocated dynamic IP Address used by the Application Gateway"
  value       = azurerm_public_ip.ip.ip_address
}

output "ip_address_id" {
  description = "The logical ID of the allocated IP address"
  value       = azurerm_public_ip.ip.id
}

output "ip_address_fqdn" {
  description = "The fully qualified domain name of the deployment"
  value       = azurerm_public_ip.ip.fqdn
}

output "agw_id" {
  description = "The logical ID of the allocated Application Gateway"
  value       = azurerm_application_gateway.agw.id
}

output "agw_name" {
  description = "The name of the allocated Application Gateway"
  value       = azurerm_application_gateway.agw.name
}

output "agw_backend_address_pool_id" {
  description = "The logical ID of the allocated Backend Address Pool needed to attach servers to the gateway"
  value       = tolist(azurerm_application_gateway.agw.backend_address_pool)[0].id
}

output "agw_backend_address_pool_name" {
  description = "The name of the allocated Backend Address Pool needed to attach servers to the gateway"
  value       = tolist(azurerm_application_gateway.agw.backend_address_pool)[0].name
}

output "agw_probe_id" {
  description = "The logical ID of the health probe"
  value       = tolist(azurerm_application_gateway.agw.probe)[0].id
}

output "agw_backend_egress_port" {
  description = "The egress port defined for the load balancer"
  value       = var.egress_port
}
