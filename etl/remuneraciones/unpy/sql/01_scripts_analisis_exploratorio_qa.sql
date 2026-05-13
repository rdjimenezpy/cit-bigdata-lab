
select count(*) from core.fact_remuneraciones_unpy;


select distinct subgrupo_codigo, subgrupo_descripcion, 
objeto_gasto_codigo, objeto_gasto_descripcion 
from core.fact_remuneraciones_unpy
order by subgrupo_codigo, objeto_gasto_codigo;

-- Scripts SQL para EDA, calidad de datos y preparación para imponer NOT NULL
-- ============================================================
-- 0. CONFIG: esquema y tabla objetivo
-- ============================================================
SET search_path = core, public;

-- Nombre de la tabla: core.fact_remuneraciones_unpy
-- Ejecuta cada sección por separado según tu flujo de trabajo.

-- ============================================================
-- 1. ESTADÍSTICAS GENERALES (conteos, filas, columnas, tipos)
-- ============================================================
-- 1.1 Conteo total de filas
SELECT COUNT(*) AS total_filas
FROM core.fact_remuneraciones_unpy;

-- 1.2 Tipos y columnas
SELECT column_name, data_type, is_nullable, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'core' AND table_name = 'fact_remuneraciones_unpy'
ORDER BY ordinal_position;

-- 1.3 Conteo de valores distintos por columnas clave (muestra)
SELECT
  COUNT(DISTINCT nivel_codigo) AS distinct_nivel_codigo,
  COUNT(DISTINCT entidad_codigo) AS distinct_entidad_codigo,
  COUNT(DISTINCT oee_codigo) AS distinct_oee_codigo,
  COUNT(DISTINCT tipo_documento) AS distinct_tipo_documento,
  COUNT(DISTINCT sexo) AS distinct_sexo
FROM core.fact_remuneraciones_unpy;

-- ============================================================
-- 2. NULOS POR COLUMNA (reporte detallado)
-- ============================================================
-- 2.1 Conteo de nulos por columna (consulta explícita)
SELECT
  SUM(CASE WHEN anho IS NULL THEN 1 ELSE 0 END) AS anho_null,
  SUM(CASE WHEN mes IS NULL THEN 1 ELSE 0 END) AS mes_null,
  SUM(CASE WHEN nivel_codigo IS NULL THEN 1 ELSE 0 END) AS nivel_codigo_null,
  SUM(CASE WHEN entidad_codigo IS NULL THEN 1 ELSE 0 END) AS entidad_codigo_null,
  SUM(CASE WHEN oee_codigo IS NULL THEN 1 ELSE 0 END) AS oee_codigo_null,
  SUM(CASE WHEN tipo_documento IS NULL THEN 1 ELSE 0 END) AS tipo_documento_null,
  SUM(CASE WHEN documento IS NULL THEN 1 ELSE 0 END) AS documento_null,
  SUM(CASE WHEN nombres IS NULL THEN 1 ELSE 0 END) AS nombres_null,
  SUM(CASE WHEN apellidos IS NULL THEN 1 ELSE 0 END) AS apellidos_null,
  SUM(CASE WHEN sexo IS NULL THEN 1 ELSE 0 END) AS sexo_null,
  SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) AS fecha_nacimiento_null,
  SUM(CASE WHEN edad IS NULL THEN 1 ELSE 0 END) AS edad_null,
  SUM(CASE WHEN grupo_etario IS NULL THEN 1 ELSE 0 END) AS grupo_etario_null,
  SUM(CASE WHEN es_discapacitado IS NULL THEN 1 ELSE 0 END) AS es_discapacitado_null,
  SUM(CASE WHEN discapacidad_descripcion IS NULL THEN 1 ELSE 0 END) AS discapacidad_descripcion_null,
  SUM(CASE WHEN estado IS NULL THEN 1 ELSE 0 END) AS estado_null,
  SUM(CASE WHEN anho_ingreso IS NULL THEN 1 ELSE 0 END) AS anho_ingreso_null,
  SUM(CASE WHEN fecha_acto_administrativo IS NULL THEN 1 ELSE 0 END) AS fecha_acto_administrativo_null,
  SUM(CASE WHEN fuente_financiamiento_codigo IS NULL THEN 1 ELSE 0 END) AS fuente_financiamiento_codigo_null,
  SUM(CASE WHEN fuente_financiamiento_descripcion IS NULL THEN 1 ELSE 0 END) AS fuente_financiamiento_descripcion_null,
  SUM(CASE WHEN objeto_gasto_codigo IS NULL THEN 1 ELSE 0 END) AS objeto_gasto_codigo_null,
  SUM(CASE WHEN objeto_gasto_descripcion IS NULL THEN 1 ELSE 0 END) AS objeto_gasto_descripcion_null,
  SUM(CASE WHEN presupuestado_gs IS NULL THEN 1 ELSE 0 END) AS presupuestado_gs_null,
  SUM(CASE WHEN devengado_gs IS NULL THEN 1 ELSE 0 END) AS devengado_gs_null
