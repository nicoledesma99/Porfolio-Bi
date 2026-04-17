# 📊 Dashboard Operativo - Prepaga de Salud

## Presentación del Proyecto

**Autor:** Nicolás Ledesma  
**Fecha:** Abril 2026  
**Objetivo:** Demostración de capacidades en Looker, BigQuery y modelado de datos para sector salud

---

## 🎯 Resumen Ejecutivo

Proyecto de BI completo que simula el sistema analítico de una prepaga de salud, implementando:

- **Modelo de datos estrella** con 2 tablas de hechos y 3 dimensionales
- **15+ KPIs** de rentabilidad, utilización y cobranzas
- **2 dashboards interactivos** (ejecutivo y operativo)
- **Datos sintéticos** realistas (79,000+ registros totales)

**Stack Tecnológico:** Looker (LookML), Google BigQuery, Python, SQL

---

## 💼 Aplicación al Mundo Real

Este proyecto está basado en mi experiencia trabajando 2 años en **Nobis S.A. (prepaga de salud)**, donde:

✅ Desarrollé KPIs de rentabilidad (margen bruto, costo médico/ingresos, morosidad)  
✅ Creé modelos de segmentación de afiliados por riesgo de churn  
✅ Automaticé reportes de prestaciones médicas con Python y SQL  
✅ Diseñé dashboards en Power BI para seguimiento operativo

**Diferencial de este proyecto Looker:**
- Implementación en cloud (BigQuery vs SQL Server on-premise)
- Modelado declarativo con LookML (más mantenible que DAX)
- Escalabilidad para grandes volúmenes (25,000 prestaciones como baseline)

---

## 🏗️ Arquitectura del Proyecto

### Modelo de Datos

```
                    CAPA DE DATOS
                    ════════════════
                    Google BigQuery
                    salud_demo dataset
                         │
          ┌──────────────┼──────────────┐
          │              │              │
     DIM_AFILIADOS  DIM_EMPRESAS  DIM_PRESTADORES
          │              │              │
          └──────┬───────┴───────┬──────┘
                 │               │
         FACT_PRESTACIONES  FACT_FACTURACION
                 │               │
                 └───────┬───────┘
                         │
                    CAPA SEMÁNTICA
                    ══════════════
                    Looker (LookML)
                         │
                   ┌─────┴─────┐
              EXPLORES      DASHBOARDS
```

### Flujo de Datos

1. **Generación:** Python genera CSVs con datos sintéticos
2. **Almacenamiento:** CSVs → BigQuery (cloud data warehouse)
3. **Modelado:** LookML define dimensiones, medidas y relaciones
4. **Consumo:** Dashboards interactivos + ad-hoc explores

---

## 📊 KPIs Implementados

### Rentabilidad

| KPI | Fórmula | Propósito |
|-----|---------|-----------|
| **Margen Bruto** | Ingresos - Costos Médicos | Rentabilidad absoluta |
| **Margen %** | (Ingresos - Costos) / Ingresos | Rentabilidad relativa |
| **Loss Ratio** | Costos Médicos / Ingresos | Siniestralidad (benchmark: <75%) |
| **ARPU** | Ingresos / Afiliados | Ingreso promedio por usuario |

### Operaciones

| KPI | Fórmula | Propósito |
|-----|---------|-----------|
| **PMR** | Prestaciones / Afiliados | Utilización de servicios |
| **Costo/Prestación** | SUM(Costos) / COUNT(Prestaciones) | Eficiencia operativa |
| **Tasa Autorización** | Autorizadas / Total | Control de utilización |

### Cobranzas

| KPI | Fórmula | Propósito |
|-----|---------|-----------|
| **Tasa Morosidad** | Morosos / Total Facturas | Salud financiera |
| **Ingresos Pendientes** | SUM(Montos Morosos) | Cartera en riesgo |
| **Días Mora Promedio** | AVG(Días de Atraso) | Calidad de cartera |

### Afiliados

| KPI | Fórmula | Propósito |
|-----|---------|-----------|
| **Tasa Churn** | Bajas / Total | Retención |
| **Antigüedad Promedio** | AVG(Meses desde Alta) | Estabilidad de base |

---

## 🔍 Casos de Uso Resueltos

### 1. Identificación de Alto Costo

**Problema:** ¿Qué prestadores están generando sobrecostos?

**Solución en Looker:**
```
Explore: fact_prestaciones
Dimensions: dim_prestadores.nombre_prestador, dim_prestadores.tipo
Measures: costo_total, cantidad_prestaciones, costo_promedio
Sort: costo_total DESC
Limit: 20
```

**Output:** Ranking de prestadores con alertas sobre desviaciones vs benchmark

**Acción de Negocio:** Renegociación de tarifas con prestadores de alto costo

---

### 2. Análisis de Siniestralidad por Plan

**Problema:** ¿Qué plan tiene peor loss ratio?

**Solución:**
```
Explore: fact_facturacion
Dimensions: dim_afiliados.plan
Measures: ingresos_totales, fact_prestaciones.costo_total, loss_ratio
```

**Insight Descubierto (datos sintéticos):**
- Plan A: Loss Ratio ~55% ✅ (rentable)
- Plan B: Loss Ratio ~68% ⚠️ (ajustado)
- Plan C: Loss Ratio ~82% 🔴 (requiere ajuste de precio o cobertura)

**Acción de Negocio:** Ajustar pricing de Plan C o reducir cobertura

---

### 3. Predicción de Churn

**Problema:** ¿Qué afiliados tienen alta probabilidad de darse de baja?

