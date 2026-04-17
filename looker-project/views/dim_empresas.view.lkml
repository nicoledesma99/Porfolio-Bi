# =====================================================
# VIEW: dim_empresas
# Dimensión de empresas contratantes
# =====================================================

view: dim_empresas {
  sql_table_name: `salud_demo.dim_empresas` ;;
  
  dimension: empresa_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.empresa_id ;;
  }
  
  dimension: nombre_empresa {
    type: string
    sql: ${TABLE}.nombre_empresa ;;
  }
  
  dimension: categoria {
    type: string
    sql: ${TABLE}.categoria ;;
  }
  
  dimension: cantidad_afiliados {
    type: number
    sql: ${TABLE}.cantidad_afiliados ;;
  }
  
  dimension_group: fecha_inicio_contrato {
    type: time
    timeframes: [date, month, year]
    sql: ${TABLE}.fecha_inicio_contrato ;;
  }
  
  measure: cantidad_empresas {
    type: count
    drill_fields: [empresa_id, nombre_empresa, categoria, cantidad_afiliados]
  }
  
  measure: total_afiliados_contratados {
    type: sum
    sql: ${cantidad_afiliados} ;;
  }
}
