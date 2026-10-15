# Decisiones técnicas, limitaciones y mejoras — Grupo NOVA

**Proyecto:** Infraestructura y despliegue automatizado en Azure  
**Equipo:** NOVA 
**Ambiente:** Desarrollo (`dev`)

## 1. Decisiones que tomamos

Durante el taller buscamos una solución que pudiéramos desplegar, probar y explicar, sin perder de vista el presupuesto de Azure for Students ni las condiciones de seguridad. Estas fueron nuestras principales decisiones.

### Infraestructura con Terraform

Elegimos Terraform para definir y administrar los recursos de Azure desde el repositorio. Esto nos permitió revisar los cambios antes de aplicarlos y evitar depender únicamente de configuraciones manuales. Utilizamos un backend remoto en Azure Storage para conservar el estado y configuramos concurrencia en GitHub Actions para no ejecutar dos actualizaciones de infraestructura al mismo tiempo.

Los recursos de soporte y la identidad federada se preparan con `scripts/bootstrap.sh`. Terraform administra después el registro de imágenes, Log Analytics, el entorno de Container Apps, la aplicación y la identidad de descarga de imágenes.

### Aplicación con Flask y Docker

Para la aplicación utilizamos Python 3.12 y Flask porque necesitábamos un servicio HTTP ligero y fácil de probar. La empaquetamos con Docker y configuramos Gunicorn para escuchar en el puerto `8000`.

Para mejorar su funcionamiento y seguridad, ejecutamos el contenedor con un usuario sin privilegios, añadimos `.dockerignore` para no incluir archivos innecesarios y creamos el endpoint `/health`. Esta ruta nos permite comprobar automáticamente el estado de la aplicación después de cada despliegue.

También utilizamos `APP_VERSION` para identificar la versión que se está ejecutando; actualmente su valor predeterminado es `v2`.

### Despliegue en Azure Container Apps

Elegimos Azure Container Apps porque podemos ejecutar el contenedor sin administrar una máquina virtual. Configuramos HTTPS externo, el perfil Consumption, `0.25` vCPU, `0.5Gi` de memoria y entre una y dos réplicas.

Estos valores nos ayudan a controlar el consumo durante la evaluación. Confirmamos la configuración efectiva mediante `docs/evidencias/09-limites-y-etiquetas.txt` y las capturas de Azure.

### Imágenes en Azure Container Registry

Utilizamos Azure Container Registry (ACR) en el plan Basic por su costo y porque es suficiente para nuestro ambiente académico. Deshabilitamos la cuenta administradora y las descargas anónimas. Para obtener las imágenes desde Container Apps configuramos una identidad administrada con el permiso `AcrPull`.

Sabíamos que ACR Basic no incorpora todas las funciones avanzadas de los planes superiores. Por ello documentamos los controles de seguridad que no cumplimos, en lugar de presentarlos como corregidos.

### Automatización y autenticación

Separamos los workflows de infraestructura y aplicación. `infra.yml` ejecuta Checkov y las validaciones de Terraform; desde `main`, también realiza `plan` y `apply`. `app.yml` construye y analiza la imagen con Trivy, la publica en ACR y actualiza Container Apps cuando corresponde.

Para la conexión con Azure configuramos OIDC, evitando guardar una contraseña permanente de la identidad del pipeline. Las imágenes se publican con etiquetas SHA para relacionarlas con el commit que las generó.

Comprobamos una ejecución exitosa de [infraestructura](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38744864451) y otra de [aplicación](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318).

## 2. Seguridad: Checkov y las excepciones justificadas

En el primer análisis de Checkov sobre Terraform encontramos **2 controles aprobados, 8 fallidos y 0 omitidos**. Los aprobados fueron `CKV_AZURE_137`, que comprueba la cuenta administradora deshabilitada en ACR, y `CKV_AZURE_138`, que comprueba la deshabilitación de descargas anónimas.

Los ocho hallazgos restantes correspondían a `azurerm_container_registry.acr`. Los revisamos con Sofía, responsable de infraestructura, y decidimos mantener ACR Basic para el ambiente de desarrollo, documentando cada excepción y su riesgo.

