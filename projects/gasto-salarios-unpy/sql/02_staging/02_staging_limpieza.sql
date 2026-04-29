-- ============================================================
-- 02_staging_limpieza.sql
-- Capa STAGING: tipado, limpieza, normalización y preparación de joins
-- ============================================================

-- ============================================================
-- 1) Funcionarios modelo: base principal del modelo analítico
-- ============================================================
CREATE OR REPLACE TABLE staging.funcionarios_modelo AS
WITH src AS (
    SELECT *
    FROM raw.funcionarios_modelo_src
),
typed AS (
    SELECT
        to_integer_py(anho) AS anho,
        to_integer_py(mes) AS mes,
        CASE
            WHEN to_integer_py(anho) BETWEEN 1900 AND 2100
             AND to_integer_py(mes) BETWEEN 1 AND 12
            THEN make_date(to_integer_py(anho), to_integer_py(mes), 1)
            ELSE NULL
        END AS fecha_periodo,

        to_integer_py(nivel) AS nivel,
        normalizar_texto(descripcion_nivel) AS descripcion_nivel,
        to_integer_py(entidad) AS entidad,
        normalizar_texto(descripcion_entidad) AS descripcion_entidad,
        to_integer_py(oee) AS oee,
        normalizar_texto(descripcion_oee) AS descripcion_oee,

        normalizar_texto(documento) AS documento,
        normalizar_texto(nombres) AS nombres,
        normalizar_texto(apellidos) AS apellidos,

        normalizar_texto(estado) AS estado,
        to_integer_py(anho_ingreso) AS anho_ingreso,
        normalizar_texto(sexo) AS sexo,
        normalizar_texto(discapacidad) AS discapacidad,
        normalizar_texto(tipo_discapacidad) AS tipo_discapacidad,

        to_integer_py(fuente_financiamiento) AS fuente_financiamiento,
        to_integer_py(objeto_gasto) AS objeto_gasto,
        normalizar_texto(concepto) AS concepto,
        normalizar_texto(linea) AS linea,
        to_integer_py(linea) AS linea_codigo,
        normalizar_texto(categoria) AS categoria,

        to_decimal_py(presupuestado) AS presupuestado_gs,
        to_decimal_py(devengado) AS devengado_gs,

        fecha_nacimiento AS fecha_nacimiento_raw,
        to_date_sfp(fecha_nacimiento) AS fecha_nacimiento,
        fecha_acto AS fecha_acto_raw,
        to_date_sfp(fecha_acto) AS fecha_acto,

        CURRENT_TIMESTAMP AS fecha_carga,
        'funcionarios_2025_3_utf8_sample10k_modelo.csv' AS fuente_archivo,

        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
            COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
            COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
            COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
            COALESCE(CAST(documento AS VARCHAR), '') || '|' ||
            COALESCE(CAST(objeto_gasto AS VARCHAR), '') || '|' ||
            COALESCE(CAST(concepto AS VARCHAR), '') || '|' ||
            COALESCE(CAST(linea AS VARCHAR), '') || '|' ||
            COALESCE(CAST(categoria AS VARCHAR), '') || '|' ||
            COALESCE(CAST(presupuestado AS VARCHAR), '') || '|' ||
            COALESCE(CAST(devengado AS VARCHAR), '')
        ) AS hash_registro
    FROM src
)
SELECT *
FROM typed;

