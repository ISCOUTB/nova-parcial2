# Destrucción y costos — Taller 2 (NOVA)

Responsable: Sofía (Azure y Terraform). Suscripción: Azure for Students de Sofía (ID `87877b30…`).

## 1. Destrucción

### Cuándo

**Solo después de la evaluación del profesor.** Hasta entonces la aplicación debe seguir publicada.

### Cómo

Desde la raíz del repositorio, en Git Bash o Cloud Shell, con `az login` hecho por la Propietaria de la suscripción:

```bash
bash scripts/destroy.sh
```

El script pide escribir `DESTRUIR` antes de empezar y selecciona la suscripción **por ID**.

### Orden y qué borra cada paso

| Paso | Qué hace | Qué borra | Cómo comprobarlo |
| --- | --- | --- | --- |
| 1 | `terraform destroy -var-file=../config/dev.tfvars` | Container App `ca-nova-t2-dev`, entorno `cae-nova-t2-dev`, ACR `acrnovat2ssab` (con sus imágenes), Log Analytics `log-nova-t2-dev`, identidad `id-nova-t2-pull` y su rol AcrPull | `az resource list -g rg-nova-t2-dev` devuelve una lista vacía |
| 2 | `az group delete -n rg-nova-t2-dev` (pide escribir `BORRAR-DEV`) | El grupo del proyecto, creado por `bootstrap.sh`, y los roles asignados sobre él (los de la identidad de GitHub y el Reader) | `az group exists -n rg-nova-t2-dev` → `false` |
| 3 (opcional, al final de todo) | `az group delete -n rg-nova-t2-ops` (pide escribir `BORRAR-OPS`) | La Storage Account del estado de Terraform y la identidad `id-nova-t2-github` con sus credenciales federadas | `az group exists -n rg-nova-t2-ops` → `false` |

El paso 1 va primero porque Terraform necesita su estado (en `rg-nova-t2-ops`) para saber qué borrar. Si se hiciera el paso 3 antes, Terraform perdería su "memoria" y habría que borrar los recursos a mano.

Después del paso 3 ya **no funcionan** Terraform ni los workflows de GitHub Actions que entran a Azure. Para reconstruir todo desde cero: `scripts/bootstrap.sh` y luego los pasos del arranque.

### Verificación previa sin borrar nada

Antes de la evaluación se revisó el plan de destrucción **sin ejecutarlo**:

```bash
terraform -chdir=infra plan -destroy -var-file=../config/dev.tfvars -no-color > docs/evidencias/10-plan-destroy.txt
```

Ver `docs/evidencias/10-plan-destroy.txt`. Debe proponer destruir **solo** los 6 recursos de Terraform y no tocar los grupos de recursos.

## 2. Costos

Todo se cobra al crédito de Azure for Students: la suscripción no tiene tarjeta asociada. Si el crédito se agota, Azure deshabilita la suscripción; no se genera una factura.

### Precios por recurso (región Brazil South, USD)

Fuente: API oficial de precios minoristas de Azure, `https://prices.azure.com/api/retail/prices`, consultada el 15 de octubre de 2026.

| Recurso | Configuración del taller | Cómo cobra | Precio (Brazil South) |
| --- | --- | --- | --- |
| Azure Container Registry | Basic, `acrnovat2ssab` | Tarifa fija por día mientras exista; 10 GB de almacenamiento incluidos | **USD 0,1666 por día** (≈ USD 5 por mes). Almacenamiento adicional: USD 0,10 por GB/mes |
| Azure Container Apps | Plan de consumo, 0,25 vCPU / 0,5 GiB, 1–2 réplicas | Por vCPU-segundo y GiB-segundo usados, más solicitudes; el plan de consumo incluye una cantidad gratuita mensual | **Pregunta abierta:** no se pudo consultar el precio para Brazil South. Ver la consulta abajo |
| Log Analytics | `log-nova-t2-dev`, tope de 0,5 GB/día, retención de 30 días | Por GB ingerido; la retención dentro del período incluido no se cobra aparte | **Pregunta abierta:** no se pudo consultar el precio para Brazil South |
| Storage del estado | `stnovat2tfssab`, Standard LRS, pocos KB | Por GB almacenado y operaciones | **Pregunta abierta.** Con unos KB de estado, el costo es despreciable |
| Entorno de Container Apps e identidades | `cae-nova-t2-dev`, `id-nova-t2-pull`, `id-nova-t2-github` | El entorno de consumo no tiene tarifa propia; las identidades administradas no tienen costo | — |

**Para completar las preguntas abiertas**, abrir en el navegador estas consultas a la misma API oficial y anotar el `unitPrice` de cada medidor:

- Container Apps: `https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure Container Apps' and armRegionName eq 'brazilsouth'`
- Log Analytics: `https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Log Analytics' and armRegionName eq 'brazilsouth'`
- Storage: `https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Storage' and armRegionName eq 'brazilsouth' and skuName eq 'Standard LRS'`

Alternativa: la calculadora oficial, `https://azure.microsoft.com/pricing/calculator/`, con la región Brazil South.

### Gasto real

El gasto real se consulta en el portal: **Cost Management → Análisis de costos**, con la suscripción `87877b30…`. Se puede filtrar por la etiqueta `proyecto = taller2-aca`. Los costos aparecen con algunas horas de retraso.

### Medidas de control de costos ya aplicadas

| Medida | Dónde | Efecto |
| --- | --- | --- |
| ACR en SKU **Basic** | `infra/main.tf` | El SKU más económico; sin geo-replicación ni red privada |
| Container App con **0,25 vCPU / 0,5 GiB** | `config/dev.tfvars` | El tamaño mínimo de Container Apps |
| **Máximo 2 réplicas** (validación en Terraform: entre 1 y 3) | `config/dev.tfvars`, `infra/variables.tf` | Limita el gasto si llega mucho tráfico |
| Log Analytics con **tope de 0,5 GB/día** y **30 días** de retención | `infra/main.tf` | Evita gastos inesperados por logs |
| **Etiquetas** `equipo`, `proyecto`, `ambiente`, `gestionado_por` en todos los recursos | `infra/main.tf` (`local.tags`) | Permiten filtrar el gasto en Cost Management |
| **Destrucción** después de la evaluación | `scripts/destroy.sh` | El ACR deja de cobrar su tarifa diaria |
