-- ============================================================
-- 06_data_quality_checks.sql
-- Proyecto: gasto-salarios-unpy
-- Capa: QUALITY / DQ
-- Motor: DuckDB
-- Autor académico: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   Ejecutar controles de calidad de datos sobre las capas RAW, STAGING,
--   CORE y DATAMART del modelo analítico de remuneraciones públicas de
--   universidades nacionales de Paraguay.
--
-- Dependencias:
--   Ejecutar antes:
--     sql/00_setup/00_create_schemas.sql
--     sql/01_raw/01_raw_ingesta.sql
--     sql/02_staging/02_staging_limpieza.sql
--     sql/03_core/03_core_modelo.sql
--     sql/04_datamart/04_datamart_obt.sql
--     sql/04_datamart/05_datamart_agregados.sql
--
-- Entradas esperadas principales:
--   RAW:
--     raw.funcionarios_modelo_src
--     raw.clasificador_gastos_src
--     raw.clasificador_oee_src
--     raw.cotizacion_usd_mensual_src
--     raw.regimen_salarial_py_src
--
--   STAGING:
--     staging.funcionarios_modelo
--     staging.funcionarios_modelo_ext
--     staging.funcionarios_modelo_enriquecido
--
--   CORE:
--     core.fact_remuneraciones_componentes
--     core.fact_remuneraciones_funcionario_mes
--
--   DATAMART:
--     datamart.obt_remuneraciones_funcionarios_publicos
--     datamart.det_remuneraciones_componentes_bi
--
-- Aclaración crítica:
--   El CSV principal NO contiene cargo, funcion, concepto, linea ni categoria.
--   Por tanto:
--     - concepto_remunerativo debe derivarse desde clasificador_gastos_src
--       vía objeto_gasto.
--     - cargo, funcion, linea y categoria no deben tratarse como fallas de
--       calidad si aparecen nulos; se reportan como no disponibles por diseño.
--
-- Salidas principales:
--   dq.resultados_checks
--   dq.vw_resumen_calidad
--   dq.vw_reporte_ejecutivo_calidad
--   dq.distribucion_nulos_obt
--   dq.distribucion_nulos_componentes
--   dq.metricas_calidad_modelo
--
-- Convención de severidad:
--   ALTA        = rompe confiabilidad del modelo o del total monetario.
--   MEDIA       = afecta interpretación, enriquecimiento o trazabilidad.
--   BAJA        = debe revisarse, pero no invalida el modelo completo.
--   INFORMATIVA = hallazgo esperado o exploratorio.
-- ============================================================

-- ============================================================
-- 0) Preparación defensiva de esquemas y auditoría
-- ============================================================
CREATE SCHEMA IF NOT EXISTS dq;
CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.etl_run_log (
    fecha_ejecucion TIMESTAMP,
    script VARCHAR,
    capa VARCHAR,
    objeto VARCHAR,
    estado VARCHAR,
    registros BIGINT,
    mensaje VARCHAR
);

-- ============================================================
-- 1) Inventario mínimo de tablas esperadas
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_tablas_esperadas AS
SELECT *
FROM (
    VALUES
        ('raw',      'funcionarios_modelo_src',                    'Fuente principal depurada para modelado'),
        ('raw',      'clasificador_gastos_src',                     'Clasificador de objetos de gasto'),
        ('raw',      'clasificador_oee_src',                        'Clasificador institucional OEE'),
        ('raw',      'cotizacion_usd_mensual_src',                  'Cotización mensual USD'),
        ('raw',      'regimen_salarial_py_src',                     'Régimen salarial Paraguay'),
        ('staging',  'funcionarios_modelo',                         'Fuente principal limpia'),
        ('staging',  'funcionarios_modelo_ext',                     'Fuente principal enriquecida'),
        ('core',     'fact_remuneraciones_componentes',             'Detalle por componente remunerativo'),
        ('core',     'fact_remuneraciones_funcionario_mes',         'Consolidado funcionario/OEE/mes'),
        ('datamart', 'obt_remuneraciones_funcionarios_publicos',    'OBT final para BI'),
        ('datamart', 'det_remuneraciones_componentes_bi',           'Detalle BI por componente')
) AS t(table_schema, table_name, descripcion);

CREATE OR REPLACE VIEW dq.vw_validacion_tablas_esperadas AS
SELECT
    e.table_schema,
    e.table_name,
    e.descripcion,
    CASE WHEN c.table_name IS NULL THEN FALSE ELSE TRUE END AS existe_tabla,
    CASE WHEN c.table_name IS NULL THEN 'NO_EXISTE' ELSE 'OK' END AS estado
FROM dq.vw_tablas_esperadas e
LEFT JOIN information_schema.tables c
       ON LOWER(c.table_schema) = LOWER(e.table_schema)
      AND LOWER(c.table_name) = LOWER(e.table_name);

-- ============================================================
-- 2) Conteos por capa y controles de volumen
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_conteo_registros_por_capa AS
SELECT 'raw.funcionarios_modelo_src' AS objeto, 'raw' AS capa, COUNT(*) AS total_registros FROM raw.funcionarios_modelo_src
UNION ALL
SELECT 'raw.clasificador_gastos_src', 'raw', COUNT(*) FROM raw.clasificador_gastos_src
UNION ALL
SELECT 'raw.clasificador_oee_src', 'raw', COUNT(*) FROM raw.clasificador_oee_src
UNION ALL
SELECT 'raw.cotizacion_usd_mensual_src', 'raw', COUNT(*) FROM raw.cotizacion_usd_mensual_src
UNION ALL
SELECT 'raw.regimen_salarial_py_src', 'raw', COUNT(*) FROM raw.regimen_salarial_py_src
UNION ALL
SELECT 'staging.funcionarios_modelo', 'staging', COUNT(*) FROM staging.funcionarios_modelo
UNION ALL
SELECT 'staging.funcionarios_modelo_ext', 'staging', COUNT(*) FROM staging.funcionarios_modelo_ext
UNION ALL
SELECT 'core.fact_remuneraciones_componentes', 'core', COUNT(*) FROM core.fact_remuneraciones_componentes
UNION ALL
SELECT 'core.fact_remuneraciones_funcionario_mes', 'core', COUNT(*) FROM core.fact_remuneraciones_funcionario_mes
UNION ALL
SELECT 'datamart.obt_remuneraciones_funcionarios_publicos', 'datamart', COUNT(*) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL
SELECT 'datamart.det_remuneraciones_componentes_bi', 'datamart', COUNT(*) FROM datamart.det_remuneraciones_componentes_bi;