FROM core.fact_remuneraciones_unpy;

-- 2.2 Conteo dinámico de nulos por columna (consulta genérica)
WITH cols AS (
  SELECT column_name
  FROM information_schema.columns
  WHERE table_schema = 'core' AND table_name = 'fact_remuneraciones_unpy'
)
SELECT
  c.column_name,
  (SELECT COUNT(*) FROM core.fact_remuneraciones_unpy t WHERE (t.*)::jsonb ->> c.column_name IS NULL OR (t.*)::jsonb ->> c.column_name = 'null')::bigint AS null_count
FROM cols c
ORDER BY null_count DESC NULLS LAST;

-- Nota: la versión anterior usa conversión a jsonb para conteo dinámico; puede ser más lenta en tablas grandes.

-- ============================================================
-- 3. DISTRIBUCIONES, RANGOS Y OUTLIERS
-- ============================================================
-- 3.1 Edad: min, max, media, mediana, desviación estándar
SELECT
  MIN(edad) AS edad_min,
  MAX(edad) AS edad_max,
  AVG(edad)::numeric(10,2) AS edad_promedio,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY edad) AS edad_mediana,
  STDDEV_POP(edad)::numeric(10,2) AS edad_stddev
FROM core.fact_remuneraciones_unpy
WHERE edad IS NOT NULL;

-- 3.2 Histograma de edad (buckets de 5 años)
SELECT width_bucket(edad, 0, 100, 20) AS bucket,
       COUNT(*) AS cnt,
       MIN(edad) AS min_edad,
       MAX(edad) AS max_edad
FROM core.fact_remuneraciones_unpy
WHERE edad IS NOT NULL
GROUP BY bucket
ORDER BY bucket;

-- 3.3 Devengado y presupuestado: percentiles y outliers simples
SELECT
  PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY devengado_gs) AS p1_dev,
  PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY devengado_gs) AS p5_dev,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY devengado_gs) AS p25_dev,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY devengado_gs) AS p50_dev,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY devengado_gs) AS p75_dev,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY devengado_gs) AS p95_dev,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY devengado_gs) AS p99_dev
FROM core.fact_remuneraciones_unpy
WHERE devengado_gs IS NOT NULL;

-- 3.4 Registros con valores negativos o inconsistentes
SELECT *
FROM core.fact_remuneraciones_unpy
WHERE (presupuestado_gs IS NOT NULL AND presupuestado_gs < 0)
   OR (devengado_gs IS NOT NULL AND devengado_gs < 0)
   OR (edad IS NOT NULL AND edad < 0)
LIMIT 200;

-- 3.5 Fecha nacimiento y acto administrativo: rangos y nulos
SELECT
  MIN(fecha_nacimiento) AS min_fn,
  MAX(fecha_nacimiento) AS max_fn,
  MIN(fecha_acto_administrativo) AS min_fa,
  MAX(fecha_acto_administrativo) AS max_fa,
  COUNT(*) FILTER (WHERE fecha_nacimiento IS NULL) AS fn_nulls,
  COUNT(*) FILTER (WHERE fecha_acto_administrativo IS NULL) AS fa_nulls
FROM core.fact_remuneraciones_unpy;

-- ============================================================
-- 4. CALIDAD DE FORMATOS Y VALIDACIONES (documento, sexo, booleanos)
-- ============================================================
-- 4.1 Valores distintos y frecuencia de 'sexo'
SELECT sexo, COUNT(*) AS cnt
FROM core.fact_remuneraciones_unpy
GROUP BY sexo
ORDER BY cnt DESC;

-- 4.2 Validar formato de documento (ejemplo: solo dígitos, o alfanumérico)
-- Ajusta la expresión regular según el formato esperado.
SELECT
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE documento ~ '^[0-9]+$') AS solo_digitos,
  COUNT(*) FILTER (WHERE documento ~ '^[A-Za-z0-9]+$') AS alfanumerico,
  COUNT(*) FILTER (WHERE documento IS NULL OR documento = '') AS documento_vacio
FROM core.fact_remuneraciones_unpy;

-- 4.3 Valores booleanos y coherencia con descripción de discapacidad
SELECT
  COUNT(*) FILTER (WHERE es_discapacitado IS TRUE AND (discapacidad_descripcion IS NULL OR discapacidad_descripcion = '')) AS disc_true_sin_descripcion,
  COUNT(*) FILTER (WHERE es_discapacitado IS FALSE AND (discapacidad_descripcion IS NOT NULL AND discapacidad_descripcion <> '')) AS disc_false_con_descripcion,
  COUNT(*) FILTER (WHERE es_discapacitado IS NULL) AS es_discapacitado_null
