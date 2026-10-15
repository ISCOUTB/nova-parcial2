# Matriz de requisitos y aceptación — Taller 2 NOVA

**Equipo:** NOVA (Sofía, Sara, Ana y Bianca)  
**Proyecto:** Aplicación HTTP en Azure Container Apps con Terraform y GitHub Actions  

> **Instrucciones:** Esta matriz se basa en la guía interna del Taller 2 del grupo NOVA. Marcar un requisito como **Cumplido** solo después de revisar su evidencia real. No subir tokens, contraseñas, claves ni valores de secretos.

## Matriz de seguimiento

| ID | Requisito obligatorio | Responsable | Evidencia que debes verificar | Estado |
|---|---|---|---|---|
| R1 | Código alojado en GitHub | Ana | URL del repositorio `nova-aca-taller2` | Pendiente |
| R2 | Infraestructura creada con Terraform | Sofía | Archivos `infra/`, backend remoto y ejecución de `apply` | Pendiente |
| R3 | Workflows de GitHub Actions | Ana | `.github/workflows/app.yml` e `infra.yml` y ejecuciones | Pendiente |
| R4 | Separar cambios de aplicación, infraestructura y configuración | Ana | Ejecuciones diferenciadas para `app/**`, `infra/**` y `config/**` | Pendiente |
| R5 | Cambio en la aplicación despliega nueva versión automáticamente | Ana y Sara | Workflow exitoso y URL mostrando nueva versión | Pendiente |
| R6 | Cambio de infraestructura se valida y aplica con Terraform | Sofía y Ana | Logs de `fmt`, `validate`, Checkov, `plan` y `apply` | Pendiente |
| R7 | Controles Checkov y Trivy | Bianca y Ana | Logs y resultados de ambos análisis | Pendiente |
| R8 | No guardar credenciales en el repositorio; preferir OIDC | Ana y Sofía | Credencial federada y configuración de workflows sin claves | Pendiente |
| R9 | README completo: arquitectura, despliegue, variables, acceso, evidencias y destrucción | Bianca | `README.md` revisado | Pendiente |
| R10 | Etiquetas de equipo, proyecto y ambiente | Sofía | Etiquetas verificadas en Terraform y Azure | Pendiente |
| R11 | Límites de recursos para controlar costos | Sofía | 0,25 vCPU, 0,5 Gi, máximo dos réplicas y ACR Basic | Pendiente |
| R12 | Demostrar cambios, seguridad y despliegue exitoso | Todas | Evidencias de las demostraciones de la Fase 6 | Pendiente |
| R13 | URL pública de la aplicación o instrucciones de acceso | Ana | Output `app_url` y acceso HTTP verificable | Pendiente |
| R14 | Dockerfile entregado | Sara | `app/Dockerfile` | Pendiente |
| R15 | Diagrama de arquitectura | Bianca | `docs/arquitectura.md` y diagrama | Pendiente |
| R16 | Evidencias de Checkov y Trivy | Bianca | Registros y capturas en `docs/evidencias/` | Pendiente |
| R17 | Decisiones técnicas, limitaciones y mejoras | Bianca y todas | `docs/decisiones.md` | Pendiente |
| R18 | ACR y entorno de Container Apps con Terraform | Sofía | Recursos en `infra/` y comprobación en Azure | Pendiente |
| R19 | Aplicación con ingreso HTTP externo | Sofía | `external_enabled = true` y prueba a la URL | Pendiente |
| R20 | Escalado mínimo y máximo configurado | Sofía | Mínimo una réplica, máximo dos; salida de Azure CLI | Pendiente |
| R21 | Construir, analizar y publicar imagen desde GitHub Actions | Ana | Ejecución `app.yml` e imagen publicada en ACR | Pendiente |
| R22 | Crear revisión nueva al cambiar imagen | Ana | Resultado de actualización y lista de revisiones | Pendiente |
| R23 | Variables no sensibles con Terraform; sensibles como secretos | Sofía y Ana | Configuración y referencias sin mostrar valores secretos | Pendiente |
| R24 | Mostrar revisión anterior y nueva creadas por proceso automatizado | Ana y Bianca | Lista de revisiones y ejecuciones `app.yml` | Pendiente |
| R25 | Presentar repositorio, ejecuciones, aplicación, seguridad y decisiones | Bianca | Carpeta completa de evidencias y guía de sustentación | Pendiente |

## Criterios para actualizar los estados

- **Pendiente:** aún no hay implementación o no se ha recibido evidencia.
- **En proceso:** el responsable está trabajando, pero falta la comprobación.
- **Bloqueado:** hay un impedimento específico que debe anotarse en la sección siguiente.
- **Cumplido:** hay evidencia verificable y el requisito supera su comprobación.

## Registro de bloqueos

| Fecha/hora | Requisito | Problema o dependencia | Responsable | Próxima acción |
|---|---|---|---|---|
| 14/10/2026 | R1 | Ana todavía no ha creado el repositorio | Ana | Crear `nova-aca-taller2`, invitar a las tres compañeras y compartir la URL |

## Evidencias por recopilar

- [ ] Aplicación pública y respuesta de `/health`.
- [ ] Versión 1 y versión 2 visibles en la aplicación.
- [ ] Ejecuciones de `app.yml` e `infra.yml` en GitHub Actions.
- [ ] Imagen en Azure Container Registry con etiqueta del commit SHA.
- [ ] Resultado de Checkov.
- [ ] Resultado de Trivy.
- [ ] Revisiones anterior y nueva en Azure Container Apps.
- [ ] Plan y aplicación del cambio de infraestructura.
- [ ] Etiquetas actualizadas, réplicas, CPU y memoria.
- [ ] Autenticación mediante OIDC sin exponer credenciales.

## Control final antes de la entrega

- [ ] Los 25 requisitos están revisados.
- [ ] Cada requisito marcado **Cumplido** tiene evidencia comprobable.
- [ ] No hay secretos visibles en los archivos ni capturas.
- [ ] `README.md`, `docs/arquitectura.md` y `docs/decisiones.md` son coherentes con lo desplegado.
- [ ] Se conoce el enlace del repositorio y de la aplicación.
- [ ] Está descrito el procedimiento de destrucción, pero no se ejecuta antes de la evaluación.
- [ ] El equipo confirma el medio de entrega y envía el material.

