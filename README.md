# Proyecto NOVA — Taller 2

**Asignatura:** Infraestructura para TI  
**Equipo:** Grupo NOVA — Sofía, Sara, Ana y Bianca  
**Universidad:** Universidad Tecnológica de Bolívar  
**Repositorio:** https://github.com/ISCOUTB/nova-parcial2

## 1. Descripción del proyecto

El proyecto NOVA consiste en implementar una aplicación web desarrollada en Python con Flask, empaquetarla mediante Docker y desplegarla en Microsoft Azure utilizando Azure Container Apps.

La infraestructura se administra mediante Terraform, mientras que GitHub Actions permite automatizar la validación, el análisis de seguridad, la construcción de imágenes y el despliegue de la aplicación.

El objetivo principal es implementar una solución reproducible, segura y organizada que permita diferenciar los cambios realizados en la aplicación de aquellos relacionados con la infraestructura.

## 2. Objetivos

- Desplegar una aplicación web accesible mediante HTTPS.
- Definir y administrar la infraestructura utilizando Terraform.
- Automatizar procesos de integración y despliegue con GitHub Actions.
- Construir imágenes Docker y almacenarlas en Azure Container Registry.
- Incorporar herramientas de seguridad como Checkov y Trivy.
- Utilizar autenticación OIDC para evitar credenciales permanentes de Azure en GitHub.
- Configurar límites de recursos para controlar los costos.
- Conservar evidencias técnicas de las pruebas y despliegues.

## 3. Tecnologías utilizadas

| Tecnología | Función |
|---|---|
| Python 3.12 | Lenguaje utilizado en la aplicación |
| Flask | Framework para crear los endpoints HTTP |
| Gunicorn | Servidor que ejecuta la aplicación en el contenedor |
| Docker | Construcción y ejecución de la imagen de la aplicación |
| Terraform | Definición y administración de infraestructura |
| Microsoft Azure | Plataforma de servicios en la nube |
| Azure Container Apps | Ejecución de la aplicación en contenedores |
| Azure Container Registry | Almacenamiento de imágenes Docker |
| Azure Storage | Almacenamiento remoto del estado de Terraform |
| GitHub | Control de versiones y colaboración |
| GitHub Actions | Automatización de validación y despliegue |
| Checkov | Análisis de seguridad de Terraform |
| Trivy | Análisis de vulnerabilidades de imágenes Docker |
| OIDC | Autenticación federada entre GitHub y Azure |

## 4. Arquitectura de la solución

La arquitectura conecta GitHub Actions, Terraform y los servicios de Azure para automatizar el despliegue de la aplicación.

**Componentes principales:**

1. **Repositorio GitHub:** almacena el código, la infraestructura y la documentación.
2. **GitHub Actions:** ejecuta los flujos de validación, construcción, seguridad y despliegue.
3. **Terraform:** administra los recursos de infraestructura de Azure.
4. **Azure Container Registry:** almacena las imágenes Docker publicadas.
5. **Azure Container Apps Environment:** proporciona el entorno de ejecución.
6. **Azure Container App:** ejecuta la aplicación y permite su acceso mediante HTTPS.
7. **Log Analytics:** centraliza información operativa.
8. **Identidad administrada:** permite descargar imágenes de ACR mediante el permiso `AcrPull`.
9. **Azure Storage:** conserva el estado remoto de Terraform.

El diagrama detallado se encuentra en:

`docs/arquitectura.md`

## 5. Estructura del repositorio