CREATE OR REPLACE VIEW dq.vw_control_volumen_entre_capas AS
WITH c AS (
    SELECT objeto, total_registros
    FROM dq.vw_conteo_registros_por_capa
), pares AS (
    SELECT
        'RAW_VS_STAGING_FUNCIONARIOS' AS control,
        (SELECT total_registros FROM c WHERE objeto = 'raw.funcionarios_modelo_src') AS registros_origen,
        (SELECT total_registros FROM c WHERE objeto = 'staging.funcionarios_modelo') AS registros_destino,
        'La limpieza staging no debe perder filas de la fuente principal' AS descripcion
    UNION ALL
    SELECT
        'STAGING_VS_STAGING_EXT_FUNCIONARIOS',
        (SELECT total_registros FROM c WHERE objeto = 'staging.funcionarios_modelo'),
        (SELECT total_registros FROM c WHERE objeto = 'staging.funcionarios_modelo_ext'),
        'El enriquecimiento staging no debe duplicar ni perder filas'
    UNION ALL
    SELECT
        'STAGING_EXT_VS_CORE_COMPONENTES',
        (SELECT total_registros FROM c WHERE objeto = 'staging.funcionarios_modelo_ext'),
        (SELECT total_registros FROM c WHERE objeto = 'core.fact_remuneraciones_componentes'),
        'El detalle core por componente debe conservar el grano de staging enriquecido'
    UNION ALL
    SELECT
        'CORE_FUNCIONARIO_MES_VS_DATAMART_OBT',
        (SELECT total_registros FROM c WHERE objeto = 'core.fact_remuneraciones_funcionario_mes'),
        (SELECT total_registros FROM c WHERE objeto = 'datamart.obt_remuneraciones_funcionarios_publicos'),
        'La OBT debe conservar el grano consolidado funcionario/OEE/mes'
    UNION ALL
    SELECT
        'CORE_COMPONENTES_VS_DATAMART_DET_COMPONENTES',
        (SELECT total_registros FROM c WHERE objeto = 'core.fact_remuneraciones_componentes'),
        (SELECT total_registros FROM c WHERE objeto = 'datamart.det_remuneraciones_componentes_bi'),
        'El detalle BI de componentes debe conservar el detalle core'
)
SELECT
    control,
    registros_origen,
    registros_destino,
    registros_destino - registros_origen AS diferencia_registros,
    CASE WHEN registros_origen = registros_destino THEN 'OK' ELSE 'REVISAR' END AS estado,
    descripcion
FROM pares;

-- ============================================================
-- 3) Validación de columnas esperadas en fuente principal RAW
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_columnas_esperadas_raw_funcionarios AS
SELECT *
FROM (
    VALUES
        ('anho'),
        ('mes'),
        ('nivel'),
        ('entidad'),
        ('oee'),
        ('documento'),
        ('nombres'),
        ('apellidos'),
        ('estado'),
        ('anho_ingreso'),
        ('sexo'),
        ('discapacidad'),
        ('tipo_discapacidad'),
        ('fuente_financiamiento'),
        ('objeto_gasto'),
        ('presupuestado'),
        ('devengado'),
        ('fecha_nacimiento'),
        ('fecha_acto')
) AS t(column_name);

CREATE OR REPLACE VIEW dq.vw_validacion_columnas_raw_funcionarios AS
SELECT
    e.column_name,
    CASE WHEN c.column_name IS NULL THEN FALSE ELSE TRUE END AS existe_columna,
    CASE WHEN c.column_name IS NULL THEN 'NO_EXISTE' ELSE 'OK' END AS estado
FROM dq.vw_columnas_esperadas_raw_funcionarios e
LEFT JOIN information_schema.columns c
       ON LOWER(c.table_schema) = 'raw'
      AND LOWER(c.table_name) = 'funcionarios_modelo_src'
      AND LOWER(c.column_name) = LOWER(e.column_name);

-- Campos explícitamente no disponibles en la fuente principal.
CREATE OR REPLACE VIEW dq.vw_campos_no_disponibles_por_diseno AS
SELECT
    'raw.funcionarios_modelo_src' AS tabla,
    'cargo' AS campo,
    'NO_DISPONIBLE_POR_DISENO' AS estado,
    'No viene en el CSV principal. No debe usarse como dimensión analítica sin nueva fuente.' AS observacion
UNION ALL
SELECT 'raw.funcionarios_modelo_src', 'funcion', 'NO_DISPONIBLE_POR_DISENO', 'No viene en el CSV principal. No debe usarse como dimensión analítica sin nueva fuente.'
UNION ALL
SELECT 'raw.funcionarios_modelo_src', 'concepto', 'NO_DISPONIBLE_POR_DISENO', 'Debe derivarse desde raw.clasificador_gastos_src usando objeto_gasto.'
UNION ALL
SELECT 'raw.funcionarios_modelo_src', 'linea', 'NO_DISPONIBLE_POR_DISENO', 'No viene en el CSV principal. Campo técnico NULL aguas abajo.'
UNION ALL
SELECT 'raw.funcionarios_modelo_src', 'categoria', 'NO_DISPONIBLE_POR_DISENO', 'No viene en el CSV principal. Campo técnico NULL aguas abajo.';

-- ============================================================
-- 4) Duplicados de negocio por grano de componente
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_duplicados_staging_componente AS
SELECT
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    presupuestado_gs,
    devengado_gs,
    fecha_acto,
    COUNT(*) AS cantidad_registros
FROM staging.funcionarios_modelo_ext
GROUP BY
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    presupuestado_gs,
    devengado_gs,
    fecha_acto
HAVING COUNT(*) > 1;

