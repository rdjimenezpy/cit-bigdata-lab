-- ============================================================
-- 05_datamart_agregados.sql
-- Proyecto: gasto-salarios-unpy
-- Capa: DATAMART
-- Motor: DuckDB
-- Autor académico: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   Crear vistas agregadas listas para Power BI, Metabase, Tableau
--   o consultas SQL exploratorias.
--
-- Dependencias:
--   Ejecutar antes:
--     sql/04_datamart/04_datamart_obt.sql
--
-- Entradas:
--   datamart.obt_remuneraciones_funcionarios_publicos
--   datamart.det_remuneraciones_componentes_bi
--
-- Nota crítica:
--   No se construyen agregados analíticos reales por cargo/función porque
--   esos campos no existen en la fuente principal. Se crea una vista
--   diagnóstica para evidenciar la no disponibilidad y evitar lecturas
--   incorrectas del modelo.
-- ============================================================

-- ============================================================
-- 1) Resumen ejecutivo mensual
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_resumen_ejecutivo_mensual AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    COUNT(DISTINCT institucion_oee_sk) AS total_instituciones_oee,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    SUM(remuneracion_total_usd) AS remuneracion_total_usd,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    MIN(remuneracion_total_gs) AS remuneracion_minima_gs,
    MAX(remuneracion_total_gs) AS remuneracion_maxima_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.25) AS remuneracion_p25_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.75) AS remuneracion_p75_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.95) AS remuneracion_p95_gs,
    SUM(salario_basico_gs) AS salario_basico_total_gs,
    SUM(honorarios_gs) AS honorarios_total_gs,
    SUM(viaticos_gs) AS viaticos_total_gs,
    SUM(beneficios_gs) AS beneficios_total_gs,
    SUM(bonificaciones_gs) AS bonificaciones_total_gs,
    SUM(gastos_representacion_gs) AS gastos_representacion_total_gs,
    SUM(aguinaldo_gs) AS aguinaldo_total_gs,
    SUM(otros_componentes_gs) AS otros_componentes_total_gs,
    SUM(becas_transferencias_gs) AS becas_transferencias_total_gs,
    ratio_pct(SUM(salario_basico_gs), SUM(remuneracion_total_gs)) AS participacion_salario_basico_pct,
    ratio_pct(SUM(honorarios_gs), SUM(remuneracion_total_gs)) AS participacion_honorarios_pct,
    ratio_pct(SUM(viaticos_gs), SUM(remuneracion_total_gs)) AS participacion_viaticos_pct,
    ratio_pct(SUM(beneficios_gs), SUM(remuneracion_total_gs)) AS participacion_beneficios_pct,
    ratio_pct(SUM(bonificaciones_gs), SUM(remuneracion_total_gs)) AS participacion_bonificaciones_pct,
    ratio_pct(SUM(gastos_representacion_gs), SUM(remuneracion_total_gs)) AS participacion_gastos_representacion_pct,
    ratio_pct(SUM(aguinaldo_gs), SUM(remuneracion_total_gs)) AS participacion_aguinaldo_pct,
    ratio_pct(SUM(otros_componentes_gs), SUM(remuneracion_total_gs)) AS participacion_otros_componentes_pct,
    SUM(CASE WHEN indicador_posible_concentracion_salarial THEN 1 ELSE 0 END) AS total_registros_posible_concentracion,
    SUM(CASE WHEN es_outlier_salarial_iqr THEN 1 ELSE 0 END) AS total_outliers_iqr
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional;

