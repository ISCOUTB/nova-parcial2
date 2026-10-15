# Proyecto NOVA - Taller 2

## Descripción
NOVA es un proyecto académico que utiliza Azure Container Apps, Docker, Terraform y GitHub Actions para automatizar la construcción, validación y despliegue de una aplicación web.

## Tecnologías
- Python y Flask para la aplicación.
- Docker para la contenerización.
- Azure Container Apps para el despliegue.
- Azure Container Registry (ACR) para almacenar imágenes Docker.
- Terraform para gestionar la infraestructura.
- GitHub Actions para automatizar los procesos CI/CD.
- Trivy y Checkov para el análisis de seguridad.

## Estructura del repositorio
- `.github/workflows/`: flujos de trabajo automatizados.
- `app/`: código fuente de la aplicación.
- `infra/`: archivos de infraestructura como código.
- `config/`: configuración del entorno.
- `docs/`: documentación y evidencias del proyecto.
- `scripts/`: scripts auxiliares.

## Validaciones
El proyecto contempla la validación del código, la construcción de la imagen Docker, el análisis de vulnerabilidades y la validación de la infraestructura Terraform.

## Despliegue
El despliegue está previsto en Azure Container Apps mediante GitHub Actions y autenticación OIDC, evitando almacenar credenciales de Azure directamente en el repositorio.

La ejecución de cambios en la infraestructura debe coordinarse con la persona responsable de Terraform y Azure.

## Estado del proyecto
Proyecto académico en desarrollo. La integración y el despliegue de la aplicación dependen de la disponibilidad del código fuente, la configuración de Azure y la autenticación OIDC.

## Equipo
Proyecto grupal de Ingeniería de Sistemas y Computación - Universidad Tecnológica de Bolívar.