**Solución:**
```
Explore: dim_afiliados
Dimensions: plan, rango_antiguedad, rango_etario
Join: fact_prestaciones (consumo bajo = señal de churn)
Measures: tasa_churn, cantidad_bajas
Filter: antiguedad < 6 meses AND consumo_prestaciones < 2
```

**Acción de Negocio:** Campaña de retención dirigida (similar a lo que hacía en Nobis con WhatsApp/Email)

---

### 4. Gestión de Morosidad

**Problema:** ¿Qué empresas tienen peor comportamiento de pago?

**Solución:**
```
Explore: fact_facturacion
Dimensions: dim_empresas.nombre_empresa, dim_empresas.categoria
Measures: tasa_morosidad, ingresos_pendientes, mora_promedio_dias
Sort: ingresos_pendientes DESC
```

**Output:** Priorización de gestión de cobranza por impacto financiero

---

## 🛠️ Highlights Técnicos

### 1. Modelado Dimensional

**Decisión de Diseño:** Separar `fact_prestaciones` y `fact_facturacion`

**Razón:**
- Granularidad diferente (prestación individual vs factura mensual)
- Ciclos de actualización distintos (prestaciones diarias, facturación mensual)
- Permite análisis independientes (ej: costo médico sin afectar cobranzas)

**Alternativa Descartada:** Modelo único `fact_eventos_paciente`
- ❌ Mezclaría granos incompatibles
- ❌ Complicaría queries de agregación
- ❌ Menor performance en BigQuery

---

### 2. Medidas Calculadas en LookML

**Ejemplo: Loss Ratio**
```lookml
measure: loss_ratio {
  type: number
  sql: SAFE_DIVIDE(${costo_total}, ${fact_facturacion.ingresos_totales}) ;;
  value_format_name: percent_2
  description: "Ratio de costo médico sobre ingresos"
}
```

**Ventajas sobre calcular en SQL:**
- ✅ Reutilizable en todos los explores
- ✅ Consistencia garantizada (una sola definición)
- ✅ Versionado con Git
- ✅ Documentación inline

---

### 3. Dimensiones Derivadas

**Ejemplo: Rango Etario**
```lookml
dimension: rango_etario {
  type: tier
  tiers: [0, 18, 30, 45, 60, 75]
  style: integer
  sql: ${edad} ;;
}
```

**Beneficio:** Segmentación automática sin necesidad de CASE WHEN en cada query

---

### 4. Drill-downs Configurados

```lookml
measure: cantidad_afiliados {
  type: count
  drill_fields: [afiliado_id, nombre, plan, estado, ciudad]
}
```

**UX:** Click en KPI → desglose automático hasta nivel de detalle

---

## 📈 Comparativa de Tecnologías

| Característica | Looker | Power BI | Tableau |
|----------------|--------|----------|---------|
| **Modelo Declarativo** | ✅ LookML | ❌ DAX imperativo | ❌ Calculations |
| **Git Versionado** | ✅ Nativo | ❌ Manual | ❌ Manual |
| **Cloud-Native** | ✅ BigQuery integrado | ⚠️ Limitado | ⚠️ Limitado |
| **Governance** | ✅ Central (LookML) | ❌ Por archivo .pbix | ❌ Por workbook |
| **Colaboración** | ✅ Multi-usuario real | ❌ 1 a la vez | ⚠️ Server necesario |

**Por qué Looker es superior para empresas:**
- Único modelo central → sin "shadow BI"
- Cambios versionados → auditoría completa
- Queries optimizadas → genera SQL eficiente
- Escalabilidad → cloud data warehouse nativo

---

## 🎓 Aprendizajes del Proyecto

### Técnicos

1. **LookML vs DAX:** Curva de aprendizaje inicial más empinada, pero más mantenible a largo plazo
2. **BigQuery Optimizations:** Particionamiento por fecha crítico para queries de rango temporal
3. **Data Quality:** Validaciones upstream (en Python) evitan bugs downstream (en Looker)

### De Negocio

1. **KPIs Accionables:** Loss Ratio >80% → señal clara de acción (no solo métrica descriptiva)
2. **Granularidad Correcta:** Prestación individual permite drill-down; agregación mensual es suficiente para reportes ejecutivos
3. **Self-Service BI:** Explores permiten que usuarios de negocio respondan sus propias preguntas sin SQL

---

## 🚀 Próximos Pasos (Roadmap Hipotético)

Si esto fuera un proyecto real en producción:

**Fase 2 - Análisis Avanzado**
- [ ] Modelos de scoring de churn (ML en BigQuery)
- [ ] Alertas automáticas (email/Slack cuando loss_ratio > 80%)
- [ ] Análisis de cohortes (retención por fecha de alta)

**Fase 3 - Integraciones**
- [ ] API de Looker para embeds en portal de autogestión
- [ ] ETL desde sistema transaccional (Airflow + dbt)
- [ ] Data catalog (documentación de lineage)

**Fase 4 - Gobierno**
- [ ] Políticas de acceso por rol (RLS en Looker)
- [ ] Auditoría de queries ejecutados
- [ ] SLAs de actualización de datos

---

## 📞 Contacto

**Nicolás Ledesma**  
Analista de Datos | Especializado en Sector Salud  

📧 nico99led@gmail.com  
📞 +543547660902  
💼 [LinkedIn](https://linkedin.com/in/nicolás-ledesma)  
🐙 [GitHub Portfolio](https://github.com/nicoledesma99/Porfolio-Bi)  

**Disponibilidad:** Inmediata  
**Ubicación:** Córdoba, Argentina (Híbrido/Remoto)  
**Modalidad Preferida:** Contractor con actualización trimestral

---

_Este proyecto fue desarrollado como demostración de capacidades técnicas. Los datos son sintéticos y no representan información real de ninguna organización._
