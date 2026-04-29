-- ============================================================
-- 04_datamart_obt.sql
-- Capa DATAMART: One Big Table para BI
-- ============================================================

-- ============================================================
-- 1) OBT principal
--
-- Grano:
--   una fila por funcionario + OEE + período mensual.
--
-- Uso:
--   Power BI, Metabase, Tableau, DuckDB SQL, exportación a Parquet/CSV.
-- ============================================================
CREATE OR REPLACE TABLE datamart.obt_remuneraciones_funcionarios_publicos AS
SELECT
    -- Identificación temporal
    anho,
    mes,
    fecha_periodo,
    STRFTIME(fecha_periodo, '%Y-%m') AS periodo_yyyy_mm,

    -- Identificación institucional
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    oee_descripcion_corta,
    es_universidad_nacional,

    -- Identificación del funcionario
    documento,
    nombres,
    apellidos,
    nombres || ' ' || apellidos AS funcionario_nombre_completo,

    -- Perfil básico
    sexo,
    discapacidad,
    tipo_discapacidad,
    estado,
    tipo_vinculo_inferido,
    tipo_funcionario_inferido,
    anho_ingreso,
    antiguedad_anhos,
    rango_antiguedad,
    fecha_nacimiento,
    edad,
    rango_etario,
    anho_nacimiento,
    generacion,
    fecha_acto,

    -- Contexto laboral
    funcion_principal,
    cargo_principal,
    carga_horaria_principal,
    profesion_principal,

    -- Métricas de grano y composición
    cantidad_componentes,
    cantidad_objetos_gasto,
    cantidad_conceptos,

    -- Métricas monetarias en Gs.
    remuneracion_presupuestada_total_gs,
    remuneracion_devengada_total_gs,
    remuneracion_total_gs,
    salario_basico_gs,
    viaticos_gs,
    beneficios_gs,
    bonificaciones_gs,
    gastos_representacion_gs,
    aguinaldo_gs,
    otros_componentes_gs,

    -- Métricas en USD
    cotizacion_usd_promedio,
    remuneracion_total_usd,
    salario_basico_usd,
    viaticos_usd,
    beneficios_usd,
    bonificaciones_usd,

    -- Régimen salarial
    fecha_regimen_salarial,
    salario_minimo_mensual_gs,
    salario_neto_referencia_gs,
    remuneracion_en_salarios_minimos,
    rango_salarios_minimos,

    -- Participaciones porcentuales
    participacion_salario_basico_pct,
    participacion_viaticos_pct,
    participacion_beneficios_pct,
    participacion_bonificaciones_pct,
    participacion_gastos_representacion_pct,
    participacion_aguinaldo_pct,
    participacion_otros_componentes_pct,

    -- Estadísticas institucionales
    promedio_institucional_gs,
    mediana_institucional_gs,
    p25_institucional_gs,
    p75_institucional_gs,
    total_institucional_gs,
    promedio_tipo_funcionario_gs,

    -- Brechas y concentración
    brecha_promedio_institucional_gs,
    brecha_promedio_institucional_pct,
    brecha_mediana_institucional_gs,
    brecha_mediana_institucional_pct,
    indicador_remuneracion_alta_media_baja,
    participacion_en_total_institucional_pct,
    indicador_posible_concentracion_salarial,

    -- Percentiles y rankings
    percentil_salarial_global,
    percentil_salarial_institucional,
    ranking_salarial_institucion,
    ranking_salarial_institucion_cargo,
    ranking_salarial_institucion_tipo_funcionario,
    es_top_10_pct_institucional,
    es_top_1_pct_global,

    -- Ratios requeridos explícitamente
    participacion_salario_basico_pct AS ratio_salario_basico_sobre_remuneracion_total_pct,
    participacion_bonificaciones_pct AS ratio_bonificaciones_sobre_remuneracion_total_pct,
    participacion_viaticos_pct AS ratio_viaticos_sobre_remuneracion_total_pct,

    -- Trazabilidad
    hash_funcionario_mes,
    fecha_carga_core,
    CURRENT_TIMESTAMP AS fecha_carga_datamart
FROM core.remuneraciones_funcionario_mes;

-- ============================================================
-- 2) Vista enfocada en Universidades Nacionales
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_obt_remuneraciones_universidades_nacionales AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE es_universidad_nacional = TRUE;

-- ============================================================
-- 3) Exportaciones opcionales
--
-- Descomentar si se desea generar archivos desde DuckDB.
-- ============================================================
-- COPY datamart.obt_remuneraciones_funcionarios_publicos
-- TO './exports/obt_remuneraciones_funcionarios_publicos.parquet'
-- (FORMAT PARQUET, COMPRESSION ZSTD);
--
-- COPY datamart.obt_remuneraciones_funcionarios_publicos
-- TO './exports/obt_remuneraciones_funcionarios_publicos.csv'
-- (HEADER, DELIMITER ',');

-- ============================================================
-- 4) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '04_datamart_obt.sql', 'datamart',
       'obt_remuneraciones_funcionarios_publicos', 'ok',
       (SELECT COUNT(*) FROM datamart.obt_remuneraciones_funcionarios_publicos),
       'OBT final generada';
