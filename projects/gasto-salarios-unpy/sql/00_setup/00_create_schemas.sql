-- ============================================================
-- 00_create_schemas.sql
-- Proyecto: Modelo analítico OBT de remuneraciones públicas
-- Motor: DuckDB
-- Autor: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   1) Crear las capas lógicas del pipeline: raw, staging, core, datamart y dq.
--   2) Crear macros reutilizables para limpieza defensiva de texto, números y fechas.
--
-- Nota:
--   Ejecutar primero sobre la base DuckDB del proyecto.
--   Ejemplo:
--     duckdb remuneraciones.duckdb < sql/00_create_schemas.sql
-- ============================================================

-- ============================================================
-- 1) Esquemas por capas
-- ============================================================
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS datamart;
CREATE SCHEMA IF NOT EXISTS dq;
CREATE SCHEMA IF NOT EXISTS audit;

-- ============================================================
-- 2) Tabla de auditoría de ejecución
-- ============================================================
CREATE TABLE IF NOT EXISTS audit.etl_run_log (
    run_ts          TIMESTAMP,
    script_name     VARCHAR,
    layer_name      VARCHAR,
    object_name     VARCHAR,
    status          VARCHAR,
    rows_affected   BIGINT,
    notes           VARCHAR
);

-- ============================================================
-- 3) Macros utilitarias
-- ============================================================

-- Normaliza texto para comparación y análisis:
-- - convierte a VARCHAR;
-- - reemplaza saltos/espacios múltiples por un espacio;
-- - aplica TRIM;
-- - convierte a mayúsculas;
-- - remueve tildes frecuentes.
CREATE OR REPLACE MACRO normalizar_texto(x) AS (
    NULLIF(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
            UPPER(TRIM(REGEXP_REPLACE(CAST(COALESCE(x, '') AS VARCHAR), '[[:space:]]+', ' ', 'g'))),
            'Á', 'A'),
            'É', 'E'),
            'Í', 'I'),
            'Ó', 'O'),
            'Ú', 'U'),
            'Ñ', 'N'
        ),
        ''
    )
);

-- Convierte campos monetarios paraguayos a DECIMAL.
-- Funciona para enteros como 1234567 y para textos con separador de miles '.'.
-- Si existiera coma decimal, la transforma a punto.
CREATE OR REPLACE MACRO to_decimal_py(x) AS (
    TRY_CAST(
        NULLIF(
            REGEXP_REPLACE(
                REPLACE(REPLACE(TRIM(CAST(COALESCE(x, '') AS VARCHAR)), '.', ''), ',', '.'),
                '[^0-9.-]',
                '',
                'g'
            ),
            ''
        ) AS DECIMAL(18, 2)
    )
);

-- Convierte a INTEGER usando limpieza numérica defensiva.
CREATE OR REPLACE MACRO to_integer_py(x) AS (
    TRY_CAST(to_decimal_py(x) AS INTEGER)
);

-- Parsea fechas frecuentes de la fuente SFP.
-- La fuente suele traer valores como: 1982/06/09 00:00:00.000
CREATE OR REPLACE MACRO to_date_sfp(x) AS (
    COALESCE(
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y/%m/%d %H:%M:%S.%f') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y/%m/%d %H:%M:%S') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y/%m/%d') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y-%m-%d %H:%M:%S.%f') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y-%m-%d %H:%M:%S') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y-%m-%d') AS DATE)
    )
);

-- Parsea timestamps frecuentes de la fuente SFP.
CREATE OR REPLACE MACRO to_timestamp_sfp(x) AS (
    COALESCE(
        TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y/%m/%d %H:%M:%S.%f'),
        TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y/%m/%d %H:%M:%S'),
        TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y-%m-%d %H:%M:%S.%f'),
        TRY_STRPTIME(NULLIF(TRIM(CAST(x AS VARCHAR)), ''), '%Y-%m-%d %H:%M:%S')
    )
);

-- Porcentaje defensivo.
CREATE OR REPLACE MACRO ratio_pct(numerador, denominador) AS (
    CASE
        WHEN denominador IS NULL OR denominador = 0 THEN NULL
        ELSE ROUND((numerador / denominador) * 100, 4)
    END
);

-- ============================================================
-- 4) Registro de auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '00_create_schemas.sql',
    'bootstrap',
    'schemas_macros',
    'ok',
    NULL,
    'Esquemas y macros creados o reemplazados correctamente';
