-- ============================================================
-- 06_data_quality_checks.sql
-- Validaciones de calidad para el modelo analítico
-- ============================================================

-- ============================================================
-- 1) Duplicados de negocio en staging por componente
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_duplicados_funcionario_componente AS
SELECT
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    concepto,
    linea,
    categoria,
    presupuestado_gs,
    devengado_gs,
    COUNT(*) AS cantidad_registros
FROM staging.funcionarios_modelo
GROUP BY
    anho, mes, nivel, entidad, oee, documento,
    objeto_gasto, concepto, linea, categoria,
    presupuestado_gs, devengado_gs
HAVING COUNT(*) > 1;

-- ============================================================
-- 2) Importes negativos, nulos o cero
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_importes_problematicos AS
SELECT
    *
FROM staging.funcionarios_modelo
WHERE devengado_gs IS NULL
   OR presupuestado_gs IS NULL
   OR devengado_gs < 0
   OR presupuestado_gs < 0;

CREATE OR REPLACE VIEW dq.vw_importes_cero AS
SELECT
    *
FROM staging.funcionarios_modelo
WHERE COALESCE(devengado_gs, 0) = 0
  AND COALESCE(presupuestado_gs, 0) = 0;

-- ============================================================
-- 3) Fechas inválidas o sospechosas
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_fechas_invalidas AS
SELECT
    *
FROM staging.funcionarios_modelo
WHERE (fecha_nacimiento_raw IS NOT NULL AND fecha_nacimiento IS NULL)
   OR (fecha_acto_raw IS NOT NULL AND fecha_acto IS NULL)
   OR fecha_nacimiento > fecha_periodo
   OR fecha_acto > CURRENT_DATE;

-- ============================================================
-- 4) Funcionarios sin institución/OEE
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_funcionarios_sin_oee AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE nivel IS NULL
   OR entidad IS NULL
   OR oee IS NULL
   OR descripcion_oee IS NULL;

-- ============================================================
-- 5) Funcionarios sin régimen salarial
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_funcionarios_sin_regimen_salarial AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE salario_minimo_mensual_gs IS NULL
   OR fecha_regimen_salarial IS NULL;

-- ============================================================
-- 6) Registros sin cotización USD
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_registros_sin_cotizacion_usd AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE cotizacion_usd_promedio IS NULL
   OR cotizacion_usd_promedio = 0
   OR remuneracion_total_usd IS NULL;

-- ============================================================
-- 7) Diferencias entre total calculado y suma de componentes
--    En este modelo, el total se construye como suma de componentes.
--    La validación detecta inconsistencias de transformación.
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_diferencias_total_componentes AS
SELECT
    *,
    (
        salario_basico_gs
        + viaticos_gs
        + beneficios_gs
        + bonificaciones_gs
        + gastos_representacion_gs
        + aguinaldo_gs
        + otros_componentes_gs
    ) AS total_componentes_recalculado_gs,
    remuneracion_total_gs
      - (
            salario_basico_gs
            + viaticos_gs
            + beneficios_gs
            + bonificaciones_gs
            + gastos_representacion_gs
            + aguinaldo_gs
            + otros_componentes_gs
        ) AS diferencia_total_componentes_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE ABS(
    remuneracion_total_gs
    - (
        salario_basico_gs
        + viaticos_gs
        + beneficios_gs
        + bonificaciones_gs
        + gastos_representacion_gs
        + aguinaldo_gs
        + otros_componentes_gs
    )
) > 1;

