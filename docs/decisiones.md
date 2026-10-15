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

### Justificación de las excepciones de Checkov

**Ambiente:** Desarrollo académico (`dev`)
**Recurso evaluado:** `azurerm_container_registry.acr`
**Plan utilizado:** Azure Container Registry Basic
**Responsable de la revisión técnica:** Sofía — Infraestructura y Terraform

Durante el análisis de seguridad con Checkov se identificaron ocho controles fallidos correspondientes a Azure Container Registry. Después de revisarlos con la responsable de infraestructura, se decidió mantener ACR Basic para el proyecto académico, teniendo en cuenta los costos y el alcance de la solución.

Los controles se registran como excepciones documentadas para el ambiente de desarrollo. Esta decisión no significa que los riesgos hayan desaparecido ni que los controles hayan sido corregidos.

#### Análisis individual de los controles

| Control | Justificación técnica | Control compensatorio | Riesgo residual |
|---|---|---|---|
| **CKV_AZURE_139** — Acceso público | ACR Basic no proporciona las mismas opciones de conectividad privada y restricciones de red de Premium. Se mantiene el acceso público para el ambiente académico. | Cuenta administradora deshabilitada, descargas anónimas deshabilitadas, autenticación mediante Microsoft Entra ID, OIDC y permisos mínimos `AcrPush`/`AcrPull`. | El endpoint del registro continúa accesible desde Internet, aunque las operaciones requieren autorización. |
| **CKV_AZURE_163** — Escaneo de vulnerabilidades | El análisis administrado mediante Microsoft Defender supone habilitar un servicio adicional con costo. | Trivy analiza las imágenes dentro de GitHub Actions antes de publicarlas y bloquea los hallazgos HIGH o CRITICAL incluidos en sus criterios. | No existe un análisis administrado continuo de las imágenes almacenadas. Pueden descubrirse nuevas vulnerabilidades después de la publicación. |
| **CKV_AZURE_164** — Imágenes firmadas | No se ha implementado un mecanismo de firma criptográfica y verificación de imágenes en el entorno académico. | Las imágenes se publican mediante el pipeline autorizado, utilizando etiquetas asociadas al SHA del commit y autenticación OIDC. | El SHA permite rastrear la versión, pero no sustituye una firma criptográfica que garantice autenticidad e integridad. |
| **CKV_AZURE_165** — Georreplicación | La georreplicación administrada requiere capacidades de ACR Premium. El proyecto utiliza una sola región, `brazilsouth`. | El código fuente y Dockerfile se conservan en GitHub, permitiendo reconstruir y publicar las imágenes. | Ante una caída regional, el registro puede quedar indisponible y la reconstrucción no garantiza una recuperación inmediata. |
| **CKV_AZURE_166** — Cuarentena de imágenes | No se utiliza cuarentena administrada dentro de ACR. | Trivy funciona como control preventivo antes de la publicación y puede bloquear imágenes con vulnerabilidades HIGH o CRITICAL que tengan corrección disponible. | No existe cuarentena nativa. Pueden permanecer riesgos de severidades no evaluadas o vulnerabilidades sin corrección. |
| **CKV_AZURE_167** — Retención de manifiestos | No se dispone de una política automática de limpieza de manifiestos sin etiqueta equivalente a la exigida por el control. | Las imágenes se publican con etiquetas basadas en el SHA del commit. Se propone revisar y eliminar imágenes antiguas de forma controlada. | Pueden acumularse imágenes o manifiestos y aumentar el consumo de almacenamiento. |
| **CKV_AZURE_233** — Redundancia por zonas | El control se registra como una posible discrepancia entre la evaluación de Checkov y las capacidades actuales de ACR. Debe verificarse la redundancia efectiva del registro en Azure. | Las imágenes pueden reconstruirse a partir del repositorio y del pipeline. | Mientras no se compruebe el estado real, no puede confirmarse la protección frente a una falla de zona. |
| **CKV_AZURE_237** — Endpoints de datos dedicados | La infraestructura no utiliza conectividad privada ni endpoints de datos dedicados. Esta funcionalidad no forma parte de la configuración seleccionada con ACR Basic. | La autenticación y autorización del registro utilizan identidades administradas, OIDC y permisos mínimos. | Las conexiones con el registro continúan dependiendo de endpoints públicos y no cuentan con aislamiento de red privado. |

#### Decisión técnica

Se mantiene Azure Container Registry en el plan Basic por razones de costo y por el alcance académico del ambiente de desarrollo.

Sofía, responsable de infraestructura, revisó los ocho hallazgos y consideró técnicamente justificadas las excepciones dentro de este contexto, sujetas a las limitaciones y riesgos residuales descritos.

Estas excepciones se documentan en `.checkov.yaml` y en este archivo para conservar la trazabilidad de la decisión.

La exclusión de un control de Checkov no equivale a su aprobación. Si la solución se trasladara a producción, deberían evaluarse nuevamente todos los controles y aplicar las medidas de seguridad correspondientes.

#### Mejoras futuras

- Evaluar la conectividad privada y las características avanzadas de ACR.
- Implementar un análisis periódico de vulnerabilidades sobre imágenes almacenadas.
- Incorporar firmas criptográficas con herramientas compatibles, como Notation o Cosign.
- Definir una política de limpieza de imágenes antiguas.
- Verificar la redundancia por zonas real del registro.
- Revisar periódicamente las excepciones de seguridad y retirar aquellas que puedan solucionarse.


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
- Se identificaron ocho controles fallidos de Checkov, revisados con Sofía y documentados como excepciones técnicas para el ambiente dev. Los riesgos residuales permanecen y deben reevaluarse si cambia el alcance del proyecto.
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

Las excepciones de Checkov fueron revisadas y justificadas técnicamente para el ambiente académico. Permanecen pendientes la verificación de los controles automatizados y la recopilación completa de las evidencias del despliegue

Las decisiones de aceptación de riesgos y los cambios de infraestructura deberán validarse con las integrantes responsables del proyecto.
