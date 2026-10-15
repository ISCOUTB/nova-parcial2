# Matriz de requisitos y aceptación — Taller 2 NOVA

**Equipo:** NOVA (Sofía, Sara, Ana y Bianca)
**Proyecto:** Aplicación HTTP en Azure Container Apps con Terraform y GitHub Actions
**Repositorio:** https://github.com/ISCOUTB/nova-parcial2
**Estado general:** En proceso de validación y recopilación de evidencias finales.

## 1. Objetivo

Esta matriz permite llevar el control de los 25 requisitos obligatorios del Taller 2 del Grupo NOVA, identificando a las responsables, las evidencias necesarias y el estado actual de cada actividad.

Los estados se asignan teniendo en cuenta los archivos publicados en GitHub, los resultados de Checkov y Trivy y las ejecuciones verificadas de GitHub Actions.

Un requisito se considera cumplido únicamente cuando existe evidencia suficiente de su implementación y funcionamiento. Los requisitos que aún dependen de pruebas, capturas o validaciones se mantienen en proceso o pendientes.

## 2. Matriz de seguimiento de requisitos

| ID | Requisito obligatorio | Responsable | Evidencia y verificación | Estado |
|---|---|---|---|---|
| R1 | Código alojado en GitHub | Ana | Repositorio institucional `ISCOUTB/nova-parcial2`, con código, documentación, ramas y Pull Requests. | Cumplido |
| R2 | Infraestructura creada con Terraform | Sofía | Archivos de `infra/`, configuración del backend remoto y comprobación de la ejecución de `terraform apply`. | En proceso |
| R3 | Workflows de GitHub Actions | Ana | Archivos `.github/workflows/app.yml` e `infra.yml`, con ejecuciones exitosas verificadas. | Cumplido |
| R4 | Separar cambios de aplicación, infraestructura y configuración | Ana | Filtros de rutas para `app/**`, `infra/**` y `config/**`. Falta completar la demostración de su funcionamiento diferenciado. | En proceso |
| R5 | Cambio en la aplicación despliega una nueva versión automáticamente | Ana y Sara | Ejecución de despliegue exitosa. Falta demostrar un cambio concreto del código y su nueva versión publicada. | En proceso |
| R6 | Cambio de infraestructura se valida y aplica con Terraform | Sofía y Ana | Validaciones `fmt`, `validate` y `plan` ejecutadas. Falta comprobar Checkov integrado y la aplicación automatizada de cambios. | En proceso |
| R7 | Controles de seguridad Checkov y Trivy | Bianca y Ana | Checkov ejecutado localmente: 2 controles aprobados y 8 fallidos. Trivy ejecutado localmente y correctamente en GitHub Actions. Falta resolver o justificar los hallazgos e integrar Checkov en el pipeline. | En proceso |
| R8 | No guardar credenciales en el repositorio; preferir OIDC | Ana y Sofía | Inicio de sesión OIDC ejecutado correctamente en GitHub Actions. Falta completar la revisión de secretos y credenciales. | En proceso |
| R9 | README completo: arquitectura, despliegue, variables, acceso, evidencias y destrucción | Bianca | Existe `README.md`, pero requiere completar instrucciones técnicas, variables, acceso a la aplicación, evidencias y destrucción de recursos. | En proceso |
| R10 | Etiquetas de equipo, proyecto y ambiente | Sofía | Etiquetas `equipo`, `proyecto` y `ambiente` declaradas en Terraform. Falta comprobarlas directamente en Azure. | En proceso |
| R11 | Límites de recursos para controlar costos | Sofía | Configuración de CPU, memoria, réplicas y ACR Basic en Terraform. Falta comprobar los valores efectivos en Azure. | En proceso |
| R12 | Demostrar cambios, seguridad y despliegue exitoso | Todas | Existen análisis de seguridad y ejecuciones exitosas. Falta organizar y completar las demostraciones finales. | En proceso |
| R13 | URL pública de la aplicación o instrucciones de acceso | Ana | El pipeline verificó exitosamente el endpoint `/health`. Falta registrar la URL pública definitiva en la documentación. | En proceso |
| R14 | Dockerfile entregado | Sara | Archivo `app/Dockerfile` publicado, con Gunicorn y usuario sin privilegios de administrador. | Cumplido |
| R15 | Diagrama de arquitectura | Bianca | Documento `docs/arquitectura.md` con diagrama Mermaid, componentes y descripción de la solución. | Cumplido |
| R16 | Evidencias de Checkov y Trivy | Bianca | Archivos `docs/evidencias/checkov-terraform.txt` y `docs/evidencias/trivy-resultado.md` publicados. Faltan evidencias finales del análisis automatizado de Checkov. | En proceso |
| R17 | Decisiones técnicas, limitaciones y mejoras | Bianca y todas | Documento `docs/decisiones.md` integrado al repositorio mediante PR #36. | Cumplido |
| R18 | ACR y entorno de Container Apps con Terraform | Sofía | Recursos definidos en `infra/` y ejecución funcional de la aplicación. Falta conservar evidencia de su creación mediante Terraform. | En proceso |
| R19 | Aplicación con ingreso HTTP externo | Sofía | `external_enabled = true` declarado en Terraform y verificación exitosa del endpoint HTTPS `/health` en GitHub Actions. | Cumplido |
| R20 | Escalado mínimo y máximo configurado | Sofía | Parámetros de réplicas definidos en Terraform. Falta comprobar los valores efectivos mediante Azure CLI o el portal. | En proceso |
| R21 | Construir, analizar y publicar imagen desde GitHub Actions | Ana | Ejecución exitosa de construcción Docker, análisis Trivy y publicación de la imagen en ACR. | Cumplido |
| R22 | Crear una revisión nueva al cambiar la imagen | Ana | El despliegue automatizado terminó correctamente. Falta comprobar y documentar la revisión creada en Azure Container Apps. | En proceso |
| R23 | Variables no sensibles con Terraform y sensibles como secretos | Sofía y Ana | Variables declaradas en Terraform y referencias a secretos. Falta realizar la validación final de su configuración y manejo seguro. | En proceso |
| R24 | Mostrar la revisión anterior y la nueva creadas por un proceso automatizado | Ana y Bianca | Falta obtener y documentar la lista de revisiones anterior y nueva de Azure Container Apps. | Pendiente |
| R25 | Presentar repositorio, ejecuciones, aplicación, seguridad y decisiones | Bianca | Repositorio y documentos disponibles. Falta organizar las capturas, enlaces y evidencias para la presentación final. | En proceso |