| Ruta | Descripción |
|---|---|
| `app/app.py` | Código principal de la aplicación Flask |
| `app/Dockerfile` | Instrucciones para construir la imagen Docker |
| `app/requirements.txt` | Dependencias Python |
| `app/test_app.py` | Pruebas básicas de los endpoints |
| `infra/main.tf` | Definición de los recursos Azure |
| `infra/variables.tf` | Variables de entrada de Terraform |
| `infra/outputs.tf` | Valores de salida de infraestructura |
| `infra/backend.tf` | Configuración del estado remoto |
| `infra/versions.tf` | Versiones de Terraform y del proveedor Azure |
| `config/dev.tfvars` | Configuración no sensible del entorno de desarrollo |
| `.github/workflows/app.yml` | Pipeline de aplicación y despliegue |
| `.github/workflows/infra.yml` | Pipeline de validación y planificación Terraform |
| `.github/workflows/oidc-test.yml` | Verificación de autenticación OIDC |
| `.checkov.yaml` | Configuración del análisis Checkov |
| `docs/arquitectura.md` | Documentación y diagrama de arquitectura |
| `docs/decisiones.md` | Decisiones técnicas, limitaciones y mejoras |
| `docs/matriz-requisitos.md` | Seguimiento de los 25 requisitos |
| `docs/evidencias/` | Reportes y registros técnicos |

**Nota:** Los archivos Terraform hacen referencia a un script de preparación `scripts/bootstrap.sh`, pero ese script no se encuentra actualmente publicado en el repositorio. La preparación inicial de recursos debe coordinarse con la responsable de Azure.

## 6. Requisitos previos

Para trabajar con el proyecto se recomienda disponer de:

- Git.
- Visual Studio Code.
- Python 3.12.
- Docker Desktop.
- Terraform 1.9.0 o superior.
- Azure CLI.
- Una suscripción de Azure con permisos adecuados.
- Acceso autorizado al repositorio del Grupo NOVA.

Las operaciones de infraestructura deben realizarse con la coordinación de Sofía y Ana para evitar modificaciones simultáneas en los recursos.

## 7. Ejecución local de la aplicación

### 7.1. Clonar el repositorio

Desde una terminal:

`git clone https://github.com/ISCOUTB/nova-parcial2.git`

Ingresar a la carpeta:

`cd nova-parcial2`

### 7.2. Construir la imagen Docker

Con Docker Desktop en funcionamiento, ejecutar desde la raíz del repositorio:

`docker build -t nova-app:local ./app`

### 7.3. Ejecutar el contenedor

`docker run --rm -p 8000:8000 -e APP_ENV=dev nova-app:local`

Este comando ejecuta localmente la aplicación y publica el puerto 8000.

### 7.4. Acceder a la aplicación

**Página principal:**

http://localhost:8000/

**Endpoint de salud:**

http://localhost:8000/health

La página principal devuelve un objeto JSON con el mensaje de la aplicación, la versión y el ambiente.

El endpoint `/health` devuelve un objeto JSON con `status` igual a `ok` y la versión de la aplicación.

### 7.5. Pruebas con Python

Como alternativa, para ejecutar las pruebas sin Docker:

1. Ingresar a la carpeta `app`.
2. Instalar las dependencias mediante `python -m pip install -r requirements.txt`.
3. Ejecutar `python -m pytest`.

Las pruebas verifican las respuestas de las rutas `/` y `/health`.

## 8. Configuración de infraestructura con Terraform

Los recursos están definidos dentro de `infra/`.

### Recursos principales

- Azure Container Registry, plan Basic.
- Azure Container Apps Environment con perfil Consumption.
- Azure Container App.
- Log Analytics Workspace.
- Identidad administrada.
- Asignación del rol `AcrPull`.

El grupo de recursos se utiliza como recurso preexistente y no es creado por `infra/main.tf`.

### Configuración del entorno

El archivo `config/dev.tfvars` contiene los parámetros no sensibles utilizados en desarrollo.

| Variable | Valor configurado |
|---|---|
| `location` | `brazilsouth` |
| `resource_group_name` | `rg-nova-t2-dev` |
| `environment` | `dev` |
| `name_suffix` | `ssab` |
| `container_port` | `8000` |
| `cpu` | `0.25` |
| `memory` | `0.5Gi` |
| `min_replicas` | `1` |
| `max_replicas` | `2` |
| `create_container_app` | `true` |

El archivo también contiene `initial_image_tag`, que identifica la imagen utilizada para la creación inicial de la aplicación.

### Estado remoto

Terraform utiliza un backend `azurerm` para guardar su estado en Azure Storage.

Antes de inicializar Terraform se debe contar con un grupo de recursos de soporte, una cuenta de almacenamiento y un contenedor para el estado remoto, además de los permisos necesarios.