-- ============================================================
-- 2) Remuneración por universidad / OEE
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
    oee_descripcion_corta,
    es_universidad_nacional,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    SUM(remuneracion_total_usd) AS remuneracion_total_usd,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    MIN(remuneracion_total_gs) AS remuneracion_minima_gs,
    MAX(remuneracion_total_gs) AS remuneracion_maxima_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs,
    SUM(salario_basico_gs) AS salario_basico_total_gs,
    SUM(honorarios_gs) AS honorarios_total_gs,
    SUM(viaticos_gs) AS viaticos_total_gs,
    SUM(beneficios_gs) AS beneficios_total_gs,
    SUM(bonificaciones_gs) AS bonificaciones_total_gs,
    SUM(becas_transferencias_gs) AS becas_transferencias_total_gs,
    ratio_pct(SUM(salario_basico_gs), SUM(remuneracion_total_gs)) AS participacion_salario_basico_pct,
    ratio_pct(SUM(bonificaciones_gs), SUM(remuneracion_total_gs)) AS participacion_bonificaciones_pct,
    ratio_pct(SUM(viaticos_gs), SUM(remuneracion_total_gs)) AS participacion_viaticos_pct,
    SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END) AS masa_salarial_top_10_pct_gs,
    ratio_pct(
        SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END),
        SUM(remuneracion_total_gs)
    ) AS participacion_top_10_pct_en_masa_salarial_pct
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    oee_descripcion_corta,
    es_universidad_nacional;

-- ============================================================
-- 3) Remuneración por tipo de funcionario inferido
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_tipo_funcionario AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    tipo_funcionario_inferido,
    tiene_indicio_docente_por_objeto_gasto,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs,
    AVG(participacion_salario_basico_pct) AS promedio_participacion_salario_basico_pct,
    AVG(participacion_bonificaciones_pct) AS promedio_participacion_bonificaciones_pct,
    AVG(participacion_viaticos_pct) AS promedio_participacion_viaticos_pct
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    tipo_funcionario_inferido,
    tiene_indicio_docente_por_objeto_gasto;

-- ============================================================
-- 4) Remuneración por tipo de vínculo inferido / estado
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_tipo_vinculo_estado AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    estado,
    tipo_vinculo_inferido,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    SUM(salario_basico_gs) AS salario_basico_total_gs,
    SUM(honorarios_gs) AS honorarios_total_gs,
    SUM(bonificaciones_gs) AS bonificaciones_total_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    estado,
    tipo_vinculo_inferido;

-- ============================================================
-- 5) Remuneración por sexo
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_sexo AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    sexo,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.25) AS remuneracion_p25_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.75) AS remuneracion_p75_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs,
    AVG(edad) AS edad_promedio,
    AVG(antiguedad_anhos) AS antiguedad_promedio
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional, sexo;

-- ============================================================
-- 6) Remuneración por generación
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_generacion AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    generacion,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    AVG(edad) AS edad_promedio,
    AVG(antiguedad_anhos) AS antiguedad_promedio,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS remuneracion_p90_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional, generacion;

-- ============================================================
-- 7) Remuneración por rango etario
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_rango_etario AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    rango_etario,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    AVG(edad) AS edad_promedio,
    AVG(antiguedad_anhos) AS antiguedad_promedio,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional, rango_etario;

-- ============================================================
-- 8) Remuneración por rango de antigüedad
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_rango_antiguedad AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    rango_antiguedad,
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    AVG(edad) AS edad_promedio,
    AVG(antiguedad_anhos) AS antiguedad_promedio,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_total_gs) AS remuneracion_promedio_gs,
    MEDIAN(remuneracion_total_gs) AS remuneracion_mediana_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional, rango_antiguedad;

-- ============================================================
-- 9) Remuneración por régimen salarial / salarios mínimos
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
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS remuneracion_total_gs,
    AVG(remuneracion_en_salarios_minimos) AS promedio_remuneracion_en_salarios_minimos,
    MEDIAN(remuneracion_en_salarios_minimos) AS mediana_remuneracion_en_salarios_minimos,
    MIN(remuneracion_en_salarios_minimos) AS minimo_remuneracion_en_salarios_minimos,
    MAX(remuneracion_en_salarios_minimos) AS maximo_remuneracion_en_salarios_minimos
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    fecha_regimen_salarial,
    salario_minimo_mensual_gs,
    rango_salarios_minimos;

