#!/bin/bash

# =====================================================
# Script de Carga Automatizada - BigQuery
# Proyecto: Prepaga de Salud - Looker Demo
# Autor: Nicolás Ledesma
# =====================================================

set -e  # Exit on error

PROJECT_ID="tu-proyecto-gcp"  # CAMBIAR POR TU PROJECT ID
DATASET="salud_demo"
LOCATION="US"

echo "=========================================="
echo "Carga de Datos - Prepaga de Salud"
echo "=========================================="
echo ""

# Verificar que gcloud esté instalado
if ! command -v bq &> /dev/null; then
    echo "ERROR: Google Cloud SDK no está instalado"
    echo "Instalar desde: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Configurar proyecto
echo "1. Configurando proyecto: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Crear dataset
echo ""
echo "2. Creando dataset: $DATASET"
bq mk --dataset --location=$LOCATION --description="Demo Prepaga de Salud - Looker" $DATASET || echo "Dataset ya existe, continuando..."

# Crear tablas
echo ""
echo "3. Creando estructura de tablas..."

bq query --use_legacy_sql=false <<EOF
CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.${DATASET}.dim_afiliados\` (
  afiliado_id INT64 NOT NULL,
  nombre STRING,
  edad INT64,
  genero STRING,
  plan STRING,
  fecha_alta DATE,
  fecha_baja DATE,
  estado STRING,
  empresa_id INT64,
  grupo_familiar_id INT64,
  ciudad STRING,
  provincia STRING
);

CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.${DATASET}.dim_empresas\` (
  empresa_id INT64 NOT NULL,
  nombre_empresa STRING,
  categoria STRING,
  cantidad_afiliados INT64,
  fecha_inicio_contrato DATE
);

CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.${DATASET}.dim_prestadores\` (
  prestador_id INT64 NOT NULL,
  nombre_prestador STRING,
  tipo STRING,
  especialidad STRING,
  ciudad STRING,
  provincia STRING,
  costo_promedio_consulta FLOAT64
);

CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.${DATASET}.fact_prestaciones\` (
  prestacion_id INT64 NOT NULL,
  afiliado_id INT64,
  prestador_id INT64,
  fecha DATE,
  tipo_prestacion STRING,
  codigo_prestacion STRING,
  costo_prestacion FLOAT64,
  costo_prestador FLOAT64,
  fue_autorizada BOOLEAN,
  diagnostico_codigo STRING
);

CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.${DATASET}.fact_facturacion\` (
  facturacion_id INT64 NOT NULL,
  afiliado_id INT64,
  periodo DATE,
  monto_cuota FLOAT64,
  fecha_vencimiento DATE,
  fecha_pago DATE,
  estado_pago STRING,
  dias_mora INT64
);
EOF

echo "   ✓ Tablas creadas exitosamente"

# Cargar CSVs
echo ""
echo "4. Cargando datos desde CSVs..."

echo "   - dim_afiliados.csv"
bq load --source_format=CSV --skip_leading_rows=1 --replace \
  ${DATASET}.dim_afiliados ./dim_afiliados.csv

echo "   - dim_empresas.csv"
bq load --source_format=CSV --skip_leading_rows=1 --replace \
  ${DATASET}.dim_empresas ./dim_empresas.csv

echo "   - dim_prestadores.csv"
bq load --source_format=CSV --skip_leading_rows=1 --replace \
  ${DATASET}.dim_prestadores ./dim_prestadores.csv

echo "   - fact_prestaciones.csv"
bq load --source_format=CSV --skip_leading_rows=1 --replace \
  ${DATASET}.fact_prestaciones ./fact_prestaciones.csv

echo "   - fact_facturacion.csv"
bq load --source_format=CSV --skip_leading_rows=1 --replace \
  ${DATASET}.fact_facturacion ./fact_facturacion.csv

echo ""
echo "=========================================="
echo "✓ Carga completada exitosamente"
echo "=========================================="
echo ""
echo "Siguiente paso:"
echo "1. Ir a Looker (https://looker.com)"
echo "2. Crear conexión a BigQuery con el proyecto: $PROJECT_ID"
echo "3. Crear proyecto Looker e importar archivos LookML"
echo ""
echo "Dataset BigQuery: ${PROJECT_ID}.${DATASET}"
echo ""

# Mostrar resumen
echo "Resumen de datos:"
bq query --use_legacy_sql=false "SELECT COUNT(*) as total_afiliados FROM \`${PROJECT_ID}.${DATASET}.dim_afiliados\`"
bq query --use_legacy_sql=false "SELECT COUNT(*) as total_prestaciones FROM \`${PROJECT_ID}.${DATASET}.fact_prestaciones\`"
bq query --use_legacy_sql=false "SELECT COUNT(*) as total_facturas FROM \`${PROJECT_ID}.${DATASET}.fact_facturacion\`"
