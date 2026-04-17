import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Seed para reproducibilidad
np.random.seed(42)
random.seed(42)

# =====================================================
# DATOS MAESTROS
# =====================================================

ciudades_cordoba = [
    'Córdoba Capital', 'Villa Carlos Paz', 'Río Cuarto', 'Alta Gracia',
    'Villa María', 'San Francisco', 'Jesús María', 'Bell Ville'
]

nombres_empresas = [
    'Arcor SA', 'Fiat Chrysler', 'Grupo Dinosaurio', 'Electroingeniería',
    'EPEC', 'Banco Macro', 'Municipalidad Córdoba', 'Universidad Nacional',
    'Roggio Ambiental', 'Clínica Privada del Sur'
]

nombres_prestadores = [
    'Hospital Privado', 'Sanatorio Allende', 'Clínica Reina Fabiola',
    'Sanatorio de la Cañada', 'Clínica Romagosa', 'Centro Médico Cerro',
    'Laboratorio Stamboulian', 'Farmacia del Centro', 'Urgencias Médicas 24hs',
    'Consultorio Dr. Pérez', 'Clínica de Ojos', 'Centro de Diagnóstico',
    'Sanatorio Parque', 'Hospital Italiano'
]

especialidades = [
    'Clínica Médica', 'Cardiología', 'Pediatría', 'Ginecología',
    'Traumatología', 'Diagnóstico por Imágenes', 'Laboratorio',
    'Farmacia', 'Urgencias'
]

tipos_prestacion = [
    'Consulta', 'Internación', 'Estudio', 'Farmacia', 'Urgencia'
]

# =====================================================
# 1. GENERAR EMPRESAS
# =====================================================

empresas = pd.DataFrame({
    'empresa_id': range(1, 11),
    'nombre_empresa': nombres_empresas,
    'categoria': np.random.choice(['Corporativa', 'PyME', 'Individual'], 10, p=[0.3, 0.5, 0.2]),
    'cantidad_afiliados': np.random.randint(50, 500, 10),
    'fecha_inicio_contrato': [
        (datetime(2020, 1, 1) + timedelta(days=random.randint(0, 1095))).strftime('%Y-%m-%d')
        for _ in range(10)
    ]
})

empresas.to_csv('/home/claude/looker-project/dim_empresas.csv', index=False)
print(f"✓ dim_empresas.csv generado: {len(empresas)} registros")

# =====================================================
# 2. GENERAR PRESTADORES
# =====================================================

prestadores = pd.DataFrame({
    'prestador_id': range(1, 15),
    'nombre_prestador': nombres_prestadores,
    'tipo': ['Hospital', 'Clínica', 'Clínica', 'Clínica', 'Clínica', 'Consultorio',
             'Laboratorio', 'Farmacia', 'Urgencia', 'Consultorio', 'Consultorio',
             'Laboratorio', 'Clínica', 'Hospital'],
    'especialidad': np.random.choice(especialidades, 14),
    'ciudad': np.random.choice(ciudades_cordoba, 14),
    'provincia': 'Córdoba',
    'costo_promedio_consulta': np.random.uniform(3000, 15000, 14).round(2)
})

prestadores.to_csv('/home/claude/looker-project/dim_prestadores.csv', index=False)
print(f"✓ dim_prestadores.csv generado: {len(prestadores)} registros")

# =====================================================
# 3. GENERAR AFILIADOS
# =====================================================

num_afiliados = 1500
fecha_inicio = datetime(2020, 1, 1)
fecha_fin = datetime(2026, 3, 31)

afiliados = []
for i in range(1, num_afiliados + 1):
    fecha_alta = fecha_inicio + timedelta(days=random.randint(0, (fecha_fin - fecha_inicio).days))
    
    # 15% de bajas
    tiene_baja = random.random() < 0.15
    dias_disponibles = (fecha_fin - fecha_alta).days
    
    if tiene_baja and dias_disponibles > 30:
        dias_desde_alta = random.randint(30, dias_disponibles)
        fecha_baja = (fecha_alta + timedelta(days=dias_desde_alta)).strftime('%Y-%m-%d')
        estado = 'Baja'
    else:
        fecha_baja = None
        estado = 'Activo'
    
    afiliados.append({
        'afiliado_id': i,
        'nombre': f'Afiliado {i:04d}',
        'edad': random.randint(0, 85),
        'genero': random.choice(['M', 'F']),
        'plan': np.random.choice(['Plan A', 'Plan B', 'Plan C'], p=[0.5, 0.35, 0.15]),
        'fecha_alta': fecha_alta.strftime('%Y-%m-%d'),
        'fecha_baja': fecha_baja,
        'estado': estado,
        'empresa_id': random.randint(1, 10),
        'grupo_familiar_id': random.randint(1, 400),
        'ciudad': random.choice(ciudades_cordoba),
        'provincia': 'Córdoba'
    })

afiliados_df = pd.DataFrame(afiliados)
afiliados_df.to_csv('/home/claude/looker-project/dim_afiliados.csv', index=False)
print(f"✓ dim_afiliados.csv generado: {len(afiliados_df)} registros")

# =====================================================
# 4. GENERAR PRESTACIONES
# =====================================================

num_prestaciones = 25000
prestaciones = []