CREATE OR REPLACE VIEW dq.vw_duplicados_core_componentes AS
SELECT
    hash_componente,
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    COUNT(*) AS cantidad_registros
FROM core.fact_remuneraciones_componentes
GROUP BY
    hash_componente,
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto
HAVING COUNT(*) > 1;

CREATE OR REPLACE VIEW dq.vw_duplicados_datamart_obt AS
SELECT
    obt_registro_id,
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    COUNT(*) AS cantidad_registros
FROM datamart.obt_remuneraciones_funcionarios_publicos
GROUP BY
    obt_registro_id,
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento
HAVING COUNT(*) > 1;

-- ============================================================
-- 5) Importes nulos, negativos, cero y diferencias monetarias
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_staging_importes_problematicos AS
SELECT
    *,
    CASE
        WHEN presupuestado_gs IS NULL AND devengado_gs IS NULL THEN 'PRESUPUESTADO_Y_DEVENGADO_NULOS'
        WHEN presupuestado_gs IS NULL THEN 'PRESUPUESTADO_NULO'
        WHEN devengado_gs IS NULL THEN 'DEVENGADO_NULO'
        WHEN presupuestado_gs < 0 OR devengado_gs < 0 THEN 'IMPORTE_NEGATIVO'
        ELSE 'NO_CLASIFICADO'
    END AS tipo_problema_importe
FROM staging.funcionarios_modelo_ext
WHERE presupuestado_gs IS NULL
   OR devengado_gs IS NULL
   OR presupuestado_gs < 0
   OR devengado_gs < 0;

CREATE OR REPLACE VIEW dq.vw_staging_importes_cero AS
SELECT *
FROM staging.funcionarios_modelo_ext
WHERE COALESCE(presupuestado_gs, 0) = 0
  AND COALESCE(devengado_gs, 0) = 0;

CREATE OR REPLACE VIEW dq.vw_datamart_remuneraciones_problematicas AS
SELECT
    *,
    CASE
        WHEN remuneracion_total_gs IS NULL THEN 'REMUNERACION_TOTAL_NULA'
        WHEN remuneracion_total_gs < 0 THEN 'REMUNERACION_TOTAL_NEGATIVA'
        WHEN remuneracion_total_gs = 0 THEN 'REMUNERACION_TOTAL_CERO'
        ELSE 'NO_CLASIFICADO'
    END AS tipo_problema_remuneracion
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE remuneracion_total_gs IS NULL
   OR remuneracion_total_gs < 0
   OR remuneracion_total_gs = 0;

-- Diferencia entre remuneración total y suma de componentes remunerativos principales.
CREATE OR REPLACE VIEW dq.vw_diferencias_total_componentes_obt AS
SELECT
    *,
    (
        COALESCE(salario_basico_gs, 0)
        + COALESCE(honorarios_gs, 0)
        + COALESCE(viaticos_gs, 0)
        + COALESCE(beneficios_gs, 0)
        + COALESCE(bonificaciones_gs, 0)
        + COALESCE(gastos_representacion_gs, 0)
        + COALESCE(aguinaldo_gs, 0)
        + COALESCE(otros_componentes_gs, 0)
    ) AS total_componentes_recalculado_gs,
    remuneracion_total_gs
      - (
            COALESCE(salario_basico_gs, 0)
            + COALESCE(honorarios_gs, 0)
            + COALESCE(viaticos_gs, 0)
            + COALESCE(beneficios_gs, 0)
            + COALESCE(bonificaciones_gs, 0)
            + COALESCE(gastos_representacion_gs, 0)
            + COALESCE(aguinaldo_gs, 0)
            + COALESCE(otros_componentes_gs, 0)
        ) AS diferencia_total_componentes_gs
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE ABS(
    remuneracion_total_gs
    - (
        COALESCE(salario_basico_gs, 0)
        + COALESCE(honorarios_gs, 0)
        + COALESCE(viaticos_gs, 0)
        + COALESCE(beneficios_gs, 0)
        + COALESCE(bonificaciones_gs, 0)
        + COALESCE(gastos_representacion_gs, 0)
        + COALESCE(aguinaldo_gs, 0)
        + COALESCE(otros_componentes_gs, 0)
    )
) > 1;

-- Diferencia entre total consolidado CORE y suma del detalle CORE por el mismo grano.
CREATE OR REPLACE VIEW dq.vw_integridad_core_funcionario_mes_vs_componentes AS
WITH detalle AS (
    SELECT
        anho,
        mes,
        nivel,
        entidad,
        oee,
        documento,
        SUM(COALESCE(monto_remunerativo_principal_gs, 0)) AS total_componentes_principales_gs,
        SUM(COALESCE(monto_componente_gs, 0)) AS total_componentes_brutos_gs,
        COUNT(*) AS cantidad_componentes_detalle
    FROM core.fact_remuneraciones_componentes
    GROUP BY anho, mes, nivel, entidad, oee, documento
), consolidado AS (
    SELECT
        anho,
        mes,
        nivel,
        entidad,
        oee,
        documento,
        remuneracion_total_gs,
        cantidad_componentes
    FROM core.fact_remuneraciones_funcionario_mes
)
SELECT
    c.anho,
    c.mes,
    c.nivel,
    c.entidad,
    c.oee,
    c.documento,
    c.remuneracion_total_gs,
    d.total_componentes_principales_gs,
    c.remuneracion_total_gs - d.total_componentes_principales_gs AS diferencia_total_gs,
    c.cantidad_componentes,
    d.cantidad_componentes_detalle,
    c.cantidad_componentes - d.cantidad_componentes_detalle AS diferencia_cantidad_componentes
FROM consolidado c
LEFT JOIN detalle d
       ON c.anho = d.anho
      AND c.mes = d.mes
      AND c.nivel = d.nivel
      AND c.entidad = d.entidad
      AND c.oee = d.oee
      AND COALESCE(c.documento, '') = COALESCE(d.documento, '')
WHERE d.documento IS NULL
   OR ABS(c.remuneracion_total_gs - d.total_componentes_principales_gs) > 1
   OR c.cantidad_componentes <> d.cantidad_componentes_detalle;

