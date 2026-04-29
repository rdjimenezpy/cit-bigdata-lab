-- ============================================================
-- 05_datamart_agregados.sql
-- Capa DATAMART: vistas agregadas para BI
-- ============================================================

-- ============================================================
-- 1) Remuneración por universidad / OEE
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_universidad_oee AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT documento) AS total_funcionarios,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    SUM(remuneracion_total_usd) AS remuneracion_total_usd,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    MIN(remuneracion_total_gs) AS remuneracion_minima_gs,
    MAX(remuneracion_total_gs) AS remuneracion_maxima_gs,
    SUM(salario_basico_gs) AS salario_basico_total_gs,
    SUM(viaticos_gs) AS viaticos_total_gs,
    SUM(beneficios_gs) AS beneficios_total_gs,
    SUM(bonificaciones_gs) AS bonificaciones_total_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE es_universidad_nacional = TRUE
GROUP BY
    anho, mes, periodo_yyyy_mm,
    nivel, descripcion_nivel,
    entidad, descripcion_entidad,
    oee, descripcion_oee;

-- ============================================================
-- 2) Remuneración por tipo de funcionario
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_tipo_funcionario AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    tipo_funcionario_inferido,
    COUNT(DISTINCT documento) AS total_funcionarios,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs,
    AVG(participacion_salario_basico_pct) AS promedio_participacion_salario_basico_pct,
    AVG(participacion_bonificaciones_pct) AS promedio_participacion_bonificaciones_pct,
    AVG(participacion_viaticos_pct) AS promedio_participacion_viaticos_pct
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    tipo_funcionario_inferido;

-- ============================================================
-- 3) Remuneración por cargo
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_cargo AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    cargo_principal,
    tipo_funcionario_inferido,
    COUNT(DISTINCT documento) AS total_funcionarios,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    MIN(remuneracion_total_gs) AS remuneracion_minima_gs,
    MAX(remuneracion_total_gs) AS remuneracion_maxima_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    cargo_principal,
    tipo_funcionario_inferido;

-- ============================================================
-- 4) Remuneración por generación
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_generacion AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    generacion,
    COUNT(DISTINCT documento) AS total_funcionarios,
    AVG(edad) AS edad_promedio,
    AVG(antiguedad_anhos) AS antiguedad_promedio,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    generacion;

-- ============================================================
-- 5) Remuneración por rango etario
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_rango_etario AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    rango_etario,
    COUNT(DISTINCT documento) AS total_funcionarios,
    AVG(antiguedad_anhos) AS antiguedad_promedio,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    rango_etario;

-- ============================================================
-- 6) Remuneración por régimen salarial / salarios mínimos
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_regimen_salarial AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    fecha_regimen_salarial,
    salario_minimo_mensual_gs,
    rango_salarios_minimos,
    COUNT(DISTINCT documento) AS total_funcionarios,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_en_salarios_minimos) AS promedio_remuneracion_en_salarios_minimos,
    MEDIAN(remuneracion_en_salarios_minimos) AS mediana_remuneracion_en_salarios_minimos
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    fecha_regimen_salarial,
    salario_minimo_mensual_gs,
    rango_salarios_minimos;

-- ============================================================
-- 7) Distribución de componentes salariales
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_distribucion_componentes_salariales AS
WITH componentes AS (
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'SALARIO_BASICO' AS componente, salario_basico_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'VIATICOS' AS componente, viaticos_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'BENEFICIOS' AS componente, beneficios_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'BONIFICACIONES' AS componente, bonificaciones_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'GASTOS_REPRESENTACION' AS componente, gastos_representacion_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'AGUINALDO' AS componente, aguinaldo_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'OTROS' AS componente, otros_componentes_gs AS monto_gs FROM datamart.obt_remuneraciones_funcionarios_publicos
)
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    componente,
    COUNT(*) AS total_registros_funcionario_mes,
    SUM(monto_gs) AS monto_total_gs,
    AVG(monto_gs) AS monto_promedio_gs,
    MEDIAN(monto_gs) AS monto_mediana_gs
FROM componentes
GROUP BY
    anho, mes, periodo_yyyy_mm,
    es_universidad_nacional,
    componente;

-- ============================================================
-- 8) Top cargos con mayor remuneración promedio
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_top_cargos_mayor_remuneracion AS
WITH agg AS (
    SELECT
        anho,
        mes,
        periodo_yyyy_mm,
        es_universidad_nacional,
        cargo_principal,
        tipo_funcionario_inferido,
        COUNT(DISTINCT documento) AS total_funcionarios,
        SUM(remuneracion_total_gs) AS remuneracion_total_gs,
        AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
        MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
        MAX(remuneracion_total_gs) AS remuneracion_maxima_gs
    FROM datamart.obt_remuneraciones_funcionarios_publicos
    WHERE cargo_principal IS NOT NULL
    GROUP BY
        anho, mes, periodo_yyyy_mm,
        es_universidad_nacional,
        cargo_principal,
        tipo_funcionario_inferido
)
SELECT
    *,
    DENSE_RANK() OVER (
        PARTITION BY anho, mes, es_universidad_nacional
        ORDER BY remuneracion_promedio_gs DESC
    ) AS ranking_cargo_por_promedio
FROM agg
QUALIFY ranking_cargo_por_promedio <= 50;

-- ============================================================
-- 9) Brecha salarial por institución
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_brecha_salarial_por_institucion AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    es_universidad_nacional,
    COUNT(DISTINCT documento) AS total_funcionarios,
    AVG(remuneracion_total_gs) AS promedio_gs,
    MEDIAN(remuneracion_total_gs) AS mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.10) AS p10_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS p90_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) - QUANTILE_CONT(remuneracion_total_gs, 0.10) AS brecha_p90_p10_gs,
    CASE
        WHEN QUANTILE_CONT(remuneracion_total_gs, 0.10) = 0 THEN NULL
        ELSE ROUND(QUANTILE_CONT(remuneracion_total_gs, 0.90) / QUANTILE_CONT(remuneracion_total_gs, 0.10), 4)
    END AS ratio_p90_p10,
    SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END) AS masa_salarial_top_10_pct_gs,
    ratio_pct(
        SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END),
        SUM(remuneracion_total_gs)
    ) AS participacion_top_10_pct_en_masa_salarial_pct
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho, mes, periodo_yyyy_mm,
    nivel, descripcion_nivel,
    entidad, descripcion_entidad,
    oee, descripcion_oee,
    es_universidad_nacional;

-- ============================================================
-- 10) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '05_datamart_agregados.sql', 'datamart',
       'views_agregadas', 'ok', NULL,
       'Vistas agregadas de datamart creadas o reemplazadas';