-- ============================================================
-- 10) Distribución de componentes salariales desde OBT
--
-- Esta vista resume los componentes principales ya pivotados en la OBT.
-- Para análisis por objeto de gasto/concepto, usar la vista 11.
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_distribucion_componentes_salariales AS
WITH componentes AS (
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'SALARIO_BASICO' AS componente_remunerativo, salario_basico_gs AS monto_gs, salario_basico_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'HONORARIOS' AS componente_remunerativo, honorarios_gs AS monto_gs, honorarios_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'VIATICOS' AS componente_remunerativo, viaticos_gs AS monto_gs, viaticos_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'BENEFICIOS' AS componente_remunerativo, beneficios_gs AS monto_gs, beneficios_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'BONIFICACIONES' AS componente_remunerativo, bonificaciones_gs AS monto_gs, bonificaciones_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'GASTOS_REPRESENTACION' AS componente_remunerativo, gastos_representacion_gs AS monto_gs, gastos_representacion_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'AGUINALDO' AS componente_remunerativo, aguinaldo_gs AS monto_gs, aguinaldo_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
    UNION ALL
    SELECT anho, mes, periodo_yyyy_mm, es_universidad_nacional, 'OTROS_COMPONENTES' AS componente_remunerativo, otros_componentes_gs AS monto_gs, otros_componentes_usd AS monto_usd FROM datamart.obt_remuneraciones_funcionarios_publicos
), agrupado AS (
    SELECT
        anho,
        mes,
        periodo_yyyy_mm,
        es_universidad_nacional,
        componente_remunerativo,
        COUNT(*) AS total_registros_funcionario_mes,
        SUM(monto_gs) AS monto_total_gs,
        SUM(monto_usd) AS monto_total_usd,
        AVG(monto_gs) AS monto_promedio_gs,
        MEDIAN(monto_gs) AS monto_mediana_gs
    FROM componentes
    GROUP BY anho, mes, periodo_yyyy_mm, es_universidad_nacional, componente_remunerativo
)
SELECT
    *,
    ratio_pct(
        monto_total_gs,
        SUM(monto_total_gs) OVER (PARTITION BY anho, mes, es_universidad_nacional)
    ) AS participacion_componente_pct
FROM agrupado;

-- ============================================================
-- 11) Distribución por objeto de gasto y concepto remunerativo
--
-- Esta vista usa el detalle de componentes, por tanto es la fuente
-- correcta para explicar concepto_remunerativo derivado del clasificador.
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_remuneracion_por_objeto_gasto_concepto AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    objeto_gasto,
    concepto_remunerativo,
    objeto_gasto_descripcion,
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    grupo_codigo,
    grupo_descripcion,
    subgrupo_codigo,
    subgrupo_descripcion,
    COUNT(*) AS total_registros_componentes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(monto_componente_gs) AS monto_componente_total_gs,
    SUM(monto_componente_usd) AS monto_componente_total_usd,
    SUM(monto_remunerativo_principal_gs) AS monto_remunerativo_principal_total_gs,
    AVG(monto_componente_gs) AS monto_componente_promedio_gs,
    MEDIAN(monto_componente_gs) AS monto_componente_mediana_gs
FROM datamart.det_remuneraciones_componentes_bi
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    es_universidad_nacional,
    objeto_gasto,
    concepto_remunerativo,
    objeto_gasto_descripcion,
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    grupo_codigo,
    grupo_descripcion,
    subgrupo_codigo,
    subgrupo_descripcion;

-- ============================================================
-- 12) Top funcionarios/registros con mayor remuneración por institución
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_top_remuneraciones_por_institucion AS
WITH ranked AS (
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
        funcionario_sk,
        documento_hash,
        documento,
        funcionario_nombre_completo,
        tipo_registro_funcionario,
        tipo_funcionario_inferido,
        tipo_vinculo_inferido,
        sexo,
        edad,
        rango_etario,
        generacion,
        antiguedad_anhos,
        rango_antiguedad,
        remuneracion_total_gs,
        remuneracion_total_usd,
        salario_basico_gs,
        honorarios_gs,
        viaticos_gs,
        beneficios_gs,
        bonificaciones_gs,
        indicador_remuneracion_alta_media_baja,
        percentil_salarial_institucional,
        ranking_salarial_institucion,
        ROW_NUMBER() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
            ORDER BY remuneracion_total_gs DESC NULLS LAST
        ) AS rn_top_institucion
    FROM datamart.obt_remuneraciones_funcionarios_publicos
)
SELECT *
FROM ranked
WHERE rn_top_institucion <= 100;