FROM core.fact_remuneraciones_unpy;

-- 4.4 Estado: valores permitidos y frecuencia
SELECT estado, COUNT(*) AS cnt
FROM core.fact_remuneraciones_unpy
GROUP BY estado
ORDER BY cnt DESC;

-- ============================================================
-- 5. DUPLICADOS Y LLAVES CANDIDATAS
-- ============================================================
-- 5.1 Detección de duplicados por combinación de campos que deberían ser únicos
-- Ajusta la lista de columnas según la clave natural esperada.
SELECT documento, anho, mes, oee_codigo, COUNT(*) AS cnt
FROM core.fact_remuneraciones_unpy
GROUP BY documento, anho, mes, oee_codigo
HAVING COUNT(*) > 1
ORDER BY cnt DESC
LIMIT 200;

-- 5.2 Muestra de duplicados completos (para inspección)
WITH dup AS (
  SELECT documento, anho, mes, oee_codigo, COUNT(*) AS cnt
  FROM core.fact_remuneraciones_unpy
  GROUP BY documento, anho, mes, oee_codigo
  HAVING COUNT(*) > 1
)
SELECT t.*
FROM core.fact_remuneraciones_unpy t
JOIN dup d USING (documento, anho, mes, oee_codigo)
ORDER BY documento, anho, mes
LIMIT 500;

-- ============================================================
-- 6. REPORTES RESUMEN (vistas útiles para EDA)
-- ============================================================
-- 6.1 Crear vista resumen por año-mes con totales y promedio devengado
CREATE OR REPLACE VIEW core.vw_remu_resumen_anho_mes AS
SELECT
  anho, mes,
  COUNT(*) AS registros,
  COUNT(DISTINCT documento) AS trabajadores_unicos,
  SUM(devengado_gs) AS total_devengado_gs,
  SUM(presupuestado_gs) AS total_presupuestado_gs,
  AVG(devengado_gs)::numeric(14,2) AS promedio_devengado_gs
FROM core.fact_remuneraciones_unpy
GROUP BY anho, mes
ORDER BY anho, mes;

-- 6.2 Vista de columnas con porcentaje de nulos (útil para priorizar limpieza)
CREATE OR REPLACE VIEW core.vw_nulls_por_columna AS
SELECT
  column_name,
  null_count,
  total_rows,
  (null_count::numeric / NULLIF(total_rows,0) * 100)::numeric(5,2) AS pct_null
FROM (
  SELECT
    c.column_name,
    (SELECT COUNT(*) FROM core.fact_remuneraciones_unpy t WHERE (t.*)::jsonb ->> c.column_name IS NULL OR (t.*)::jsonb ->> c.column_name = 'null')::bigint AS null_count,
    (SELECT COUNT(*) FROM core.fact_remuneraciones_unpy)::bigint AS total_rows
  FROM information_schema.columns c
  WHERE c.table_schema = 'core' AND c.table_name = 'fact_remuneraciones_unpy'
) s
ORDER BY pct_null DESC;

-- ============================================================
-- 7. PASOS Y SCRIPTS PARA IMPONER NOT NULL (seguro y reversible)
-- ============================================================
-- 7.1 Paso A: identificar columnas candidatas a NOT NULL (ejemplo)
-- Recomendación: elegir columnas con pct_null = 0 o muy bajas y con significado obligatorio.
SELECT column_name, null_count, total_rows, (null_count::numeric/NULLIF(total_rows,0))*100 AS pct_null
FROM core.vw_nulls_por_columna
ORDER BY pct_null;

-- 7.2 Paso B: crear tabla temporal con filas que tienen nulos en columnas críticas
-- Ejemplo: columnas críticas: anho, mes, documento, oee_codigo, devengado_gs
CREATE TEMP TABLE tmp_nulls_criticos AS
SELECT *
FROM core.fact_remuneraciones_unpy
WHERE anho IS NULL OR mes IS NULL OR documento IS NULL OR oee_codigo IS NULL OR devengado_gs IS NULL;

-- Revisa los datos problemáticos:
SELECT COUNT(*) AS filas_problematicas FROM tmp_nulls_criticos;
SELECT * FROM tmp_nulls_criticos LIMIT 200;

-- 7.3 Paso C: limpieza (ejemplos de acciones)
--  - Rellenar valores por defecto cuando aplique
--  - Corregir formatos de documento
--  - Eliminar duplicados exactos si corresponde
-- Ejemplo: normalizar documento (quitar espacios y guiones)
UPDATE core.fact_remuneraciones_unpy
SET documento = regexp_replace(documento, '[^A-Za-z0-9]', '', 'g')
WHERE documento IS NOT NULL
  AND documento ~ '[^A-Za-z0-9]';

