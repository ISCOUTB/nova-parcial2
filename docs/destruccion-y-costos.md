# Costos y destrucción de infraestructura — Grupo NOVA

**Proyecto:** Infraestructura y despliegue automatizado en Azure   
**Región:** Brazil South (`brazilsouth`)

## 1. Cuándo eliminaremos los recursos

**No debemos destruir la infraestructura antes de la evaluación del profesor.** Nuestra aplicación y sus evidencias deben seguir disponibles durante la sustentación.

Como los recursos pueden generar costos mientras existen, preparamos un procedimiento para eliminarlos después de terminar la evaluación y confirmar que ya no los necesitamos.

## 2. Procedimiento de destrucción

Desde la raíz del repositorio, la persona autorizada puede ejecutar el script en Git Bash o Azure Cloud Shell, después de iniciar sesión con `az login`:

```bash
bash scripts/destroy.sh
```

**Advertencia:** este comando elimina recursos reales de Azure. El script exige escribir `DESTRUIR` para continuar y verifica la suscripción configurada. No debe utilizarse únicamente para probar si funciona.

El orden importa porque Terraform necesita acceder a su estado remoto antes de que se eliminen los recursos de soporte.

| Etapa | Qué eliminamos | Comprobación posterior |
|---|---|---|
| **1. `terraform destroy`** | La Container App, su entorno, ACR y sus imágenes, Log Analytics, identidad administrada de descarga y rol `AcrPull`. | Revisar `az resource list -g rg-nova-t2-dev`. |
| **2. Grupo de recursos del proyecto** | `rg-nova-t2-dev`, preparado por `bootstrap.sh`, junto con los recursos de soporte ligados a ese grupo. | `az group exists -n rg-nova-t2-dev` debe devolver `false`. |
| **3. Grupo de soporte (opcional, al final)** | `rg-nova-t2-ops`, donde se encuentran el almacenamiento del estado y la identidad federada de GitHub. | `az group exists -n rg-nova-t2-ops` debe devolver `false`. |

El script solicita confirmaciones adicionales para eliminar los grupos. El grupo de soporte se elimina al final, porque hacerlo antes dejaría a Terraform sin el estado necesario para identificar los recursos que administra.

Después de eliminar el grupo de soporte, los workflows que dependen de esos recursos ya no podrán utilizar la misma configuración de Azure. Para reconstruir la infraestructura se debe repetir la preparación inicial con `scripts/bootstrap.sh` y continuar con el arranque del proyecto.

### Comprobación previa sin borrar recursos

Antes de la evaluación, Sofía generó un plan de destrucción **sin ejecutarlo**:

```bash
terraform -chdir=infra plan -destroy -var-file=../config/dev.tfvars -no-color > docs/evidencias/10-plan-destroy.txt
```

El archivo [10-plan-destroy.txt](evidencias/10-plan-destroy.txt) permite revisar qué recursos administra Terraform y cuáles se verían afectados. Los grupos de recursos y el almacenamiento de soporte deben revisarse por separado porque no forman parte de los seis recursos principales administrados mediante esta configuración.

## 3. Cómo controlamos los costos

Trabajamos con la suscripción Azure for Students de Sofía. Para el taller utilizamos recursos reducidos y algunas configuraciones que limitan el consumo. Esto no significa que Azure sea gratuito en todos los casos: los precios y el gasto dependen de los servicios y del tiempo de uso.

### Estimación por servicio

Como referencia utilizamos la [API de precios minoristas de Azure](https://prices.azure.com/api/retail/prices), consultada por el equipo el 15 de octubre de 2026 para la región Brazil South.

| Servicio | Configuración del taller | Referencia de cobro |
|---|---|---|
| Azure Container Registry | SKU Basic (`acrnovat2ssab`) | La consulta del equipo registró aproximadamente **USD 0,1666 por día** (alrededor de USD 5 al mes), más almacenamiento adicional si corresponde. |
| Azure Container Apps | Consumption, `0.25` vCPU y `0.5Gi`, entre una y dos réplicas | Depende del consumo de CPU, memoria y solicitudes; puede aplicar la asignación gratuita del plan. No tenemos una cifra exacta validada para el taller. |
| Log Analytics | Cuota de `0.5 GB/día` y retención de 30 días | Depende de los datos ingeridos. No tenemos una cifra final validada para Brazil South. |
| Azure Storage | Cuenta estándar LRS para el estado remoto | Se cobra según almacenamiento y operaciones; el estado ocupa poco espacio. |
| Entorno Consumption e identidades administradas | Recursos de soporte de la solución | No se ha identificado una tarifa independiente por la mera creación del entorno de consumo o las identidades. |

La cifra de ACR es una referencia de la consulta del equipo, no un importe facturado. Para conocer el precio vigente se puede revisar la [calculadora oficial de Azure](https://azure.microsoft.com/pricing/calculator/) o volver a consultar la API de precios minoristas.

### Consultar el gasto real

El gasto del proyecto se revisa en **Azure Portal → Cost Management → Análisis de costos**, seleccionando la suscripción y, cuando corresponda, el filtro `proyecto = taller2-aca`. Los datos de consumo pueden aparecer con retraso.

No debemos reemplazar los precios estimados por cifras de gasto real hasta consultarlas directamente en Azure.

## 4. Medidas de control que aplicamos

| Medida | Configuración | Para qué sirve |
|---|---|---|
| Registro económico | ACR Basic en `infra/main.tf` | Reducir el costo fijo del registro frente a planes superiores. |
| Contenedor pequeño | `0.25` vCPU y `0.5Gi` en `config/dev.tfvars` | Limitar los recursos usados por réplica. |
| Escalado acotado | De `1` a `2` réplicas | Evitar un crecimiento ilimitado del número de contenedores. |
| Límite de registros | Log Analytics con `0.5 GB/día` y 30 días de retención | Controlar el volumen de información ingerida. |
| Etiquetas | `equipo`, `proyecto`, `ambiente`, `gestionado_por` | Identificar recursos y facilitar el análisis de costos. |
| Eliminación después de evaluar | `scripts/destroy.sh` | Evitar mantener recursos innecesarios una vez terminado el taller. |

Comprobamos CPU, memoria, réplicas y etiquetas mediante [09-limites-y-etiquetas.txt](evidencias/09-limites-y-etiquetas.txt) y las capturas de Azure.

## 5. Cierre

Nuestra prioridad fue mantener la aplicación disponible durante la evaluación, con suficientes recursos para demostrar los cambios y con un consumo razonable. Al finalizar, Sofía y el equipo deberán verificar el alcance de la eliminación, ejecutar el procedimiento autorizado y revisar Cost Management para comprobar que no queden recursos innecesarios generando cargos.
