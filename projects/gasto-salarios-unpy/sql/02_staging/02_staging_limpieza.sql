-- ============================================================
-- 02_staging_limpieza.sql
-- Proyecto: gasto-salarios-unpy
-- Capa: STAGING
-- Motor: DuckDB
-- Autor académico: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   1) Tipar y normalizar la fuente principal raw.funcionarios_modelo_src.
--   2) Normalizar clasificadores externos.
--   3) Enriquecer la fuente principal con:
--        - concepto_remunerativo desde raw.clasificador_gastos_src
--          mediante objeto_gasto = objeto_gasto_codigo.
--        - descripcion_nivel, descripcion_entidad y descripcion_oee
--          desde raw.clasificador_oee_src mediante nivel/entidad/oee.
--        - cotizacion mensual USD y régimen salarial mensual.
--   4) Preparar claves de unión limpias para la capa core.
--   5) Registrar controles básicos de staging.
--
-- Aclaración técnica importante:
--   raw.funcionarios_modelo_src NO contiene las columnas:
--     cargo, funcion, concepto, linea, categoria.
--
--   Por diseño, este script NO intenta obtener cargo ni funcion desde otra
--   fuente auxiliar. Si se requiere analizar cargo/función, debe incorporarse
--   una fuente confiable adicional en RAW y documentarse como nuevo linaje.
--
--   concepto se deriva desde clasificador_gastos_src.objeto_gasto_descripcion.
--   con scripts posteriores que aún puedan referenciarlas, pero NO deben
--   interpretarse como datos disponibles en la fuente principal.
--
-- Dependencias:
--   Ejecutar antes:
--     sql/00_setup/00_create_schemas.sql
--     sql/01_raw/01_raw_ingesta.sql
--
-- Tablas RAW esperadas:
--   raw.funcionarios_modelo_src
--   raw.clasificador_gastos_src
--   raw.clasificador_oee_src
--   raw.cotizacion_usd_mensual_src
--   raw.regimen_salarial_py_src
--
-- Tablas STAGING generadas:
--   staging.funcionarios_modelo
--   staging.clasificador_gastos
--   staging.clasificador_oee
--   staging.cotizacion_usd_mensual
--   staging.regimen_salarial_py
--   staging.funcionarios_modelo_ext
--   staging.funcionarios_modelo_enriquecido
--
-- Vistas/Tables de control:
--   staging.vw_control_staging_registros
--   staging.vw_control_staging_calidad_basica
--   staging.vw_control_staging_enriquecimiento
--   audit.validacion_staging_cantidad_registros
-- ============================================================

-- ============================================================
-- 0) Nota de exploración recomendada
-- ============================================================
-- Consultas útiles si se necesita verificar el esquema antes de ejecutar:
--
-- DESCRIBE raw.funcionarios_modelo_src;
-- DESCRIBE raw.clasificador_gastos_src;
-- DESCRIBE raw.clasificador_oee_src;
-- DESCRIBE raw.cotizacion_usd_mensual_src;
-- DESCRIBE raw.regimen_salarial_py_src;
--
-- SELECT * FROM raw.funcionarios_modelo_src LIMIT 10;
-- SELECT * FROM raw.clasificador_gastos_src LIMIT 10;
-- SELECT * FROM raw.clasificador_oee_src LIMIT 10;
-- SELECT * FROM raw.cotizacion_usd_mensual_src LIMIT 10;
-- SELECT * FROM raw.regimen_salarial_py_src LIMIT 10;

