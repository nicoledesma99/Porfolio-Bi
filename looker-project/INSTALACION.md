# 🚀 Guía de Implementación Paso a Paso

## Opción 1: Instalación Completa (BigQuery + Looker)

### Prerequisitos
- Cuenta de Google Cloud Platform (GCP)
- Looker Studio o Looker (versión completa)
- Google Cloud SDK instalado localmente

### Paso 1: Generar los Datos (5 min)

```bash
# Clonar o descargar el proyecto
cd looker-project

# Generar datos sintéticos
python generar_datos.py

# Verificar que se crearon los CSVs
ls -lh *.csv
```

**Output esperado:**
```
dim_afiliados.csv      (1,500 registros)
dim_empresas.csv       (10 registros)
dim_prestadores.csv    (14 registros)
fact_prestaciones.csv  (25,000 registros)
fact_facturacion.csv   (53,000+ registros)
```

### Paso 2: Configurar Google Cloud Platform (10 min)

1. **Crear Proyecto GCP:**
   - Ir a https://console.cloud.google.com
   - Click en "Select a project" → "New Project"
   - Nombre: `looker-prepaga-demo`
   - Project ID: `looker-prepaga-demo-xxxxx` (único)
   - Click "Create"

2. **Habilitar BigQuery API:**
   - Ir a "APIs & Services" → "Library"
   - Buscar "BigQuery API"
   - Click "Enable"

3. **Crear Service Account (para Looker):**
   - Ir a "IAM & Admin" → "Service Accounts"
   - Click "Create Service Account"
   - Nombre: `looker-bigquery-access`
   - Role: "BigQuery Data Editor" + "BigQuery Job User"
   - Click "Done"
   - Click en la cuenta → "Keys" → "Add Key" → "JSON"
   - Descargar el archivo JSON (lo necesitarás en Paso 4)

### Paso 3: Cargar Datos en BigQuery (15 min)

**Opción A: Script Automatizado (Recomendado)**

```bash
# Editar script con tu PROJECT_ID
nano cargar_bigquery.sh

# Cambiar esta línea:
PROJECT_ID="looker-prepaga-demo-xxxxx"  # TU PROJECT ID AQUÍ

# Dar permisos de ejecución
chmod +x cargar_bigquery.sh

# Ejecutar
./cargar_bigquery.sh
```

**Opción B: Manual desde la UI de BigQuery**

1. Ir a https://console.cloud.google.com/bigquery
2. Click en tu proyecto → "Create Dataset"
   - Dataset ID: `salud_demo`
   - Location: `US (multiple regions in United States)`
   - Click "Create Dataset"

3. Para cada tabla:
   - Click en `salud_demo` → "Create Table"
   - Source: "Upload" → seleccionar CSV
   - Table: nombre de la tabla (ej: `dim_afiliados`)
   - Schema: "Auto detect"
   - Click "Create Table"
   
   Repetir para:
   - `dim_afiliados.csv` → `dim_afiliados`
   - `dim_empresas.csv` → `dim_empresas`
   - `dim_prestadores.csv` → `dim_prestadores`
   - `fact_prestaciones.csv` → `fact_prestaciones`
   - `fact_facturacion.csv` → `fact_facturacion`

4. Verificar datos:
```sql
SELECT COUNT(*) as total FROM `salud_demo.dim_afiliados`;
-- Debe devolver: 1500

SELECT COUNT(*) as total FROM `salud_demo.fact_prestaciones`;
-- Debe devolver: 25000
```

### Paso 4: Configurar Looker (20 min)

#### Si usas Looker Studio (Gratis)

1. Ir a https://lookerstudio.google.com
2. Click "Create" → "Data Source"
3. Seleccionar "BigQuery"
4. Proyecto: `looker-prepaga-demo-xxxxx`
5. Dataset: `salud_demo`
6. Crear reportes manualmente basándote en los dashboards .lookml

**Nota:** Looker Studio no soporta LookML directamente, necesitarás recrear los dashboards en la UI.

#### Si usas Looker (versión completa)