Sus identificadores se proporcionan al ejecutar `terraform init` mediante los parámetros `-backend-config`.

### Validación

Una vez configurado el backend y la autenticación, las validaciones disponibles incluyen:

- `terraform fmt -check -recursive infra`
- `terraform -chdir=infra init -backend=false`
- `terraform -chdir=infra validate`

El pipeline de infraestructura también ejecuta `terraform plan` utilizando `config/dev.tfvars` y las variables necesarias para Azure.

**Importante:** La ejecución de `terraform apply` debe realizarse únicamente por las responsables autorizadas y sobre el estado remoto correcto. El workflow de infraestructura revisado todavía no contiene un paso de `apply` automatizado.

## 9. Variables y credenciales

El proyecto separa las variables no sensibles de la información confidencial.

### Variables Terraform

Las variables no sensibles se encuentran en `config/dev.tfvars` y `infra/variables.tf`.

Entre ellas se incluyen:

- `location`
- `environment`
- `resource_group_name`
- `name_suffix`
- `cpu`
- `memory`
- `min_replicas`
- `max_replicas`
- `initial_image_tag`

### Variables de GitHub Actions

Los workflows utilizan variables de repositorio como:

| Variable | Finalidad |
|---|---|
| `AZURE_CLIENT_ID` | Identificador de la aplicación o identidad utilizada en OIDC |
| `AZURE_TENANT_ID` | Identificador del tenant de Azure |
| `AZURE_SUBSCRIPTION_ID` | Identificador de la suscripción |
| `AZURE_RESOURCE_GROUP` | Grupo de recursos de la aplicación |
| `AZURE_LOCATION` | Región de Azure |
| `ACR_NAME` | Nombre de Azure Container Registry |
| `ACR_LOGIN_SERVER` | Servidor de imágenes de ACR |
| `CONTAINER_APP_NAME` | Nombre de Azure Container App |
| `TFSTATE_RESOURCE_GROUP` | Grupo de recursos del backend |
| `TFSTATE_STORAGE_ACCOUNT` | Cuenta de almacenamiento del backend |
| `TFSTATE_CONTAINER` | Contenedor del estado remoto |
| `NAME_SUFFIX` | Sufijo de nombres de recursos |

### Información sensible

El proyecto utiliza el secreto de GitHub:

`APP_SECRET`

Durante los procesos Terraform se transmite mediante la variable de entorno `TF_VAR_app_secret`.

**Medidas de seguridad:**

- No publicar contraseñas ni tokens en Git.
- No guardar `APP_SECRET` en `dev.tfvars`.
- No incluir valores de secretos en capturas o reportes.
- Utilizar autenticación OIDC para el acceso de GitHub Actions a Azure.
- Limitar los permisos de las identidades utilizadas.
- Proteger el estado remoto de Terraform, que puede contener información sensible.

## 10. Automatización con GitHub Actions

El repositorio contiene workflows separados para la aplicación y la infraestructura.

### 10.1. Pipeline de aplicación — `app.yml`

Se ejecuta para validar cambios relacionados con la aplicación y puede activarse manualmente.

Sus principales tareas son:

1. Descargar el repositorio.
2. Verificar los archivos principales de la aplicación.
3. Construir la imagen Docker.
4. Ejecutar Trivy.
5. Autenticarse en Azure mediante OIDC cuando corresponda.
6. Construir y publicar la imagen en Azure Container Registry.
7. Actualizar la imagen de Azure Container Apps.
8. Comprobar el endpoint `/health`.

La publicación y el despliegue se realizan en las ejecuciones correspondientes a cambios integrados en `main`.

**Evidencia de ejecución exitosa:**

https://github.com/ISCOUTB/nova-parcial2/actions/runs/38685137897

### 10.2. Pipeline de infraestructura — `infra.yml`

Se activa cuando existen cambios en archivos de infraestructura o configuración, y también permite ejecución manual.

Actualmente realiza:

1. Descarga del repositorio.
2. Instalación de Terraform.
3. Comprobación de formato.
4. Inicialización sin backend.
5. Validación de la configuración.
6. Autenticación OIDC para la planificación.
7. Inicialización con backend remoto.
8. Ejecución de `terraform plan`.