-- ============================================================
-- 1) Clasificador de gastos normalizado
--
-- Grano esperado:
--   una fila por objeto_gasto_codigo.
--
-- Uso en el modelo:
--   objeto_gasto_codigo permite obtener objeto_gasto_descripcion, que será
--   usado como concepto_remunerativo en la fuente principal enriquecida.
-- ============================================================
CREATE OR REPLACE TABLE staging.clasificador_gastos AS
WITH src AS (
    SELECT
        grupo_codigo,
        grupo_descripcion,
        subgrupo_codigo,
        subgrupo_descripcion,
        objeto_gasto_codigo,
        objeto_gasto_descripcion,
        control_financiero_codigo,
        control_financiero_descripcion,
        clasificacion_gasto_descripcion
    FROM raw.clasificador_gastos_src
), typed AS (
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
        'clasificador_gastos_utf8.csv' AS fuente_archivo,
        md5(
            COALESCE(CAST(objeto_gasto_codigo AS VARCHAR), '') || '|' ||
            COALESCE(CAST(objeto_gasto_descripcion AS VARCHAR), '') || '|' ||
            COALESCE(CAST(subgrupo_codigo AS VARCHAR), '') || '|' ||
            COALESCE(CAST(grupo_codigo AS VARCHAR), '')
        ) AS hash_clasificador_gasto
    FROM src
)
SELECT *
FROM typed;

-- Tabla deduplicada para joins seguros por objeto de gasto.
CREATE OR REPLACE TABLE staging.clasificador_gastos_dedup AS
SELECT * EXCLUDE (rn)
FROM (
    SELECT
        g.*,
        ROW_NUMBER() OVER (
            PARTITION BY objeto_gasto_codigo
            ORDER BY
                CASE WHEN objeto_gasto_descripcion IS NOT NULL THEN 0 ELSE 1 END,
                grupo_codigo,
                subgrupo_codigo
        ) AS rn
    FROM staging.clasificador_gastos g
    WHERE objeto_gasto_codigo IS NOT NULL
)
WHERE rn = 1;

-- ============================================================
-- 2) Clasificador OEE normalizado
--
-- Grano esperado:
--   codigo_nivel + codigo_entidad + codigo_oee.
--
-- Uso en el modelo:
--   Permite obtener descripciones institucionales para nivel, entidad y OEE.
-- ============================================================
CREATE OR REPLACE TABLE staging.clasificador_oee AS
WITH src AS (
    SELECT
        codigo_nivel,
        descripcion_nivel,
        codigo_entidad,
        descripcion_entidad,
        codigo_oee,
        descripcion_oee,
        descripcion_corta
    FROM raw.clasificador_oee_src
), typed AS (
    SELECT
        to_integer_py(codigo_nivel) AS codigo_nivel,
        normalizar_texto(descripcion_nivel) AS descripcion_nivel,
        to_integer_py(codigo_entidad) AS codigo_entidad,
        normalizar_texto(descripcion_entidad) AS descripcion_entidad,
        to_integer_py(codigo_oee) AS codigo_oee,
        normalizar_texto(descripcion_oee) AS descripcion_oee,
        normalizar_texto(descripcion_corta) AS descripcion_corta,
        CAST(NULL AS VARCHAR) AS uri_oee,
        CURRENT_TIMESTAMP AS fecha_carga,
        'clasificador_oee_utf8.csv' AS fuente_archivo,
        md5(
            COALESCE(CAST(codigo_nivel AS VARCHAR), '') || '|' ||
            COALESCE(CAST(codigo_entidad AS VARCHAR), '') || '|' ||
            COALESCE(CAST(codigo_oee AS VARCHAR), '')
        ) AS hash_oee
    FROM src
)
SELECT *
FROM typed;

-- Tabla deduplicada para joins seguros por nivel/entidad/oee.
CREATE OR REPLACE TABLE staging.clasificador_oee_dedup AS
SELECT * EXCLUDE (rn)
FROM (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY codigo_nivel, codigo_entidad, codigo_oee
            ORDER BY
                CASE WHEN descripcion_oee IS NOT NULL THEN 0 ELSE 1 END,
                descripcion_oee
        ) AS rn
    FROM staging.clasificador_oee o
    WHERE codigo_nivel IS NOT NULL
      AND codigo_entidad IS NOT NULL
      AND codigo_oee IS NOT NULL
)
WHERE rn = 1;

