# Proyecto NOVA — Parcial 2

**Asignatura:** Infraestructura para TI  
**Universidad:** Universidad Tecnológica de Bolívar  
**Equipo:** NOVA
**Repositorio:** https://github.com/ISCOUTB/nova-parcial2

## 1. Nuestro proyecto

En el Taller 2 desarrollamos una aplicación web con Python y Flask, la empaquetamos con Docker y la desplegamos en Azure Container Apps. Utilizamos Terraform para administrar la infraestructura y GitHub Actions para automatizar las validaciones, los análisis de seguridad y los despliegues.

Nuestro objetivo fue comprobar que podíamos modificar la aplicación y la infraestructura por separado, publicar los cambios de forma controlada y conservar evidencias de cada prueba. También tuvimos en cuenta la seguridad y los costos de la suscripción académica de Azure.

## 2. Tecnologías utilizadas

| Tecnología | ¿Para qué la utilizamos? |
|---|---|
| Python 3.12 y Flask | Crear la aplicación y los endpoints HTTP. |
| Gunicorn y Docker | Ejecutar la aplicación en un contenedor. |
| Terraform | Definir y administrar los recursos de Azure. |
| Azure Container Apps | Alojar y publicar la aplicación mediante HTTPS. |
| Azure Container Registry (ACR) | Almacenar las imágenes Docker. |
| Azure Storage | Guardar el estado remoto de Terraform. |
| Log Analytics | Centralizar registros del entorno. |
| Git y GitHub | Organizar los cambios mediante ramas y Pull Requests. |
| GitHub Actions | Automatizar las comprobaciones y los despliegues. |
| Checkov y Trivy | Analizar la configuración de Terraform y las imágenes Docker. |
| OIDC | Autenticar los pipelines de GitHub en Azure sin una contraseña permanente. |

## 3. Arquitectura

Separamos el proyecto en dos procesos. El primero administra la infraestructura con Terraform; el segundo construye y publica las imágenes de nuestra aplicación. Ambos utilizan GitHub Actions y se conectan con Azure mediante OIDC.

La aplicación obtiene sus imágenes de ACR mediante una identidad administrada con permiso `AcrPull`. Azure Container Apps la ejecuta en un entorno de consumo y Log Analytics recibe los registros operativos. El estado de Terraform se conserva en Azure Storage.

Nuestro diagrama Mermaid y la explicación de las conexiones están en [docs/arquitectura.md](docs/arquitectura.md).

## 4. Estructura del repositorio

| Ruta | Contenido |
|---|---|
| `app/` | Aplicación Flask, Dockerfile, dependencias y pruebas. |
| `infra/` | Recursos y variables definidos con Terraform. |
| `config/dev.tfvars` | Parámetros no sensibles del ambiente de desarrollo. |
| `scripts/bootstrap.sh` | Preparación inicial de los recursos de soporte y de la identidad federada. |
| `scripts/destroy.sh` | Procedimiento de eliminación controlada de la infraestructura. |
| `.github/workflows/app.yml` | Validación, Trivy, publicación de imágenes y despliegue. |
| `.github/workflows/infra.yml` | Checkov, validación, planificación y aplicación de Terraform. |
| `.github/workflows/oidc-test.yml` | Pruebas de autenticación OIDC. |
| `.checkov.yaml` | Configuración y excepciones justificadas de Checkov. |
| `docs/` | Arquitectura, decisiones, requisitos, costos y evidencias. |

## 5. Ejecutar y probar la aplicación localmente

Necesitamos Git y Docker Desktop. Para ejecutar Pytest sin Docker también necesitamos Python 3.12.

Desde una terminal, clonamos el repositorio:

```bash
git clone https://github.com/ISCOUTB/nova-parcial2.git
cd nova-parcial2
```

Con Docker en funcionamiento, construimos la imagen y ejecutamos el contenedor desde la raíz del proyecto:

```bash
docker build -t nova-app:local ./app
docker run --rm -p 8000:8000 -e APP_ENV=dev nova-app:local
```

Los dos endpoints quedan disponibles en:

- **Aplicación:** http://localhost:8000/
- **Salud:** http://localhost:8000/health

La ruta `/` devuelve un JSON con el mensaje, la versión y el ambiente. La ruta `/health` devuelve el estado `ok` y la versión. En el código actual, `APP_VERSION` tiene el valor predeterminado `v2`.

Para ejecutar las pruebas de Python en otra terminal:

```bash
cd app
python -m pip install -r requirements.txt
python -m pytest
```

En Docker usamos Gunicorn en el puerto `8000` y un usuario sin privilegios, en lugar de ejecutar el servicio como `root`. También incluimos `.dockerignore` para evitar archivos innecesarios dentro de la imagen.

## 6. Infraestructura de Azure

Definimos la infraestructura principal en `infra/`. Terraform administra ACR Basic, Log Analytics, el entorno de Container Apps, la Container App, una identidad administrada y su asignación `AcrPull`.