**Evidencia de validación y planificación exitosa:**

https://github.com/ISCOUTB/nova-parcial2/actions/runs/38683030473

**Limitación:** La versión revisada del workflow no ejecuta automáticamente Checkov ni `terraform apply`. Su incorporación está pendiente de validación por las responsables.

## 11. Seguridad

### Checkov

Se utiliza Checkov para revisar configuraciones de seguridad de la infraestructura Terraform.

El análisis local realizado obtuvo:

- **Controles aprobados:** 2.
- **Controles fallidos:** 8.
- **Controles omitidos:** 0.

Los hallazgos se concentran en configuraciones y características de seguridad y disponibilidad del registro Azure Container Registry.

Los controles fallidos deben revisarse con Sofía para determinar cuáles pueden corregirse y cuáles requieren una decisión técnica documentada.

**Evidencia:** `docs/evidencias/checkov-terraform.txt`

### Trivy

Trivy analiza vulnerabilidades de paquetes del sistema y dependencias utilizadas en las imágenes Docker.

El análisis local se realizó sobre la imagen `nova-app:seguridad`, utilizando Trivy 0.69.3.

**Resultados:**

- Vulnerabilidades HIGH detectadas: 0.
- Vulnerabilidades CRITICAL detectadas: 0.

Este resultado corresponde a los criterios `--severity HIGH,CRITICAL` y `--ignore-unfixed`. No constituye una garantía de ausencia de vulnerabilidades de otras severidades o sin corrección disponible.

**Evidencia:** `docs/evidencias/trivy-resultado.md`

El pipeline de aplicación también tiene integrado Trivy y cuenta con ejecuciones exitosas.

## 12. Acceso a la aplicación desplegada

La aplicación se encuentra configurada para permitir conexiones HTTPS mediante Azure Container Apps.

La URL pública puede consultarse desde Azure Portal, Azure CLI o la salida `app_url` de Terraform, cuando el estado de infraestructura esté inicializado correctamente.

Para consultar el dominio desde Azure CLI, con una sesión autenticada y permisos adecuados:

`az containerapp show --name ca-nova-t2-dev --resource-group rg-nova-t2-dev --query properties.configuration.ingress.fqdn --output tsv`

La URL corresponde al dominio obtenido, precedido por `https://`.

**URL pública definitiva:** Pendiente de incorporar y verificar en este README con el equipo.

Una vez disponible, deben verificarse:

- Página principal: `/`
- Endpoint de salud: `/health`

La ejecución exitosa del pipeline ya incluye una comprobación automática del endpoint de salud.

## 13. Control de versiones y revisiones

Las imágenes Docker publicadas por GitHub Actions utilizan el SHA del commit como identificador de versión.

Al actualizar la imagen de la Container App, Azure puede crear una nueva revisión de la aplicación.

La configuración Terraform utiliza `revision_mode = "Single"`, por lo que la versión activa recibe el tráfico y las revisiones anteriores pueden permanecer inactivas.

Para consultar las revisiones, con acceso autorizado a Azure:

`az containerapp revision list --name ca-nova-t2-dev --resource-group rg-nova-t2-dev --output table`

Para completar la demostración académica deben documentarse:

- La revisión anterior.
- La revisión nueva.
- Las imágenes asociadas.
- El estado de cada revisión.
- La ejecución de GitHub Actions que generó el cambio.

La aplicación permite mostrar un identificador mediante `APP_VERSION`, cuyo valor predeterminado en el código es `v1`. La demostración de dos versiones debe verificarse realmente antes de reportarla como completada.

## 14. Control de costos

El proyecto utiliza límites de recursos para reducir el consumo durante el desarrollo.

| Recurso | Configuración |
|---|---|
| Azure Container Registry | Basic |
| Container Apps | Perfil Consumption |
| CPU por réplica | 0.25 vCPU |
| Memoria por réplica | 0.5 GiB |
| Réplicas mínimas | 1 |
| Réplicas máximas | 2 |
| Log Analytics | Cuota diaria configurada de 0.5 GB |