-- ============================================================
-- 3) Cotización mensual USD normalizada
--
-- Archivo observado:
--   fecha_cierre, periodo, anho, mes, cotizacion, periodo_id
--
-- Resultado estándar:
--   cotizacion_usd_promedio
-- ============================================================
CREATE OR REPLACE TABLE staging.cotizacion_usd_mensual AS
WITH src AS (
    SELECT
        fecha_cierre,
        periodo,
        anho,
        mes,
        cotizacion,
        periodo_id
    FROM raw.cotizacion_usd_mensual_src
), typed AS (
    SELECT
        to_integer_py(anho) AS anho,
        to_integer_py(mes) AS mes,
        CASE
            WHEN to_integer_py(anho) BETWEEN 1900 AND 2100
             AND to_integer_py(mes) BETWEEN 1 AND 12
            THEN make_date(to_integer_py(anho), to_integer_py(mes), 1)
            ELSE NULL
        END AS fecha_periodo,
        to_date_sfp(fecha_cierre) AS fecha_cierre,
        NULLIF(TRIM(CAST(periodo AS VARCHAR)), '') AS periodo,
        to_decimal_py(cotizacion) AS cotizacion_usd_promedio,
        to_integer_py(periodo_id) AS periodo_id,
        CURRENT_TIMESTAMP AS fecha_carga,
        'cotizacion_usd_mensual_utf8.csv' AS fuente_archivo,
        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
            COALESCE(CAST(cotizacion AS VARCHAR), '')
        ) AS hash_cotizacion
    FROM src
)
SELECT *
FROM typed;

CREATE OR REPLACE TABLE staging.cotizacion_usd_mensual_dedup AS
SELECT * EXCLUDE (rn)
FROM (
    SELECT
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY anho, mes
            ORDER BY fecha_cierre DESC NULLS LAST, cotizacion_usd_promedio DESC NULLS LAST
        ) AS rn
    FROM staging.cotizacion_usd_mensual c
    WHERE anho IS NOT NULL
      AND mes IS NOT NULL
)
WHERE rn = 1;

-- ============================================================
-- 4) Régimen salarial Paraguay normalizado
-- ============================================================
CREATE OR REPLACE TABLE staging.regimen_salarial_py AS
WITH src AS (
    SELECT
        anho,
        mes,
        mes_nombre,
        salario_minimo_mensual,
        salario_por_dia,
        jornal_por_dia,
        salario_por_hora,
        salario_nocturno_mensual,
        salario_nocturno_por_dia,
        jornal_nocturno_por_dia,
        salario_nocturno_por_hora,
        asignacion_familiar_por_hijo,
        aporte_patronal,
        aporte_empleado,
        salario_neto,
        vigente
    FROM raw.regimen_salarial_py_src
), typed AS (
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
            WHEN LOWER(TRIM(CAST(vigente AS VARCHAR))) IN ('true', 't', '1', 'si', 'sí', 's', 'yes', 'y') THEN TRUE
            WHEN LOWER(TRIM(CAST(vigente AS VARCHAR))) IN ('false', 'f', '0', 'no', 'n') THEN FALSE
            ELSE NULL
        END AS vigente,
        CURRENT_TIMESTAMP AS fecha_carga,
        'regimen_salarial_py_utf8.csv' AS fuente_archivo,
        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
            COALESCE(CAST(salario_minimo_mensual AS VARCHAR), '')
        ) AS hash_regimen_salarial
    FROM src
)
SELECT *
FROM typed;

CREATE OR REPLACE TABLE staging.regimen_salarial_py_dedup AS
SELECT * EXCLUDE (rn)
FROM (
    SELECT
        r.*,
        ROW_NUMBER() OVER (
            PARTITION BY anho, mes
            ORDER BY fecha_regimen DESC NULLS LAST, vigente DESC NULLS LAST
        ) AS rn
    FROM staging.regimen_salarial_py r
    WHERE anho IS NOT NULL
      AND mes IS NOT NULL
)
WHERE rn = 1;

