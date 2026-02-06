output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "container_app_fqdn" {
  value = azurerm_container_app.mc.ingress[0].fqdn
}

output "container_app_ip" {
  value = azurerm_container_app_environment.env.static_ip_address
}

output "dns_name_servers" {
  description = "Name servers for the Azure DNS zone. Update your registrar with these if using custom domain."
  value       = var.domain_name != null ? azurerm_dns_zone.dns[0].name_servers : null
}

output "connect_minecraft" {
  value = var.domain_name != null ? "${var.domain_name}:25565" : "${azurerm_container_app.mc.ingress[0].fqdn}:25565"
}
