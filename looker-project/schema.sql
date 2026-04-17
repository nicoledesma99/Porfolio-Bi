-- SCHEMA: Prepaga de Salud - Looker Demo Project
-- Dataset: salud_demo
-- Autor: Nicolás Ledesma
-- Propósito: Portfolio - Demostración de modelado en Looker para sector salud

-- =====================================================
-- TABLA 1: dim_afiliados
-- Dimensión de afiliados/socios
-- =====================================================
CREATE TABLE `salud_demo.dim_afiliados` (
  afiliado_id INT64 NOT NULL,
  nombre STRING,
  edad INT64,
  genero STRING,
  plan STRING,  -- Plan A (básico), Plan B (intermedio), Plan C (premium)
  fecha_alta DATE,
  fecha_baja DATE,
  estado STRING,  -- Activo, Baja
  empresa_id INT64,
  grupo_familiar_id INT64,
  ciudad STRING,
  provincia STRING
);

-- =====================================================
-- TABLA 2: dim_empresas
-- Dimensión de empresas/grupos contratantes
-- =====================================================
CREATE TABLE `salud_demo.dim_empresas` (
  empresa_id INT64 NOT NULL,
  nombre_empresa STRING,
  categoria STRING,  -- Corporativa, PyME, Individual
  cantidad_afiliados INT64,
  fecha_inicio_contrato DATE
);

-- =====================================================
-- TABLA 3: dim_prestadores
-- Dimensión de prestadores médicos
-- =====================================================
CREATE TABLE `salud_demo.dim_prestadores` (
  prestador_id INT64 NOT NULL,
  nombre_prestador STRING,
  tipo STRING,  -- Hospital, Clínica, Consultorio, Laboratorio
  especialidad STRING,
  ciudad STRING,
  provincia STRING,
  costo_promedio_consulta FLOAT64
);

-- =====================================================
-- TABLA 4: fact_prestaciones
-- Tabla de hechos: prestaciones médicas
-- =====================================================
CREATE TABLE `salud_demo.fact_prestaciones` (
  prestacion_id INT64 NOT NULL,
  afiliado_id INT64,
  prestador_id INT64,
  fecha DATE,
  tipo_prestacion STRING,  -- Consulta, Internación, Estudio, Farmacia, Urgencia
  codigo_prestacion STRING,
  costo_prestacion FLOAT64,
  costo_prestador FLOAT64,  -- Lo que se paga al prestador
  fue_autorizada BOOLEAN,
  diagnostico_codigo STRING
);

-- =====================================================
-- TABLA 5: fact_facturacion
-- Tabla de hechos: facturación mensual por afiliado
-- =====================================================
CREATE TABLE `salud_demo.fact_facturacion` (
  facturacion_id INT64 NOT NULL,
  afiliado_id INT64,
  periodo DATE,  -- Primer día del mes
  monto_cuota FLOAT64,
  fecha_vencimiento DATE,
  fecha_pago DATE,
  estado_pago STRING,  -- Pagado, Pendiente, Moroso
  dias_mora INT64
);

-- =====================================================
-- ÍNDICES Y COMENTARIOS
-- =====================================================
-- Las PKs y FKs se manejan en el modelo LookML
-- Este schema es para carga en BigQuery