-- ============================================================
-- 13) Top objetos de gasto con mayor masa remunerativa
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_top_objetos_gasto_mayor_monto AS
WITH agg AS (
    SELECT
        anho,
        mes,
        periodo_yyyy_mm,
        es_universidad_nacional,
        objeto_gasto,
        concepto_remunerativo,
        componente_remunerativo,
        COUNT(*) AS total_registros_componentes,
        COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
        SUM(monto_componente_gs) AS monto_total_gs,
        SUM(monto_componente_usd) AS monto_total_usd,
        AVG(monto_componente_gs) AS monto_promedio_gs
    FROM datamart.det_remuneraciones_componentes_bi
    GROUP BY
        anho,
        mes,
        periodo_yyyy_mm,
        es_universidad_nacional,
        objeto_gasto,
        concepto_remunerativo,
        componente_remunerativo
), ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY anho, mes, es_universidad_nacional
            ORDER BY monto_total_gs DESC NULLS LAST
        ) AS ranking_objeto_gasto_monto
    FROM agg
)
SELECT *
FROM ranked
WHERE ranking_objeto_gasto_monto <= 50;

-- ============================================================
-- 14) Brecha salarial por institución
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
    COUNT(*) AS total_registros_funcionario_mes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(remuneracion_total_gs) AS masa_salarial_total_gs,
    AVG(remuneracion_total_gs) AS promedio_gs,
    MEDIAN(remuneracion_total_gs) AS mediana_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.10) AS p10_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.25) AS p25_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.75) AS p75_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) AS p90_gs,
    QUANTILE_CONT(remuneracion_total_gs, 0.90) - QUANTILE_CONT(remuneracion_total_gs, 0.10) AS brecha_p90_p10_gs,
    CASE
        WHEN QUANTILE_CONT(remuneracion_total_gs, 0.10) IS NULL THEN NULL
        WHEN QUANTILE_CONT(remuneracion_total_gs, 0.10) = 0 THEN NULL
        ELSE ROUND(QUANTILE_CONT(remuneracion_total_gs, 0.90) / QUANTILE_CONT(remuneracion_total_gs, 0.10), 4)
    END AS ratio_p90_p10,
    SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END) AS masa_salarial_top_10_pct_gs,
    ratio_pct(
        SUM(CASE WHEN es_top_10_pct_institucional THEN remuneracion_total_gs ELSE 0 END),
        SUM(remuneracion_total_gs)
    ) AS participacion_top_10_pct_en_masa_salarial_pct,
    SUM(CASE WHEN indicador_posible_concentracion_salarial THEN 1 ELSE 0 END) AS registros_posible_concentracion_salarial,
    SUM(CASE WHEN es_outlier_salarial_iqr THEN 1 ELSE 0 END) AS registros_outlier_iqr
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    anho,
    mes,
    periodo_yyyy_mm,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    es_universidad_nacional;

-- ============================================================
-- 15) Brecha salarial por sexo dentro de institución
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_brecha_salarial_por_sexo_institucion AS
WITH agg AS (
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
        sexo,
        COUNT(*) AS total_registros_funcionario_mes,
        COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
        SUM(remuneracion_total_gs) AS remuneracion_total_gs,
        AVG(remuneracion_total_gs) AS promedio_gs,
        MEDIAN(remuneracion_total_gs) AS mediana_gs
    FROM datamart.obt_remuneraciones_funcionarios_publicos
    GROUP BY
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
        sexo
), ref AS (
    SELECT
        *,
        MAX(CASE WHEN sexo = 'M' THEN promedio_gs END) OVER (PARTITION BY anho, mes, nivel, entidad, oee) AS promedio_masculino_gs,
        MAX(CASE WHEN sexo = 'F' THEN promedio_gs END) OVER (PARTITION BY anho, mes, nivel, entidad, oee) AS promedio_femenino_gs,
        MAX(CASE WHEN sexo = 'M' THEN mediana_gs END) OVER (PARTITION BY anho, mes, nivel, entidad, oee) AS mediana_masculino_gs,
        MAX(CASE WHEN sexo = 'F' THEN mediana_gs END) OVER (PARTITION BY anho, mes, nivel, entidad, oee) AS mediana_femenino_gs
    FROM agg
)
SELECT
    *,
    promedio_masculino_gs - promedio_femenino_gs AS brecha_promedio_menos_f_gs,
    ratio_pct(promedio_masculino_gs - promedio_femenino_gs, promedio_femenino_gs) AS brecha_promedio_menos_f_pct,
    mediana_masculino_gs - mediana_femenino_gs AS brecha_mediana_menos_f_gs,
    ratio_pct(mediana_masculino_gs - mediana_femenino_gs, mediana_femenino_gs) AS brecha_mediana_menos_f_pct