| Control | Por qué justificamos la excepción | Medida compensatoria | Riesgo residual |
|---|---|---|---|
| **CKV_AZURE_139 — Acceso público** | ACR Basic no ofrece las mismas opciones de redes privadas y restricciones de acceso que Premium. | Cuenta administradora y descargas anónimas deshabilitadas; Microsoft Entra ID, OIDC y permisos mínimos `AcrPush`/`AcrPull`. | El endpoint del registro sigue accesible desde Internet, aunque las operaciones requieren autorización. |
| **CKV_AZURE_163 — Escaneo de vulnerabilidades** | No habilitamos el análisis administrado de Microsoft Defender, que representa un servicio adicional con costo. | Trivy revisa las imágenes antes de publicarlas y puede bloquear hallazgos HIGH y CRITICAL incluidos en sus filtros. | No hay análisis administrado continuo de las imágenes almacenadas; pueden aparecer nuevas vulnerabilidades después de publicarlas. |
| **CKV_AZURE_164 — Imágenes firmadas** | No implementamos firma criptográfica y verificación de imágenes en este entorno. | Publicación mediante el pipeline autorizado, autenticación OIDC y etiquetas SHA. | Un SHA permite identificar la versión, pero no reemplaza una firma que garantice autenticidad e integridad. |
| **CKV_AZURE_165 — Georreplicación** | Trabajamos en una sola región (`brazilsouth`) y la georreplicación administrada requiere capacidades de Premium. | Conservamos el código y Dockerfile en GitHub para reconstruir las imágenes. | Una falla regional podría dejar indisponible ACR; reconstruir las imágenes no garantiza recuperación inmediata. |
| **CKV_AZURE_166 — Cuarentena de imágenes** | No configuramos cuarentena administrada dentro de ACR. | Trivy actúa como control preventivo del pipeline y bloquea la publicación ante hallazgos que incumplen sus criterios. | No existe cuarentena nativa; pueden permanecer vulnerabilidades no evaluadas o sin corrección disponible. |
| **CKV_AZURE_167 — Retención de manifiestos** | No configuramos una política automática de limpieza de manifiestos sin etiqueta. | Utilizamos etiquetas SHA y proponemos revisar periódicamente las imágenes antiguas. | La acumulación de imágenes o manifiestos puede aumentar el almacenamiento y su costo. |
| **CKV_AZURE_233 — Redundancia por zonas** | Identificamos una posible discrepancia entre la evaluación de Checkov y las capacidades actuales de ACR; debemos comprobar la redundancia efectiva del registro. | Podemos reconstruir las imágenes desde GitHub y el pipeline. | No podemos confirmar protección frente a fallas de zona sin verificar su configuración real en Azure. |
| **CKV_AZURE_237 — Endpoints de datos dedicados** | No implementamos endpoints dedicados ni aislamiento de red privado con la configuración Basic elegida. | Utilizamos identidades autorizadas, OIDC y permisos mínimos. | La comunicación depende de endpoints públicos y no dispone de aislamiento privado de red. |

Registramos las ocho excepciones en `.checkov.yaml` mediante `skip-check`. Después, el análisis informó **2 controles aprobados, 0 fallidos y 0 omitidos contabilizados**, porque los ocho controles excluidos ya no participaron en el reporte.

**Esto no significa que solucionamos los ocho riesgos.** Las excepciones se aceptaron únicamente para el ambiente académico y tendrían que revisarse nuevamente antes de utilizar la solución en producción. Entre ellas, el acceso público a ACR merece especial atención por mantener expuesto el endpoint del registro.

**Evidencias:** `docs/evidencias/checkov-terraform.txt`, `docs/evidencias/checkov-excepciones-2026-10-15.txt`, `.checkov.yaml` y la [ejecución del pipeline de infraestructura](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38744864451).

## 3. Resultado del análisis con Trivy

Realizamos una prueba local con Trivy 0.69.3 sobre la imagen `nova-app:seguridad`. No encontramos vulnerabilidades HIGH ni CRITICAL **dentro de los filtros configurados**: `--severity HIGH,CRITICAL` y `--ignore-unfixed`.