-- ============================================================
-- 5) Fuente principal: funcionarios_modelo normalizado
--
-- Grano de entrada:
--   anho + mes + nivel + entidad + oee + documento + objeto_gasto
--   con potenciales repeticiones según la fuente.
-- ============================================================
CREATE OR REPLACE TABLE staging.funcionarios_modelo AS
WITH src AS (
    SELECT
        anho,
        mes,
        nivel,
        entidad,
        oee,
        documento,
        nombres,
        apellidos,
        estado,
        anho_ingreso,
        sexo,
        discapacidad,
        tipo_discapacidad,
        fuente_financiamiento,
        objeto_gasto,
        presupuestado,
        devengado,
        fecha_nacimiento,
        fecha_acto
    FROM raw.funcionarios_modelo_src
), typed AS (
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
        to_integer_py(entidad) AS entidad,
        to_integer_py(oee) AS oee,
        normalizar_texto(documento) AS documento,
        md5(COALESCE(normalizar_texto(documento), '')) AS documento_hash,
        normalizar_texto(nombres) AS nombres,
        normalizar_texto(apellidos) AS apellidos,
        normalizar_texto(estado) AS estado,
        to_integer_py(anho_ingreso) AS anho_ingreso,
        normalizar_texto(sexo) AS sexo,
        normalizar_texto(discapacidad) AS discapacidad,
        normalizar_texto(tipo_discapacidad) AS tipo_discapacidad,
        to_integer_py(fuente_financiamiento) AS fuente_financiamiento,
        to_integer_py(objeto_gasto) AS objeto_gasto,
        to_decimal_py(presupuestado) AS presupuestado_gs,
        to_decimal_py(devengado) AS devengado_gs,
        COALESCE(to_decimal_py(devengado), to_decimal_py(presupuestado), 0) AS monto_base_calculo_gs,
        fecha_nacimiento AS fecha_nacimiento_raw,
        to_date_sfp(fecha_nacimiento) AS fecha_nacimiento,
        fecha_acto AS fecha_acto_raw,
        to_date_sfp(fecha_acto) AS fecha_acto,
        CURRENT_TIMESTAMP AS fecha_carga,
        'funcionarios_2025_*_utf8.csv' AS fuente_archivo,
        md5(
            COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
            COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
            COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
            COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
            COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
            COALESCE(CAST(documento AS VARCHAR), '') || '|' ||
            COALESCE(CAST(objeto_gasto AS VARCHAR), '') || '|' ||
            COALESCE(CAST(presupuestado AS VARCHAR), '') || '|' ||
            COALESCE(CAST(devengado AS VARCHAR), '') || '|' ||
            COALESCE(CAST(fecha_acto AS VARCHAR), '')
        ) AS hash_registro
    FROM src
)
SELECT *
FROM typed;


