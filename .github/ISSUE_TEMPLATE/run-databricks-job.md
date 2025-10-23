---
name: 🚀 Ejecutar Job de Databricks
about: Llena este formulario para ejecutar un job.
labels: 'databricks-run'
---

**Por favor, llena los parámetros del job dentro del bloque YAML de abajo.**
No borres las comillas.

- `target_project`: Nombre del proyecto (para referencia).
- `databricks_job_id`: El ID numérico del job en Databricks.
- `execution_type`: `periodo_unico` o `rango_periodo`.
- `periodo_unico`: (Opcional) `YYYYMM`. Déjalo `""` si no aplica.
- `periodo_inicio`: (Opcional) `YYYYMM`. Déjalo `""` si no aplica.
- `periodo_fin`: (Opcional) `YYYYMM`. Déjalo `""` si no aplica.

---

```yaml
run_parameters:
  target_project: "cemm-pilotos"
  databricks_job_id: "12345"
  execution_type: "periodo_unico"
  periodo_unico: "202504"
  periodo_inicio: ""
  periodo_fin: ""
```

---

## ❗️ Recordatorios Finales

Para que todo esto funcione, solo asegúrate de dos cosas en tu repositorio `databricks-runner`:

1. **Scripts de Validación:** Crea una carpeta llamada `scripts` en la raíz de tu repositorio y pon allí tus archivos `validate-period-single.sh` y `validate-period-range.sh`.
2. **Secretos:** Ve a **Settings > Secrets and variables > Actions** y crea los secretos `DATABRICKS_HOST` y `DATABRICKS_TOKEN`.
