-- ============================================================
-- 01_raw_ingesta.sql
-- Capa RAW: lectura directa de CSV en DuckDB
--
-- Supuesto de estructura de carpetas:
--   ./data/funcionarios_2025_3_utf8_sample10k.csv
--   ./data/funcionarios_2025_3_utf8_sample10k_modelo.csv
--   ./data/clasificador_gastos_utf8.csv
--   ./data/clasificador_oee_utf8.csv
--   ./data/cotizacion_usd_mensual.csv
--   ./data/regimen_salarial_py.csv
--
-- Importante:
--   La capa raw conserva los datos prácticamente como vienen del archivo.
--   Se fuerza all_varchar=true para evitar pérdida o conversión prematura.
-- ============================================================

-- ============================================================
-- 0) Exploración recomendada antes de materializar
-- ============================================================
-- Ejecutar manualmente si se desea revisar la inferencia de DuckDB:
--
-- DESCRIBE SELECT * FROM read_csv_auto('./data/funcionarios_2025_3_utf8_sample10k.csv', header=true, sample_size=-1);
-- DESCRIBE SELECT * FROM read_csv_auto('./data/funcionarios_2025_3_utf8_sample10k_modelo.csv', header=true, sample_size=-1);
-- DESCRIBE SELECT * FROM read_csv_auto('./data/clasificador_gastos_utf8.csv', header=true, sample_size=-1);
-- DESCRIBE SELECT * FROM read_csv_auto('./data/regimen_salarial_py.csv', header=true, sample_size=-1);
--
-- SELECT * FROM read_csv_auto('./data/funcionarios_2025_3_utf8_sample10k_modelo.csv', header=true, all_varchar=true) LIMIT 10;
-- SUMMARIZE SELECT * FROM read_csv_auto('./data/funcionarios_2025_3_utf8_sample10k_modelo.csv', header=true, all_varchar=true, sample_size=-1);

-- ============================================================
-- 1) Fuente principal completa: funcionarios origen
-- ============================================================
CREATE OR REPLACE TABLE raw.funcionarios_origen_src AS
SELECT *
FROM read_csv_auto(
    './data/funcionarios_2025_3_utf8_sample10k.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- ============================================================
-- 2) Fuente principal depurada para modelado
-- ============================================================
CREATE OR REPLACE TABLE raw.funcionarios_modelo_src AS
SELECT *
FROM read_csv_auto(
    './data/funcionarios_2025_3_utf8_sample10k_modelo.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- ============================================================
-- 3) Clasificador de gastos públicos
-- ============================================================
CREATE OR REPLACE TABLE raw.clasificador_gastos_src AS
SELECT *
FROM read_csv_auto(
    './data/clasificador_gastos_utf8.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- ============================================================
-- 4) Clasificador OEE
--
-- Observación técnica:
--   El archivo observado viene con cada línea completa entre comillas.
--   Por eso se carga como una sola columna raw llamada linea_raw.
--   La separación de campos se realiza en staging.
-- ============================================================
CREATE OR REPLACE TABLE raw.clasificador_oee_src AS
SELECT
    REPLACE(linea_raw, CHR(65279), '') AS linea_raw
FROM read_csv(
    './data/clasificador_oee_utf8.csv',
    header = false,
    columns = {'linea_raw': 'VARCHAR'},
    quote = '"',
    escape = '"',
    ignore_errors = false
);

-- ============================================================
-- 5) Cotización mensual USD
--
-- Supuesto de columnas esperadas:
--   anho, mes, cotizacion_usd
--
-- Si el archivo real trae otros nombres, ajustar la normalización en
-- 02_staging_limpieza.sql, sección staging.cotizacion_usd_mensual.
-- ============================================================
CREATE OR REPLACE TABLE raw.cotizacion_usd_mensual_src AS
SELECT *
FROM read_csv_auto(
    './data/cotizacion_usd_mensual.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- ============================================================
-- 6) Régimen salarial de Paraguay
-- ============================================================
CREATE OR REPLACE TABLE raw.regimen_salarial_py_src AS
SELECT *
FROM read_csv_auto(
    './data/regimen_salarial_py.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- ============================================================
-- 7) Validaciones básicas RAW: cantidad de registros
-- ============================================================
CREATE OR REPLACE TABLE raw.validacion_raw_cantidad_registros AS
SELECT 'raw.funcionarios_origen_src' AS tabla, COUNT(*) AS total_registros FROM raw.funcionarios_origen_src
UNION ALL
SELECT 'raw.funcionarios_modelo_src' AS tabla, COUNT(*) AS total_registros FROM raw.funcionarios_modelo_src
UNION ALL
SELECT 'raw.clasificador_gastos_src' AS tabla, COUNT(*) AS total_registros FROM raw.clasificador_gastos_src
UNION ALL
SELECT 'raw.clasificador_oee_src' AS tabla, COUNT(*) AS total_registros FROM raw.clasificador_oee_src
UNION ALL
SELECT 'raw.cotizacion_usd_mensual_src' AS tabla, COUNT(*) AS total_registros FROM raw.cotizacion_usd_mensual_src
UNION ALL
SELECT 'raw.regimen_salarial_py_src' AS tabla, COUNT(*) AS total_registros FROM raw.regimen_salarial_py_src;

-- ============================================================
-- 8) Validaciones básicas RAW: cantidad de columnas
-- ============================================================
CREATE OR REPLACE TABLE raw.validacion_raw_cantidad_columnas AS
SELECT
    table_schema || '.' || table_name AS tabla,
    COUNT(*) AS total_columnas
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name IN (
      'funcionarios_origen_src',
      'funcionarios_modelo_src',
      'clasificador_gastos_src',
      'clasificador_oee_src',
      'cotizacion_usd_mensual_src',
      'regimen_salarial_py_src'
  )
GROUP BY 1
ORDER BY 1;

-- ============================================================
-- 9) Muestras rápidas para revisión
-- ============================================================
CREATE OR REPLACE VIEW raw.vw_sample_funcionarios_modelo AS
SELECT *
FROM raw.funcionarios_modelo_src
LIMIT 20;

CREATE OR REPLACE VIEW raw.vw_sample_funcionarios_origen AS
SELECT *
FROM raw.funcionarios_origen_src
LIMIT 20;

-- ============================================================
-- 10) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '01_raw_ingesta.sql', 'raw', 'raw_tables', 'ok', NULL,
       'Tablas raw cargadas desde archivos CSV';