-- ============================================================
-- 6) Fuente principal enriquecida
--
-- Esta tabla es la salida principal de STAGING para la capa CORE.
--
-- Enriquecimientos:
--   - descripcion_nivel, descripcion_entidad, descripcion_oee desde OEE.
--   - concepto / concepto_remunerativo desde objeto_gasto_descripcion.
--   - metadatos de gasto: grupo, subgrupo, clasificación y control financiero.
--   - cotización USD mensual.
--   - régimen salarial exacto por anho/mes, cuando exista.
--
-- Nota sobre régimen salarial:
--   En esta capa se une por igualdad anho/mes. Si en CORE se desea aplicar
--   regla de "último régimen vigente anterior o igual al periodo", puede
--   resolverse con una tabla dimensional de régimen mensual aplicable.
-- ============================================================
CREATE OR REPLACE TABLE staging.funcionarios_modelo_ext AS
SELECT
    f.anho,
    f.mes,
    f.fecha_periodo,
	--
    f.nivel,
    o.descripcion_nivel,
    f.entidad,
    o.descripcion_entidad,
    f.oee,
    o.descripcion_oee,
    o.descripcion_corta AS descripcion_corta_oee,
	--
    f.documento,
    f.documento_hash,
    f.nombres,
    f.apellidos,
    f.estado,
    f.anho_ingreso,
    f.sexo,
    f.discapacidad,
    --COALESCE(f.tipo_discapacidad, 'NO APLICA') AS tipo_discapacidad,
   	CASE
	    	WHEN (f.tipo_discapacidad IS NULL AND f.discapacidad = 'NO') THEN 'NA'
	    	WHEN (f.tipo_discapacidad IS NULL AND f.discapacidad = 'SI') THEN 'DESCONOCIDO'
    		ELSE 'NA'
    END AS tipo_discapacidad,
    f.fuente_financiamiento,
	--
    f.objeto_gasto,
    g.objeto_gasto_descripcion,
    g.objeto_gasto_descripcion AS concepto,
    g.objeto_gasto_descripcion AS concepto_remunerativo,
    g.subgrupo_codigo,
    g.subgrupo_descripcion,
    g.grupo_codigo,
    g.grupo_descripcion,
    g.control_financiero_codigo,
    g.control_financiero_descripcion,
    g.clasificacion_gasto_descripcion,
    -- Campos no disponibles en raw.funcionarios_modelo_src.
    -- Se mantienen como NULL técnico para evitar quiebres temporales en scripts
    -- downstream, pero no deben usarse como dimensiones analíticas hasta contar
    -- con una fuente confiable.
    CAST(NULL AS VARCHAR) AS cargo,
    CAST(NULL AS VARCHAR) AS funcion,
    CAST(NULL AS VARCHAR) AS carga_horaria,
    CAST(NULL AS VARCHAR) AS linea,
    CAST(NULL AS INTEGER) AS linea_codigo,
    CAST(NULL AS VARCHAR) AS categoria,
    CAST(NULL AS VARCHAR) AS movimiento,
    CAST(NULL AS VARCHAR) AS lugar,
    CAST(NULL AS TIMESTAMP) AS fec_ult_modif_ts,
    CAST(NULL AS VARCHAR) AS uri,
    CAST(NULL AS VARCHAR) AS correo,
    CAST(NULL AS VARCHAR) AS profesion,
    CAST(NULL AS VARCHAR) AS motivo_movimiento,
	--
    f.presupuestado_gs,
    f.devengado_gs,
    f.monto_base_calculo_gs,
	--
    c.cotizacion_usd_promedio,
    CASE
        WHEN c.cotizacion_usd_promedio IS NULL OR c.cotizacion_usd_promedio = 0 THEN NULL
        ELSE ROUND(f.presupuestado_gs / c.cotizacion_usd_promedio, 2)
    END AS presupuestado_usd,
    CASE
        WHEN c.cotizacion_usd_promedio IS NULL OR c.cotizacion_usd_promedio = 0 THEN NULL
        ELSE ROUND(f.devengado_gs / c.cotizacion_usd_promedio, 2)
    END AS devengado_usd,
    CASE
        WHEN c.cotizacion_usd_promedio IS NULL OR c.cotizacion_usd_promedio = 0 THEN NULL
        ELSE ROUND(f.monto_base_calculo_gs / c.cotizacion_usd_promedio, 2)
    END AS monto_base_calculo_usd,
	--
    r.fecha_regimen,
    r.mes_nombre AS mes_nombre_regimen,
    r.salario_minimo_mensual_gs,
    r.salario_por_dia_gs,
    r.jornal_por_dia_gs,
    r.salario_por_hora_gs,
    r.salario_nocturno_mensual_gs,
    r.salario_nocturno_por_dia_gs,
    r.jornal_nocturno_por_dia_gs,
    r.salario_nocturno_por_hora_gs,
    r.asignacion_familiar_por_hijo_gs,
    r.aporte_patronal_gs,
    r.aporte_empleado_gs,
    r.salario_neto_gs,
    r.vigente AS regimen_vigente,
	--
    f.fecha_nacimiento_raw,
    f.fecha_nacimiento,
    f.fecha_acto_raw,
    f.fecha_acto,
	--
    CASE
        WHEN f.documento IS NULL OR f.documento = '' THEN 'SIN_DOCUMENTO'
        WHEN REGEXP_MATCHES(f.documento, 'VACAN|VACANC|VACANTE') THEN 'VACANCIA'
        WHEN REGEXP_MATCHES(f.documento, '^[0-9]+$') THEN 'DOCUMENTO_NUMERICO'
        ELSE 'DOCUMENTO_NO_CONVENCIONAL'
    END AS tipo_registro_documento,
	--
    CASE
        WHEN f.documento IS NULL OR f.documento = '' THEN TRUE
        WHEN REGEXP_MATCHES(f.documento, 'VACAN|VACANC|VACANTE') THEN TRUE
        ELSE FALSE
    END AS es_vacancia,
	--
    CASE
        WHEN g.objeto_gasto_codigo IS NULL THEN TRUE ELSE FALSE
    END AS tiene_objeto_gasto_sin_clasificar,
	--
    CASE
        WHEN o.codigo_oee IS NULL THEN TRUE ELSE FALSE
    END AS tiene_oee_sin_clasificar,
	--
    CASE
        WHEN c.cotizacion_usd_promedio IS NULL THEN TRUE ELSE FALSE
    END AS tiene_cotizacion_usd_faltante,
	--
    CASE
        WHEN r.salario_minimo_mensual_gs IS NULL THEN TRUE ELSE FALSE
    END AS tiene_regimen_salarial_faltante,
	--
    f.fecha_carga,
    f.fuente_archivo,
    f.hash_registro,
	--
    md5(
        COALESCE(CAST(f.anho AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.mes AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.nivel AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.entidad AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.oee AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.documento AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.objeto_gasto AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.presupuestado_gs AS VARCHAR), '') || '|' ||
        COALESCE(CAST(f.devengado_gs AS VARCHAR), '')
    ) AS hash_registro_enriquecido
