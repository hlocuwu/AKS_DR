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

output "primary_aks_name" {
  value = azurerm_kubernetes_cluster.primary_aks.name
}

output "primary_rg_name" {
  value = azurerm_resource_group.primary_rg.name
}

output "secondary_aks_name" {
  value = azurerm_kubernetes_cluster.secondary_aks.name
}

output "secondary_rg_name" {
  value = azurerm_resource_group.secondary_rg.name
}

output "primary_ingress_ip" {
  value = azurerm_public_ip.primary_ip.ip_address
}

output "secondary_ingress_ip" {
  value = azurerm_public_ip.secondary_ip.ip_address
}

output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}

output "postgres_server_fqdn" {
  description = "The FQDN of the PostgreSQL Server"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

# output "postgres_database_name" {
#  description = "The name of the default database"
#  value       = azurerm_postgresql_flexible_server_database.default.name
#   }

output "postgres_admin_username" {
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
}

