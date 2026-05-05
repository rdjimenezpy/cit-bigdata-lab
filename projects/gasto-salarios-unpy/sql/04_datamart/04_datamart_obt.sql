-- ============================================================
-- 04_datamart_obt.sql
-- Proyecto: gasto-salarios-unpy
-- Capa: DATAMART
-- Motor: DuckDB
-- Autor académico: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   1) Construir la One Big Table (OBT) final para consumo BI.
--   2) Exponer una tabla de detalle complementaria por componente
--      remunerativo para análisis de composición salarial.
--   3) Crear vistas de control mínimo del datamart.
--
-- Dependencias:
--   Ejecutar antes:
--     sql/00_setup/00_create_schemas.sql
--     sql/01_raw/01_raw_ingesta.sql
--     sql/02_staging/02_staging_limpieza.sql
--     sql/03_core/03_core_modelo.sql
--
-- Entradas CORE:
--   core.remuneraciones_funcionario_mes
--   core.fact_remuneraciones_componentes
--
-- Salidas DATAMART:
--   datamart.obt_remuneraciones_funcionarios_publicos
--   datamart.det_remuneraciones_componentes_bi
--   datamart.vw_obt_remuneraciones_universidades_nacionales
--   datamart.vw_det_componentes_universidades_nacionales
--   datamart.vw_control_datamart_obt
--   datamart.vw_control_datamart_componentes
--
-- Grano de la OBT:
--   una fila por anho + mes + nivel + entidad + oee + documento.
--
-- Aclaraciones críticas:
--   - La fuente principal raw.funcionarios_modelo_src no contiene cargo,
--     funcion, linea, categoria ni concepto como columna original.
--   - concepto_remunerativo fue derivado previamente desde
--     raw.clasificador_gastos_src.objeto_gasto_descripcion mediante
--     objeto_gasto.
--   - cargo_principal y funcion_principal se conservan como NULL técnico
--     para compatibilidad, pero no deben usarse como dimensiones reales
--     hasta incorporar una fuente confiable.
--   - tipo_funcionario_inferido NO equivale a cargo laboral. Solo expresa
--     si existe indicio docente por objeto de gasto/concepto.
-- ============================================================