FROM staging.funcionarios_modelo f
LEFT JOIN staging.clasificador_gastos_dedup g
       ON f.objeto_gasto = g.objeto_gasto_codigo
LEFT JOIN staging.clasificador_oee_dedup o
       ON f.nivel = o.codigo_nivel
      AND f.entidad = o.codigo_entidad
      AND f.oee = o.codigo_oee
LEFT JOIN staging.cotizacion_usd_mensual_dedup c
       ON f.anho = c.anho
      AND f.mes = c.mes
LEFT JOIN staging.regimen_salarial_py_dedup r
       ON f.anho = r.anho
      AND f.mes = r.mes;

-- Alias semántico recomendado para nuevos scripts CORE.
CREATE OR REPLACE VIEW staging.funcionarios_modelo_enriquecido AS
SELECT *
FROM staging.funcionarios_modelo_ext;

-- ============================================================
-- 7) Controles de staging: conteo de registros
-- ============================================================
CREATE OR REPLACE VIEW staging.vw_control_staging_registros AS
SELECT 'staging.funcionarios_modelo' AS tabla, COUNT(*) AS total_registros FROM staging.funcionarios_modelo
UNION ALL
SELECT 'staging.funcionarios_modelo_ext' AS tabla, COUNT(*) AS total_registros FROM staging.funcionarios_modelo_ext
UNION ALL
SELECT 'staging.clasificador_gastos' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_gastos
UNION ALL
SELECT 'staging.clasificador_gastos_dedup' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_gastos_dedup
UNION ALL
SELECT 'staging.clasificador_oee' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_oee
UNION ALL
SELECT 'staging.clasificador_oee_dedup' AS tabla, COUNT(*) AS total_registros FROM staging.clasificador_oee_dedup
UNION ALL
SELECT 'staging.cotizacion_usd_mensual' AS tabla, COUNT(*) AS total_registros FROM staging.cotizacion_usd_mensual
UNION ALL
SELECT 'staging.cotizacion_usd_mensual_dedup' AS tabla, COUNT(*) AS total_registros FROM staging.cotizacion_usd_mensual_dedup
UNION ALL
SELECT 'staging.regimen_salarial_py' AS tabla, COUNT(*) AS total_registros FROM staging.regimen_salarial_py
UNION ALL
SELECT 'staging.regimen_salarial_py_dedup' AS tabla, COUNT(*) AS total_registros FROM staging.regimen_salarial_py_dedup;

CREATE OR REPLACE TABLE audit.validacion_staging_cantidad_registros AS
SELECT
    CURRENT_TIMESTAMP AS fecha_validacion,
    *
FROM staging.vw_control_staging_registros;

