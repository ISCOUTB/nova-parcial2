# Recursos del Taller 2: ACR, Log Analytics, entorno de Container Apps,
# identidad de descarga de imágenes y la Container App.

# El grupo de recursos lo crea scripts/bootstrap.sh; aquí solo se leen.
data "azurerm_resource_group" "dev" {
  name = var.resource_group_name
}

locals {
  # Etiquetas obligatorias del enunciado: equipo, proyecto y ambiente.
  tags = merge(
    {
      equipo         = "NOVA"
      proyecto       = "taller2-aca"
      ambiente       = var.environment
      gestionado_por = "terraform"
    },
    var.extra_tags
  )

  acr_name = "acrnovat2${var.name_suffix}"
}

# --- Logs ---------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-nova-t2-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.dev.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  # mínimo del plan; reduce costo
  daily_quota_gb      = 0.5 # tope diario de ingesta para controlar costos
  tags                = local.tags
}

# --- Registro de imágenes -------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.dev.name
  sku                 = "Basic" # el más económico; sin red privada ni geo-replicación
  admin_enabled       = false   # sin usuario/contraseña: se usa identidad administrada
  tags                = local.tags
}

# --- Identidad con la que la Container App descarga imágenes del ACR -------------
resource "azurerm_user_assigned_identity" "pull" {
  name                = "id-nova-t2-pull"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tags                = local.tags
}

# Permiso mínimo: solo descargar imágenes de este registro.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.pull.principal_id
  principal_type       = "ServicePrincipal"
}

# --- Entorno de Container Apps (plan de consumo) --------------------------------
resource "azurerm_container_app_environment" "env" {
  name                       = "cae-nova-t2-${var.environment}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.dev.name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  tags                       = local.tags
}

# --- Container App ----------------------------------------------------------------
# Se crea solo cuando ya existe la primera imagen (create_container_app = true).
resource "azurerm_container_app" "app" {
  count = var.create_container_app ? 1 : 0

  name                         = "ca-nova-t2-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = data.azurerm_resource_group.dev.name
  revision_mode                = "Single" # cada imagen nueva crea una revisión; la anterior queda inactiva
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.pull.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.pull.id
  }

  # Dato sensible: guardado como secreto de Container Apps, nunca en texto plano.
  secret {
    name  = "app-secret"
    value = var.app_secret
  }

  ingress {
    external_enabled           = true # ingreso HTTP externo (requisito)
    target_port                = var.container_port
    transport                  = "auto"
    allow_insecure_connections = false # solo HTTPS

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "nova-app"
      image  = "${azurerm_container_registry.acr.login_server}/nova-app:${var.initial_image_tag}"
      cpu    = var.cpu
      memory = var.memory

      # Variables no sensibles (requisito: definidas por Terraform).
      env {
        name  = "APP_ENV"
        value = var.environment
      }
      env {
        name  = "TEAM_NAME"
        value = "NOVA"
      }
      # Variable sensible: referencia al secreto, no el valor.
      env {
        name        = "APP_SECRET"
        secret_name = "app-secret"
      }

      liveness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/health"
      }
    }

    # Escala de 1 a 2 réplicas según solicitudes HTTP concurrentes.
    http_scale_rule {
      name                = "http-concurrencia"
      concurrent_requests = "50"
    }
  }

  lifecycle {
    # La imagen y el sufijo de revisión los administra el pipeline de aplicación.
    # Así un terraform apply posterior no devuelve la app a una versión vieja.
    ignore_changes = [
      template[0].container[0].image,
      template[0].revision_suffix,
    ]

    precondition {
      condition     = var.initial_image_tag != ""
      error_message = "Para crear la Container App hace falta initial_image_tag (SHA de la primera imagen publicada)."
    }
    precondition {
      condition     = var.app_secret != ""
      error_message = "Falta app_secret: configúrelo en GitHub Secrets como APP_SECRET (llega como TF_VAR_app_secret)."
    }
  }

  # La identidad debe tener AcrPull antes de que la app intente descargar la imagen.
  depends_on = [azurerm_role_assignment.acr_pull]
}
