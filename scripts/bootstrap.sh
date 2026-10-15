#!/usr/bin/env bash
# =============================================================================
# Taller 2 - Grupo NOVA - Preparación inicial (paso 0 del arranque)
#
# Crea lo que el pipeline necesita ANTES de poder ejecutarse por sí mismo:
#   1. Grupo de recursos del proyecto (rg-nova-t2-dev)
#   2. Storage Account privada para el estado de Terraform (en rg-nova-t2-ops)
#   3. Identidad administrada para GitHub Actions + credencial federada (OIDC)
#   4. Roles mínimos para esa identidad y acceso de lectura para la Propietaria y el Lector
#
# ESTADO: YA SE EJECUTÓ UNA VEZ para
# ISCOUTB/nova-parcial2. NO debe repetirse en el uso normal del taller: solo
# sirve para reconstruir el entorno desde cero (por ejemplo, después de
# scripts/destroy.sh). Si se repite, lo que ya existe no se duplica.
#
# Se ejecuta en Azure Cloud Shell (Bash), por la Propietaria de la suscripción.
#
# Uso:
#   bash scripts/bootstrap.sh <organizacion-o-usuario>/<repositorio>
# Ejemplo (el que se usó):
#   bash scripts/bootstrap.sh ISCOUTB/nova-parcial2
#
# No crea secretos: todos los valores que imprime al final son identificadores
# públicos que van en "Variables" de GitHub (no en "Secrets").
# =============================================================================
set -euo pipefail

GITHUB_REPO="${1:?Uso: bash bootstrap.sh <usuario-github>/<repositorio>}"

# --- Valores acordados por el equipo (ver "Acuerdos del equipo") -------------
SUBSCRIPTION_ID="87877b30-39be-4c4a-a163-fe80a995025e"   # Azure for Students 
LOCATION="brazilsouth"                                   # región permitida por la política
OPS_RG="rg-nova-t2-ops"                                  # estado + identidad de GitHub
DEV_RG="rg-nova-t2-dev"                                  # recursos que crear Terraform
SUFFIX="${SUFFIX:-ssab}"                                 # 4 letras; cambiar si el nombre está ocupado
STATE_SA="stnovat2tf${SUFFIX}"                           # 3-24 letras minúsculas y números
STATE_CONTAINER="tfstate"
GH_IDENTITY="id-nova-t2-github"
FED_CRED_NAME="github-main"
READER_EMAIL="${READER_EMAIL:-bmastrascusa@utb.edu.co}"  # rol Lector para verificar
TAGS=(equipo=NOVA proyecto=taller2-aca ambiente=dev gestionado_por=bootstrap)

# IDs fijos de roles integrados de Azure (iguales en todos los tenants)
ACRPULL_ROLE_ID="7f951dda-4ed3-4680-a7ca-43fe172d538d"
ACRPUSH_ROLE_ID="8311e382-0749-4cb8-b61a-304f252e45ec"

paso() { echo; echo "==> $*"; }

# Asigna un rol solo si no existe. Busca por alcance y principalId para no
# depender de Microsoft Graph (una identidad recién creada tarda en aparecer).
asignar_rol() {
  local pid="$1" ptype="$2" role="$3" scope="$4" cond="${5:-}"
  local existe
  existe=$(az role assignment list --scope "$scope" --role "$role" \
             --query "[?principalId=='${pid}'] | [0].id" -o tsv 2>/dev/null || true)
  if [ -n "$existe" ]; then
    echo "    ya existía: ${role}"
    return 0
  fi
  local args=(--assignee-object-id "$pid" --assignee-principal-type "$ptype"
              --role "$role" --scope "$scope" --only-show-errors -o none)
  if [ -n "$cond" ]; then
    args+=(--condition "$cond" --condition-version "2.0")
  fi
  local intento
  for intento in 1 2 3 4 5 6; do
    if az role assignment create "${args[@]}"; then
      echo "    asignado: ${role}"
      return 0
    fi
    echo "    reintento ${intento}/6 en 20 s (la identidad puede tardar en propagarse)..."
    sleep 20
  done
  echo "ERROR: no se pudo asignar el rol ${role}" >&2
  exit 1
}

# -----------------------------------------------------------------------------
paso "1/7 Seleccionando la suscripción"
az account set --subscription "$SUBSCRIPTION_ID"
TENANT_ID=$(az account show --query tenantId -o tsv)
ME_ID=$(az ad signed-in-user show --query id -o tsv)
echo "    suscripción: ${SUBSCRIPTION_ID}"