-- ============================================================
-- 6) Fechas, edad y antigüedad
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_staging_fechas_invalidas_sospechosas AS
SELECT
    *,
    CASE
        WHEN fecha_periodo IS NULL THEN 'PERIODO_INVALIDO'
        WHEN fecha_nacimiento_raw IS NOT NULL AND fecha_nacimiento IS NULL THEN 'FECHA_NACIMIENTO_NO_PARSEABLE'
        WHEN fecha_acto_raw IS NOT NULL AND fecha_acto IS NULL THEN 'FECHA_ACTO_NO_PARSEABLE'
        WHEN fecha_nacimiento > fecha_periodo THEN 'FECHA_NACIMIENTO_POSTERIOR_AL_PERIODO'
        WHEN fecha_acto > CURRENT_DATE THEN 'FECHA_ACTO_FUTURA'
        WHEN anho_ingreso IS NOT NULL AND anho_ingreso > anho THEN 'ANHO_INGRESO_POSTERIOR_AL_PERIODO'
        WHEN anho_ingreso IS NOT NULL AND anho_ingreso < 1900 THEN 'ANHO_INGRESO_MUY_ANTIGUO'
        ELSE 'NO_CLASIFICADO'
    END AS tipo_problema_fecha
FROM staging.funcionarios_modelo_ext
WHERE fecha_periodo IS NULL
   OR (fecha_nacimiento_raw IS NOT NULL AND fecha_nacimiento IS NULL)
   OR (fecha_acto_raw IS NOT NULL AND fecha_acto IS NULL)
   OR fecha_nacimiento > fecha_periodo
   OR fecha_acto > CURRENT_DATE
   OR (anho_ingreso IS NOT NULL AND anho_ingreso > anho)
   OR (anho_ingreso IS NOT NULL AND anho_ingreso < 1900);

CREATE OR REPLACE VIEW dq.vw_datamart_demografia_sospechosa AS
SELECT
    *,
    CASE
        WHEN edad IS NOT NULL AND edad < 18 THEN 'EDAD_MENOR_18'
        WHEN edad IS NOT NULL AND edad > 100 THEN 'EDAD_MAYOR_100'
        WHEN antiguedad_anhos IS NOT NULL AND antiguedad_anhos < 0 THEN 'ANTIGUEDAD_NEGATIVA'
        WHEN antiguedad_anhos IS NOT NULL AND antiguedad_anhos > 60 THEN 'ANTIGUEDAD_MAYOR_60'
        WHEN fecha_nacimiento IS NOT NULL AND fecha_nacimiento > fecha_periodo THEN 'FECHA_NACIMIENTO_POSTERIOR_AL_PERIODO'
        ELSE 'NO_CLASIFICADO'
    END AS tipo_problema_demografico
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE (edad IS NOT NULL AND (edad < 18 OR edad > 100))
   OR (antiguedad_anhos IS NOT NULL AND (antiguedad_anhos < 0 OR antiguedad_anhos > 60))
   OR (fecha_nacimiento IS NOT NULL AND fecha_nacimiento > fecha_periodo);

-- ============================================================
-- 7) Enriquecimiento: concepto, OEE, cotización USD y régimen salarial
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_staging_enriquecimiento_faltante AS
SELECT
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    concepto_remunerativo,
    descripcion_nivel,
    descripcion_entidad,
    descripcion_oee,
    cotizacion_usd_promedio,
    salario_minimo_mensual_gs,
    tiene_objeto_gasto_sin_clasificar,
    tiene_oee_sin_clasificar,
    tiene_cotizacion_usd_faltante,
    tiene_regimen_salarial_faltante,
    CASE
        WHEN objeto_gasto IS NOT NULL AND (concepto_remunerativo IS NULL OR concepto_remunerativo = 'SIN CLASIFICAR') THEN 'CONCEPTO_NO_DERIVADO_DESDE_CLASIFICADOR_GASTOS'
        WHEN descripcion_oee IS NULL THEN 'OEE_SIN_DESCRIPCION'
        WHEN cotizacion_usd_promedio IS NULL THEN 'SIN_COTIZACION_USD'
        WHEN salario_minimo_mensual_gs IS NULL THEN 'SIN_REGIMEN_SALARIAL'
        ELSE 'NO_CLASIFICADO'
    END AS tipo_faltante
FROM staging.funcionarios_modelo_ext
WHERE (objeto_gasto IS NOT NULL AND (concepto_remunerativo IS NULL OR concepto_remunerativo = 'SIN CLASIFICAR'))
   OR descripcion_oee IS NULL
   OR cotizacion_usd_promedio IS NULL
   OR salario_minimo_mensual_gs IS NULL
   OR tiene_objeto_gasto_sin_clasificar = TRUE
   OR tiene_oee_sin_clasificar = TRUE
   OR tiene_cotizacion_usd_faltante = TRUE
   OR tiene_regimen_salarial_faltante = TRUE;

CREATE OR REPLACE VIEW dq.vw_datamart_sin_oee AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE nivel IS NULL
   OR entidad IS NULL
   OR oee IS NULL
   OR descripcion_oee IS NULL
   OR descripcion_oee = 'NO INFORMADO'
   OR tiene_oee_sin_clasificar = TRUE;

CREATE OR REPLACE VIEW dq.vw_datamart_sin_cotizacion_usd AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE cotizacion_usd_promedio IS NULL
   OR cotizacion_usd_promedio = 0
   OR remuneracion_total_usd IS NULL
   OR tiene_cotizacion_usd_faltante = TRUE;

CREATE OR REPLACE VIEW dq.vw_datamart_sin_regimen_salarial AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE salario_minimo_mensual_gs IS NULL
   OR fecha_regimen_salarial IS NULL
   OR tiene_regimen_salarial_faltante = TRUE;

CREATE OR REPLACE VIEW dq.vw_core_objetos_gasto_sin_clasificar AS
SELECT
    objeto_gasto,
    COUNT(*) AS total_registros,
    SUM(COALESCE(monto_componente_gs, 0)) AS monto_total_gs,
    COUNT(DISTINCT documento_hash) AS total_funcionarios_sk
