# =====================================================
# MODELO LOOKER: Prepaga de Salud
# Autor: Nicolás Ledesma
# Dataset: salud_demo (BigQuery)
# =====================================================

connection: "bigquery_salud"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

datagroup: salud_default_datagroup {
  sql_trigger: SELECT MAX(fecha) FROM `salud_demo.fact_prestaciones` ;;
  max_cache_age: "1 hour"
}

persist_with: salud_default_datagroup

# =====================================================
# EXPLORES (puntos de entrada para análisis)
# =====================================================

explore: fact_prestaciones {
  label: "Prestaciones Médicas"
  description: "Análisis de prestaciones, costos y utilización de servicios médicos"
  
  join: dim_afiliados {
    type: left_outer
    sql_on: ${fact_prestaciones.afiliado_id} = ${dim_afiliados.afiliado_id} ;;
    relationship: many_to_one
  }
  
  join: dim_empresas {
    type: left_outer
    sql_on: ${dim_afiliados.empresa_id} = ${dim_empresas.empresa_id} ;;
    relationship: many_to_one
  }
  
  join: dim_prestadores {
    type: left_outer
    sql_on: ${fact_prestaciones.prestador_id} = ${dim_prestadores.prestador_id} ;;
    relationship: many_to_one
  }
}

explore: fact_facturacion {
  label: "Facturación y Cobranzas"
  description: "Análisis de ingresos, morosidad y cobranzas"
  
  join: dim_afiliados {
    type: left_outer
    sql_on: ${fact_facturacion.afiliado_id} = ${dim_afiliados.afiliado_id} ;;
    relationship: many_to_one
  }
  
  join: dim_empresas {
    type: left_outer
    sql_on: ${dim_afiliados.empresa_id} = ${dim_empresas.empresa_id} ;;
    relationship: many_to_one
  }
}

explore: dim_afiliados {
  label: "Afiliados y Churn"
  description: "Análisis de base de afiliados, altas, bajas y retención"
  
  join: dim_empresas {
    type: left_outer
    sql_on: ${dim_afiliados.empresa_id} = ${dim_empresas.empresa_id} ;;
    relationship: many_to_one
  }
  
  # Join con prestaciones para análisis de consumo
  join: fact_prestaciones {
    type: left_outer
    sql_on: ${dim_afiliados.afiliado_id} = ${fact_prestaciones.afiliado_id} ;;
    relationship: one_to_many
  }
  
  join: fact_facturacion {
    type: left_outer
    sql_on: ${dim_afiliados.afiliado_id} = ${fact_facturacion.afiliado_id} ;;
    relationship: one_to_many
  }
}