-- ============================================================
-- 2) Funcionarios origen: fuente auxiliar para recuperar cargo/función
--
-- El archivo modelo no contiene cargo ni función. La fuente origen sí.
-- Se normaliza para enriquecer el modelo sin reemplazar la base principal.
-- ============================================================
CREATE OR REPLACE TABLE staging.funcionarios_origen AS
WITH src AS (
    SELECT *
    FROM raw.funcionarios_origen_src
),
typed AS (
    SELECT
        to_integer_py(anho) AS anho,
        to_integer_py(mes) AS mes,
        CASE
            WHEN to_integer_py(anho) BETWEEN 1900 AND 2100
             AND to_integer_py(mes) BETWEEN 1 AND 12
            THEN make_date(to_integer_py(anho), to_integer_py(mes), 1)
            ELSE NULL
        END AS fecha_periodo,

        to_integer_py(nivel) AS nivel,
        normalizar_texto(descripcion_nivel) AS descripcion_nivel,
        to_integer_py(entidad) AS entidad,
        normalizar_texto(descripcion_entidad) AS descripcion_entidad,
        to_integer_py(oee) AS oee,
        normalizar_texto(descripcion_oee) AS descripcion_oee,

        normalizar_texto(documento) AS documento,
        normalizar_texto(nombres) AS nombres,
        normalizar_texto(apellidos) AS apellidos,

        normalizar_texto(funcion) AS funcion,
        normalizar_texto(cargo) AS cargo,
        normalizar_texto(carga_horaria) AS carga_horaria,

        normalizar_texto(estado) AS estado,
        to_integer_py(anho_ingreso) AS anho_ingreso,
        normalizar_texto(sexo) AS sexo,
        normalizar_texto(discapacidad) AS discapacidad,
        normalizar_texto(tipo_discapacidad) AS tipo_discapacidad,

        to_integer_py(fuente_financiamiento) AS fuente_financiamiento,
        to_integer_py(objeto_gasto) AS objeto_gasto,
        normalizar_texto(concepto) AS concepto,
        normalizar_texto(linea) AS linea,
        to_integer_py(linea) AS linea_codigo,
        normalizar_texto(categoria) AS categoria,

        to_decimal_py(presupuestado) AS presupuestado_gs,
        to_decimal_py(devengado) AS devengado_gs,

        normalizar_texto(movimiento) AS movimiento,
        normalizar_texto(lugar) AS lugar,
        to_date_sfp(fecha_nacimiento) AS fecha_nacimiento,
        to_timestamp_sfp(fec_ult_modif) AS fec_ult_modif_ts,
        NULLIF(TRIM(uri), '') AS uri,
        to_date_sfp(fecha_acto) AS fecha_acto,
        normalizar_texto(correo) AS correo,
        normalizar_texto(profesion) AS profesion,
        normalizar_texto(motivo_movimiento) AS motivo_movimiento,

        CURRENT_TIMESTAMP AS fecha_carga,
        'funcionarios_2025_3_utf8_sample10k.csv' AS fuente_archivo,

        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
            COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
            COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
            COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
            COALESCE(CAST(documento AS VARCHAR), '') || '|' ||
            COALESCE(CAST(objeto_gasto AS VARCHAR), '') || '|' ||
            COALESCE(CAST(concepto AS VARCHAR), '') || '|' ||
            COALESCE(CAST(linea AS VARCHAR), '') || '|' ||
            COALESCE(CAST(categoria AS VARCHAR), '') || '|' ||
            COALESCE(CAST(presupuestado AS VARCHAR), '') || '|' ||
            COALESCE(CAST(devengado AS VARCHAR), '')
        ) AS hash_registro
    FROM src
)
SELECT *
FROM typed;

-- ============================================================
-- 3) Funcionarios modelo enriquecido con cargo/función del origen
-- ============================================================
CREATE OR REPLACE TABLE staging.funcionarios_modelo_ext AS
WITH origen_dedup AS (
    SELECT *
    FROM (
        SELECT
            o.*,
            ROW_NUMBER() OVER (
                PARTITION BY
                    anho, mes, nivel, entidad, oee, documento,
                    objeto_gasto, concepto, linea, categoria,
                    presupuestado_gs, devengado_gs
                ORDER BY fec_ult_modif_ts DESC NULLS LAST, fecha_carga DESC
            ) AS rn
        FROM staging.funcionarios_origen o
    )
    WHERE rn = 1
)
SELECT
    m.*,
    o.funcion,
    o.cargo,
    o.carga_horaria,
    o.movimiento,
    o.lugar,
    o.fec_ult_modif_ts,
    o.uri,
    o.correo,
    o.profesion,
    o.motivo_movimiento