FROM core.fact_remuneraciones_componentes
WHERE objeto_gasto IS NULL
   OR concepto_remunerativo IS NULL
   OR concepto_remunerativo = 'SIN CLASIFICAR'
   OR tiene_objeto_gasto_sin_clasificar = TRUE
GROUP BY objeto_gasto
ORDER BY monto_total_gs DESC;

-- ============================================================
-- 8) Validaciones de clasificación salarial y composición
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_componentes_no_mapeados_o_sospechosos AS
SELECT
    componente_remunerativo,
    objeto_gasto,
    concepto_remunerativo,
    COUNT(*) AS total_registros,
    SUM(COALESCE(monto_componente_gs, 0)) AS monto_total_gs,
    SUM(COALESCE(monto_remunerativo_principal_gs, 0)) AS monto_remunerativo_principal_gs
FROM datamart.det_remuneraciones_componentes_bi
WHERE componente_remunerativo IS NULL
   OR componente_remunerativo = 'SIN_CLASIFICAR'
   OR concepto_remunerativo IS NULL
GROUP BY componente_remunerativo, objeto_gasto, concepto_remunerativo
ORDER BY monto_total_gs DESC;

CREATE OR REPLACE VIEW dq.vw_obt_composicion_porcentual_invalida AS
SELECT
    *,
    COALESCE(participacion_salario_basico_pct, 0)
    + COALESCE(participacion_honorarios_pct, 0)
    + COALESCE(participacion_viaticos_pct, 0)
    + COALESCE(participacion_beneficios_pct, 0)
    + COALESCE(participacion_bonificaciones_pct, 0)
    + COALESCE(participacion_gastos_representacion_pct, 0)
    + COALESCE(participacion_aguinaldo_pct, 0)
    + COALESCE(participacion_otros_componentes_pct, 0) AS suma_participaciones_pct
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE remuneracion_total_gs > 0
  AND ABS(
        (
            COALESCE(participacion_salario_basico_pct, 0)
            + COALESCE(participacion_honorarios_pct, 0)
            + COALESCE(participacion_viaticos_pct, 0)
            + COALESCE(participacion_beneficios_pct, 0)
            + COALESCE(participacion_bonificaciones_pct, 0)
            + COALESCE(participacion_gastos_representacion_pct, 0)
            + COALESCE(participacion_aguinaldo_pct, 0)
            + COALESCE(participacion_otros_componentes_pct, 0)
        ) - 100
      ) > 0.10;