También integramos Trivy en GitHub Actions y comprobamos ejecuciones exitosas durante la validación y antes de publicar las imágenes en ACR.

El resultado no equivale a una revisión completa de todas las severidades ni confirma ausencia de secretos. Por eso lo utilizamos como control complementario, no como garantía absoluta de seguridad.

**Evidencias:** `docs/evidencias/trivy-resultado.md`, las capturas `02-trivy-resultados-parte1.png` y `03-trivy-resultados-parte2.png`, y la [ejecución de aplicación](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318).

## 4. Demostraciones y limitaciones encontradas

### Cambio de la aplicación de v1 a v2

Para comprobar el despliegue automático realizamos un cambio controlado en la aplicación. La versión anterior corresponde al commit `2e8b26f` y la nueva al commit `3cfe621`.

Las dos ejecuciones finalizaron correctamente:

- [Pipeline de v1](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38685137897).
- [Pipeline de v2](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318).

El archivo `docs/evidencias/06-revisiones-e-imagenes.txt` confirma que las imágenes de ambos commits estaban disponibles en ACR y que la aplicación pública respondía con `v2`. Esto nos permite relacionar el código, la imagen y el despliegue.

### Historial de revisiones de Container Apps

Configuramos `ca-nova-t2-dev` con `revision_mode = "Single"`. Durante la comprobación realizada por Sofía, el listado disponible mostró una sola revisión activa, `ca-nova-t2-dev--latest`, asociada a la imagen `v2`. No aparecieron dos revisiones diferenciadas que pudiéramos presentar directamente como anterior y nueva.

Por este motivo, demostramos el cambio de `v1` a `v2` mediante los dos pipelines, las etiquetas SHA en ACR y las respuestas de la aplicación. Esta es **una limitación observada en nuestro despliegue**, no una afirmación de que Azure Container Apps nunca conserve revisiones anteriores.

**Evidencias:** `docs/evidencias/06-revisiones-e-imagenes.txt`, `06-revision-actual.png` y `06b-revisiones-inactivas.png`.

### Cambio de infraestructura

También probamos una modificación independiente de infraestructura: actualizamos la etiqueta `version_infra` de `1` a `2` en `config/dev.tfvars`. El cambio se integró mediante el PR #47 y el pipeline de infraestructura aplicó la nueva configuración.

El reporte `docs/evidencias/07-cambio-etiqueta.txt` muestra `version_infra = 2` en los recursos consultados. Así pudimos demostrar que no necesitábamos cambiar el código Flask para actualizar la infraestructura.

### Costos y disponibilidad

Trabajamos con ACR Basic, una sola región y recursos limitados. Esta decisión es adecuada para el alcance del taller, pero no proporciona todas las opciones de conectividad, disponibilidad y seguridad necesarias en un sistema productivo.

Para controlar el gasto configuramos límites de CPU, memoria, réplicas y una cuota de ingesta de Log Analytics. El detalle está en [docs/destruccion-y-costos.md](destruccion-y-costos.md).

## 5. Mejoras que proponemos

Si continuáramos desarrollando la solución, priorizaríamos revisar las excepciones de Checkov, evaluar conectividad privada para ACR, implementar firma de imágenes y análisis periódicos de vulnerabilidades, establecer una política de limpieza de imágenes antiguas y mejorar la conservación de revisiones para facilitar comparaciones entre despliegues.

También volveríamos a revisar los permisos y secretos antes de utilizar el sistema en otro ambiente y evaluaríamos opciones de mayor disponibilidad si la aplicación necesitara operar fuera del contexto académico.

## 6. Conclusión

Durante el taller comprobamos que no basta con tener una aplicación funcionando: también necesitamos automatizar los despliegues, revisar la infraestructura, controlar los costos y conservar evidencias. Las pruebas de Terraform, GitHub Actions, Checkov y Trivy nos ayudaron a entender cómo se relacionan estas tareas y a identificar las limitaciones que debemos tener en cuenta como equipo.