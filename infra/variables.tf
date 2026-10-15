# Variables de entrada. Los valores NO sensibles van en config/dev.tfvars.
# El único dato sensible (app_secret) llega desde GitHub Secrets como TF_VAR_app_secret.

variable "location" {
  description = "Región de Azure. La política de Azure for Students solo permite algunas."
  type        = string
  default     = "brazilsouth"
}

variable "resource_group_name" {
  description = "Grupo de recursos del proyecto (lo crea scripts/bootstrap.sh)."
  type        = string
}

variable "environment" {
  description = "Nombre del ambiente; se usa en nombres y etiquetas."
  type        = string
  default     = "dev"
}

variable "name_suffix" {
  description = "Sufijo para nombres que deben ser únicos en todo Azure (ACR)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.name_suffix))
    error_message = "name_suffix debe tener entre 3 y 8 letras minúsculas o números."
  }
}

variable "extra_tags" {
  description = "Etiquetas adicionales. Cambiar una de ellas es la demostración de cambio de infraestructura."
  type        = map(string)
  default     = {}
}

# --- Aplicación -------------------------------------------------------------

variable "create_container_app" {
  description = "false en el paso 1 del arranque (aún no hay imagen); true desde el paso 3."
  type        = bool
  default     = false
}

variable "initial_image_tag" {
  description = "Etiqueta (SHA del commit) de la primera imagen publicada. Después la imagen la cambia el pipeline de aplicación."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Puerto interno donde escucha la aplicación (acordado con Sara)."
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "vCPU por réplica. 0.25 es el mínimo de Container Apps (control de costos)."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memoria por réplica; debe ir en pareja con cpu (0.25 vCPU -> 0.5Gi)."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Réplicas mínimas. 1 evita el arranque en frío durante la demostración."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Réplicas máximas. Limita el costo si llega mucho tráfico."
  type        = number
  default     = 2

  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 3
    error_message = "max_replicas debe estar entre 1 y 3 para controlar costos."
  }
}

variable "app_secret" {
  description = "Dato sensible de demostración. Se entrega como TF_VAR_app_secret desde GitHub Secrets; nunca va en archivos."
  type        = string
  sensitive   = true
  default     = ""
}
