- dashboard: dashboard_ejecutivo
  title: "Dashboard Ejecutivo - Prepaga de Salud"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Vista ejecutiva con KPIs principales de rentabilidad, afiliados y tendencias"
  
  elements:
  
  # ===== FILA 1: KPIs PRINCIPALES =====
  
  - name: kpi_afiliados_activos
    title: "Afiliados Activos"
    model: salud_prepaga
    explore: dim_afiliados
    type: single_value
    fields: [dim_afiliados.cantidad_activos]
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    value_format: "#,##0"
    font_size: medium
    text_color: "#3A4245"
    row: 0
    col: 0
    width: 4
    height: 3
    
  - name: kpi_ingresos_mes
    title: "Ingresos Mes Actual"
    model: salud_prepaga
    explore: fact_facturacion
    type: single_value
    fields: [fact_facturacion.periodo_month, fact_facturacion.ingresos_totales]
    filters:
      fact_facturacion.periodo_month: 1 months
    sorts: [fact_facturacion.periodo_month desc]
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: progress_percentage
    value_format: "$#,##0"
    font_size: medium
    text_color: "#3A4245"
    row: 0
    col: 4
    width: 4
    height: 3
    
  - name: kpi_loss_ratio
    title: "Loss Ratio"
    model: salud_prepaga
    explore: fact_prestaciones
    type: single_value
    fields: [fact_prestaciones.loss_ratio]
    filters:
      fact_prestaciones.fecha_month: 1 months
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    value_format: "0.0%"
    font_size: medium
    text_color: "#3A4245"
    row: 0
    col: 8
    width: 4
    height: 3
    
  - name: kpi_margen_bruto
    title: "Margen Bruto"
    model: salud_prepaga
    explore: fact_facturacion
    type: single_value
    fields: [fact_facturacion.margen_bruto]
    filters:
      fact_facturacion.periodo_month: 1 months
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    value_format: "$#,##0"
    font_size: medium
    text_color: "#3A4245"
    row: 0
    col: 12
    width: 4
    height: 3
    
  - name: kpi_tasa_morosidad
    title: "Tasa de Morosidad"
    model: salud_prepaga
    explore: fact_facturacion
    type: single_value
    fields: [fact_facturacion.tasa_morosidad]
    filters:
      fact_facturacion.periodo_month: 1 months
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    value_format: "0.0%"
    font_size: medium
    text_color: "#D32F2F"
    row: 0
    col: 16
    width: 4
    height: 3
    
  - name: kpi_churn_rate
    title: "Tasa de Churn"
    model: salud_prepaga
    explore: dim_afiliados
    type: single_value
    fields: [dim_afiliados.tasa_churn]
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    value_format: "0.0%"
    font_size: medium
    text_color: "#D32F2F"
    row: 0
    col: 20
    width: 4
    height: 3
    
  # ===== FILA 2: EVOLUCIÓN TEMPORAL =====
  
  - name: tendencia_ingresos_costos
    title: "Evolución Ingresos vs Costos Médicos"
    model: salud_prepaga
    explore: fact_facturacion
    type: looker_line
    fields: [fact_facturacion.periodo_month, fact_facturacion.ingresos_totales, 
             fact_prestaciones.costo_total, fact_facturacion.margen_bruto]
    filters:
      fact_facturacion.periodo_month: 12 months
    sorts: [fact_facturacion.periodo_month]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    series_colors:
      fact_facturacion.ingresos_totales: "#1f77b4"
      fact_prestaciones.costo_total: "#d62728"
      fact_facturacion.margen_bruto: "#2ca02c"
    row: 3
    col: 0
    width: 12
    height: 6
    
  - name: evolucion_afiliados
    title: "Evolución Base de Afiliados"
    model: salud_prepaga
    explore: dim_afiliados
    type: looker_column
    fields: [dim_afiliados.fecha_alta_month, dim_afiliados.cantidad_afiliados]
    filters:
      dim_afiliados.fecha_alta_month: 12 months
    sorts: [dim_afiliados.fecha_alta_month]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: true
    show_x_axis_ticks: true
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    series_colors:
      dim_afiliados.cantidad_afiliados: "#5E2129"
    row: 3
    col: 12
    width: 12
    height: 6
    
  # ===== FILA 3: DISTRIBUCIONES =====
  
  - name: distribucion_por_plan
    title: "Distribución de Afiliados por Plan"
    model: salud_prepaga
    explore: dim_afiliados
    type: looker_pie
    fields: [dim_afiliados.plan, dim_afiliados.cantidad_afiliados]
    filters:
      dim_afiliados.estado: "Activo"
    sorts: [dim_afiliados.cantidad_afiliados desc]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 40
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    series_colors:
      Plan A: "#7CB5EC"
      Plan B: "#90ED7D"
      Plan C: "#F7A35C"
    row: 9
    col: 0
    width: 8
    height: 6
    
  - name: top_prestadores_costo
    title: "Top 10 Prestadores por Costo"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_bar
    fields: [dim_prestadores.nombre_prestador, fact_prestaciones.costo_total, 
             fact_prestaciones.cantidad_prestaciones]
    filters:
      fact_prestaciones.fecha_month: 3 months
    sorts: [fact_prestaciones.costo_total desc]
    limit: 10
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: false
    show_x_axis_ticks: true
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    row: 9
    col: 8
    width: 8
    height: 6
    
  - name: morosidad_por_plan
    title: "Morosidad por Plan"
    model: salud_prepaga
    explore: fact_facturacion
    type: looker_column
    fields: [dim_afiliados.plan, fact_facturacion.tasa_morosidad, 
             fact_facturacion.ingresos_pendientes]
    filters:
      fact_facturacion.periodo_month: 1 months
    sorts: [fact_facturacion.ingresos_pendientes desc]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: false
    show_x_axis_ticks: true
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    row: 9
    col: 16
    width: 8
    height: 6