# -----------------------------------------------------------------------------
paso "2/7 Grupos de recursos"
if [ "$(az group exists -n "$OPS_RG")" = "true" ]; then
  echo "    ya existía: ${OPS_RG}"
else
  az group create -n "$OPS_RG" -l "$LOCATION" --tags "${TAGS[@]}" -o none
  echo "    creado: ${OPS_RG}"
fi
if [ "$(az group exists -n "$DEV_RG")" = "true" ]; then
  echo "    ya existía: ${DEV_RG}"
else
  az group create -n "$DEV_RG" -l "$LOCATION" --tags "${TAGS[@]}" -o none
  echo "    creado: ${DEV_RG}"
fi

# -----------------------------------------------------------------------------
paso "3/7 Storage Account para el estado de Terraform (${STATE_SA})"
if az storage account show -n "$STATE_SA" -g "$OPS_RG" -o none 2>/dev/null; then
  echo "    ya existía: ${STATE_SA}"
else
  disponible=$(az storage account check-name -n "$STATE_SA" --query nameAvailable -o tsv)
  if [ "$disponible" != "true" ]; then
    echo "ERROR: el nombre ${STATE_SA} ya lo usa otra persona en Azure." >&2
    echo "       Vuelve a ejecutar con otro sufijo, por ejemplo:" >&2
    echo "       SUFFIX=nva7 bash bootstrap.sh ${GITHUB_REPO}" >&2
    exit 1
  fi
  # Privada: sin acceso público a blobs, sin claves compartidas (solo Entra ID),
  # HTTPS y TLS 1.2 como mínimo.
  az storage account create -n "$STATE_SA" -g "$OPS_RG" -l "$LOCATION" \
    --sku Standard_LRS --kind StorageV2 \
    --https-only true --min-tls-version TLS1_2 \
    --allow-blob-public-access false --allow-shared-key-access false \
    --tags "${TAGS[@]}" -o none
  echo "    creada: ${STATE_SA}"
fi
# Versionado y papelera de 7 días: permiten recuperar un estado dañado o borrado.
az storage account blob-service-properties update \
  --account-name "$STATE_SA" -g "$OPS_RG" \
  --enable-versioning true --enable-delete-retention true --delete-retention-days 7 -o none
# Contenedor creado por el plano de administración (no necesita claves).
if az storage container-rm show --storage-account "$STATE_SA" -g "$OPS_RG" -n "$STATE_CONTAINER" -o none 2>/dev/null; then
  echo "    ya existía el contenedor: ${STATE_CONTAINER}"
else
  az storage container-rm create --storage-account "$STATE_SA" -g "$OPS_RG" \
    -n "$STATE_CONTAINER" --public-access off -o none
  echo "    creado el contenedor: ${STATE_CONTAINER}"
fi

# -----------------------------------------------------------------------------
paso "4/7 Identidad de GitHub Actions (${GH_IDENTITY})"
if az identity show -n "$GH_IDENTITY" -g "$OPS_RG" -o none 2>/dev/null; then
  echo "    ya existía: ${GH_IDENTITY}"
else
  az identity create -n "$GH_IDENTITY" -g "$OPS_RG" -l "$LOCATION" --tags "${TAGS[@]}" -o none
  echo "    creada: ${GH_IDENTITY}"
fi
GH_CLIENT_ID=$(az identity show -n "$GH_IDENTITY" -g "$OPS_RG" --query clientId -o tsv)
GH_PRINCIPAL_ID=$(az identity show -n "$GH_IDENTITY" -g "$OPS_RG" --query principalId -o tsv)

# -----------------------------------------------------------------------------
paso "5/7 Credencial federada: solo la rama main de ${GITHUB_REPO}"
SUBJECT="repo:${GITHUB_REPO}:ref:refs/heads/main"
if az identity federated-credential show -n "$FED_CRED_NAME" \
     --identity-name "$GH_IDENTITY" -g "$OPS_RG" -o none 2>/dev/null; then
  echo "    ya existía; se actualiza el sujeto por si cambió el repositorio"
  az identity federated-credential update -n "$FED_CRED_NAME" \
    --identity-name "$GH_IDENTITY" -g "$OPS_RG" \
    --issuer "https://token.actions.githubusercontent.com" \
    --subject "$SUBJECT" --audiences "api://AzureADTokenExchange" -o none