## 3. Criterios para actualizar los estados

Los requisitos se clasifican utilizando los siguientes criterios:

- **Pendiente:** la actividad todavía no tiene una implementación o evidencia suficiente para comenzar su validación.
- **En proceso:** existe una implementación parcial o una actividad desarrollada, pero faltan pruebas, correcciones o evidencias.
- **Bloqueado:** existe un impedimento concreto que debe resolverse antes de continuar.
- **Cumplido:** la implementación solicitada cuenta con evidencia verificable y satisface el requisito correspondiente.

Los estados deben actualizarse cuando exista nueva evidencia. No se debe marcar como cumplido un requisito únicamente porque su código esté escrito o porque la actividad esté asignada a una integrante.

## 4. Registro de bloqueos y dependencias

| Fecha | Requisito | Problema o dependencia | Responsable | Próxima acción |
|---|---|---|---|---|
| 15/10/2026 | R6 | El workflow de infraestructura contiene las validaciones y la planificación, pero todavía no evidencia la ejecución automatizada de Checkov y `terraform apply`. | Ana y Sofía | Completar los controles faltantes y guardar los resultados. |
| 15/10/2026 | R7 | Checkov identificó ocho controles fallidos en la configuración de ACR. | Sofía y Bianca | Revisar cada hallazgo y corregirlo o documentar una excepción justificada. |
| 15/10/2026 | R9 | El README todavía no contiene todos los apartados solicitados. | Bianca | Completar arquitectura, variables, despliegue, acceso, evidencias y destrucción. |
| 15/10/2026 | R16 | Existen los resultados locales de Checkov y Trivy, pero faltan evidencias completas de los controles automatizados. | Bianca y Ana | Conservar enlaces y registros de GitHub Actions y finalizar Checkov. |
| 15/10/2026 | R22 y R24 | No se ha incorporado evidencia de las revisiones anterior y nueva de la Container App. | Ana y Bianca | Obtener la lista de revisiones de Azure y registrar sus identificadores y estados. |
| 15/10/2026 | R25 | Falta consolidar las evidencias y preparar la sustentación final del equipo. | Bianca y todas | Organizar capturas, enlaces, documentación y demostraciones. |

**Nota:** El problema anterior de actualización de la Container App fue corregido y la ejecución posterior de GitHub Actions terminó exitosamente. Por tanto, no se mantiene como bloqueo activo.

## 5. Evidencias verificadas

### 5.1. Repositorio y documentación

- [x] Repositorio de GitHub creado y disponible.
- [x] Código fuente de la aplicación publicado.
- [x] Dockerfile de la aplicación publicado.
- [x] Diagrama de arquitectura documentado.
- [x] Matriz de requisitos creada.
- [x] Documento de decisiones técnicas y limitaciones integrado.
- [ ] README completado con todos los apartados exigidos.

### 5.2. Seguridad

- [x] Análisis local de Checkov ejecutado.
- [x] Reporte de Checkov guardado en `docs/evidencias/checkov-terraform.txt`.
- [x] Análisis local de Trivy ejecutado.
- [x] Resultados de Trivy documentados en `docs/evidencias/trivy-resultado.md`.
- [x] Análisis Trivy ejecutado correctamente en GitHub Actions.
- [ ] Revisión de los ocho hallazgos de Checkov con Sofía.
- [ ] Integración y comprobación de Checkov en GitHub Actions.
- [ ] Validación final de la gestión de secretos y credenciales.

### 5.3. GitHub Actions e infraestructura

