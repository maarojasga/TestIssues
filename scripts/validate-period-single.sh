#!/bin/bash
 
PERIODO=$1
 
# Validar que se haya pasado un parámetro
if [[ -z "$PERIODO" ]]; then
  echo "❌ Debes ingresar un periodo en formato YYYYMM"
  exit 1
fi
 
# Validar formato (YYYYMM)
if [[ ! $PERIODO =~ ^[0-9]{6}$ ]]; then
  echo "❌ Formato inválido. Usa: YYYYMM"
  exit 1
fi
 
# Extraer año y mes
ANIO=${PERIODO:0:4}
MES=${PERIODO:4:2}
 
# Validar mes
if ((10#$MES < 1 || 10#$MES > 12)); then
  echo "❌ Mes inválido. Debe estar entre 01 y 12."
  exit 1
fi
 
# ✅ Validación correcta: guardar en archivo
echo "$PERIODO" > periodos.txt
 
echo "✅ Periodo guardado en periodos.txt:"
cat periodos.txt