else
  az identity federated-credential create -n "$FED_CRED_NAME" \
    --identity-name "$GH_IDENTITY" -g "$OPS_RG" \
    --issuer "https://token.actions.githubusercontent.com" \
    --subject "$SUBJECT" --audiences "api://AzureADTokenExchange" -o none
  echo "    creada para: ${SUBJECT}"
fi

# Segunda credencial: la organización ISCOUTB usa "subject con identificadores
# inmutables" (ID de la organización e ID del repositorio). GitHub envía:
#   repo:ISCOUTB@<id-org>/nova-parcial2@<id-repo>:ref:refs/heads/main
# El valor exacto se toma del error AADSTS700213 del primer intento.
SUBJECT_IDS="${SUBJECT_IDS:-repo:ISCOUTB@9059274/nova-parcial2@1419948702:ref:refs/heads/main}"
if [ -n "$SUBJECT_IDS" ]; then
  if az identity federated-credential show -n "${FED_CRED_NAME}-ids" \
       --identity-name "$GH_IDENTITY" -g "$OPS_RG" -o none 2>/dev/null; then
    echo "    ya existía la credencial con identificadores inmutables"
  else
    az identity federated-credential create -n "${FED_CRED_NAME}-ids" \
      --identity-name "$GH_IDENTITY" -g "$OPS_RG" \
      --issuer "https://token.actions.githubusercontent.com" \
      --subject "$SUBJECT_IDS" --audiences "api://AzureADTokenExchange" -o none
    echo "    creada para: ${SUBJECT_IDS}"
  fi
fi

# -----------------------------------------------------------------------------
paso "6/7 Roles mínimos"
DEV_RG_ID=$(az group show -n "$DEV_RG" --query id -o tsv)
SA_ID=$(az storage account show -n "$STATE_SA" -g "$OPS_RG" --query id -o tsv)

echo "  GitHub Actions -> ${DEV_RG}: Contributor (crear y actualizar recursos solo ahí)"
asignar_rol "$GH_PRINCIPAL_ID" ServicePrincipal "Contributor" "$DEV_RG_ID"

echo "  GitHub Actions -> ${DEV_RG}: RBAC Administrator limitado a AcrPull/AcrPush"
# Condición: solo puede crear o borrar asignaciones de los roles AcrPull y AcrPush.
COND="((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${ACRPULL_ROLE_ID}, ${ACRPUSH_ROLE_ID}})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${ACRPULL_ROLE_ID}, ${ACRPUSH_ROLE_ID}}))"
asignar_rol "$GH_PRINCIPAL_ID" ServicePrincipal "Role Based Access Control Administrator" "$DEV_RG_ID" "$COND"

echo "  GitHub Actions -> ${STATE_SA}: Storage Blob Data Contributor (leer y escribir el estado)"
asignar_rol "$GH_PRINCIPAL_ID" ServicePrincipal "Storage Blob Data Contributor" "$SA_ID"

echo "  Sofía -> ${STATE_SA}: Storage Blob Data Contributor (terraform desde Cloud Shell si hace falta)"
asignar_rol "$ME_ID" User "Storage Blob Data Contributor" "$SA_ID"

READER_ID=$(az ad user show --id "$READER_EMAIL" --query id -o tsv 2>/dev/null || true)
if [ -n "$READER_ID" ]; then
  echo "  ${READER_EMAIL} -> ${DEV_RG}: Reader (verificar despliegues y evidencias)"
  asignar_rol "$READER_ID" User "Reader" "$DEV_RG_ID"
else
  echo "  AVISO: no se encontró ${READER_EMAIL}; el rol Reader se asigna después desde el portal."
fi

# -----------------------------------------------------------------------------
paso "7/7 Valores para GitHub (Settings > Secrets and variables > Actions > Variables)"
cat <<EOF

  Ninguno de estos valores es secreto. Van en la pestaña "Variables", NO en "Secrets".

  AZURE_CLIENT_ID        = ${GH_CLIENT_ID}
  AZURE_TENANT_ID        = ${TENANT_ID}
  AZURE_SUBSCRIPTION_ID  = ${SUBSCRIPTION_ID}
  TFSTATE_RESOURCE_GROUP = ${OPS_RG}
  TFSTATE_STORAGE_ACCOUNT= ${STATE_SA}
  TFSTATE_CONTAINER      = ${STATE_CONTAINER}
  AZURE_RESOURCE_GROUP   = ${DEV_RG}
  AZURE_LOCATION         = ${LOCATION}
  NAME_SUFFIX            = ${SUFFIX}

  La credencial federada acepta solo: ${SUBJECT}
  Preparación inicial terminada.
EOF
