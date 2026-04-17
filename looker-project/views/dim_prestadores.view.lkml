# =====================================================
# VIEW: dim_prestadores
# Dimensión de prestadores médicos
# =====================================================

view: dim_prestadores {
  sql_table_name: `salud_demo.dim_prestadores` ;;
  
  dimension: prestador_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.prestador_id ;;
  }
  
  dimension: nombre_prestador {
    type: string
    sql: ${TABLE}.nombre_prestador ;;
  }
  
  dimension: tipo {
    type: string
    sql: ${TABLE}.tipo ;;
  }
  
  dimension: especialidad {
    type: string
    sql: ${TABLE}.especialidad ;;
  }
  
  dimension: ciudad {
    type: string
    sql: ${TABLE}.ciudad ;;
  }
  
  dimension: provincia {
    type: string
    sql: ${TABLE}.provincia ;;
  }
  
  dimension: costo_promedio_consulta {
    type: number
    sql: ${TABLE}.costo_promedio_consulta ;;
    value_format_name: decimal_2
  }
  
  measure: cantidad_prestadores {
    type: count
    drill_fields: [prestador_id, nombre_prestador, tipo, especialidad]
  }
  
  measure: costo_promedio_catalogo {
    type: average
    sql: ${costo_promedio_consulta} ;;
    value_format: "$#,##0.00"
  }
}
