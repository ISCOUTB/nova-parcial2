# Registro de evidencias - Proyecto NOVA

## GitHub y control de versiones
- Repositorio institucional creado en GitHub.
- Rama `main` protegida mediante reglas.
- Cambios gestionados mediante Pull Requests.

## GitHub Actions
- Workflow `Infra - Validación Terraform`: ejecución exitosa.
- Workflow `Prueba OIDC Azure`: ejecución exitosa de la verificación de estructura del repositorio.
- Workflow `App - Validación y seguridad`: pendiente de los archivos de la aplicación.

## Azure y despliegue
- Variables de configuración de Azure registradas en GitHub Actions.
- Autenticación OIDC con Azure pendiente de completar y verificar.
- Infraestructura y despliegue pendientes de coordinación con la responsable de Azure y Terraform.

## Evidencias pendientes
- [ ] Captura de las reglas de protección de `main`.
- [ ] Captura de la ejecución exitosa de `Infra - Validación Terraform`.
- [ ] Captura de la ejecución exitosa de `Prueba OIDC Azure`.
- [ ] Captura de la aplicación desplegada y funcionando en Azure Container Apps.

## Estado general
El proyecto continúa en desarrollo. La validación de la infraestructura y la estructura básica del repositorio ya se han comprobado. Quedan pendientes los archivos de la aplicación, la autenticación OIDC real y el despliegue en Azure.
