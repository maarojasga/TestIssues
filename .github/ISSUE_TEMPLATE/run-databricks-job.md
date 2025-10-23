---
name: 🚀 Ejecutar Job de Databricks
about: Llena este formulario para ejecutar un job.
labels: 'databricks-run' # <-- Etiqueta CLAVE para que el workflow lo detecte
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
---

## Archivo 2: El Workflow "Motor" (El que ejecuta el job)

Este es el workflow reutilizable que creamos antes. No cambia. Su trabajo es validar (con tus scripts `.sh`) y llamar a la API de Databricks.

**Ruta:** `.github/workflows/run-databricks-job.yml`

```yaml
name: 🚀 Disparador Manual y Reutilizable de Job Databricks

on:
  # 1. Permite ejecutarlo manualmente (con el formulario en "Actions")
  workflow_dispatch:
    inputs:
      target_project:
        description: 'Nombre del Proyecto/Repositorio (para referencia)'
        required: true
        type: string
        default: 'cemm-pilotos'
      databricks_job_id:
        description: 'ID del Job de Databricks a ejecutar'
        required: true
        type: string
      execution_type:
        description: 'Tipo de ejecución'
        required: true
        type: choice
        options:
          - periodo_unico
          - rango_periodo
      periodo_unico:
        description: 'Periodo (YYYYMM) para ejecución única'
        required: false
      periodo_inicio:
        description: 'Periodo de inicio (YYYYMM) para rango'
        required: false
      periodo_fin:
        description: 'Periodo de fin (YYYYMM) para rango'
        required: false

  # 2. Permite que otros workflows lo llamen (como el workflow "issue-trigger")
  workflow_call:
    inputs:
      target_project:
        required: true
        type: string
      databricks_job_id:
        required: true
        type: string
      execution_type:
        required: true
        type: string
      periodo_unico:
        required: false
        type: string
      periodo_inicio:
        required: false
        type: string
      periodo_fin:
        required: false
        type: string
    # Nota: No pedimos 'secrets' porque este workflow
    # usará los secretos de su propio repositorio.

jobs:
  run-databricks-job:
    runs-on: ubuntu-latest
    steps:
      # Paso 1: Clonar el repositorio para tener acceso a la carpeta /scripts
      - name: 1. Checkout de scripts locales
        uses: actions/checkout@v4

      # Paso 2: Dar permisos de ejecución a los scripts
      - name: 2. Dar permisos a scripts
        run: |
          chmod +x scripts/validate-period-single.sh
          chmod +x scripts/validate-period-range.sh

      # Paso 3: Validar las entradas usando los scripts .sh
      - name: 3. Validar Entradas (con scripts .sh)
        run: |
          echo "Validando entradas para el proyecto: ${{ inputs.target_project }}"
          echo "Tipo: ${{ inputs.execution_type }}"
          
          if [ "${{ inputs.execution_type }}" == "periodo_unico" ]; then
            ./scripts/validate-period-single.sh "${{ inputs.periodo_unico }}"
          
          elif [ "${{ inputs.execution_type }}" == "rango_periodo" ]; then
            RANGO_COMBINADO="${{ inputs.periodo_inicio }}-${{ inputs.periodo_fin }}"
            echo "Validando rango combinado: $RANGO_COMBINADO"
            ./scripts/validate-period-range.sh "$RANGO_COMBINADO"
          
          else
            echo "::error::Tipo de ejecución no reconocido."
            exit 1
          fi
          
          echo "Validación exitosa."

      # Paso 4: Construir los parámetros JSON para la API de Databricks
      - name: 4. Construir Parámetros para Databricks
        id: params
        run: |
          PARAMS_JSON=""
          if [ "${{ inputs.execution_type }}" == "periodo_unico" ]; then
            PARAMS_JSON="{\"periodo\": \"${{ inputs.periodo_unico }}\"}"
          else
            PARAMS_JSON="{\"periodo_inicio\": \"${{ inputs.periodo_inicio }}\", \"periodo_fin\": \"${{ inputs.periodo_fin }}\"}"
          fi
          
          echo "databricks_params=$PARAMS_JSON" >> $GITHUB_OUTPUT

      # Paso 5: Ejecutar el Job de Databricks vía API
      - name: 5. Ejecutar Job de Databricks vía API
        env:
          # Usará los secretos definidos en este repositorio (databricks-runner)
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
        run: |
          echo "Llamando a Databricks para el Job: ${{ inputs.databricks_job_id }}"
          PARAMS_PAYLOAD='${{ steps.params.outputs.databricks_params }}'
          
          JSON_PAYLOAD=$(jq -n \
                            --arg job_id "${{ inputs.databricks_job_id }}" \
                            --argjson params "$PARAMS_PAYLOAD" \
                            '{job_id: $job_id | tonumber, notebook_params: $params}')
          
          echo "Payload final: $JSON_PAYLOAD"
          
          curl -X POST "${DATABRICKS_HOST}/api/2.1/jobs/run-now" \
            -H "Authorization: Bearer ${DATABRICKS_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "$JSON_PAYLOAD"