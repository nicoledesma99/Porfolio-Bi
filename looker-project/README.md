# 📊 Dashboard Operativo - Prepaga de Salud (Looker)

**Proyecto de demostración** desarrollado por **Nicolás Ledesma** para portfolio profesional.

## 🎯 Objetivo del Proyecto

Demostrar capacidades de **modelado de datos en Looker** aplicado al sector salud, creando dashboards interactivos para análisis de rentabilidad, utilización médica y gestión de cobranzas en una prepaga de salud.

## 📋 Descripción

Este proyecto simula el sistema de BI de una prepaga de salud en Córdoba, Argentina, con datos sintéticos que representan:

- **1,500 afiliados** distribuidos en 10 empresas
- **25,000 prestaciones médicas** (consultas, internaciones, estudios, farmacia, urgencias)
- **53,000+ registros de facturación** mensual
- **14 prestadores** (hospitales, clínicas, consultorios, laboratorios)

### KPIs Implementados

**Rentabilidad:**
- Margen Bruto (Ingresos - Costos Médicos)
- Margen Porcentual
- Loss Ratio (Costo Médico / Ingresos)
- ARPU (Average Revenue Per User)

**Operaciones:**
- PMR (Prestaciones por Afiliado)
- Costo Promedio por Prestación
- Tasa de Autorización
- Distribución por Tipo de Prestación

**Cobranzas:**
- Tasa de Morosidad
- Ingresos Pendientes
- Mora Promedio (días)
- Tasa de Cobranza

**Afiliados:**
- Tasa de Churn
- Antigüedad Promedio
- Distribución por Plan (A/B/C)
- Evolución de Altas/Bajas

## 🗂️ Estructura del Proyecto

```
looker-project/
├── models/
│   └── salud_prepaga.model.lkml      # Modelo principal con explores
├── views/
│   ├── dim_afiliados.view.lkml       # Vista de afiliados
│   ├── dim_empresas.view.lkml        # Vista de empresas contratantes
│   ├── dim_prestadores.view.lkml     # Vista de prestadores médicos
│   ├── fact_prestaciones.view.lkml   # Vista de prestaciones (hechos)
│   └── fact_facturacion.view.lkml    # Vista de facturación (hechos)
├── dashboards/
│   ├── dashboard_ejecutivo.dashboard.lookml    # KPIs principales
│   └── dashboard_operativo.dashboard.lookml    # Análisis operativo
├── data/
│   ├── dim_afiliados.csv
│   ├── dim_empresas.csv
│   ├── dim_prestadores.csv
│   ├── fact_prestaciones.csv
│   └── fact_facturacion.csv
├── schema.sql                         # Schema para BigQuery
├── generar_datos.py                   # Script generador de datos
└── README.md
```

## 🔧 Tecnologías Utilizadas

- **Looker**: Plataforma de BI (LookML para modelado)
- **Google BigQuery**: Data Warehouse (cloud)
- **SQL**: Consultas y transformaciones
- **Python**: Generación de datos sintéticos (pandas, numpy)

## 📊 Modelo de Datos

### Diagrama Relacional

```
dim_empresas (1) ─────┐
                       │
                       ↓ (N)
                  dim_afiliados (1)
                       │
                       ├─────→ (N) fact_prestaciones (N) ←──── (1) dim_prestadores
                       │
                       └─────→ (N) fact_facturacion
```

### Tablas Dimensionales

**dim_afiliados**
- Información demográfica (edad, género, ciudad)
- Plan contratado (A, B, C)
- Fechas de alta/baja
- Estado (Activo/Baja)
- Empresa contratante

**dim_empresas**
- Categoría (Corporativa, PyME, Individual)
- Cantidad de afiliados
- Fecha inicio de contrato

**dim_prestadores**
- Tipo (Hospital, Clínica, Consultorio, etc.)
- Especialidad médica
- Ubicación geográfica
- Costo promedio de consulta

### Tablas de Hechos

**fact_prestaciones**
- Tipo de prestación (Consulta, Internación, Estudio, Farmacia, Urgencia)
- Costo de prestación
- Pago al prestador
- Margen de la prepaga
- Autorización (SI/NO)
- Fecha de realización

**fact_facturacion**
- Período mensual
- Monto de cuota según plan
- Estado de pago (Pagado, Pendiente, Moroso)
- Días de mora
- Fecha de vencimiento y pago

## 🚀 Cómo Implementar

### 1. Cargar Datos en BigQuery

```bash
# Crear dataset
bq mk --dataset --location=US salud_demo

# Crear tablas desde schema
bq query --use_legacy_sql=false < schema.sql

# Cargar CSVs
bq load --source_format=CSV --skip_leading_rows=1 \
  salud_demo.dim_afiliados ./data/dim_afiliados.csv

bq load --source_format=CSV --skip_leading_rows=1 \
  salud_demo.dim_empresas ./data/dim_empresas.csv

bq load --source_format=CSV --skip_leading_rows=1 \
  salud_demo.dim_prestadores ./data/dim_prestadores.csv

bq load --source_format=CSV --skip_leading_rows=1 \
  salud_demo.fact_prestaciones ./data/fact_prestaciones.csv

bq load --source_format=CSV --skip_leading_rows=1 \
  salud_demo.fact_facturacion ./data/fact_facturacion.csv
```