Estas configuraciones buscan controlar el gasto, pero no garantizan un costo cero.

El equipo debe revisar periódicamente el consumo y eliminar los recursos cuando finalice la evaluación, siguiendo el procedimiento autorizado.

## 15. Procedimiento de destrucción de infraestructura

La destrucción debe realizarse únicamente después de finalizar la evaluación y con autorización del equipo.

**Procedimiento general:**

1. Confirmar que el profesor ya evaluó el proyecto.
2. Guardar las capturas, los resultados y los enlaces necesarios para la entrega.
3. Verificar la suscripción y el grupo de recursos de Azure.
4. Coordinar con Sofía y Ana el acceso al backend remoto de Terraform.
5. Verificar que no existan ejecuciones simultáneas del pipeline.
6. Preparar la autenticación y las variables necesarias.
7. Revisar los recursos que serían destruidos mediante `terraform plan -destroy`.
8. Ejecutar `terraform destroy` únicamente después de confirmar el alcance del plan.
9. Revisar por separado los recursos de soporte creados fuera de Terraform, como el grupo de recursos y el almacenamiento del estado.
10. Confirmar que no queden recursos del proyecto generando costos innecesarios.

**Advertencia:** El backend remoto de Azure Storage y otros recursos de preparación inicial podrían no formar parte del estado administrado por esta configuración. Su eliminación debe tratarse por separado.

**No ejecutar la destrucción antes de la sustentación.**

## 16. Evidencias del proyecto

La carpeta `docs/evidencias/` reúne los resultados disponibles de las pruebas.

| Archivo | Contenido |
|---|---|
| `checkov-terraform.txt` | Resultado del análisis de seguridad Terraform |
| `trivy-resultado.md` | Análisis de seguridad de la imagen Docker |
| `registro.md` | Registro de evidencias del proyecto |

También se dispone de:

- `docs/arquitectura.md`
- `docs/decisiones.md`
- `docs/matriz-requisitos.md`
- Historial de Pull Requests.
- Ejecuciones de GitHub Actions.
- Configuraciones de aplicación e infraestructura.

**Evidencias todavía por consolidar:**

- URL pública definitiva.
- Capturas del despliegue de Azure Container Apps.
- Revisiones anterior y nueva.
- Límites de recursos comprobados en Azure.
- Resolución o justificación de hallazgos de Checkov.
- Aplicación automatizada de cambios de infraestructura.

## 17. Estado actual y limitaciones

El proyecto cuenta con una aplicación Docker, una infraestructura definida mediante Terraform y pipelines de GitHub Actions.

Se han comprobado ejecuciones exitosas de construcción, análisis Trivy, publicación en ACR, actualización de Container Apps y verificación del endpoint de salud.

También existen reportes locales de seguridad y documentación de arquitectura, decisiones técnicas y requisitos.

Sin embargo, todavía se deben completar algunas evidencias y controles, principalmente:

- Revisión de los ocho hallazgos de Checkov.
- Automatización y evidencia de los controles de infraestructura pendientes.
- Demostración de cambios de versión y revisiones.
- Comprobación final de recursos y configuraciones en Azure.

El estado individual de los 25 requisitos se encuentra actualizado en `docs/matriz-requisitos.md`.

## 18. Equipo de trabajo

| Integrante | Responsabilidad principal |
|---|---|
| Sofía | Infraestructura Azure y Terraform |
| Sara | Aplicación Python, Flask y Docker |
| Ana | GitHub Actions, integración y despliegue |
| Bianca | Documentación, seguimiento de requisitos, seguridad y evidencias |

## 19. Conclusión

El Taller 2 NOVA demuestra cómo integrar infraestructura como código, contenedores, servicios en la nube y automatización para desplegar una aplicación web.

El uso de Terraform, Docker y GitHub Actions permite organizar los procesos técnicos, mientras que Checkov y Trivy aportan mecanismos para identificar riesgos de seguridad.

Los resultados obtenidos representan un avance importante en la construcción de una solución automatizada. Las evidencias y validaciones pendientes se mantienen identificadas para completar correctamente la entrega y sustentación del proyecto.