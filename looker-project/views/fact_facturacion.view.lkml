# =====================================================
# VIEW: fact_facturacion
# Tabla de hechos: facturación y cobranzas
# =====================================================

view: fact_facturacion {
  sql_table_name: `salud_demo.fact_facturacion` ;;
  
  # ===== DIMENSIONES =====
  
  dimension: facturacion_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.facturacion_id ;;
  }
  
  dimension: afiliado_id {
    type: number
    hidden: yes
    sql: ${TABLE}.afiliado_id ;;
  }
  
  dimension_group: periodo {
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.periodo ;;
  }
  
  dimension: monto_cuota {
    type: number
    sql: ${TABLE}.monto_cuota ;;
    value_format_name: decimal_2
  }
  
  dimension_group: fecha_vencimiento {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.fecha_vencimiento ;;
  }
  
  dimension_group: fecha_pago {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.fecha_pago ;;
  }
  
  dimension: estado_pago {
    type: string
    sql: ${TABLE}.estado_pago ;;
  }
  
  dimension: dias_mora {
    type: number
    sql: ${TABLE}.dias_mora ;;
  }
  
  dimension: rango_mora {
    type: tier
    tiers: [0, 1, 15, 30, 60, 90]
    style: integer
    sql: ${dias_mora} ;;
    description: "Rangos de morosidad en días"
  }
  
  dimension: esta_moroso {
    type: yesno
    sql: ${estado_pago} = 'Moroso' ;;
  }
  
  dimension: pago_a_tiempo {
    type: yesno
    sql: ${dias_mora} = 0 ;;
  }
  
  # ===== MEDIDAS =====
  
  measure: cantidad_facturas {
    type: count
    drill_fields: [afiliado_id, periodo_month, monto_cuota, estado_pago]
  }
  
  measure: cantidad_pagadas {
    type: count
    filters: [estado_pago: "Pagado"]
  }
  
  measure: cantidad_morosas {
    type: count
    filters: [estado_pago: "Moroso"]
  }
  
  measure: tasa_cobranza {
    type: number
    sql: SAFE_DIVIDE(${cantidad_pagadas}, ${cantidad_facturas}) ;;
    value_format_name: percent_2
    description: "Porcentaje de facturas cobradas"
  }
  
  measure: tasa_morosidad {
    type: number
    sql: SAFE_DIVIDE(${cantidad_morosas}, ${cantidad_facturas}) ;;
    value_format_name: percent_2
  }
  
  # KPIs de Ingresos
  measure: ingresos_totales {
    type: sum
    sql: ${monto_cuota} ;;
    value_format: "$#,##0"
    drill_fields: [periodo_month, dim_afiliados.plan, ingresos_totales]
  }
  
  measure: ingresos_cobrados {
    type: sum
    sql: ${monto_cuota} ;;
    filters: [estado_pago: "Pagado"]
    value_format: "$#,##0"
  }
  
  measure: ingresos_pendientes {
    type: sum
    sql: ${monto_cuota} ;;
    filters: [estado_pago: "Moroso"]
    value_format: "$#,##0"
    description: "Monto total en mora"
  }
  
  measure: ingreso_promedio_afiliado {
    type: average
    sql: ${monto_cuota} ;;
    value_format: "$#,##0.00"
  }
  
  measure: mora_promedio_dias {
    type: average
    sql: ${dias_mora} ;;
    value_format_name: decimal_1
  }
  
  # ARPU (Average Revenue Per User)
  measure: arpu {
    type: number
    sql: SAFE_DIVIDE(${ingresos_totales}, ${dim_afiliados.cantidad_afiliados}) ;;
    value_format: "$#,##0"
    description: "Ingreso promedio por afiliado"
  }
  
  # Margen bruto (Ingresos - Costos médicos)
  measure: margen_bruto {
    type: number
    sql: ${ingresos_totales} - ${fact_prestaciones.costo_total} ;;
    value_format: "$#,##0"
  }
  
  measure: margen_porcentual {
    type: number
    sql: SAFE_DIVIDE(
           ${ingresos_totales} - ${fact_prestaciones.costo_total},
           ${ingresos_totales}
         ) ;;
    value_format_name: percent_2
    description: "Margen bruto como porcentaje de ingresos"
  }
}