### 2. Configurar Looker

1. **Crear Conexión a BigQuery:**
   - Admin > Connections > Add Connection
   - Nombre: `bigquery_salud`
   - Tipo: Google BigQuery
   - Configurar credenciales de servicio

2. **Crear Proyecto en Looker:**
   - Develop > Manage LookML Projects > New Project
   - Nombre: `prepaga_salud`
   - Conexión: `bigquery_salud`

3. **Importar Archivos LookML:**
   - Copiar archivos de `/models`, `/views`, `/dashboards` al proyecto
   - Commit y Deploy

4. **Validar y Explorar:**
   - Explore > Prestaciones Médicas
   - Explore > Facturación y Cobranzas
   - Dashboards > Dashboard Ejecutivo

## 📈 Casos de Uso Principales

### 1. Análisis de Rentabilidad
**Pregunta:** ¿Cuál es el margen bruto por plan?
- Explore: `fact_facturacion`
- Dimensión: `dim_afiliados.plan`
- Medidas: `ingresos_totales`, `fact_prestaciones.costo_total`, `margen_bruto`

### 2. Identificación de Alto Costo
**Pregunta:** ¿Qué prestadores generan el mayor costo médico?
- Explore: `fact_prestaciones`
- Dimensión: `dim_prestadores.nombre_prestador`
- Medidas: `costo_total`, `cantidad_prestaciones`, `costo_promedio`
- Ordenar: `costo_total DESC`

### 3. Análisis de Morosidad
**Pregunta:** ¿Cuál es la tasa de morosidad por empresa?
- Explore: `fact_facturacion`
- Dimensión: `dim_empresas.nombre_empresa`
- Medidas: `tasa_morosidad`, `ingresos_pendientes`, `mora_promedio_dias`

### 4. Predicción de Churn
**Pregunta:** ¿Qué afiliados tienen alta probabilidad de baja?
- Explore: `dim_afiliados`
- Dimensiones: `plan`, `rango_antiguedad`, `rango_etario`
- Medidas: `tasa_churn`, `cantidad_bajas`
- Join con `fact_prestaciones` para analizar consumo

### 5. Utilización de Servicios
**Pregunta:** ¿Cuántas prestaciones promedio consume cada afiliado?
- Explore: `fact_prestaciones`
- Medida: `pmr` (Prestaciones por Afiliado)
- Dimensiones: `dim_afiliados.plan`, `tipo_prestacion`

## 🎨 Dashboards

### Dashboard Ejecutivo
KPIs de alto nivel para toma de decisiones:
- 6 KPIs principales (afiliados activos, ingresos, loss ratio, margen, morosidad, churn)
- Evolución temporal de ingresos vs costos
- Distribución por plan
- Top prestadores por costo
- Morosidad por plan

### Dashboard Operativo
Análisis detallado de prestaciones:
- Métricas operativas (PMR, costo promedio, tasa autorización)
- Distribución por tipo de prestación
- Tendencias temporales
- Ranking de prestadores (Top 20)
- Análisis por día de la semana
- Filtros interactivos (fecha, plan)

## 🔍 Highlights Técnicos

### LookML Avanzado

**Medidas Calculadas:**
```lookml
measure: loss_ratio {
  type: number
  sql: SAFE_DIVIDE(${costo_total}, ${fact_facturacion.ingresos_totales}) ;;
  value_format_name: percent_2
}
```

**Dimensiones Derivadas:**
```lookml
dimension: antiguedad_meses {
  type: number
  sql: CAST(${antiguedad_dias} / 30 AS INT64) ;;
}

dimension: rango_antiguedad {
  type: tier
  tiers: [0, 3, 6, 12, 24, 36]
  style: integer
  sql: ${antiguedad_meses} ;;
}
```

**Drill-downs:**
```lookml
measure: cantidad_afiliados {
  type: count
  drill_fields: [afiliado_id, nombre, plan, estado, ciudad]
}
```

## 💼 Aplicaciones en el Mundo Real

Este modelo se puede adaptar para:

1. **Prepagas y Obras Sociales**: Análisis de siniestralidad, gestión de prestadores
2. **Hospitales Privados**: Rentabilidad por servicio, ocupación, pacientes
3. **Farmacias**: Gestión de obras sociales, rentabilidad por prestador
4. **Aseguradoras de Salud**: Análisis de riesgo, pricing de pólizas

## 📧 Contacto

**Nicolás Ledesma**  
Analista de Datos | BI Consultant  
📧 nico99led@gmail.com  
📞 +543547660902  
🌐 [GitHub Portfolio](https://github.com/nicoledesma99/Porfolio-Bi)  
🔗 [LinkedIn](https://linkedin.com/in/nicolás-ledesma)

---

**Nota:** Este proyecto utiliza datos sintéticos generados aleatoriamente. Cualquier similitud con datos reales es coincidencia.