- [x] Workflow de aplicación disponible.
- [x] Workflow de infraestructura disponible.
- [x] Ejecución exitosa de validación Terraform.
- [x] Ejecución exitosa de `terraform plan`.
- [x] Autenticación OIDC exitosa en ejecuciones de GitHub Actions.
- [x] Construcción de imagen Docker desde GitHub Actions.
- [x] Publicación de imagen en Azure Container Registry.
- [x] Actualización exitosa de la Container App.
- [x] Verificación exitosa del endpoint `/health`.
- [ ] Evidencia de `terraform apply` automatizado.
- [ ] Demostración diferenciada de cambios de aplicación e infraestructura.
- [ ] Demostración de cambio de versión de la aplicación.

### 5.4. Azure Container Apps

- [x] Configuración de ingreso externo declarada en Terraform.
- [x] Aplicación actualizada y endpoint de salud verificado mediante GitHub Actions.
- [ ] URL pública incorporada al README.
- [ ] Captura o registro de las etiquetas de recursos.
- [ ] Captura o registro de límites de CPU y memoria.
- [ ] Comprobación de mínimo y máximo de réplicas.
- [ ] Evidencia de la revisión anterior y de la nueva revisión.
- [ ] Evidencia de la aplicación mostrando dos versiones diferentes.

## 6. Enlaces a evidencias del proyecto

### Repositorio

https://github.com/ISCOUTB/nova-parcial2

### Diagrama de arquitectura

`docs/arquitectura.md`

### Decisiones técnicas

`docs/decisiones.md`

### Reporte Checkov

`docs/evidencias/checkov-terraform.txt`

### Reporte Trivy

`docs/evidencias/trivy-resultado.md`

### Pull Requests de documentación y seguridad

- **PR #32:** configuración y evidencia de Checkov.
- **PR #34:** resultados del análisis Trivy.
- **PR #36:** decisiones técnicas y limitaciones de seguridad.

### Ejecuciones de GitHub Actions verificadas

**Aplicación, seguridad y despliegue exitoso:**

https://github.com/ISCOUTB/nova-parcial2/actions/runs/38685137897

**Validación y planificación Terraform exitosa:**

https://github.com/ISCOUTB/nova-parcial2/actions/runs/38683030473

Estas ejecuciones constituyen evidencia de las tareas indicadas en sus registros, pero no sustituyen la comprobación de las revisiones de Azure ni la ejecución de un `terraform apply` automatizado.

## 7. Actividades pendientes antes de la entrega

### Sofía — Infraestructura Azure

- Revisar los ocho hallazgos detectados por Checkov.
- Confirmar los recursos desplegados y sus etiquetas.
- Verificar los límites de CPU, memoria y escalado.
- Conservar evidencia de la aplicación de cambios de infraestructura mediante Terraform.

### Sara — Aplicación y Docker

- Confirmar el correcto funcionamiento de la aplicación.
- Coordinar una demostración de cambio de versión.
- Apoyar las pruebas de la imagen Docker y del endpoint de salud.

### Ana — GitHub Actions y automatización

- Conservar evidencias de las ejecuciones exitosas.
- Completar o coordinar la integración de Checkov en el workflow de infraestructura.
- Revisar la automatización de los cambios de infraestructura.
- Obtener evidencia de la creación y actualización de revisiones de Azure Container Apps.

### Bianca — Documentación y evidencias

- Actualizar esta matriz con los resultados finales.
- Completar el README.
- Mantener organizados los reportes de Checkov y Trivy.
- Documentar las revisiones anterior y nueva cuando Ana proporcione los resultados.
- Reunir las evidencias necesarias para la entrega y sustentación.

## 8. Control final antes de entregar

- [ ] Revisar los estados de los 25 requisitos con todo el equipo.
- [ ] Confirmar que cada requisito marcado como cumplido tenga su evidencia correspondiente.
- [ ] Revisar que no existan contraseñas, tokens o valores sensibles expuestos en el repositorio o en las capturas.
- [ ] Confirmar que `README.md`, `docs/arquitectura.md` y `docs/decisiones.md` sean coherentes con la infraestructura realmente desplegada.
- [ ] Completar los enlaces a la aplicación, al repositorio y a las ejecuciones de GitHub Actions.
- [ ] Adjuntar las evidencias de las revisiones anterior y nueva.
- [ ] Describir el procedimiento de destrucción de recursos sin ejecutarlo antes de la evaluación.
- [ ] Verificar que se cumplan todos los entregables solicitados por el profesor.
- [ ] Confirmar el formato de entrega y la sustentación con el equipo.

## 9. Observaciones finales

El Grupo NOVA cuenta con avances verificables en el repositorio, la documentación técnica, la construcción de imágenes Docker, el análisis de seguridad y el despliegue automatizado de la aplicación.

Los análisis locales permitieron registrar resultados concretos: Checkov identificó dos controles aprobados y ocho fallidos, mientras que Trivy no detectó vulnerabilidades altas ni críticas con corrección disponible bajo los filtros utilizados.

GitHub Actions también registra ejecuciones exitosas de validación Terraform, autenticación OIDC, análisis Trivy, publicación de la imagen y actualización de Azure Container Apps.

Sin embargo, todavía deben atenderse los hallazgos de Checkov, comprobarse la automatización completa de infraestructura, documentarse las revisiones de la aplicación y consolidarse las evidencias finales.

