# Matriz de requisitos y seguimiento — Grupo NOVA

**Proyecto:** Infraestructura y despliegue automatizado en Azure  
**Equipo:** NOVA 
**Repositorio:** https://github.com/ISCOUTB/nova-parcial2  
**Revisión:** 15 de octubre de 2026

## 1. Cómo organizamos el seguimiento

En esta matriz registramos los 25 requisitos del taller, las integrantes responsables y las pruebas que respaldan cada resultado. Evitamos dar por cumplida una actividad solo porque el código exista: buscamos una ejecución, un reporte o una comprobación que podamos mostrar al profesor.

Utilizamos tres estados: **Cumplido** cuando contamos con evidencia suficiente; **En proceso** cuando existe un avance, pero falta una comprobación o cierre; y **Pendiente** cuando no hay implementación ni prueba suficiente.

## 2. Matriz de requisitos R1–R25

| ID | Requisito | Responsable | Evidencia y resultado | Estado |
|---|---|---|---|---|
| R1 | Código alojado en GitHub | Ana | Repositorio `ISCOUTB/nova-parcial2`, ramas y Pull Requests. | Cumplido |
| R2 | Infraestructura creada con Terraform | Sofía | Recursos en `infra/`, estado remoto, `terraform apply` exitoso y `09-limites-y-etiquetas.txt`. | Cumplido |
| R3 | Workflows de GitHub Actions | Ana | `app.yml` e `infra.yml`, ambos con ejecuciones exitosas. | Cumplido |
| R4 | Separar cambios de aplicación, infraestructura y configuración | Ana | Filtros de rutas y ejecuciones diferenciadas; cambio de `version_infra` por el PR #47. | Cumplido |
| R5 | Desplegar una nueva versión al modificar la aplicación | Ana y Sara | Cambio `v1 → v2`, PR #40, commits `2e8b26f` y `3cfe621`, pipelines exitosos y respuesta pública `v2`. | Cumplido |
| R6 | Validar y aplicar cambios con Terraform | Sofía y Ana | Checkov, `fmt`, `validate`, `plan` y `apply` en la ejecución `38744864451`; `07-cambio-etiqueta.txt`. | Cumplido |
| R7 | Controles de seguridad Checkov y Trivy | Bianca y Ana | Ambos análisis integrados en los workflows; ocho excepciones de Checkov justificadas con riesgos residuales. | Cumplido |
| R8 | No publicar credenciales y preferir OIDC | Ana y Sofía | OIDC comprobado y secretos referenciados. Falta la revisión final de permisos y posibles datos sensibles. | En proceso |
| R9 | README completo | Bianca | README final con arquitectura, ejecución, variables, seguridad, URL, revisiones y destrucción. | Cumplido |
| R10 | Etiquetas de equipo, proyecto y ambiente | Sofía | Valores verificados en `09-limites-y-etiquetas.txt` y `07-cambio-etiqueta.txt`. | Cumplido |
| R11 | Límites de recursos y control de costos | Sofía | CPU `0.25`, memoria `0.5Gi`, réplicas `1–2`, ACR Basic y evidencias de Azure. | Cumplido |
| R12 | Demostrar cambios, seguridad y despliegue | Todas | Pipelines, imágenes, reportes y respuestas públicas disponibles; falta la presentación final. | En proceso |
| R13 | URL pública o instrucciones de acceso | Ana | URL incluida en el README; evidencia HTTP en `06-revisiones-e-imagenes.txt` y capturas `05-url-v2.png`. | Cumplido |
| R14 | Entregar Dockerfile | Sara | `app/Dockerfile`, Gunicorn, Python 3.12, usuario sin privilegios y capturas locales. | Cumplido |
| R15 | Diagrama de arquitectura | Bianca | `docs/arquitectura.md` con diagrama Mermaid y explicación de componentes. | Cumplido |
| R16 | Evidencias de Checkov y Trivy | Bianca | Reportes locales, excepciones, capturas de Trivy y ejecuciones automatizadas. | Cumplido |
| R17 | Decisiones, limitaciones y mejoras | Bianca y todas | `docs/decisiones.md`: elección de tecnologías, ocho excepciones, riesgos y limitación de revisiones. | Cumplido |
| R18 | ACR y entorno de Container Apps con Terraform | Sofía | Recursos declarados, estado Terraform, lista de recursos y ejecución de `apply`. | Cumplido |
| R19 | Aplicación con ingreso HTTP externo | Sofía | Ingreso externo HTTPS y respuestas públicas `/` y `/health` verificadas. | Cumplido |
| R20 | Escalado mínimo y máximo | Sofía | `1` y `2` réplicas comprobadas en el reporte y en capturas del portal. | Cumplido |
| R21 | Construir, analizar y publicar la imagen desde GitHub Actions | Ana | Construcción Docker, Trivy y publicación en ACR con etiqueta SHA. | Cumplido |
| R22 | Crear una revisión nueva al actualizar la imagen | Ana | Actualización automática verificada; falta demostrar el identificador de una revisión nueva distinto del anterior. | En proceso |
| R23 | Variables no sensibles y secretos | Sofía y Ana | Variables declaradas en Terraform y GitHub; `APP_SECRET` mediante referencias. Falta revisión final de exposición y permisos. | En proceso |
| R24 | Mostrar la revisión anterior y la nueva | Ana y Bianca | Dos imágenes SHA y dos pipelines, pero Azure solo mostró `ca-nova-t2-dev--latest`; limitación documentada. | En proceso |
| R25 | Presentación de repositorio, pruebas, seguridad y decisiones | Bianca | Archivos, capturas y enlaces integrados; falta realizar la sustentación final. | En proceso |