-- ============================================================
-- 9) Distribución de nulos en campos prioritarios
-- ============================================================
CREATE OR REPLACE TABLE dq.distribucion_nulos_obt AS
SELECT 'obt_registro_id' AS columna, COUNT(*) AS total_registros, SUM(CASE WHEN obt_registro_id IS NULL THEN 1 ELSE 0 END) AS total_nulos FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'periodo_sk', COUNT(*), SUM(CASE WHEN periodo_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'institucion_oee_sk', COUNT(*), SUM(CASE WHEN institucion_oee_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'funcionario_sk', COUNT(*), SUM(CASE WHEN funcionario_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'anho', COUNT(*), SUM(CASE WHEN anho IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'mes', COUNT(*), SUM(CASE WHEN mes IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'fecha_periodo', COUNT(*), SUM(CASE WHEN fecha_periodo IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'nivel', COUNT(*), SUM(CASE WHEN nivel IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'entidad', COUNT(*), SUM(CASE WHEN entidad IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'oee', COUNT(*), SUM(CASE WHEN oee IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'descripcion_oee', COUNT(*), SUM(CASE WHEN descripcion_oee IS NULL OR descripcion_oee = 'NO INFORMADO' THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'documento', COUNT(*), SUM(CASE WHEN documento IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'tipo_registro_funcionario', COUNT(*), SUM(CASE WHEN tipo_registro_funcionario IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'tipo_funcionario_inferido', COUNT(*), SUM(CASE WHEN tipo_funcionario_inferido IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'tipo_vinculo_inferido', COUNT(*), SUM(CASE WHEN tipo_vinculo_inferido IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'sexo', COUNT(*), SUM(CASE WHEN sexo IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'anho_ingreso', COUNT(*), SUM(CASE WHEN anho_ingreso IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'fecha_nacimiento', COUNT(*), SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'edad', COUNT(*), SUM(CASE WHEN edad IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'antiguedad_anhos', COUNT(*), SUM(CASE WHEN antiguedad_anhos IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'remuneracion_total_gs', COUNT(*), SUM(CASE WHEN remuneracion_total_gs IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'remuneracion_total_usd', COUNT(*), SUM(CASE WHEN remuneracion_total_usd IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'cotizacion_usd_promedio', COUNT(*), SUM(CASE WHEN cotizacion_usd_promedio IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'salario_minimo_mensual_gs', COUNT(*), SUM(CASE WHEN salario_minimo_mensual_gs IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'cargo_principal', COUNT(*), SUM(CASE WHEN cargo_principal IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos
UNION ALL SELECT 'funcion_principal', COUNT(*), SUM(CASE WHEN funcion_principal IS NULL THEN 1 ELSE 0 END) FROM datamart.obt_remuneraciones_funcionarios_publicos;

CREATE OR REPLACE VIEW dq.vw_distribucion_nulos_obt AS
SELECT
    columna,
    total_registros,
    total_nulos,
    CASE
        WHEN total_registros = 0 THEN NULL
        ELSE ROUND(total_nulos * 100.0 / total_registros, 4)
    END AS porcentaje_nulos,
    CASE
        WHEN columna IN ('cargo_principal', 'funcion_principal') THEN 'NULO_ESPERADO_POR_DISENO'
        WHEN total_nulos = 0 THEN 'OK'
        ELSE 'REVISAR'
    END AS estado
FROM dq.distribucion_nulos_obt
ORDER BY porcentaje_nulos DESC NULLS LAST, columna;

CREATE OR REPLACE TABLE dq.distribucion_nulos_componentes AS
SELECT 'componente_registro_id' AS columna, COUNT(*) AS total_registros, SUM(CASE WHEN componente_registro_id IS NULL THEN 1 ELSE 0 END) AS total_nulos FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'periodo_sk', COUNT(*), SUM(CASE WHEN periodo_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'institucion_oee_sk', COUNT(*), SUM(CASE WHEN institucion_oee_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'funcionario_sk', COUNT(*), SUM(CASE WHEN funcionario_sk IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'objeto_gasto', COUNT(*), SUM(CASE WHEN objeto_gasto IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'concepto_remunerativo', COUNT(*), SUM(CASE WHEN concepto_remunerativo IS NULL OR concepto_remunerativo = 'SIN CLASIFICAR' THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'componente_remunerativo', COUNT(*), SUM(CASE WHEN componente_remunerativo IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'monto_componente_gs', COUNT(*), SUM(CASE WHEN monto_componente_gs IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi
UNION ALL SELECT 'monto_componente_usd', COUNT(*), SUM(CASE WHEN monto_componente_usd IS NULL THEN 1 ELSE 0 END) FROM datamart.det_remuneraciones_componentes_bi;

CREATE OR REPLACE VIEW dq.vw_distribucion_nulos_componentes AS
SELECT
    columna,
    total_registros,
    total_nulos,
    CASE
        WHEN total_registros = 0 THEN NULL
        ELSE ROUND(total_nulos * 100.0 / total_registros, 4)
    END AS porcentaje_nulos,
    CASE WHEN total_nulos = 0 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM dq.distribucion_nulos_componentes
ORDER BY porcentaje_nulos DESC NULLS LAST, columna;

-- ============================================================
-- 10) Outliers salariales por IQR mensual e institucional
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_outliers_salariales_iqr_global_mensual AS
WITH stats AS (
    SELECT
        anho,
        mes,
        QUANTILE_CONT(remuneracion_total_gs, 0.25) AS q1,
        QUANTILE_CONT(remuneracion_total_gs, 0.75) AS q3
    FROM datamart.obt_remuneraciones_funcionarios_publicos
    WHERE remuneracion_total_gs IS NOT NULL
    GROUP BY anho, mes
), bounds AS (
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
    END AS tipo_outlier_iqr
FROM datamart.obt_remuneraciones_funcionarios_publicos o
JOIN bounds b
  ON o.anho = b.anho
 AND o.mes = b.mes
WHERE o.remuneracion_total_gs < b.limite_inferior
   OR o.remuneracion_total_gs > b.limite_superior;

CREATE OR REPLACE VIEW dq.vw_outliers_salariales_iqr_institucional AS
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
WHERE es_outlier_salarial_iqr = TRUE;

-- ============================================================
-- 11) Métricas generales de calidad del modelo
-- ============================================================
CREATE OR REPLACE TABLE dq.metricas_calidad_modelo AS
SELECT
    CURRENT_TIMESTAMP AS fecha_ejecucion,

    (SELECT COUNT(*) FROM raw.funcionarios_modelo_src) AS raw_funcionarios_registros,
    (SELECT COUNT(*) FROM staging.funcionarios_modelo_ext) AS staging_funcionarios_ext_registros,
    (SELECT COUNT(*) FROM core.fact_remuneraciones_componentes) AS core_componentes_registros,
    (SELECT COUNT(*) FROM core.fact_remuneraciones_funcionario_mes) AS core_funcionario_mes_registros,
    (SELECT COUNT(*) FROM datamart.obt_remuneraciones_funcionarios_publicos) AS datamart_obt_registros,
    (SELECT COUNT(*) FROM datamart.det_remuneraciones_componentes_bi) AS datamart_componentes_registros,

    (SELECT SUM(remuneracion_total_gs) FROM datamart.obt_remuneraciones_funcionarios_publicos) AS masa_salarial_obt_gs,
    (SELECT SUM(monto_remunerativo_principal_gs) FROM datamart.det_remuneraciones_componentes_bi) AS masa_salarial_componentes_principal_gs,
    (SELECT SUM(monto_componente_gs) FROM datamart.det_remuneraciones_componentes_bi) AS masa_componentes_bruta_gs,

    (SELECT COUNT(*) FROM dq.vw_duplicados_staging_componente) AS duplicados_staging_componente,
    (SELECT COUNT(*) FROM dq.vw_duplicados_core_componentes) AS duplicados_core_componentes,
    (SELECT COUNT(*) FROM dq.vw_duplicados_datamart_obt) AS duplicados_datamart_obt,
    (SELECT COUNT(*) FROM dq.vw_staging_importes_problematicos) AS staging_importes_problematicos,
    (SELECT COUNT(*) FROM dq.vw_datamart_remuneraciones_problematicas) AS obt_remuneraciones_problematicas,
    (SELECT COUNT(*) FROM dq.vw_staging_fechas_invalidas_sospechosas) AS staging_fechas_sospechosas,
    (SELECT COUNT(*) FROM dq.vw_datamart_demografia_sospechosa) AS obt_demografia_sospechosa,
    (SELECT COUNT(*) FROM dq.vw_staging_enriquecimiento_faltante) AS staging_enriquecimiento_faltante,
    (SELECT COUNT(*) FROM dq.vw_datamart_sin_oee) AS obt_sin_oee,
    (SELECT COUNT(*) FROM dq.vw_datamart_sin_cotizacion_usd) AS obt_sin_cotizacion_usd,
    (SELECT COUNT(*) FROM dq.vw_datamart_sin_regimen_salarial) AS obt_sin_regimen_salarial,
    (SELECT COUNT(*) FROM dq.vw_diferencias_total_componentes_obt) AS obt_diferencias_total_componentes,
    (SELECT COUNT(*) FROM dq.vw_integridad_core_funcionario_mes_vs_componentes) AS core_diferencias_consolidado_vs_componentes,
    (SELECT COUNT(*) FROM dq.vw_outliers_salariales_iqr_global_mensual) AS outliers_iqr_global_mensual,
    (SELECT COUNT(*) FROM dq.vw_outliers_salariales_iqr_institucional) AS outliers_iqr_institucional;

-- ============================================================
-- 12) Resultados consolidados de checks
-- ============================================================
CREATE OR REPLACE TABLE dq.resultados_checks AS
WITH checks AS (
    SELECT
        'DQ001_TABLAS_ESPERADAS' AS check_id,
        'raw/staging/core/datamart' AS capa,
        'information_schema.tables' AS objeto,
        'ALTA' AS severidad,
        COUNT(*) AS registros_afectados,
        0 AS umbral_permitido,
        'Tablas requeridas inexistentes' AS descripcion,
        'dq.vw_validacion_tablas_esperadas' AS consulta_detalle
    FROM dq.vw_validacion_tablas_esperadas
    WHERE existe_tabla = FALSE

    UNION ALL
    SELECT
        'DQ002_COLUMNAS_RAW_FUNCIONARIOS',
        'raw',
        'raw.funcionarios_modelo_src',
        'ALTA',
        COUNT(*),
        0,
        'Columnas esperadas faltantes en la fuente principal RAW',
        'dq.vw_validacion_columnas_raw_funcionarios'
    FROM dq.vw_validacion_columnas_raw_funcionarios
    WHERE existe_columna = FALSE

    UNION ALL
    SELECT
        'DQ003_VOLUMEN_ENTRE_CAPAS',
        'cross-layer',
        'raw/staging/core/datamart',
        'ALTA',
        COUNT(*),
        0,
        'Diferencias de volumen no esperadas entre capas equivalentes',
        'dq.vw_control_volumen_entre_capas'
    FROM dq.vw_control_volumen_entre_capas
    WHERE estado <> 'OK'

    UNION ALL
    SELECT
        'DQ004_DUPLICADOS_STAGING_COMPONENTE',
        'staging',
        'staging.funcionarios_modelo_ext',
        'ALTA',
        COUNT(*),
        0,
        'Duplicados por grano de componente en staging enriquecido',
        'dq.vw_duplicados_staging_componente'
    FROM dq.vw_duplicados_staging_componente

    UNION ALL
    SELECT
        'DQ005_DUPLICADOS_CORE_COMPONENTES',
        'core',
        'core.fact_remuneraciones_componentes',
        'ALTA',
        COUNT(*),
        0,
        'Duplicados por hash de componente en CORE',
        'dq.vw_duplicados_core_componentes'
    FROM dq.vw_duplicados_core_componentes

    UNION ALL
    SELECT
        'DQ006_DUPLICADOS_DATAMART_OBT',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'ALTA',
        COUNT(*),
        0,
        'Duplicados del identificador de registro OBT',
        'dq.vw_duplicados_datamart_obt'
    FROM dq.vw_duplicados_datamart_obt

    UNION ALL
    SELECT
        'DQ007_IMPORTES_STAGING_PROBLEMATICOS',
        'staging',
        'staging.funcionarios_modelo_ext',
        'ALTA',
        COUNT(*),
        0,
        'Importes presupuestados/devengados nulos o negativos',
        'dq.vw_staging_importes_problematicos'
    FROM dq.vw_staging_importes_problematicos

    UNION ALL
    SELECT
        'DQ008_REMUNERACIONES_OBT_PROBLEMATICAS',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'MEDIA',
        COUNT(*),
        0,
        'Remuneración total nula, negativa o cero en OBT',
        'dq.vw_datamart_remuneraciones_problematicas'
    FROM dq.vw_datamart_remuneraciones_problematicas

    UNION ALL
    SELECT
        'DQ009_FECHAS_STAGING_INVALIDAS',
        'staging',
        'staging.funcionarios_modelo_ext',
        'MEDIA',
        COUNT(*),
        0,
        'Fechas no parseables o inconsistentes en staging',
        'dq.vw_staging_fechas_invalidas_sospechosas'
    FROM dq.vw_staging_fechas_invalidas_sospechosas

    UNION ALL
    SELECT
        'DQ010_DEMOGRAFIA_OBT_SOSPECHOSA',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'MEDIA',
        COUNT(*),
        0,
        'Edad o antigüedad fuera de rangos esperados',
        'dq.vw_datamart_demografia_sospechosa'
    FROM dq.vw_datamart_demografia_sospechosa

    UNION ALL
    SELECT
        'DQ011_ENRIQUECIMIENTO_STAGING_FALTANTE',
        'staging',
        'staging.funcionarios_modelo_ext',
        'MEDIA',
        COUNT(*),
        0,
        'Faltantes de concepto, OEE, cotización USD o régimen salarial en staging',
        'dq.vw_staging_enriquecimiento_faltante'
    FROM dq.vw_staging_enriquecimiento_faltante

    UNION ALL
    SELECT
        'DQ012_OBT_SIN_OEE',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'ALTA',
        COUNT(*),
        0,
        'Registros OBT sin institución/OEE clasificada',
        'dq.vw_datamart_sin_oee'
    FROM dq.vw_datamart_sin_oee

    UNION ALL
    SELECT
        'DQ013_OBT_SIN_COTIZACION_USD',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'MEDIA',
        COUNT(*),
        0,
        'Registros OBT sin cotización USD o conversión USD',
        'dq.vw_datamart_sin_cotizacion_usd'
    FROM dq.vw_datamart_sin_cotizacion_usd

    UNION ALL
    SELECT
        'DQ014_OBT_SIN_REGIMEN_SALARIAL',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'MEDIA',
        COUNT(*),
        0,
        'Registros OBT sin régimen salarial de referencia',
        'dq.vw_datamart_sin_regimen_salarial'
    FROM dq.vw_datamart_sin_regimen_salarial

    UNION ALL
    SELECT
        'DQ015_DIFERENCIA_TOTAL_COMPONENTES_OBT',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'ALTA',
        COUNT(*),
        0,
        'Diferencia entre remuneración total y suma de componentes OBT',
        'dq.vw_diferencias_total_componentes_obt'
    FROM dq.vw_diferencias_total_componentes_obt

    UNION ALL
    SELECT
        'DQ016_INTEGRIDAD_CORE_CONSOLIDADO_COMPONENTES',
        'core',
        'core.fact_remuneraciones_funcionario_mes',
        'ALTA',
        COUNT(*),
        0,
        'Diferencias entre consolidado CORE y detalle de componentes',
        'dq.vw_integridad_core_funcionario_mes_vs_componentes'
    FROM dq.vw_integridad_core_funcionario_mes_vs_componentes

    UNION ALL
    SELECT
        'DQ017_COMPONENTES_NO_MAPEADOS',
        'datamart',
        'datamart.det_remuneraciones_componentes_bi',
        'MEDIA',
        COUNT(*),
        0,
        'Componentes u objetos de gasto sin clasificación analítica suficiente',
        'dq.vw_componentes_no_mapeados_o_sospechosos'
    FROM dq.vw_componentes_no_mapeados_o_sospechosos

    UNION ALL
    SELECT
        'DQ018_COMPOSICION_PORCENTUAL_INVALIDA',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'ALTA',
        COUNT(*),
        0,
        'La suma de participaciones porcentuales no aproxima 100%',
        'dq.vw_obt_composicion_porcentual_invalida'
    FROM dq.vw_obt_composicion_porcentual_invalida

    UNION ALL
    SELECT
        'DQ019_OUTLIERS_IQR_GLOBAL_MENSUAL',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'INFORMATIVA',
        COUNT(*),
        0,
        'Outliers salariales detectados por IQR global mensual',
        'dq.vw_outliers_salariales_iqr_global_mensual'
    FROM dq.vw_outliers_salariales_iqr_global_mensual

    UNION ALL
    SELECT
        'DQ020_OUTLIERS_IQR_INSTITUCIONAL',
        'datamart',
        'datamart.obt_remuneraciones_funcionarios_publicos',
        'INFORMATIVA',
        COUNT(*),
        0,
        'Outliers salariales marcados por regla IQR institucional en CORE/OBT',
        'dq.vw_outliers_salariales_iqr_institucional'
    FROM dq.vw_outliers_salariales_iqr_institucional

    UNION ALL
    SELECT
        'DQ021_CAMPOS_LABORALES_NO_DISPONIBLES',
        'raw/staging/datamart',
        'cargo/funcion/linea/categoria',
        'INFORMATIVA',
        COUNT(*),
        0,
        'Campos no disponibles por diseño en la fuente principal; no deben usarse como dimensiones reales',
        'dq.vw_campos_no_disponibles_por_diseno'
    FROM dq.vw_campos_no_disponibles_por_diseno
)
SELECT
    CURRENT_TIMESTAMP AS run_ts,
    check_id,
    capa,
    objeto,
    severidad,
    registros_afectados,
    umbral_permitido,
    CASE
        WHEN severidad = 'INFORMATIVA' THEN 'INFO'
        WHEN registros_afectados <= umbral_permitido THEN 'OK'
        ELSE 'REVISAR'
    END AS estado,
    descripcion,
    consulta_detalle
FROM checks;

-- ============================================================
-- 13) Resúmenes para consumo humano y BI
-- ============================================================
CREATE OR REPLACE VIEW dq.vw_resumen_calidad AS
SELECT
    run_ts,
    check_id,
    capa,
    objeto,
    severidad,
    registros_afectados,
    umbral_permitido,
    estado,
    descripcion,
    consulta_detalle
FROM dq.resultados_checks
ORDER BY
    CASE severidad
        WHEN 'ALTA' THEN 1
        WHEN 'MEDIA' THEN 2
        WHEN 'BAJA' THEN 3
        WHEN 'INFORMATIVA' THEN 4
        ELSE 5
    END,
    CASE estado
        WHEN 'REVISAR' THEN 1
        WHEN 'OK' THEN 2
        WHEN 'INFO' THEN 3
        ELSE 4
    END,
    registros_afectados DESC,
    check_id;

CREATE OR REPLACE VIEW dq.vw_reporte_ejecutivo_calidad AS
SELECT
    COUNT(*) AS total_checks,
    SUM(CASE WHEN estado = 'OK' THEN 1 ELSE 0 END) AS checks_ok,
    SUM(CASE WHEN estado = 'REVISAR' THEN 1 ELSE 0 END) AS checks_revisar,
    SUM(CASE WHEN estado = 'INFO' THEN 1 ELSE 0 END) AS checks_informativos,
    SUM(CASE WHEN severidad = 'ALTA' AND estado = 'REVISAR' THEN 1 ELSE 0 END) AS checks_alta_revisar,
    SUM(CASE WHEN severidad = 'MEDIA' AND estado = 'REVISAR' THEN 1 ELSE 0 END) AS checks_media_revisar,
    SUM(registros_afectados) AS total_hallazgos_reportados,
    CASE
        WHEN SUM(CASE WHEN severidad = 'ALTA' AND estado = 'REVISAR' THEN 1 ELSE 0 END) > 0 THEN 'NO_APTO_PARA_PUBLICACION_SIN_REVISION'
        WHEN SUM(CASE WHEN severidad = 'MEDIA' AND estado = 'REVISAR' THEN 1 ELSE 0 END) > 0 THEN 'APTO_CON_OBSERVACIONES'
        ELSE 'APTO'
    END AS estado_general_calidad
FROM dq.resultados_checks;

CREATE OR REPLACE VIEW dq.vw_checks_revisar AS
SELECT *
FROM dq.vw_resumen_calidad
WHERE estado = 'REVISAR';

CREATE OR REPLACE VIEW dq.vw_checks_informativos AS
SELECT *
FROM dq.vw_resumen_calidad
WHERE estado = 'INFO';

-- ============================================================
-- 14) Auditoría de ejecución
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '06_data_quality_checks.sql',
    'dq',
    'resultados_checks',
    CASE
        WHEN (SELECT checks_alta_revisar FROM dq.vw_reporte_ejecutivo_calidad) > 0 THEN 'warning'
        ELSE 'ok'
    END,
    (SELECT COUNT(*) FROM dq.resultados_checks),
    'Checks de calidad reconstruidos para RAW, STAGING, CORE y DATAMART con concepto derivado desde clasificador_gastos y cargo/funcion no disponibles por diseño';
