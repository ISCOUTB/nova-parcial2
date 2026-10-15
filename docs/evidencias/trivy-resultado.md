
# Evidencia de seguridad — Trivy

**Proyecto:** Taller 2 NOVA  


## Herramienta utilizada

- Herramienta: Trivy
- Versión: 0.69.3
- Imagen analizada: nova-app:seguridad
- Sistema base detectado: Debian 13.7

## Comando ejecutado

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.69.3 image --image-src docker --severity HIGH,CRITICAL --ignore-unfixed nova-app:seguridad

## Resultados obtenidos

- Vulnerabilidades HIGH detectadas: 0
- Vulnerabilidades CRITICAL detectadas: 0
- Vulnerabilidades mostradas en el reporte: 0

## Interpretación

El análisis no identificó vulnerabilidades
de severidad alta o crítica con corrección
disponible en la imagen Docker evaluada.

Se analizaron paquetes de Debian y
dependencias Python de la aplicación.

## Limitaciones

El análisis utilizó --ignore-unfixed,
por lo que no incluyó vulnerabilidades
sin corrección disponible.

Tampoco se evaluaron todas las severidades.
La columna Secrets del reporte no permite
confirmar la ausencia de secretos.

## Conclusión

La imagen superó la revisión local de
vulnerabilidades bajo los criterios definidos.

Queda pendiente comprobar el análisis
automatizado de Trivy en GitHub Actions
y conservar su resultado como evidencia.

**Requisitos relacionados:** R7 y R16.
