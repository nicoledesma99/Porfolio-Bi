- dashboard: dashboard_operativo
  title: "Dashboard Operativo - Análisis de Prestaciones"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Análisis operativo de prestaciones, utilización y eficiencia de prestadores"
  
  filters:
  - name: rango_fechas
    title: "Rango de Fechas"
    type: field_filter
    default_value: "3 months"
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: salud_prepaga
    explore: fact_prestaciones
    listens_to_filters: []
    field: fact_prestaciones.fecha_month
    
  - name: filtro_plan
    title: "Plan"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: popover
    model: salud_prepaga
    explore: fact_prestaciones
    listens_to_filters: []
    field: dim_afiliados.plan
    
  elements:
  
  # ===== FILA 1: MÉTRICAS OPERATIVAS =====
  
  - name: total_prestaciones
    title: "Total Prestaciones"
    model: salud_prepaga
    explore: fact_prestaciones
    type: single_value
    fields: [fact_prestaciones.cantidad_prestaciones]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    value_format: "#,##0"
    font_size: medium
    row: 0
    col: 0
    width: 5
    height: 3
    
  - name: costo_promedio_prestacion
    title: "Costo Promedio por Prestación"
    model: salud_prepaga
    explore: fact_prestaciones
    type: single_value
    fields: [fact_prestaciones.costo_promedio]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    value_format: "$#,##0"
    font_size: medium
    row: 0
    col: 5
    width: 5
    height: 3
    
  - name: pmr_rate
    title: "PMR (Prestaciones por Afiliado)"
    model: salud_prepaga
    explore: fact_prestaciones
    type: single_value
    fields: [fact_prestaciones.pmr]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    value_format: "0.00"
    font_size: medium
    row: 0
    col: 10
    width: 5
    height: 3
    
  - name: tasa_autorizacion
    title: "Tasa de Autorización"
    model: salud_prepaga
    explore: fact_prestaciones
    type: single_value
    fields: [fact_prestaciones.tasa_autorizacion]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    limit: 1
    custom_color_enabled: true
    show_single_value_title: true
    value_format: "0.0%"
    font_size: medium
    row: 0
    col: 15
    width: 5
    height: 3
    
  # ===== FILA 2: DISTRIBUCIÓN POR TIPO =====
  
  - name: prestaciones_por_tipo
    title: "Distribución de Prestaciones por Tipo"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_pie
    fields: [fact_prestaciones.tipo_prestacion, fact_prestaciones.cantidad_prestaciones]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    sorts: [fact_prestaciones.cantidad_prestaciones desc]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 50
    color_application:
      collection_id: looker
      palette_id: looker-categorical-0
    series_colors:
      Consulta: "#7CB5EC"
      Internación: "#D32F2F"
      Estudio: "#90ED7D"
      Farmacia: "#F7A35C"
      Urgencia: "#8085E9"
    row: 3
    col: 0
    width: 10
    height: 6
    
  - name: costo_por_tipo
    title: "Costo Total por Tipo de Prestación"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_column
    fields: [fact_prestaciones.tipo_prestacion, fact_prestaciones.costo_total, 
             fact_prestaciones.pago_prestadores, fact_prestaciones.margen_total]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    sorts: [fact_prestaciones.costo_total desc]
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
    series_colors:
      fact_prestaciones.costo_total: "#1f77b4"
      fact_prestaciones.pago_prestadores: "#ff7f0e"
      fact_prestaciones.margen_total: "#2ca02c"
    row: 3
    col: 10
    width: 14
    height: 6
    
  # ===== FILA 3: ANÁLISIS TEMPORAL =====
  
  - name: prestaciones_por_dia_semana
    title: "Prestaciones por Día de la Semana"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_column
    fields: [fact_prestaciones.fecha_day_of_week, fact_prestaciones.cantidad_prestaciones]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    sorts: [fact_prestaciones.fecha_day_of_week]
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
    col: 0
    width: 12
    height: 6
    
  - name: tendencia_mensual_tipo
    title: "Tendencia Mensual por Tipo de Prestación"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_line
    fields: [fact_prestaciones.fecha_month, fact_prestaciones.tipo_prestacion, 
             fact_prestaciones.cantidad_prestaciones]
    pivots: [fact_prestaciones.tipo_prestacion]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    sorts: [fact_prestaciones.fecha_month, fact_prestaciones.tipo_prestacion]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: true
    show_x_axis_ticks: true
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
    row: 9
    col: 12
    width: 12
    height: 6
    
  # ===== FILA 4: TABLAS DETALLE =====
  
  - name: ranking_prestadores
    title: "Ranking de Prestadores - Top 20"
    model: salud_prepaga
    explore: fact_prestaciones
    type: looker_grid
    fields: [dim_prestadores.nombre_prestador, dim_prestadores.tipo, 
             fact_prestaciones.cantidad_prestaciones, fact_prestaciones.costo_total,
             fact_prestaciones.costo_promedio, fact_prestaciones.pago_prestadores]
    listen:
      rango_fechas: fact_prestaciones.fecha_month
      filtro_plan: dim_afiliados.plan
    sorts: [fact_prestaciones.costo_total desc]
    limit: 20
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: true
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    series_cell_visualizations:
      fact_prestaciones.costo_total:
        is_active: true
    row: 15
    col: 0
    width: 24
    height: 8
