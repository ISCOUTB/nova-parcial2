# Configuración NO sensible del ambiente dev.
# Cambiar este archivo activa el workflow de infraestructura (plan + apply).
# Nunca escribir aquí secretos: app_secret llega desde GitHub Secrets.

location            = "brazilsouth"
resource_group_name = "rg-nova-t2-dev"
environment         = "dev"
name_suffix         = "ssab"

# Arranque: primero  false (aún no hay imagen). Luego = true + SHA de la primera imagen.
create_container_app = true
initial_image_tag    = "41717c86acd34580d928f9ac11c2ec089609fd08"

# Contenedor y escalado (límites para controlar costos)
container_port = 8000
cpu            = 0.25
memory         = "0.5Gi"
min_replicas   = 1
max_replicas   = 2

# Demostración de cambio de infraestructura: cambiar este valor (por ejemplo "1" -> "2").
extra_tags = {
  version_infra = "2"
}