-- ============================================================
-- 1) OBT principal para BI
-- ============================================================
CREATE OR REPLACE TABLE datamart.obt_remuneraciones_funcionarios_publicos AS
WITH base AS (
    SELECT *
    FROM core.remuneraciones_funcionario_mes
), obt AS (
    SELECT
        -- ----------------------------------------------------
        -- Claves técnicas de análisis
        -- ----------------------------------------------------
        hash_funcionario_mes AS obt_registro_id,
        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '')
        ) AS periodo_sk,
        md5(
            COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
            COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
            COALESCE(CAST(oee AS VARCHAR), '')
        ) AS institucion_oee_sk,
        COALESCE(documento_hash, md5(COALESCE(CAST(documento AS VARCHAR), ''))) AS funcionario_sk,

        -- ----------------------------------------------------
        -- Dimensión temporal
        -- ----------------------------------------------------
        anho,
        mes,
        fecha_periodo,
        periodo_yyyy_mm,
        periodo_id,
        mes_nombre,
        trimestre,
        semestre,

        -- ----------------------------------------------------
        -- Dimensión institucional/OEE
        -- ----------------------------------------------------
        nivel,
        descripcion_nivel,
        entidad,
        descripcion_entidad,
        oee,
        descripcion_oee,
        oee_descripcion_corta,
        uri_oee,
        es_universidad_nacional,
        CAST(nivel AS VARCHAR) || '-' || CAST(entidad AS VARCHAR) || '-' || CAST(oee AS VARCHAR) AS codigo_nivel_entidad_oee,
        descripcion_entidad || ' / ' || descripcion_oee AS institucion_oee_descripcion_larga,

        -- ----------------------------------------------------
        -- Identificación del funcionario o registro administrativo
        -- ----------------------------------------------------
        documento,
        documento_hash,
        nombres,
        apellidos,
        TRIM(COALESCE(nombres, '') || ' ' || COALESCE(apellidos, '')) AS funcionario_nombre_completo,
        tipo_registro_funcionario,
        es_vacancia,
        es_registro_anonimo,

        -- ----------------------------------------------------
        -- Perfil demográfico y administrativo
        -- ----------------------------------------------------
        estado,
        tipo_vinculo_inferido,
        tipo_funcionario_inferido,
        tiene_indicio_docente_por_objeto_gasto,
        sexo,
        discapacidad,
        tipo_discapacidad,
        anho_ingreso,
        antiguedad_anhos,
        rango_antiguedad,
        fecha_nacimiento,
        anho_nacimiento,
        edad,
        rango_etario,
        generacion,
        fecha_acto,

        -- ----------------------------------------------------
        -- Campos laborales no disponibles en la fuente actual
        -- ----------------------------------------------------
        cargo_principal,
        funcion_principal,
        carga_horaria_principal,
        profesion_principal,
        CASE WHEN cargo_principal IS NULL THEN TRUE ELSE FALSE END AS cargo_no_disponible_en_fuente,
        CASE WHEN funcion_principal IS NULL THEN TRUE ELSE FALSE END AS funcion_no_disponible_en_fuente,

        -- ----------------------------------------------------
        -- Trazabilidad presupuestaria por lista de objetos/conceptos
        -- ----------------------------------------------------
        objetos_gasto_lista,
        conceptos_remunerativos_lista,
        componentes_remunerativos_lista,
        cantidad_componentes,
        cantidad_objetos_gasto,
        cantidad_conceptos,

        -- ----------------------------------------------------
        -- Métricas monetarias en guaraníes
        -- ----------------------------------------------------
        remuneracion_presupuestada_total_gs,
        remuneracion_devengada_total_gs,
        total_presupuestado_gs,
        total_devengado_gs,
        diferencia_presupuestado_devengado_gs,
        remuneracion_total_gs,
        salario_basico_gs,
        honorarios_gs,
        viaticos_gs,
        beneficios_gs,
        bonificaciones_gs,
        gastos_representacion_gs,
        aguinaldo_gs,
        otros_componentes_puros_gs,
        sin_clasificar_gs,
        otros_componentes_gs,
        becas_transferencias_gs,

        -- ----------------------------------------------------
        -- Métricas monetarias en USD
        -- ----------------------------------------------------
        cotizacion_usd_promedio,
        remuneracion_total_usd,
        total_devengado_usd,
        salario_basico_usd,
        honorarios_usd,
        viaticos_usd,
        beneficios_usd,
        bonificaciones_usd,
        gastos_representacion_usd,
        aguinaldo_usd,
        otros_componentes_usd,
        becas_transferencias_usd,

        -- ----------------------------------------------------
        -- Régimen salarial de referencia
        -- ----------------------------------------------------
        fecha_regimen_salarial,
        salario_minimo_mensual_gs,
        salario_por_dia_gs,
        jornal_por_dia_gs,
        salario_por_hora_gs,
        salario_neto_referencia_gs,
        remuneracion_en_salarios_minimos,
        rango_salarios_minimos,

        -- ----------------------------------------------------
        -- Participación porcentual de componentes
        -- ----------------------------------------------------
        participacion_salario_basico_pct,
        participacion_honorarios_pct,
        participacion_viaticos_pct,
        participacion_beneficios_pct,
        participacion_bonificaciones_pct,
        participacion_gastos_representacion_pct,
        participacion_aguinaldo_pct,
        participacion_otros_componentes_pct,
        ratio_salario_basico_sobre_remuneracion_total_pct,
        ratio_bonificaciones_sobre_remuneracion_total_pct,
        ratio_viaticos_sobre_remuneracion_total_pct,

        -- ----------------------------------------------------
        -- Estadística institucional ya calculada en CORE
        -- ----------------------------------------------------
        promedio_institucional_gs,
        mediana_institucional_gs,
        p25_institucional_gs,
        p75_institucional_gs,
        p90_institucional_gs,
        p95_institucional_gs,
        total_institucional_gs,
        total_registros_institucionales,
        promedio_tipo_funcionario_gs,
        mediana_tipo_funcionario_gs,

        -- ----------------------------------------------------
        -- Brechas, concentración, percentiles y rankings
        -- ----------------------------------------------------
        brecha_promedio_institucional_gs,
        brecha_promedio_institucional_pct,
        brecha_mediana_institucional_gs,
        brecha_mediana_institucional_pct,
        indicador_remuneracion_alta_media_baja,
        participacion_en_total_institucional_pct,
        indicador_posible_concentracion_salarial,
        percentil_salarial_global,
        percentil_salarial_institucional,
        ranking_salarial_institucion,
        ranking_salarial_institucion_cargo,
        ranking_salarial_institucion_tipo_funcionario,
        es_top_10_pct_institucional,
        es_top_1_pct_global,
        es_outlier_salarial_iqr,

        -- ----------------------------------------------------
        -- Indicadores de calidad heredados desde CORE/STAGING
        -- ----------------------------------------------------
        tiene_objeto_gasto_sin_clasificar,
        tiene_oee_sin_clasificar,
        tiene_cotizacion_usd_faltante,
        tiene_regimen_salarial_faltante,
        CASE
            WHEN remuneracion_total_gs IS NULL THEN TRUE
            WHEN remuneracion_total_gs < 0 THEN TRUE
            ELSE FALSE
        END AS tiene_remuneracion_invalida,
        CASE
            WHEN edad IS NOT NULL AND (edad < 18 OR edad > 100) THEN TRUE
            ELSE FALSE
        END AS tiene_edad_sospechosa,
        CASE
            WHEN antiguedad_anhos IS NOT NULL AND antiguedad_anhos > 60 THEN TRUE
            ELSE FALSE
        END AS tiene_antiguedad_sospechosa,

        -- ----------------------------------------------------
        -- Linaje y auditoría
        -- ----------------------------------------------------
        fuentes_archivo_lista,
        fecha_carga_staging_min,
        fecha_carga_staging_max,
        hash_funcionario_mes,
        fecha_carga_core,
        CURRENT_TIMESTAMP AS fecha_carga_datamart
    FROM base
)
SELECT *
FROM obt;

