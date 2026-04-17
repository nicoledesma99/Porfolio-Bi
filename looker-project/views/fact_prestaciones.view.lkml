# =====================================================
# VIEW: fact_prestaciones
# Tabla de hechos: prestaciones médicas
# =====================================================

view: fact_prestaciones {
  sql_table_name: `salud_demo.fact_prestaciones` ;;
  
  # ===== DIMENSIONES =====
  
  dimension: prestacion_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.prestacion_id ;;
  }
  
  dimension: afiliado_id {
    type: number
    hidden: yes
    sql: ${TABLE}.afiliado_id ;;
  }
  
  dimension: prestador_id {
    type: number
    hidden: yes
    sql: ${TABLE}.prestador_id ;;
  }
  
  dimension_group: fecha {
    type: time
    timeframes: [date, week, month, quarter, year, day_of_week]
    sql: ${TABLE}.fecha ;;
  }
  
  dimension: tipo_prestacion {
    type: string
    sql: ${TABLE}.tipo_prestacion ;;
  }
  
  dimension: codigo_prestacion {
    type: string
    sql: ${TABLE}.codigo_prestacion ;;
  }
  
  dimension: costo_prestacion {
    type: number
    sql: ${TABLE}.costo_prestacion ;;
    value_format_name: decimal_2
  }
  
  dimension: costo_prestador {
    type: number
    sql: ${TABLE}.costo_prestador ;;
    value_format_name: decimal_2
    description: "Monto pagado al prestador"
  }
  
  dimension: margen_prestacion {
    type: number
    sql: ${costo_prestacion} - ${costo_prestador} ;;
    value_format_name: decimal_2
    description: "Diferencia entre costo total y pago a prestador"
  }
  
  dimension: fue_autorizada {
    type: yesno
    sql: ${TABLE}.fue_autorizada ;;
  }
  
  dimension: diagnostico_codigo {
    type: string
    sql: ${TABLE}.diagnostico_codigo ;;
  }
  
  # Segmentación de costos
  dimension: categoria_costo {
    type: tier
    tiers: [0, 10000, 50000, 100000, 200000, 500000]
    style: integer
    sql: ${costo_prestacion} ;;
  }
  
  # ===== MEDIDAS =====
  
  measure: cantidad_prestaciones {
    type: count
    drill_fields: [prestacion_id, fecha_date, tipo_prestacion, costo_prestacion]
  }
  
  measure: cantidad_autorizadas {
    type: count
    filters: [fue_autorizada: "yes"]
  }
  
  measure: tasa_autorizacion {
    type: number
    sql: SAFE_DIVIDE(${cantidad_autorizadas}, ${cantidad_prestaciones}) ;;
    value_format_name: percent_2
  }
  
  # KPIs de Costos
  measure: costo_total {
    type: sum
    sql: ${costo_prestacion} ;;
    value_format: "$#,##0"
    drill_fields: [fecha_month, tipo_prestacion, costo_total]
  }
  
  measure: pago_prestadores {
    type: sum
    sql: ${costo_prestador} ;;
    value_format: "$#,##0"
  }
  
  measure: margen_total {
    type: sum
    sql: ${margen_prestacion} ;;
    value_format: "$#,##0"
    description: "Diferencia entre costo total y pago a prestadores"
  }
  
  measure: costo_promedio {
    type: average
    sql: ${costo_prestacion} ;;
    value_format: "$#,##0.00"
  }
  
  measure: costo_por_afiliado {
    type: number
    sql: SAFE_DIVIDE(${costo_total}, ${dim_afiliados.cantidad_afiliados}) ;;
    value_format: "$#,##0"
    description: "Costo médico promedio por afiliado"
  }
  
  # PMR (Prestación Médica por Afiliado)
  measure: pmr {
    type: number
    sql: SAFE_DIVIDE(${cantidad_prestaciones}, ${dim_afiliados.cantidad_afiliados}) ;;
    value_format_name: decimal_2
    description: "Prestaciones promedio por afiliado (Prestación Médica Rate)"
  }
  
  # Loss Ratio (Costo médico / Ingresos)
  measure: loss_ratio {
    type: number
    sql: SAFE_DIVIDE(${costo_total}, ${fact_facturacion.ingresos_totales}) ;;
    value_format_name: percent_2
    description: "Ratio de costo médico sobre ingresos"
  }
}