FROM staging.funcionarios_modelo m
LEFT JOIN origen_dedup o
  ON m.anho = o.anho
 AND m.mes = o.mes
 AND m.nivel = o.nivel
 AND m.entidad = o.entidad
 AND m.oee = o.oee
 AND m.documento = o.documento
 AND COALESCE(m.objeto_gasto, -1) = COALESCE(o.objeto_gasto, -1)
 AND COALESCE(m.concepto, '') = COALESCE(o.concepto, '')
 AND COALESCE(m.linea, '') = COALESCE(o.linea, '')
 AND COALESCE(m.categoria, '') = COALESCE(o.categoria, '')
 AND COALESCE(m.presupuestado_gs, 0) = COALESCE(o.presupuestado_gs, 0)
 AND COALESCE(m.devengado_gs, 0) = COALESCE(o.devengado_gs, 0);

-- ============================================================
-- 4) Clasificador de gastos
-- ============================================================
CREATE OR REPLACE TABLE staging.clasificador_gastos AS
SELECT
    to_integer_py(grupo_codigo) AS grupo_codigo,
    normalizar_texto(grupo_descripcion) AS grupo_descripcion,
    to_integer_py(subgrupo_codigo) AS subgrupo_codigo,
    normalizar_texto(subgrupo_descripcion) AS subgrupo_descripcion,
    to_integer_py(objeto_gasto_codigo) AS objeto_gasto_codigo,
    normalizar_texto(objeto_gasto_descripcion) AS objeto_gasto_descripcion,
    to_integer_py(control_financiero_codigo) AS control_financiero_codigo,
    normalizar_texto(control_financiero_descripcion) AS control_financiero_descripcion,
    normalizar_texto(clasificacion_gasto_descripcion) AS clasificacion_gasto_descripcion,
    CURRENT_TIMESTAMP AS fecha_carga,
    'clasificador_gastos_utf8.csv' AS fuente_archivo
FROM raw.clasificador_gastos_src;

-- ============================================================
-- 5) Clasificador OEE
--
-- Se extraen los campos necesarios desde linea_raw.
-- Los campos posteriores a descripcion_corta pueden contener comas en dirección,
-- por eso no se intentan parsear de forma completa en esta versión.
-- ============================================================
CREATE OR REPLACE TABLE staging.clasificador_oee AS
WITH src AS (
    SELECT
        TRIM(REGEXP_REPLACE(REPLACE(linea_raw, CHR(65279), ''), '^"|"$', '', 'g')) AS linea_limpia
    FROM raw.clasificador_oee_src
),
filtrado AS (
    SELECT *
    FROM src
    WHERE linea_limpia IS NOT NULL
      AND linea_limpia <> ''
      AND LOWER(SUBSTR(linea_limpia, 1, 12)) <> 'codigo_nivel'
)
SELECT
    to_integer_py(split_part(linea_limpia, ',', 1)) AS codigo_nivel,
    normalizar_texto(split_part(linea_limpia, ',', 2)) AS descripcion_nivel,
    to_integer_py(split_part(linea_limpia, ',', 3)) AS codigo_entidad,
    normalizar_texto(split_part(linea_limpia, ',', 4)) AS descripcion_entidad,
    to_integer_py(split_part(linea_limpia, ',', 5)) AS codigo_oee,
    normalizar_texto(split_part(linea_limpia, ',', 6)) AS descripcion_oee,
    normalizar_texto(split_part(linea_limpia, ',', 7)) AS descripcion_corta,
    REGEXP_EXTRACT(linea_limpia, '(http://datos\.sfp\.gov\.py/id/oee/[0-9]+/[0-9]+/[0-9]+)$', 1) AS uri_oee,
    CURRENT_TIMESTAMP AS fecha_carga,
    'clasificador_oee_utf8.csv' AS fuente_archivo
FROM filtrado;