Antes del despliegue inicial, `scripts/bootstrap.sh` prepara los grupos de recursos, el almacenamiento del estado remoto y la identidad federada que utiliza GitHub Actions. Estos recursos de soporte no se deben confundir con los que administra `infra/main.tf`.

### Configuración del ambiente

Los valores no sensibles están en `config/dev.tfvars`:

| Parámetro | Valor |
|---|---|
| Región | `brazilsouth` |
| Ambiente | `dev` |
| Grupo de recursos | `rg-nova-t2-dev` |
| Sufijo de recursos | `ssab` |
| Puerto | `8000` |
| CPU | `0.25` vCPU |
| Memoria | `0.5Gi` |
| Réplicas mínimas y máximas | `1` y `2` |
| Perfil de Container Apps | `Consumption` |
| Modo de revisiones | `Single` |

La variable `initial_image_tag` identifica la imagen utilizada durante la creación inicial de la Container App. Las actualizaciones posteriores de esa imagen se gestionan desde el pipeline de aplicación.

### Validaciones de Terraform

Desde la raíz del repositorio se pueden comprobar el formato y la configuración sin utilizar el backend remoto:

```bash
terraform fmt -check -recursive infra
terraform -chdir=infra init -backend=false
terraform -chdir=infra validate
```

Las operaciones con backend remoto, `plan` y `apply` requieren autenticación y permisos autorizados. Las coordinamos con Sofía y Ana para evitar modificaciones simultáneas del estado.

## 7. Variables y credenciales

Separamos las variables de configuración de los datos sensibles. Los parámetros generales están en los archivos Terraform y en `config/dev.tfvars`.

GitHub Actions utiliza variables de repositorio como `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`, `AZURE_LOCATION`, `ACR_NAME`, `ACR_LOGIN_SERVER`, `CONTAINER_APP_NAME`, `NAME_SUFFIX`, `TFSTATE_RESOURCE_GROUP`, `TFSTATE_STORAGE_ACCOUNT` y `TFSTATE_CONTAINER`.

El valor sensible `APP_SECRET` se guarda en GitHub Secrets y se entrega a Terraform mediante `TF_VAR_app_secret`. La Container App lo recibe a través de una referencia a su propio secreto. No publicamos sus valores en el repositorio ni en las capturas.

Para la autenticación de GitHub Actions en Azure configuramos OIDC, evitando guardar contraseñas permanentes de la identidad de despliegue. El estado remoto de Terraform también se trata como información sensible.

## 8. Automatización con GitHub Actions

### Infraestructura: `.github/workflows/infra.yml`

Cuando modificamos `infra/`, `config/`, `.checkov.yaml` o el propio workflow, GitHub Actions ejecuta las verificaciones correspondientes. En las ejecuciones desde `main`, después de validar, también puede planificar y aplicar los cambios.

Las etapas son Checkov, `terraform fmt`, inicialización para validación, `terraform validate`, autenticación OIDC, inicialización con backend remoto, `terraform plan` y `terraform apply`.

Configuramos concurrencia para que las ejecuciones de infraestructura no se superpongan.

**Evidencia:** [Ejecución exitosa de infraestructura, Checkov, plan y apply](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38744864451).

### Aplicación: `.github/workflows/app.yml`

Cuando modificamos `app/` o el workflow de aplicación, construimos la imagen Docker y la analizamos con Trivy. En las ejecuciones correspondientes a `main`, el pipeline se autentica con Azure, publica la imagen en ACR utilizando el SHA completo del commit, actualiza la Container App y comprueba `/health`.

**Evidencia:** [Ejecución exitosa de la versión v2](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318).

Los cambios exclusivamente documentales no tienen por qué activar ambos workflows; cada uno utiliza filtros de rutas.

## 9. Seguridad

### Checkov

En el primer análisis de Terraform obtuvimos **2 controles aprobados y 8 fallidos**, relacionados con características de Azure Container Registry. Después de revisar los hallazgos con Sofía, justificamos ocho excepciones para el ambiente académico `dev` y las configuramos mediante `skip-check` en `.checkov.yaml`.

El análisis posterior informó **2 aprobados, 0 fallidos y 0 omitidos contabilizados** porque esos ocho controles quedaron excluidos. **No significa que los ocho riesgos se hayan corregido.** Sus justificaciones, medidas compensatorias y riesgos residuales están detallados en [docs/decisiones.md](docs/decisiones.md).

**Reportes:** `docs/evidencias/checkov-terraform.txt` y `docs/evidencias/checkov-excepciones-2026-10-15.txt`.

### Trivy

El análisis local con Trivy 0.69.3 sobre `nova-app:seguridad` no detectó vulnerabilidades HIGH ni CRITICAL **dentro de los filtros utilizados**, incluido `--ignore-unfixed`. También comprobamos su ejecución automatizada en GitHub Actions. Estos resultados no garantizan que no existan otros tipos de vulnerabilidades ni sustituyen un escaneo de secretos.