1. **Crear Conexión:**
   - Admin → Connections → Add Connection
   - Name: `bigquery_salud`
   - Dialect: Google BigQuery Standard SQL
   - Upload Service Account JSON (del Paso 2)
   - Database: `looker-prepaga-demo-xxxxx`
   - Test Connection → Save

2. **Crear Proyecto LookML:**
   - Develop → Manage LookML Projects → New Project
   - Name: `prepaga_salud`
   - Connection: `bigquery_salud`
   - Starting Point: Blank Project
   - Create Project

3. **Importar Archivos:**
   - En el IDE de Looker, crear estructura:
     ```
     prepaga_salud/
     ├── models/
     ├── views/
     └── dashboards/
     ```
   
   - Copiar contenido de tus archivos locales:
     - `models/salud_prepaga.model.lkml` → Looker IDE
     - `views/*.view.lkml` → Looker IDE
     - `dashboards/*.dashboard.lookml` → Looker IDE

4. **Validar y Deploy:**
   - Click "Validate LookML"
   - Si no hay errores, click "Commit Changes"
   - Message: "Initial import - Prepaga Salud project"
   - Click "Deploy to Production"

5. **Acceder a Dashboards:**
   - Browse → Dashboards → "Dashboard Ejecutivo"
   - Browse → Dashboards → "Dashboard Operativo"

### Paso 5: Verificación (5 min)

**Test de Explores:**

1. Explore → "Prestaciones Médicas"
   - Dimension: `tipo_prestacion`
   - Measure: `costo_total`
   - Run → Debería mostrar costos por tipo

2. Explore → "Facturación y Cobranzas"
   - Dimension: `periodo_month`
   - Measure: `ingresos_totales`
   - Run → Debería mostrar evolución de ingresos

**Test de Dashboards:**

1. Dashboard Ejecutivo:
   - ✓ KPI "Afiliados Activos" muestra ~1,273
   - ✓ Gráfico de evolución muestra tendencia
   - ✓ Pie chart de distribución por plan funciona

2. Dashboard Operativo:
   - ✓ Filtros de fecha funcionan
   - ✓ Tabla de ranking de prestadores se carga
   - ✓ Gráfico de tipo de prestación responde

---

## Opción 2: Demo Rápido (Solo Visualización)

Si no querés configurar todo BigQuery/Looker, podés crear visualizaciones rápidas:

### Con Looker Studio (30 min)

1. Subir CSVs a Google Drive
2. Looker Studio → New Report
3. Data Source → Google Sheets (apuntar a tus CSVs)
4. Recrear dashboards manualmente usando la UI drag-and-drop

### Con Power BI (si ya lo tenés)

1. Importar CSVs a Power BI Desktop
2. Crear relaciones manualmente
3. Crear medidas DAX equivalentes a las de LookML
4. Diseñar dashboards

---

## Troubleshooting

### Error: "Permission denied in BigQuery"
- Verificar que el Service Account tenga roles correctos
- Roles necesarios: BigQuery Data Editor, BigQuery Job User

### Error: "Table not found"
- Verificar que el dataset se llame exactamente `salud_demo`
- Verificar que el PROJECT_ID en la conexión de Looker sea correcto

### Error: "Invalid LookML syntax"
- Verificar que los archivos .lkml tengan la indentación correcta
- Looker es sensible a espacios/tabs

### Dashboards vacíos
- Verificar que hay datos en BigQuery: `SELECT COUNT(*) FROM salud_demo.dim_afiliados`
- Verificar que la conexión de Looker esté activa
- Verificar que los explores estén en el model file

---

## Próximos Pasos

✅ Proyecto funcionando  
✅ Screenshots tomados  
✅ README actualizado en GitHub  

**Para el Portfolio:**
1. Subir carpeta `looker-project` a GitHub
2. Agregar screenshots de dashboards al README
3. Crear video demo de 2-3 minutos (opcional)
4. Linkear desde tu portfolio principal

**Para Entrevistas:**
1. Tener el proyecto corriendo en Looker
2. Poder navegar en vivo por los explores
3. Explicar decisiones de modelado (ej: por qué fact_prestaciones está separado de fact_facturacion)
4. Mostrar casos de uso reales (ej: "así identificaríamos prestadores de alto costo")