**Nota sobre R9:** su estado «Cumplido» corresponde al contenido final de esta entrega. Solo debe mantenerse así después de publicar el README actualizado en `main`.

## 3. Evidencias principales

### Despliegue de la aplicación

Comprobamos el cambio de versión y sus dos ejecuciones:

- **`v1`**, commit `2e8b26f`: https://github.com/ISCOUTB/nova-parcial2/actions/runs/38685137897
- **`v2`**, commit `3cfe621`: https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318

El archivo `docs/evidencias/06-revisiones-e-imagenes.txt` muestra las dos imágenes en ACR y el resultado público de `v2`. También contamos con capturas de la aplicación y de `/health`.

### Infraestructura y seguridad

La ejecución https://github.com/ISCOUTB/nova-parcial2/actions/runs/38744864451 verificó Checkov y las fases de Terraform, incluyendo `plan` y `apply`.

El cambio independiente de infraestructura se registra en `docs/evidencias/07-cambio-etiqueta.txt`, donde aparece `version_infra = 2`. Los recursos, las etiquetas y los límites efectivos se encuentran en `docs/evidencias/09-limites-y-etiquetas.txt`.

El análisis inicial de Checkov encontró dos controles aprobados y ocho fallidos. Justificamos esos ocho controles como excepciones académicas mediante `skip-check`, conservando sus riesgos residuales. El reporte posterior informó dos aprobados y cero fallidos **por las exclusiones**, no porque se corrigieran los ocho controles.

Trivy no detectó vulnerabilidades HIGH ni CRITICAL con corrección disponible bajo los filtros utilizados, tanto en la prueba local como en las ejecuciones automatizadas verificadas.

**Archivos:** `checkov-terraform.txt`, `checkov-excepciones-2026-10-15.txt`, `trivy-resultado.md` y sus capturas, todos en `docs/evidencias/`.

## 4. Limitación con las revisiones (R22 y R24)

La Container App usa el modo `Single`. En el reporte que preparó Sofía aparece una sola revisión listada, `ca-nova-t2-dev--latest`, asociada a la imagen de `v2`. Aunque las imágenes de `v1` y `v2` permanecen en ACR y ambas ejecuciones finalizaron correctamente, no contamos con dos identificadores de revisión diferenciados para mostrarlos directamente en Azure.

La situación quedó registrada en `docs/evidencias/06-revisiones-e-imagenes.txt` y en las capturas `06-revision-actual.png` y `06b-revisiones-inactivas.png`. Por eso mantenemos R22 y R24 en proceso, con una explicación clara de lo que sí pudimos demostrar.

## 5. Últimas comprobaciones antes de entregar

- Revisar los permisos de OIDC, los secretos y las capturas para evitar exponer información sensible (R8 y R23).
- Comprobar que el README y los demás documentos finales estén publicados en `main`.
- Verificar la URL pública inmediatamente antes de la evaluación.
- Preparar la demostración de los dos pipelines, las imágenes de ACR, los reportes de seguridad y la limitación de revisiones (R12 y R25).
- Mantener los recursos activos hasta que termine la evaluación; el procedimiento de eliminación está en `docs/destruccion-y-costos.md`.

El detalle de cada captura, reporte y enlace está en [docs/evidencias/registro.md](evidencias/registro.md). Así mantenemos esta matriz enfocada en los requisitos, sin repetir toda la documentación de las pruebas.