-- ============================================================
-- 2) Tabla de detalle complementaria para análisis de componentes
--
-- Grano:
--   anho + mes + nivel + entidad + oee + documento + objeto_gasto
--
-- Justificación:
--   La OBT consolida a nivel funcionario/OEE/mes. Esta tabla permite
--   explicar la composición salarial exacta por objeto de gasto y concepto.
-- ============================================================
CREATE OR REPLACE TABLE datamart.det_remuneraciones_componentes_bi AS
SELECT
    hash_componente AS componente_registro_id,
    md5(
        COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
        COALESCE(CAST(mes AS VARCHAR), '')
    ) AS periodo_sk,
    md5(
        COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
        COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
        COALESCE(CAST(oee AS VARCHAR), '')
    ) AS institucion_oee_sk,
    COALESCE(documento_hash, md5(COALESCE(CAST(documento AS VARCHAR), ''))) AS funcionario_sk,

    anho,
    mes,
    fecha_periodo,
    periodo_yyyy_mm,
    periodo_id,
    mes_nombre,
    trimestre,
    semestre,

    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    oee_descripcion_corta,
    uri_oee,
    es_universidad_nacional,

    documento,
    documento_hash,
    nombres,
    apellidos,
    TRIM(COALESCE(nombres, '') || ' ' || COALESCE(apellidos, '')) AS funcionario_nombre_completo,
    tipo_registro_funcionario,
    es_registro_anonimo,
    es_vacancia,
    estado,
    tipo_vinculo_inferido,
    tiene_indicio_docente_por_objeto_gasto,

    objeto_gasto,
    concepto_remunerativo,
    objeto_gasto_descripcion,
    grupo_codigo,
    grupo_descripcion,
    subgrupo_codigo,
    subgrupo_descripcion,
    control_financiero_codigo,
    control_financiero_descripcion,
    clasificacion_gasto_descripcion,
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    criterio_clasificacion_componente,

    presupuestado_gs,
    devengado_gs,
    monto_componente_gs,
    monto_remunerativo_principal_gs,
    monto_beca_transferencia_gs,
    cotizacion_usd_promedio,
    monto_componente_usd,
    monto_remunerativo_principal_usd,
    salario_minimo_mensual_gs,
    monto_componente_en_salarios_minimos,

    tiene_objeto_gasto_sin_clasificar,
    tiene_oee_sin_clasificar,
    tiene_cotizacion_usd_faltante,
    tiene_regimen_salarial_faltante,
    fuente_archivo,
    hash_registro,
    hash_registro_enriquecido,
    hash_componente,
    fecha_carga_core,
    CURRENT_TIMESTAMP AS fecha_carga_datamart
FROM core.fact_remuneraciones_componentes;

-- ============================================================
-- 3) Vistas de acceso frecuente
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_obt_remuneraciones_universidades_nacionales AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE es_universidad_nacional = TRUE;

