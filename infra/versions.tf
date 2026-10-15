# Versiones de Terraform y del proveedor de Azure.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.20.0, < 5.0.0"
    }
  }
}

# La autenticación NO va aquí: llega por variables de entorno.
#   - En GitHub Actions: ARM_USE_OIDC=true, ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID.
#   - En Cloud Shell: la sesión de az login de Sofía + ARM_SUBSCRIPTION_ID.
provider "azurerm" {
  features {}

  # Los proveedores (Microsoft.App, ContainerRegistry, etc.) ya se encuentran registrados
  # La identidad de GitHub solo tiene permisos sobre rg-nova-t2-dev, no sobre la
  # suscripción, así que Terraform no debe intentar registrarlos.
  resource_provider_registrations = "none"

  # Acceso a Storage con Entra ID en lugar de claves compartidas.
  storage_use_azuread = true
}