for _ in range(num_prestaciones):
    afiliado_id = random.randint(1, num_afiliados)
    afiliado = afiliados_df[afiliados_df['afiliado_id'] == afiliado_id].iloc[0]
    
    # Fecha entre fecha_alta y (fecha_baja o hoy)
    fecha_alta = datetime.strptime(afiliado['fecha_alta'], '%Y-%m-%d')
    if pd.notna(afiliado['fecha_baja']):
        fecha_limite = datetime.strptime(afiliado['fecha_baja'], '%Y-%m-%d')
    else:
        fecha_limite = fecha_fin
    
    fecha_prestacion = fecha_alta + timedelta(days=random.randint(0, (fecha_limite - fecha_alta).days))
    
    tipo_prest = random.choice(tipos_prestacion)
    
    # Costos realistas según tipo
    if tipo_prest == 'Consulta':
        costo = random.uniform(5000, 15000)
        costo_prest = costo * random.uniform(0.6, 0.8)
    elif tipo_prest == 'Internación':
        costo = random.uniform(200000, 800000)
        costo_prest = costo * random.uniform(0.7, 0.85)
    elif tipo_prest == 'Estudio':
        costo = random.uniform(15000, 80000)
        costo_prest = costo * random.uniform(0.65, 0.8)
    elif tipo_prest == 'Farmacia':
        costo = random.uniform(2000, 25000)
        costo_prest = costo * random.uniform(0.5, 0.7)
    else:  # Urgencia
        costo = random.uniform(30000, 120000)
        costo_prest = costo * random.uniform(0.7, 0.85)
    
    prestaciones.append({
        'prestacion_id': len(prestaciones) + 1,
        'afiliado_id': afiliado_id,
        'prestador_id': random.randint(1, 14),
        'fecha': fecha_prestacion.strftime('%Y-%m-%d'),
        'tipo_prestacion': tipo_prest,
        'codigo_prestacion': f'{tipo_prest[:3].upper()}{random.randint(1000, 9999)}',
        'costo_prestacion': round(costo, 2),
        'costo_prestador': round(costo_prest, 2),
        'fue_autorizada': random.random() < 0.95,
        'diagnostico_codigo': f'CIE{random.randint(10, 99)}.{random.randint(0, 9)}'
    })

prestaciones_df = pd.DataFrame(prestaciones)
prestaciones_df.to_csv('/home/claude/looker-project/fact_prestaciones.csv', index=False)
print(f"✓ fact_prestaciones.csv generado: {len(prestaciones_df)} registros")

# =====================================================
# 5. GENERAR FACTURACIÓN
# =====================================================

facturacion = []
facturacion_id = 1

# Cuotas mensuales según plan
cuotas_plan = {
    'Plan A': 45000,
    'Plan B': 75000,
    'Plan C': 120000
}

for _, afiliado in afiliados_df.iterrows():
    fecha_alta = datetime.strptime(afiliado['fecha_alta'], '%Y-%m-%d')
    if pd.notna(afiliado['fecha_baja']):
        fecha_limite = datetime.strptime(afiliado['fecha_baja'], '%Y-%m-%d')
    else:
        fecha_limite = fecha_fin
    
    # Generar facturas mensuales
    fecha_actual = datetime(fecha_alta.year, fecha_alta.month, 1)
    
    while fecha_actual <= fecha_limite:
        fecha_venc = fecha_actual + timedelta(days=10)
        
        # 85% pagan a tiempo, 10% con mora, 5% morosos crónicos
        rand = random.random()
        if rand < 0.85:
            fecha_pago = fecha_venc - timedelta(days=random.randint(0, 5))
            estado = 'Pagado'
            dias_mora = 0
        elif rand < 0.95:
            dias_atraso = random.randint(1, 30)
            fecha_pago = fecha_venc + timedelta(days=dias_atraso)
            estado = 'Pagado'
            dias_mora = dias_atraso
        else:
            fecha_pago = None
            estado = 'Moroso'
            dias_mora = max(0, (fecha_fin - fecha_venc).days)
        
        facturacion.append({
            'facturacion_id': facturacion_id,
            'afiliado_id': afiliado['afiliado_id'],
            'periodo': fecha_actual.strftime('%Y-%m-%d'),
            'monto_cuota': cuotas_plan[afiliado['plan']],
            'fecha_vencimiento': fecha_venc.strftime('%Y-%m-%d'),
            'fecha_pago': fecha_pago.strftime('%Y-%m-%d') if fecha_pago else None,
            'estado_pago': estado,
            'dias_mora': dias_mora
        })
        
        facturacion_id += 1
        fecha_actual = (fecha_actual + timedelta(days=32)).replace(day=1)

facturacion_df = pd.DataFrame(facturacion)
facturacion_df.to_csv('/home/claude/looker-project/fact_facturacion.csv', index=False)
print(f"✓ fact_facturacion.csv generado: {len(facturacion_df)} registros")

print("\n=== RESUMEN ===")
print(f"Total afiliados: {len(afiliados_df)}")
print(f"  - Activos: {len(afiliados_df[afiliados_df['estado'] == 'Activo'])}")
print(f"  - Bajas: {len(afiliados_df[afiliados_df['estado'] == 'Baja'])}")
print(f"Total prestaciones: {len(prestaciones_df)}")
print(f"Total facturas: {len(facturacion_df)}")
print(f"Costo médico total: ${prestaciones_df['costo_prestacion'].sum():,.0f}")
print(f"Ingresos totales: ${facturacion_df['monto_cuota'].sum():,.0f}")