-- ============================================================
-- 8) Controles de staging: calidad básica de la fuente principal
-- ============================================================
CREATE OR REPLACE VIEW staging.vw_control_staging_calidad_basica AS
SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN anho IS NULL THEN 1 ELSE 0 END) AS registros_anho_nulo,
    SUM(CASE WHEN mes IS NULL THEN 1 ELSE 0 END) AS registros_mes_nulo,
    SUM(CASE WHEN fecha_periodo IS NULL THEN 1 ELSE 0 END) AS registros_fecha_periodo_nula,
    SUM(CASE WHEN nivel IS NULL THEN 1 ELSE 0 END) AS registros_nivel_nulo,
    SUM(CASE WHEN entidad IS NULL THEN 1 ELSE 0 END) AS registros_entidad_nula,
    SUM(CASE WHEN oee IS NULL THEN 1 ELSE 0 END) AS registros_oee_nulo,
    SUM(CASE WHEN documento IS NULL THEN 1 ELSE 0 END) AS registros_documento_nulo,
    SUM(CASE WHEN objeto_gasto IS NULL THEN 1 ELSE 0 END) AS registros_objeto_gasto_nulo,
    SUM(CASE WHEN presupuestado_gs IS NULL THEN 1 ELSE 0 END) AS registros_presupuestado_nulo,
    SUM(CASE WHEN devengado_gs IS NULL THEN 1 ELSE 0 END) AS registros_devengado_nulo,
    SUM(CASE WHEN presupuestado_gs < 0 THEN 1 ELSE 0 END) AS registros_presupuestado_negativo,
    SUM(CASE WHEN devengado_gs < 0 THEN 1 ELSE 0 END) AS registros_devengado_negativo,
    SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) AS registros_fecha_nacimiento_nula,
    SUM(CASE WHEN fecha_acto IS NULL THEN 1 ELSE 0 END) AS registros_fecha_acto_nula,
    COUNT(DISTINCT hash_registro) AS total_hash_registro_distintos
FROM staging.funcionarios_modelo;

-- ============================================================
-- 9) Controles de staging: resultado de enriquecimiento
-- ============================================================
CREATE OR REPLACE VIEW staging.vw_control_staging_enriquecimiento AS
SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN objeto_gasto_descripcion IS NULL THEN 1 ELSE 0 END) AS registros_sin_concepto_remunerativo,
    SUM(CASE WHEN descripcion_nivel IS NULL THEN 1 ELSE 0 END) AS registros_sin_descripcion_nivel,
    SUM(CASE WHEN descripcion_entidad IS NULL THEN 1 ELSE 0 END) AS registros_sin_descripcion_entidad,
    SUM(CASE WHEN descripcion_oee IS NULL THEN 1 ELSE 0 END) AS registros_sin_descripcion_oee,
    SUM(CASE WHEN cotizacion_usd_promedio IS NULL THEN 1 ELSE 0 END) AS registros_sin_cotizacion_usd,
    SUM(CASE WHEN salario_minimo_mensual_gs IS NULL THEN 1 ELSE 0 END) AS registros_sin_regimen_salarial,
    SUM(CASE WHEN tiene_objeto_gasto_sin_clasificar THEN 1 ELSE 0 END) AS registros_objeto_gasto_sin_clasificar,
    SUM(CASE WHEN tiene_oee_sin_clasificar THEN 1 ELSE 0 END) AS registros_oee_sin_clasificar,
    SUM(CASE WHEN tiene_cotizacion_usd_faltante THEN 1 ELSE 0 END) AS registros_cotizacion_usd_faltante,
    SUM(CASE WHEN tiene_regimen_salarial_faltante THEN 1 ELSE 0 END) AS registros_regimen_salarial_faltante
FROM staging.funcionarios_modelo_ext;

-- ============================================================
-- 10) Control específico: duplicados técnicos por grano de componente
-- ============================================================
CREATE OR REPLACE VIEW staging.vw_control_staging_duplicados_componente AS
SELECT
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento_hash,
    objeto_gasto,
    presupuestado_gs,
    devengado_gs,
    COUNT(*) AS cantidad_registros
FROM staging.funcionarios_modelo_ext
GROUP BY
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento_hash,
    objeto_gasto,
    presupuestado_gs,
    devengado_gs
HAVING COUNT(*) > 1;

-- ============================================================
-- 11) Auditoría de ejecución
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '02_staging_limpieza.sql',
    'staging',
    'staging_tables',
    'ok',
    NULL,
    'Capa staging creada: fuente principal normalizada y enriquecida con clasificador de gastos, OEE, cotizacion USD y regimen salarial';
