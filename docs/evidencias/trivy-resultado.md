# Resultado del análisis de seguridad con Trivy — Grupo NOVA

**Proyecto:** Infraestructura y despliegue automatizado en Azure  
**Requisitos relacionados:** R7 y R16

## ¿Qué analizamos?

Utilizamos Trivy para revisar las vulnerabilidades de los paquetes del sistema operativo y de las dependencias de nuestra imagen Docker. Realizamos una prueba local y también integramos el análisis en GitHub Actions.

## 1. Análisis local

- **Herramienta:** Trivy 0.69.3.
- **Imagen:** `nova-app:seguridad`.
- **Sistema base identificado:** Debian 13.7.
- **Severidades consultadas:** HIGH y CRITICAL.

Ejecutamos el siguiente comando con Docker:

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.69.3 image --image-src docker --severity HIGH,CRITICAL --ignore-unfixed nova-app:seguridad
```

| Resultado | Cantidad |
|---|---:|
| Vulnerabilidades HIGH detectadas | 0 |
| Vulnerabilidades CRITICAL detectadas | 0 |
| Hallazgos incluidos en el reporte | 0 |

No encontramos vulnerabilidades de severidad alta o crítica con corrección disponible dentro de los criterios configurados.

## 2. Análisis automatizado

Configuramos Trivy en `.github/workflows/app.yml` para revisar las imágenes Docker durante el proceso de validación y antes de publicarlas en ACR. El pipeline utiliza `aquasecurity/trivy-action@v0.36.0`, analiza vulnerabilidades de sistema operativo y librerías, y falla si encuentra hallazgos HIGH o CRITICAL que cumplan sus filtros.

Comprobamos una ejecución exitosa en GitHub Actions:

[Ejecución del despliegue v2](https://github.com/ISCOUTB/nova-parcial2/actions/runs/38687530318)

Conservamos estas capturas del reporte automatizado:

![Resultados de Trivy, parte 1](./02-trivy-resultados-parte1.png)

![Resultados de Trivy, parte 2](./03-trivy-resultados-parte2.png)

## 3. Alcance y limitaciones

El parámetro `--ignore-unfixed` excluye del resultado las vulnerabilidades sin corrección disponible. Tampoco analizamos todas las severidades: nos concentramos en HIGH y CRITICAL. Por eso, **cero hallazgos no significa que la imagen esté libre de cualquier vulnerabilidad**.

En las capturas del análisis automatizado, la columna *Secrets* aparece como «Not scanned». No podemos afirmar que se realizó una búsqueda de secretos a partir de ese resultado.

El análisis de Trivy complementa nuestros controles de seguridad, pero no reemplaza las protecciones del registro de contenedores ni las excepciones de Checkov documentadas en `docs/decisiones.md`.

## 4. Resultado

La imagen superó las verificaciones local y automatizada bajo los criterios que definimos. Conservamos los resultados y las capturas como evidencia para los requisitos R7 y R16.