-- Ejemplo: rellenar grupo_etario a partir de edad si está vacío
UPDATE core.fact_remuneraciones_unpy
SET grupo_etario =
  CASE
    WHEN edad IS NULL THEN grupo_etario
    WHEN edad < 18 THEN '0-17'
    WHEN edad BETWEEN 18 AND 29 THEN '18-29'
    WHEN edad BETWEEN 30 AND 44 THEN '30-44'
    WHEN edad BETWEEN 45 AND 64 THEN '45-64'
    ELSE '65+'
  END
WHERE grupo_etario IS NULL AND edad IS NOT NULL;

-- 7.4 Paso D: verificar que no quedan nulos antes de imponer NOT NULL
-- Ejemplo para columna 'documento'
SELECT COUNT(*) AS documento_nulls
FROM core.fact_remuneraciones_unpy
WHERE documento IS NULL OR documento = '';

-- Si el resultado es 0, se puede imponer NOT NULL. Repite para cada columna.

-- 7.5 Paso E: imponer NOT NULL (ejemplo para varias columnas)
-- IMPORTANTE: ejecutar solo después de confirmar que no existen nulos.
ALTER TABLE core.fact_remuneraciones_unpy
  ALTER COLUMN anho SET NOT NULL,
  ALTER COLUMN mes SET NOT NULL,
  ALTER COLUMN documento SET NOT NULL,
  ALTER COLUMN oee_codigo SET NOT NULL,
  ALTER COLUMN devengado_gs SET NOT NULL;

-- Si necesitas establecer un valor por defecto antes de SET NOT NULL:
-- ALTER TABLE ... ALTER COLUMN col SET DEFAULT <valor>;
-- UPDATE ... SET col = <valor> WHERE col IS NULL;
-- ALTER TABLE ... ALTER COLUMN col SET NOT NULL;

-- 7.6 Paso F: crear índices para acelerar EDA y consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_remu_anho_mes ON core.fact_remuneraciones_unpy (anho, mes);
CREATE INDEX IF NOT EXISTS idx_remu_documento ON core.fact_remuneraciones_unpy (documento);
CREATE INDEX IF NOT EXISTS idx_remu_oee ON core.fact_remuneraciones_unpy (oee_codigo);

-- ============================================================
-- 8. CONSULTAS ADICIONALES ÚTILES
-- ============================================================
-- 8.1 Top 20 OEE por monto devengado
SELECT oee_codigo, SUM(devengado_gs) AS total_devengado
FROM core.fact_remuneraciones_unpy
GROUP BY oee_codigo
ORDER BY total_devengado DESC
LIMIT 20;

-- 8.2 Trabajadores con mayor devengado en un periodo (ejemplo anho=2024, mes=3)
SELECT documento, nombres, apellidos, oee_codigo, devengado_gs
FROM core.fact_remuneraciones_unpy
WHERE anho = 2024 AND mes = 3
ORDER BY devengado_gs DESC
LIMIT 50;

-- 8.3 Comparación presupuestado vs devengado (porcentaje)
SELECT anho, mes,
  SUM(presupuestado_gs) AS total_presupuestado,
  SUM(devengado_gs) AS total_devengado,
  CASE WHEN SUM(presupuestado_gs) = 0 THEN NULL
       ELSE (SUM(devengado_gs)::numeric / SUM(presupuestado_gs)::numeric * 100)::numeric(8,2)
  END AS pct_dev_vs_pres
FROM core.fact_remuneraciones_unpy
GROUP BY anho, mes
ORDER BY anho, mes;

-- ============================================================
-- 9. SCRIPTS DE AUDITORÍA (registros problemáticos para revisión manual)
-- ============================================================
-- 9.1 Registros sin documento o con documento inválido
SELECT *
FROM core.fact_remuneraciones_unpy
WHERE documento IS NULL OR documento = ''
   OR documento ~ '[^A-Za-z0-9]'
LIMIT 500;

-- 9.2 Registros con edad incompatible con fecha_nacimiento (edad calculada)
SELECT *,
  DATE_PART('year', AGE(CURRENT_DATE, fecha_nacimiento))::int AS edad_calc
FROM core.fact_remuneraciones_unpy
WHERE fecha_nacimiento IS NOT NULL
  AND edad IS NOT NULL
  AND ABS(edad - (DATE_PART('year', AGE(CURRENT_DATE, fecha_nacimiento))::int)) > 1
LIMIT 200;

-- ============================================================
-- FIN
-- ============================================================
-- Recomendaciones finales:
-- 1) Ejecuta las consultas de diagnóstico primero (secciones 1-6).
-- 2) Revisa manualmente las muestras problemáticas (sección 9).
-- 3) Aplica transformaciones y actualizaciones (sección 7.3).
-- 4) Vuelve a ejecutar los conteos de nulos y validaciones.
-- 5) Impone NOT NULL y crea índices solo cuando estés seguro.
