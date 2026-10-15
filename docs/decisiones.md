# Decisiones técnicas, limitaciones y mejoras — Grupo NOVA

**Proyecto:** Taller 2 — Infraestructura y despliegue automatizado en Azure  


## 1. Decisiones técnicas implementadas

### Infraestructura como código

Se utiliza Terraform para definir los recursos de Azure de manera organizada y reproducible, evitando depender exclusivamente de configuraciones manuales.

### Plataforma de despliegue

Se seleccionó Azure Container Apps para ejecutar la aplicación web desarrollada con Python y Flask, utilizando Docker para empaquetarla.

### Registro de imágenes

Se configuró Azure Container Registry (ACR) en su plan Basic, priorizando el control de costos del proyecto académico.

Se deshabilitó la cuenta administradora del registro y se configuró una identidad administrada con permisos AcrPull para descargar imágenes.

### Recursos y costos

La infraestructura contempla límites de CPU, memoria y escalado para controlar el consumo de recursos. Su configuración y comportamiento real deben verificarse durante el despliegue.

### Automatización

Se utilizan GitHub Actions para validar el código, construir imágenes, analizar su seguridad y ejecutar los procesos relacionados con el despliegue.

La autenticación mediante OIDC está contemplada para evitar el uso de credenciales permanentes de Azure. Su funcionamiento debe validarse mediante evidencias de ejecución.

## 2. Resultados de seguridad

### Checkov

Se ejecutó Checkov sobre la infraestructura Terraform.

**Resultados:**
- 2 controles aprobados.
- 8 controles fallidos.
- 0 controles omitidos.

Los controles aprobados verificaron que la cuenta administradora de ACR está deshabilitada y que no se permite la descarga anónima de imágenes.

Los controles fallidos fueron:

| Control | Hallazgo |
|---|---|
| CKV_AZURE_166 | Cuarentena, análisis y verificación de imágenes |
| CKV_AZURE_163 | Análisis de vulnerabilidades del registro |
| CKV_AZURE_164 | Uso de imágenes firmadas o confiables |
| CKV_AZURE_139 | Restricción de acceso público al registro |
| CKV_AZURE_165 | Georreplicación |
| CKV_AZURE_167 | Retención de manifiestos sin etiqueta |
| CKV_AZURE_233 | Redundancia por zonas |
| CKV_AZURE_237 | Puntos de conexión de datos dedicados |

Estos ocho hallazgos permanecen abiertos. Sofía deberá revisar cuáles pueden corregirse con la configuración actual y cuáles requieren cambios de plan, arquitectura o costos.

**Evidencia:** `docs/evidencias/checkov-terraform.txt`

### Trivy

Se ejecutó Trivy 0.69.3 sobre la imagen Docker `nova-app:seguridad`.

**Resultados:**
- 0 vulnerabilidades HIGH detectadas.
- 0 vulnerabilidades CRITICAL detectadas.

El resultado corresponde al análisis local con las opciones `--severity HIGH,CRITICAL` y `--ignore-unfixed`. Por tanto, no representa una evaluación exhaustiva de todas las vulnerabilidades.

Este análisis ayuda a detectar problemas en la imagen antes del despliegue, pero no reemplaza todos los controles de seguridad del registro de contenedores.

**Evidencia:** `docs/evidencias/trivy-resultado.md`

## 3. Limitaciones identificadas

- El plan Basic de ACR debe evaluarse frente a los controles de seguridad avanzada, conectividad privada y disponibilidad requeridos.
- Se mantienen ocho controles fallidos de Checkov pendientes de revisión.
- El resultado de Trivy corresponde a una imagen local y a filtros específicos.
- Se necesita verificar que los controles automatizados de GitHub Actions se ejecuten y generen evidencia.
- Se deben confirmar mediante pruebas reales el despliegue, la aplicación pública y las revisiones de Azure Container Apps.

## 4. Mejoras propuestas

1. Revisar y corregir, cuando sea viable, los hallazgos de Checkov.
2. Evaluar los costos y beneficios de características avanzadas de ACR.
3. Mantener Trivy integrado en GitHub Actions para analizar las imágenes antes de publicarlas.
4. Verificar la autenticación OIDC y el manejo seguro de variables sensibles.
5. Conservar capturas y registros de los despliegues exitosos.
6. Actualizar periódicamente las dependencias y las imágenes base.
7. Revisar los controles de seguridad antes de utilizar la solución en un entorno productivo.

## 5. Conclusión

El Grupo NOVA ha implementado una base de infraestructura automatizada con herramientas de análisis de seguridad. Las pruebas locales permiten identificar riesgos y documentar los resultados.

Sin embargo, todavía es necesario revisar los ocho hallazgos de Checkov y comprobar los procesos automatizados y el despliegue real antes de considerar todos los requisitos completados.

Las decisiones de aceptación de riesgos y los cambios de infraestructura deberán validarse con las integrantes responsables del proyecto.