FROM ref;

-- ============================================================
-- 16) Vista diagnóstica de cargo/función no disponible
--
-- No debe usarse como análisis real de cargos. Su objetivo es dejar
-- evidencia técnica de que la fuente principal no contiene esos campos.
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_diagnostico_cargo_funcion_no_disponible AS
SELECT
    anho,
    mes,
    periodo_yyyy_mm,
    COUNT(*) AS total_registros_obt,
    SUM(CASE WHEN cargo_no_disponible_en_fuente THEN 1 ELSE 0 END) AS registros_sin_cargo,
    SUM(CASE WHEN funcion_no_disponible_en_fuente THEN 1 ELSE 0 END) AS registros_sin_funcion,
    ratio_pct(SUM(CASE WHEN cargo_no_disponible_en_fuente THEN 1 ELSE 0 END), COUNT(*)) AS pct_sin_cargo,
    ratio_pct(SUM(CASE WHEN funcion_no_disponible_en_fuente THEN 1 ELSE 0 END), COUNT(*)) AS pct_sin_funcion,
    'cargo y funcion no existen en raw.funcionarios_modelo_src; incorporar fuente confiable si se requiere esta dimension' AS nota_tecnica
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY anho, mes, periodo_yyyy_mm;

-- ============================================================
-- 17) Catálogo simple de vistas DATAMART
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_catalogo_vistas_bi AS
SELECT *
FROM (
    VALUES
        ('vw_resumen_ejecutivo_mensual', 'Resumen mensual de masa salarial, promedios, percentiles y composición.'),
        ('vw_remuneracion_por_universidad_oee', 'Agregado por universidad/OEE.'),
        ('vw_remuneracion_por_tipo_funcionario', 'Agregado por tipo de funcionario inferido. No equivale a cargo.'),
        ('vw_remuneracion_por_tipo_vinculo_estado', 'Agregado por estado y vínculo inferido.'),
        ('vw_remuneracion_por_sexo', 'Agregado por sexo declarado en la fuente.'),
        ('vw_remuneracion_por_generacion', 'Agregado por generación calculada desde fecha de nacimiento.'),
        ('vw_remuneracion_por_rango_etario', 'Agregado por rango etario.'),
        ('vw_remuneracion_por_rango_antiguedad', 'Agregado por rango de antigüedad calculado desde año de ingreso.'),
        ('vw_remuneracion_por_regimen_salarial', 'Agregado contra salario mínimo mensual de referencia.'),
        ('vw_distribucion_componentes_salariales', 'Distribución de componentes pivotados desde la OBT.'),
        ('vw_remuneracion_por_objeto_gasto_concepto', 'Distribución por objeto de gasto y concepto derivado desde clasificador_gastos.'),
        ('vw_top_remuneraciones_por_institucion', 'Top 100 remuneraciones por institución y mes.'),
        ('vw_top_objetos_gasto_mayor_monto', 'Top 50 objetos de gasto por masa remunerativa.'),
        ('vw_brecha_salarial_por_institucion', 'Brecha P90/P10, top 10% y outliers por institución.'),
        ('vw_brecha_salarial_por_sexo_institucion', 'Brecha salarial descriptiva por sexo dentro de institución.'),
        ('vw_diagnostico_cargo_funcion_no_disponible', 'Diagnóstico de no disponibilidad de cargo/función en fuente principal.')
) AS t(nombre_vista, descripcion);

-- ============================================================
-- 18) Auditoría de ejecución
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '05_datamart_agregados.sql',
    'datamart',
    'vistas_agregadas_bi',
    'ok',
    (SELECT COUNT(*) FROM datamart.vw_catalogo_vistas_bi),
    'Vistas agregadas BI creadas. Cargo/funcion se exponen solo como diagnostico de no disponibilidad';