-- ============================================================
-- 6) Cotización mensual USD
--
-- Supuesto del archivo:
--   anho, mes, cotizacion_usd
--
-- Si el CSV trae columnas diferentes, ajustar aquí:
--   - cambiar cotizacion_usd por venta, compra, promedio, valor, etc.
--   - mantener el resultado final como cotizacion_usd_promedio.
-- ============================================================
CREATE OR REPLACE TABLE staging.cotizacion_usd_mensual AS
SELECT
    to_integer_py(anho) AS anho,
    to_integer_py(mes) AS mes,
    CASE
        WHEN to_integer_py(anho) BETWEEN 1900 AND 2100
         AND to_integer_py(mes) BETWEEN 1 AND 12
        THEN make_date(to_integer_py(anho), to_integer_py(mes), 1)
        ELSE NULL
    END AS fecha_periodo,
    to_decimal_py(cotizacion_usd) AS cotizacion_usd_promedio,
    CURRENT_TIMESTAMP AS fecha_carga,
    'cotizacion_usd_mensual.csv' AS fuente_archivo
FROM raw.cotizacion_usd_mensual_src;

-- ============================================================
-- 7) Régimen salarial Paraguay
-- ============================================================
CREATE OR REPLACE TABLE staging.regimen_salarial_py AS
SELECT
    to_integer_py(anho) AS anho,
    to_integer_py(mes) AS mes,
    CASE
        WHEN to_integer_py(anho) BETWEEN 1900 AND 2100
         AND to_integer_py(mes) BETWEEN 1 AND 12
        THEN make_date(to_integer_py(anho), to_integer_py(mes), 1)
        ELSE NULL
    END AS fecha_regimen,
    normalizar_texto(mes_nombre) AS mes_nombre,
    to_decimal_py(salario_minimo_mensual) AS salario_minimo_mensual_gs,
    to_decimal_py(salario_por_dia) AS salario_por_dia_gs,
    to_decimal_py(jornal_por_dia) AS jornal_por_dia_gs,
    to_decimal_py(salario_por_hora) AS salario_por_hora_gs,
    to_decimal_py(salario_nocturno_mensual) AS salario_nocturno_mensual_gs,
    to_decimal_py(salario_nocturno_por_dia) AS salario_nocturno_por_dia_gs,
    to_decimal_py(jornal_nocturno_por_dia) AS jornal_nocturno_por_dia_gs,
    to_decimal_py(salario_nocturno_por_hora) AS salario_nocturno_por_hora_gs,
    to_decimal_py(asignacion_familiar_por_hijo) AS asignacion_familiar_por_hijo_gs,
    to_decimal_py(aporte_patronal) AS aporte_patronal_gs,
    to_decimal_py(aporte_empleado) AS aporte_empleado_gs,
    to_decimal_py(salario_neto) AS salario_neto_gs,
    CASE
        WHEN LOWER(TRIM(CAST(vigente AS VARCHAR))) IN ('true', 't', '1', 'si', 'sí', 'yes') THEN TRUE
        WHEN LOWER(TRIM(CAST(vigente AS VARCHAR))) IN ('false', 'f', '0', 'no') THEN FALSE
        ELSE NULL
    END AS vigente,
    CURRENT_TIMESTAMP AS fecha_carga,
    'regimen_salarial_py.csv' AS fuente_archivo
FROM raw.regimen_salarial_py_src;

-- ============================================================
-- 8) Vistas de control staging
-- ============================================================
CREATE OR REPLACE VIEW staging.vw_control_staging_registros AS
SELECT 'staging.funcionarios_modelo' AS tabla, COUNT(*) AS total_registros FROM staging.funcionarios_modelo
UNION ALL
SELECT 'staging.funcionarios_origen' AS tabla, COUNT(*) AS total_registros FROM staging.funcionarios_origen
UNION ALL
SELECT 'staging.funcionarios_modelo_ext' AS tabla, COUNT(*) AS total_registros FROM staging.funcionarios_modelo_ext
UNION ALL
SELECT 'staging.clasificador_gastos' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_gastos
UNION ALL
SELECT 'staging.clasificador_oee' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_oee
UNION ALL
SELECT 'staging.cotizacion_usd_mensual' AS tabla, COUNT(*) AS total_registros FROM staging.cotizacion_usd_mensual
UNION ALL
SELECT 'staging.regimen_salarial_py' AS tabla, COUNT(*) AS total_registros FROM staging.regimen_salarial_py;

-- ============================================================
-- 9) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '02_staging_limpieza.sql', 'staging', 'staging_tables', 'ok', NULL,
       'Tablas staging tipadas, normalizadas y enriquecidas';
