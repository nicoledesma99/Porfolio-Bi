# =====================================================
# VIEW: dim_afiliados
# Dimensiones de afiliados/socios
# =====================================================

view: dim_afiliados {
  sql_table_name: `salud_demo.dim_afiliados` ;;
  
  # ===== DIMENSIONES =====
  
  dimension: afiliado_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.afiliado_id ;;
  }
  
  dimension: nombre {
    type: string
    sql: ${TABLE}.nombre ;;
  }
  
  dimension: edad {
    type: number
    sql: ${TABLE}.edad ;;
  }
  
  dimension: rango_etario {
    type: tier
    tiers: [0, 18, 30, 45, 60, 75]
    style: integer
    sql: ${edad} ;;
  }
  
  dimension: genero {
    type: string
    sql: ${TABLE}.genero ;;
  }
  
  dimension: plan {
    type: string
    sql: ${TABLE}.plan ;;
    order_by_field: plan_order
  }
  
  dimension: plan_order {
    hidden: yes
    type: number
    sql: CASE ${plan}
           WHEN 'Plan A' THEN 1
           WHEN 'Plan B' THEN 2
           WHEN 'Plan C' THEN 3
         END ;;
  }
  
  dimension_group: fecha_alta {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.fecha_alta ;;
  }
  
  dimension_group: fecha_baja {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.fecha_baja ;;
  }
  
  dimension: estado {
    type: string
    sql: ${TABLE}.estado ;;
  }
  
  dimension: empresa_id {
    type: number
    hidden: yes
    sql: ${TABLE}.empresa_id ;;
  }
  
  dimension: grupo_familiar_id {
    type: number
    sql: ${TABLE}.grupo_familiar_id ;;
  }
  
  dimension: ciudad {
    type: string
    sql: ${TABLE}.ciudad ;;
  }
  
  dimension: provincia {
    type: string
    sql: ${TABLE}.provincia ;;
  }
  
  # Dimensión calculada: Antigüedad en días
  dimension: antiguedad_dias {
    type: number
    sql: DATE_DIFF(
           COALESCE(${fecha_baja_date}, CURRENT_DATE()),
           ${fecha_alta_date},
           DAY
         ) ;;
  }
  
  dimension: antiguedad_meses {
    type: number
    sql: CAST(${antiguedad_dias} / 30 AS INT64) ;;
  }
  
  dimension: rango_antiguedad {
    type: tier
    tiers: [0, 3, 6, 12, 24, 36]
    style: integer
    sql: ${antiguedad_meses} ;;
    description: "Antigüedad en meses agrupada por rangos"
  }
  
  # ===== MEDIDAS =====
  
  measure: cantidad_afiliados {
    type: count
    drill_fields: [afiliado_id, nombre, plan, estado, ciudad]
  }
  
  measure: cantidad_activos {
    type: count
    filters: [estado: "Activo"]
    drill_fields: [afiliado_id, nombre, plan, ciudad]
  }
  
  measure: cantidad_bajas {
    type: count
    filters: [estado: "Baja"]
    drill_fields: [afiliado_id, nombre, fecha_baja_date, plan]
  }
  
  measure: tasa_churn {
    type: number
    sql: SAFE_DIVIDE(${cantidad_bajas}, ${cantidad_afiliados}) ;;
    value_format_name: percent_2
    description: "Porcentaje de bajas sobre total de afiliados"
  }
  
  measure: edad_promedio {
    type: average
    sql: ${edad} ;;
    value_format_name: decimal_1
  }
  
  measure: antiguedad_promedio_meses {
    type: average
    sql: ${antiguedad_meses} ;;
    value_format_name: decimal_1
  }
  
  measure: cantidad_grupos_familiares {
    type: count_distinct
    sql: ${grupo_familiar_id} ;;
  }
}
