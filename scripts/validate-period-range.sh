#!/bin/bash
 
RANGO=$1
 
# Validar formato
if [[ ! $RANGO =~ ^[0-9]{6}-[0-9]{6}$ ]]; then
  echo "❌ Formato inválido. Usa: YYYYMM-YYYYMM"
  exit 1
fi
 
INICIO=${RANGO%-*}
FIN=${RANGO#*-}
 
ANIO_INI=${INICIO:0:4}
MES_INI=${INICIO:4:2}
ANIO_FIN=${FIN:0:4}
MES_FIN=${FIN:4:2}
 
if ((10#$MES_INI < 1 || 10#$MES_INI > 12)) || ((10#$MES_FIN < 1 || 10#$MES_FIN > 12)); then
  echo "❌ Mes inválido. Debe estar entre 01 y 12."
  exit 1
fi
 
if [[ "$INICIO" == "$FIN" ]]; then
  echo "❌ Las fechas no pueden ser iguales."
  exit 1
fi
 
if (( ANIO_FIN < ANIO_INI )) || { (( ANIO_FIN == ANIO_INI )) && ((10#$MES_FIN <= 10#$MES_INI)); }; then
  echo "❌ La fecha final debe ser mayor que la inicial."
  exit 1
fi
 
# ✅ Validación correcta, generar lista
ANIO=$ANIO_INI
MES=$((10#$MES_INI))
 
> periodos.txt # Limpiar archivo
 
while true; do
  PERIODO=$(printf "%04d%02d" $ANIO $MES)
  echo "$PERIODO" >> periodos.txt
 
  if [[ "$PERIODO" == "$FIN" ]]; then
    break
  fi
 
  MES=$((MES + 1))
  if (( MES > 12 )); then
    MES=1
    ANIO=$((ANIO + 1))
  fi
done
 
echo "✅ Lista de periodos generada:"
cat periodos.txt