-- ============================================================
-- 8) Distribución de nulos por columnas prioritarias de la OBT
-- ============================================================
CREATE OR REPLACE TABLE dq.distribucion_nulos_obt AS
SELECT 'documento' AS columna, COUNT(*) AS total_registros, SUM(CASE WHEN documento IS NULL THEN 1 ELSE 0 END) AS total_nulos FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'descripcion_oee', COUNT(*), SUM(CASE WHEN descripcion_oee IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'tipo_funcionario_inferido', COUNT(*), SUM(CASE WHEN tipo_funcionario_inferido IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'cargo_principal', COUNT(*), SUM(CASE WHEN cargo_principal IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'anho_ingreso', COUNT(*), SUM(CASE WHEN anho_ingreso IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'fecha_nacimiento', COUNT(*), SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'edad', COUNT(*), SUM(CASE WHEN edad IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'remuneracion_total_gs', COUNT(*), SUM(CASE WHEN remuneracion_total_gs IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'remuneracion_total_usd', COUNT(*), SUM(CASE WHEN remuneracion_total_usd IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'salario_minimo_mensual_gs', COUNT(*), SUM(CASE WHEN salario_minimo_mensual_gs IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos;

CREATE OR REPLACE VIEW dq.vw_distribucion_nulos_obt AS
SELECT
    columna,
    total_registros,
    total_nulos,
    ratio_pct(total_nulos, total_registros) AS porcentaje_nulos
FROM dq.distribucion_nulos_obt
ORDER BY porcentaje_nulos DESC;

-- ============================================================
-- 9) Outliers salariales por IQR
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_outliers_salariales_iqr AS
WITH stats AS (
    SELECT
        anho,
        mes,
        QUANTILE_CONT(remuneracion_total_gs, 0.25) AS q1,
        QUANTILE_CONT(remuneracion_total_gs, 0.75) AS q3
    FROM datamart.obt_remuneraciones_funcionarios_publicos
    WHERE remuneracion_total_gs IS NOT NULL
    GROUP BY anho, mes
),
bounds AS (
    SELECT
        *,
        q3 - q1 AS iqr,
        q1 - 1.5 * (q3 - q1) AS limite_inferior,
        q3 + 1.5 * (q3 - q1) AS limite_superior
    FROM stats
)
SELECT
    o.*,
    b.q1,
    b.q3,
    b.iqr,
    b.limite_inferior,
    b.limite_superior,
    CASE
        WHEN o.remuneracion_total_gs < b.limite_inferior THEN 'OUTLIER_BAJO'
        WHEN o.remuneracion_total_gs > b.limite_superior THEN 'OUTLIER_ALTO'
        ELSE 'NO_OUTLIER'
    END AS tipo_outlier
FROM datamart.obt_remuneraciones_funcionarios_publicos o
JOIN bounds b
  ON o.anho = b.anho
 AND o.mes = b.mes
WHERE o.remuneracion_total_gs < b.limite_inferior
   OR o.remuneracion_total_gs > b.limite_superior;

-- ============================================================
-- 10) Resultados consolidados de checks
-- ============================================================
CREATE OR REPLACE TABLE dq.resultados_checks AS
SELECT
    CURRENT_TIMESTAMP AS run_ts,
    'DUPLICADOS_COMPONENTE' AS check_name,
    'ALTA' AS severidad,
    COUNT(*) AS registros_afectados,
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END AS estado,
    'Duplicados por clave de negocio preliminar en staging.funcionarios_modelo' AS descripcion
FROM dq.vw_duplicados_funcionario_componente

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'IMPORTES_NEGATIVOS_O_NULOS',
    'ALTA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Registros con devengado/presupuestado nulo o negativo'
FROM dq.vw_importes_problematicos

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'FECHAS_INVALIDAS',
    'MEDIA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Fechas no parseables o inconsistentes'
FROM dq.vw_fechas_invalidas

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'FUNCIONARIOS_SIN_OEE',
    'ALTA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Registros consolidados sin institución/OEE'
FROM dq.vw_funcionarios_sin_oee

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'FUNCIONARIOS_SIN_REGIMEN_SALARIAL',
    'MEDIA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Registros sin referencia de salario mínimo aplicable'
FROM dq.vw_funcionarios_sin_regimen_salarial

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'REGISTROS_SIN_COTIZACION_USD',
    'MEDIA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Registros sin cotización USD mensual'
FROM dq.vw_registros_sin_cotizacion_usd

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'DIFERENCIA_TOTAL_COMPONENTES',
    'ALTA',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END,
    'Diferencia entre remuneración total y suma de componentes'
FROM dq.vw_diferencias_total_componentes

UNION ALL

SELECT
    CURRENT_TIMESTAMP,
    'OUTLIERS_SALARIALES_IQR',
    'INFORMATIVA',
    COUNT(*),
    'REVISAR',
    'Outliers salariales detectados por regla IQR'
FROM dq.vw_outliers_salariales_iqr;

-- ============================================================
-- 11) Resumen ejecutivo de calidad
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_resumen_calidad AS
SELECT *
FROM dq.resultados_checks
ORDER BY
    CASE severidad
        WHEN 'ALTA' THEN 1
        WHEN 'MEDIA' THEN 2
        WHEN 'BAJA' THEN 3
        ELSE 4
    END,
    registros_afectados DESC;

-- ============================================================
-- 12) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '06_data_quality_checks.sql', 'dq',
       'quality_checks', 'ok', NULL,
       'Checks de calidad generados';
