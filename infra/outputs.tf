# Valores que Terraform muestra al terminar y que usa el pipeline de aplicación.

output "acr_name" {
  description = "Nombre del registro de imágenes."
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Servidor del registro (prefijo de las imágenes)."
  value       = azurerm_container_registry.acr.login_server
}

output "container_app_environment" {
  description = "Nombre del entorno de Container Apps."
  value       = azurerm_container_app_environment.env.name
}

output "container_app_name" {
  description = "Nombre de la Container App (null antes del paso 3 del arranque)."
  value       = try(azurerm_container_app.app[0].name, null)
}

output "app_url" {
  description = "URL pública de la aplicación (null antes del paso 3 del arranque)."
  value       = try("https://${azurerm_container_app.app[0].ingress[0].fqdn}", null)
}
