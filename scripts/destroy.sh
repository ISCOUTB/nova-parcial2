#!/usr/bin/env bash
# =============================================================================
# Taller 2 - Grupo NOVA - Destrucción de la infraestructura
#
#   ⚠  NO EJECUTAR ANTES DE LA EVALUACIÓN.  ⚠
#   Borra la aplicación publicada y todo lo que la sostiene.
#
# Se ejecuta desde la raíz del repositorio, en Git Bash o Cloud Shell, con
# "az login" hecho por la Propietaria de la suscripción:
#   bash scripts/destroy.sh
#
# Orden (de lo más nuevo a lo más básico):
#   Paso 1. terraform destroy: Container App, entorno, ACR, Log Analytics,
#           identidad de descarga y rol AcrPull (todo lo que creó Terraform).
#   Paso 2. Borrar rg-nova-t2-dev (lo creó bootstrap.sh, no Terraform).
#   Paso 3. OPCIONAL y al final de todo: borrar rg-nova-t2-ops (estado de
#           Terraform e identidad de GitHub). Después ya no funcionan
#           Terraform ni los pipelines.
#
# No usa secretos: el valor de app_secret no hace falta para destruir, así que
# se usa un texto de relleno que nunca llega a Azure.
# =============================================================================
set -euo pipefail

# --- Valores del taller (los mismos de bootstrap.sh) --------------------------
SUBSCRIPTION_ID="87877b30-39be-4c4a-a163-fe80a995025e"   # Azure for Students 
DEV_RG="rg-nova-t2-dev"
OPS_RG="rg-nova-t2-ops"
STATE_SA="stnovat2tfssab"
STATE_CONTAINER="tfstate"
STATE_KEY="taller2-dev.tfstate"
TFVARS="../config/dev.tfvars"    # relativo a infra/

paso() { echo; echo "==> $*"; }

# --- Confirmación -------------------------------------------------------------
echo "Este script BORRA la infraestructura del Taller 2 en la suscripción ${SUBSCRIPTION_ID}."
echo "Solo debe ejecutarse DESPUÉS de la evaluación."
read -r -p 'Escriba DESTRUIR para continuar: ' RESPUESTA
if [ "$RESPUESTA" != "DESTRUIR" ]; then
  echo "Cancelado. No se borró nada."
  exit 1
fi

# --- Suscripción, siempre por ID ---------------------------------------------
paso "Seleccionando la suscripción por ID"
az account set --subscription "$SUBSCRIPTION_ID"
ACTUAL=$(az account show --query id -o tsv)
if [ "$ACTUAL" != "$SUBSCRIPTION_ID" ]; then
  echo "ERROR: la suscripción activa es ${ACTUAL}, no ${SUBSCRIPTION_ID}." >&2
  exit 1
fi
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
# Texto de relleno: la variable es obligatoria en el código, pero al destruir
# su valor no se usa ni se envía a Azure.
export TF_VAR_app_secret="${TF_VAR_app_secret:-solo-para-destroy}"

# --- Paso 1: terraform destroy -----------------------------------------------
paso "Paso 1/3: terraform destroy (recursos creados por Terraform)"
terraform -chdir=infra init -reconfigure \
  -backend-config="resource_group_name=${OPS_RG}" \
  -backend-config="storage_account_name=${STATE_SA}" \
  -backend-config="container_name=${STATE_CONTAINER}" \
  -backend-config="key=${STATE_KEY}"
# Terraform muestra el plan de destrucción y pide escribir "yes".
terraform -chdir=infra destroy -var-file="$TFVARS"

paso "Comprobación: recursos que quedan en ${DEV_RG} (debe estar vacío)"
az resource list -g "$DEV_RG" --query "[].{nombre:name, tipo:type}" -o table

# --- Paso 2: grupo del proyecto -------------------------------------------------
paso "Paso 2/3: borrar el grupo ${DEV_RG} (creado por bootstrap.sh)"
read -r -p "Escriba BORRAR-DEV para borrar ${DEV_RG}: " R2
if [ "$R2" = "BORRAR-DEV" ]; then
  az group delete -n "$DEV_RG" --yes
  echo "    ¿Existe todavía ${DEV_RG}? $(az group exists -n "$DEV_RG")   (debe decir false)"
else
  echo "    Se omitió el paso 2."
fi

# --- Paso 3 (opcional): estado e identidad de GitHub --------------------------
paso "Paso 3/3 (OPCIONAL): borrar ${OPS_RG}"
echo "    Contiene el ESTADO de Terraform (${STATE_SA}) y la identidad de GitHub."
echo "    Después de borrarlo ya NO funcionan Terraform ni los pipelines."
read -r -p "Escriba BORRAR-OPS para borrarlo (cualquier otra cosa lo omite): " R3
if [ "$R3" = "BORRAR-OPS" ]; then
  az group delete -n "$OPS_RG" --yes
  echo "    ¿Existe todavía ${OPS_RG}? $(az group exists -n "$OPS_RG")   (debe decir false)"
else
  echo "    Se conservó ${OPS_RG}."
fi

paso "Fin. Revise también Cost Management en el portal durante los próximos días."
