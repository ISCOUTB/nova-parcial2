# Estado remoto de Terraform en la Storage Account privada creada por scripts/bootstrap.sh.
# Los nombres concretos NO se escriben aquí: se pasan en "terraform init" con -backend-config
# (ver README y el workflow infra.yml). Así el mismo código sirve para otro equipo o ambiente.
#
#   terraform init \
#     -backend-config="resource_group_name=rg-nova-t2-ops" \
#     -backend-config="storage_account_name=stnovat2tfssab" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=taller2-dev.tfstate"
#
# Azure bloquea el archivo de estado (lease del blob) mientras alguien ejecuta plan o apply,
# lo que evita dos ejecuciones simultáneas.
terraform {
  backend "azurerm" {
    use_azuread_auth = true
  }
}