**Reporte:** `docs/evidencias/trivy-resultado.md`. Las capturas y los enlaces están en [docs/evidencias/registro.md](docs/evidencias/registro.md).

## 10. Acceso a nuestra aplicación en Azure

Nuestra aplicación está publicada mediante HTTPS en la dirección:

**https://ca-nova-t2-dev.bravepond-62a4a131.brazilsouth.azurecontainerapps.io**

- **Aplicación:** https://ca-nova-t2-dev.bravepond-62a4a131.brazilsouth.azurecontainerapps.io/
- **Salud:** https://ca-nova-t2-dev.bravepond-62a4a131.brazilsouth.azurecontainerapps.io/health

La evidencia `docs/evidencias/06-revisiones-e-imagenes.txt` registra que `/` devolvió `version: v2` y `/health` devolvió `status: ok`, también con `v2`. La disponibilidad debe comprobarse nuevamente antes de la sustentación, porque depende de que los recursos sigan activos.

Si tenemos acceso a Azure CLI, podemos consultar el dominio con:

```bash
az containerapp show --name ca-nova-t2-dev --resource-group rg-nova-t2-dev --query properties.configuration.ingress.fqdn --output tsv
```

## 11. Cambios de versión y revisiones

Para demostrar la automatización actualizamos nuestra aplicación de `v1` a `v2`:

| Versión | Commit | Ejecución de GitHub Actions |
|---|---|---|
| `v1` | `2e8b26f` | [Ejecución anterior](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38685137897) |
| `v2` | `3cfe621` | [Ejecución posterior](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318) |

El reporte `docs/evidencias/06-revisiones-e-imagenes.txt` registra ambas imágenes en ACR, identificadas mediante sus SHA completos. También muestra que la aplicación pública respondía con `v2`.

Para consultar todas las revisiones disponibles, incluidas las inactivas:

```bash
az containerapp revision list --name ca-nova-t2-dev --resource-group rg-nova-t2-dev --all --output table
```

Nuestra Container App utiliza el modo `Single`. Durante la comprobación de Sofía se observó una única revisión listada, `ca-nova-t2-dev--latest`, asociada a la imagen `v2`. **No disponemos de dos revisiones diferenciadas visibles para compararlas directamente en Azure.** Por eso demostramos el cambio de versión mediante los dos pipelines, las imágenes conservadas en ACR y las respuestas de la aplicación. Esta es una limitación observada en nuestro despliegue, no una afirmación sobre todos los entornos de Azure Container Apps.

## 12. Costos y destrucción de recursos

Para reducir el consumo utilizamos ACR Basic, el perfil Consumption, `0.25` vCPU, `0.5Gi`, un máximo de dos réplicas y una cuota diaria de ingesta en Log Analytics de `0.5 GB`. Estas medidas ayudan a controlar el gasto, aunque no lo eliminan.

Los precios consultados, los controles aplicados y el procedimiento de eliminación están en [docs/destruccion-y-costos.md](docs/destruccion-y-costos.md).

Preparamos `scripts/destroy.sh` para eliminar los recursos administrados por Terraform y después los de soporte, con confirmaciones explícitas. **No debemos ejecutar la destrucción antes de la evaluación del profesor.** También conservamos un plan de destrucción sin ejecutarlo en `docs/evidencias/10-plan-destroy.txt`.

## 13. Documentación y evidencias

| Documento | Contenido |
|---|---|
| [Arquitectura](docs/arquitectura.md) | Componentes y diagrama Mermaid. |
| [Decisiones técnicas](docs/decisiones.md) | Justificaciones de seguridad y limitaciones del proyecto. |
| [Matriz de requisitos](docs/matriz-requisitos.md) | Seguimiento de R1–R25. |
| [Registro de evidencias](docs/evidencias/registro.md) | Capturas, reportes y enlaces de ejecución. |
| [Destrucción y costos](docs/destruccion-y-costos.md) | Procedimiento y control de consumo. |
| [Reporte de Trivy](docs/evidencias/trivy-resultado.md) | Resultado local y referencia al análisis automatizado. |

La carpeta `docs/evidencias/` también contiene capturas de las pruebas locales de Sara, la aplicación pública, el cambio de versión, las revisiones consultadas en Azure, Checkov, Trivy, límites, etiquetas y pipelines.

## 14. Nuestro equipo

| Integrante | Responsabilidad principal |
|---|---|
| Sofía | Infraestructura de Azure, Terraform y costos. |
| Sara | Aplicación Flask, Docker y pruebas. |
| Ana | GitHub Actions, integración y despliegue. |
| Bianca | Documentación, seguridad y organización de evidencias. |

Trabajamos sobre el mismo repositorio, coordinando las pruebas necesarias para integrar la aplicación con la infraestructura. El proyecto nos permitió comprobar el proceso de despliegue automatizado, identificar riesgos de seguridad y documentar las limitaciones encontradas durante las pruebas.