CREATE OR REPLACE VIEW datamart.vw_det_componentes_universidades_nacionales AS
SELECT *
FROM datamart.det_remuneraciones_componentes_bi
WHERE es_universidad_nacional = TRUE;

-- ============================================================
-- 4) Vistas de control de carga DATAMART
-- ============================================================
CREATE OR REPLACE VIEW datamart.vw_control_datamart_obt AS
SELECT
    COUNT(*) AS total_registros_obt,
    COUNT(DISTINCT obt_registro_id) AS total_registros_obt_distintos,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    COUNT(DISTINCT institucion_oee_sk) AS total_instituciones_oee,
    COUNT(DISTINCT periodo_sk) AS total_periodos,
    SUM(remuneracion_total_gs) AS masa_salarial_total_gs,
    SUM(remuneracion_total_usd) AS masa_salarial_total_usd,
    SUM(CASE WHEN es_universidad_nacional THEN 1 ELSE 0 END) AS registros_universidades_nacionales,
    SUM(CASE WHEN tiene_objeto_gasto_sin_clasificar THEN 1 ELSE 0 END) AS registros_con_objeto_gasto_sin_clasificar,
    SUM(CASE WHEN tiene_oee_sin_clasificar THEN 1 ELSE 0 END) AS registros_con_oee_sin_clasificar,
    SUM(CASE WHEN tiene_cotizacion_usd_faltante THEN 1 ELSE 0 END) AS registros_sin_cotizacion_usd,
    SUM(CASE WHEN tiene_regimen_salarial_faltante THEN 1 ELSE 0 END) AS registros_sin_regimen_salarial,
    SUM(CASE WHEN cargo_no_disponible_en_fuente THEN 1 ELSE 0 END) AS registros_sin_cargo_por_diseno,
    SUM(CASE WHEN funcion_no_disponible_en_fuente THEN 1 ELSE 0 END) AS registros_sin_funcion_por_diseno,
    MIN(fecha_carga_datamart) AS primera_fecha_carga_datamart,
    MAX(fecha_carga_datamart) AS ultima_fecha_carga_datamart
FROM datamart.obt_remuneraciones_funcionarios_publicos;

CREATE OR REPLACE VIEW datamart.vw_control_datamart_componentes AS
SELECT
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    COUNT(*) AS total_registros_componentes,
    COUNT(DISTINCT funcionario_sk) AS total_funcionarios_sk,
    SUM(monto_componente_gs) AS monto_total_componente_gs,
    SUM(monto_remunerativo_principal_gs) AS monto_total_remunerativo_principal_gs,
    SUM(monto_beca_transferencia_gs) AS monto_total_beca_transferencia_gs,
    SUM(CASE WHEN tiene_objeto_gasto_sin_clasificar THEN 1 ELSE 0 END) AS registros_objeto_gasto_sin_clasificar
FROM datamart.det_remuneraciones_componentes_bi
GROUP BY componente_remunerativo, incluir_en_remuneracion_principal;

CREATE OR REPLACE TABLE audit.validacion_datamart_obt AS
SELECT
    CURRENT_TIMESTAMP AS fecha_validacion,
    *
FROM datamart.vw_control_datamart_obt;

-- ============================================================
-- 5) Exportaciones opcionales
--
-- Descomentar cuando se requiera generar archivos físicos desde DuckDB.
-- Ajustar rutas según la estructura real del repositorio.
-- ============================================================
-- COPY datamart.obt_remuneraciones_funcionarios_publicos
-- TO './exports/obt_remuneraciones_funcionarios_publicos.parquet'
-- (FORMAT PARQUET, COMPRESSION ZSTD);
--
-- COPY datamart.det_remuneraciones_componentes_bi
-- TO './exports/det_remuneraciones_componentes_bi.parquet'
-- (FORMAT PARQUET, COMPRESSION ZSTD);
--
-- COPY datamart.obt_remuneraciones_funcionarios_publicos
-- TO './exports/obt_remuneraciones_funcionarios_publicos.csv'
-- (HEADER, DELIMITER ',');

-- ============================================================
-- 6) Auditoría de ejecución
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '04_datamart_obt.sql',
    'datamart',
    'obt_remuneraciones_funcionarios_publicos',
    'ok',
    (SELECT COUNT(*) FROM datamart.obt_remuneraciones_funcionarios_publicos),
    'OBT final y detalle de componentes BI generados desde core sin depender de cargo/funcion no disponibles';
