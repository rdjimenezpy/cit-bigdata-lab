-- ============================================================
-- 03_core_modelo.sql
-- Proyecto: gasto-salarios-unpy
-- Capa: CORE
-- Motor: DuckDB
-- Autor académico: Prof. Ing. Richard D. Jiménez-R.
--
-- Propósito:
--   1) Construir entidades analíticas limpias desde staging.
--   2) Clasificar objetos de gasto en componentes remunerativos.
--   3) Crear una tabla de detalle por componente remunerativo.
--   4) Crear una tabla consolidada por funcionario/registro + OEE + mes.
--   5) Calcular métricas de edad, antigüedad, generación, régimen salarial,
--      conversión USD, percentiles, rankings y brechas institucionales.
--
-- Dependencias:
--   Ejecutar antes:
--     sql/00_setup/00_create_schemas.sql
--     sql/01_raw/01_raw_ingesta.sql
--     sql/02_staging/02_staging_limpieza.sql
--
-- Entrada principal:
--   staging.funcionarios_modelo_enriquecido
--
-- Tablas CORE generadas:
--   core.dim_periodo_mensual
--   core.dim_institucion_oee
--   core.dim_clasificador_gasto
--   core.dim_cotizacion_usd_mensual
--   core.dim_regimen_salarial_mensual
--   core.map_objeto_gasto_componente
--   core.fact_remuneraciones_componentes
--   core.fact_remuneraciones_funcionario_mes
--
-- Vistas CORE generadas:
--   core.remuneraciones_funcionario_mes
--   core.vw_remuneraciones_universidades_nacionales
--   core.vw_control_core_registros
--   core.vw_control_core_componentes
--   core.vw_control_core_calidad_modelo
--
-- Aclaraciones críticas de diseño:
--   - raw.funcionarios_modelo_src no contiene cargo, funcion, concepto,
--     linea ni categoria.
--   - concepto_remunerativo se deriva desde
--     clasificador_gastos.objeto_gasto_descripcion vía objeto_gasto.
--   - cargo y funcion se mantienen como NULL técnico si vienen desde staging,
--     pero no se usan para inferir tipo de funcionario.
--   - La clasificación docente/administrativo NO es confiable con la fuente
--     actual. Solo se calcula un indicador de indicio docente por objeto de
--     gasto, no una categoría laboral definitiva.
--   - El objeto 841 BECAS se separa de la remuneración principal. Se conserva
--     como transferencia/beca para análisis específico.
-- ============================================================

-- ============================================================
-- 0) Exploración recomendada previa
-- ============================================================
-- DESCRIBE staging.funcionarios_modelo_enriquecido;
-- SELECT * FROM staging.funcionarios_modelo_enriquecido LIMIT 20;
-- SELECT objeto_gasto, concepto_remunerativo, COUNT(*)
-- FROM staging.funcionarios_modelo_enriquecido
-- GROUP BY objeto_gasto, concepto_remunerativo
-- ORDER BY objeto_gasto;

-- ============================================================
-- 1) Dimensión calendario mensual observada
-- ============================================================
CREATE OR REPLACE TABLE core.dim_periodo_mensual AS
SELECT DISTINCT
    anho,
    mes,
    fecha_periodo,
    STRFTIME(fecha_periodo, '%Y-%m') AS periodo_yyyy_mm,
    CAST(anho * 100 + mes AS INTEGER) AS periodo_id,
    CASE mes
        WHEN 1 THEN 'ENERO'
        WHEN 2 THEN 'FEBRERO'
        WHEN 3 THEN 'MARZO'
        WHEN 4 THEN 'ABRIL'
        WHEN 5 THEN 'MAYO'
        WHEN 6 THEN 'JUNIO'
        WHEN 7 THEN 'JULIO'
        WHEN 8 THEN 'AGOSTO'
        WHEN 9 THEN 'SEPTIEMBRE'
        WHEN 10 THEN 'OCTUBRE'
        WHEN 11 THEN 'NOVIEMBRE'
        WHEN 12 THEN 'DICIEMBRE'
        ELSE 'NO INFORMADO'
    END AS mes_nombre,
    CASE
        WHEN mes BETWEEN 1 AND 3 THEN 1
        WHEN mes BETWEEN 4 AND 6 THEN 2
        WHEN mes BETWEEN 7 AND 9 THEN 3
        WHEN mes BETWEEN 10 AND 12 THEN 4
        ELSE NULL
    END AS trimestre,
    CASE
        WHEN mes BETWEEN 1 AND 6 THEN 1
        WHEN mes BETWEEN 7 AND 12 THEN 2
        ELSE NULL
    END AS semestre,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM staging.funcionarios_modelo_enriquecido
WHERE fecha_periodo IS NOT NULL;

-- Alias de compatibilidad con scripts previos.
CREATE OR REPLACE VIEW core.dim_calendario_mensual AS
SELECT *
FROM core.dim_periodo_mensual;

-- ============================================================
-- 2) Dimensión institución / OEE
--
-- Se prioriza staging.clasificador_oee_dedup y se complementan claves
-- observadas en funcionarios si hubiera códigos sin descripción.
-- ============================================================
CREATE OR REPLACE TABLE core.dim_institucion_oee AS
WITH observados AS (
    SELECT DISTINCT
        nivel AS codigo_nivel,
        descripcion_nivel,
        entidad AS codigo_entidad,
        descripcion_entidad,
        oee AS codigo_oee,
        descripcion_oee,
        descripcion_corta_oee AS descripcion_corta,
        uri_oee,
        'funcionarios_modelo_enriquecido' AS origen
    FROM staging.funcionarios_modelo_enriquecido
), clasificador AS (
    SELECT DISTINCT
        codigo_nivel,
        descripcion_nivel,
        codigo_entidad,
        descripcion_entidad,
        codigo_oee,
        descripcion_oee,
        descripcion_corta,
        uri_oee,
        'clasificador_oee' AS origen
    FROM staging.clasificador_oee_dedup
), unificado AS (
    SELECT * FROM clasificador
    UNION ALL
    SELECT * FROM observados
), priorizado AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY codigo_nivel, codigo_entidad, codigo_oee
            ORDER BY
                CASE WHEN origen = 'clasificador_oee' THEN 0 ELSE 1 END,
                CASE WHEN descripcion_oee IS NOT NULL THEN 0 ELSE 1 END,
                descripcion_oee
        ) AS rn
    FROM unificado
    WHERE codigo_nivel IS NOT NULL
      AND codigo_entidad IS NOT NULL
      AND codigo_oee IS NOT NULL
)
SELECT
    codigo_nivel,
    COALESCE(descripcion_nivel, 'NO INFORMADO') AS descripcion_nivel,
    codigo_entidad,
    COALESCE(descripcion_entidad, 'NO INFORMADO') AS descripcion_entidad,
    codigo_oee,
    COALESCE(descripcion_oee, 'NO INFORMADO') AS descripcion_oee,
    descripcion_corta,
    uri_oee,
    CASE
        WHEN codigo_nivel = 28 THEN TRUE
        WHEN REGEXP_MATCHES(
                COALESCE(descripcion_entidad, '') || ' ' || COALESCE(descripcion_oee, ''),
                'UNIVERSIDAD NACIONAL|RECTORADO|FACULTAD|INSTITUTO SUPERIOR|POLITECNICA'
             )
        THEN TRUE
        ELSE FALSE
    END AS es_universidad_nacional,
    origen AS origen_preferido,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM priorizado
WHERE rn = 1;

-- Alias de compatibilidad con scripts previos.
CREATE OR REPLACE VIEW core.dim_oee AS
SELECT
    codigo_nivel,
    descripcion_nivel,
    codigo_entidad,
    descripcion_entidad,
    codigo_oee,
    descripcion_oee,
    descripcion_corta,
    uri_oee,
    es_universidad_nacional,
    fecha_carga_core AS fecha_carga
FROM core.dim_institucion_oee;

-- ============================================================
-- 3) Dimensión clasificador de gastos
-- ============================================================
CREATE OR REPLACE TABLE core.dim_clasificador_gasto AS
SELECT
    objeto_gasto_codigo,
    objeto_gasto_descripcion AS concepto_remunerativo,
    objeto_gasto_descripcion,
    subgrupo_codigo,
    subgrupo_descripcion,
    grupo_codigo,
    grupo_descripcion,
    control_financiero_codigo,
    control_financiero_descripcion,
    clasificacion_gasto_descripcion,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM staging.clasificador_gastos_dedup;

-- Alias de compatibilidad con scripts previos.
CREATE OR REPLACE VIEW core.dim_clasificador_gastos AS
SELECT
    objeto_gasto_codigo,
    objeto_gasto_descripcion,
    subgrupo_codigo,
    subgrupo_descripcion,
    grupo_codigo,
    grupo_descripcion,
    control_financiero_codigo,
    control_financiero_descripcion,
    clasificacion_gasto_descripcion,
    fecha_carga_core AS fecha_carga
FROM core.dim_clasificador_gasto;

-- ============================================================
-- 4) Dimensión cotización USD mensual
-- ============================================================
CREATE OR REPLACE TABLE core.dim_cotizacion_usd_mensual AS
SELECT
    anho,
    mes,
    fecha_periodo,
    periodo,
    periodo_id,
    cotizacion_usd_promedio,
    fecha_cierre,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM staging.cotizacion_usd_mensual_dedup;

-- ============================================================
-- 5) Dimensión régimen salarial mensual aplicable
--
-- Regla:
--   para cada periodo observado se toma el último régimen con
--   fecha_regimen <= fecha_periodo. Esto evita dejar meses sin referencia
--   cuando el salario mínimo cambia en una fecha específica.
-- ============================================================
CREATE OR REPLACE TABLE core.dim_regimen_salarial_mensual AS
WITH periodos AS (
    SELECT DISTINCT
        anho,
        mes,
        fecha_periodo
    FROM core.dim_periodo_mensual
), candidatos AS (
    SELECT
        p.anho,
        p.mes,
        p.fecha_periodo,
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
        r.vigente,
        ROW_NUMBER() OVER (
            PARTITION BY p.anho, p.mes
            ORDER BY r.fecha_regimen DESC NULLS LAST
        ) AS rn
    FROM periodos p
    LEFT JOIN staging.regimen_salarial_py_dedup r
           ON r.fecha_regimen <= p.fecha_periodo
)
SELECT
    anho,
    mes,
    fecha_periodo,
    fecha_regimen,
    mes_nombre_regimen,
    salario_minimo_mensual_gs,
    salario_por_dia_gs,
    jornal_por_dia_gs,
    salario_por_hora_gs,
    salario_nocturno_mensual_gs,
    salario_nocturno_por_dia_gs,
    jornal_nocturno_por_dia_gs,
    salario_nocturno_por_hora_gs,
    asignacion_familiar_por_hijo_gs,
    aporte_patronal_gs,
    aporte_empleado_gs,
    salario_neto_gs,
    vigente,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM candidatos
WHERE rn = 1;

-- ============================================================
-- 6) Mapeo controlado de objeto de gasto a componente remunerativo
--
-- Nota:
--   Este mapeo debe ser revisado por criterio presupuestario/contable si
--   se incorporan nuevos objetos de gasto. No intenta reemplazar al
--   clasificador oficial: lo complementa para análisis salarial.
-- ============================================================
CREATE OR REPLACE TABLE core.map_objeto_gasto_componente AS
SELECT *
FROM (
    VALUES
        (111, 'SALARIO_BASICO',          TRUE,  'SUELDOS'),
        (112, 'SALARIO_BASICO',          TRUE,  'DIETAS'),
        (113, 'GASTOS_REPRESENTACION',   TRUE,  'GASTOS DE REPRESENTACION'),
        (114, 'AGUINALDO',               TRUE,  'AGUINALDO'),
        (123, 'BONIFICACIONES',          TRUE,  'REMUNERACIONES EXTRAORDINARIAS'),
        (125, 'BONIFICACIONES',          TRUE,  'REMUNERACION ADICIONAL'),
        (131, 'BENEFICIOS',              TRUE,  'SUBSIDIO FAMILIAR'),
        (132, 'BONIFICACIONES',          TRUE,  'ESCALAFON DOCENTE'),
        (133, 'BONIFICACIONES',          TRUE,  'BONIFICACIONES Y GRATIFICACIONES'),
        (141, 'SALARIO_BASICO',          TRUE,  'CONTRATACION DE PERSONAL TECNICO'),
        (142, 'SALARIO_BASICO',          TRUE,  'CONTRATACION DE PERSONAL DE SALUD'),
        (143, 'SALARIO_BASICO',          TRUE,  'CONTRATACION OCASIONAL'),
        (144, 'SALARIO_BASICO',          TRUE,  'JORNALES'),
        (145, 'HONORARIOS',              TRUE,  'HONORARIOS PROFESIONALES'),
        (146, 'SALARIO_BASICO',          TRUE,  'CONTRATACION DE PERSONAL'),
        (148, 'SALARIO_BASICO',          TRUE,  'CONTRATACION DE PERSONAL DOCENTE E INSTRUCTORES'),
        (161, 'SALARIO_BASICO',          TRUE,  'REMUNERACIONES TEMPORALES'),
        (162, 'GASTOS_REPRESENTACION',   TRUE,  'GASTOS DE REPRESENTACION TEMPORALES'),
        (163, 'AGUINALDO',               TRUE,  'AGUINALDO TEMPORAL'),
        (182, 'BONIFICACIONES',          TRUE,  'BONIFICACIONES'),
        (183, 'BONIFICACIONES',          TRUE,  'GRATIFICACIONES'),
        (185, 'BONIFICACIONES',          TRUE,  'REMUNERACION ADICIONAL'),
        (191, 'BENEFICIOS',              TRUE,  'SUBSIDIO PARA LA SALUD'),
        (192, 'BENEFICIOS',              TRUE,  'SUBSIDIOS'),
        (193, 'BENEFICIOS',              TRUE,  'SEGUROS'),
        (194, 'BENEFICIOS',              TRUE,  'OTROS BENEFICIOS'),
        (195, 'BENEFICIOS',              TRUE,  'AYUDA ESCOLAR U OTROS BENEFICIOS'),
        (199, 'OTROS_COMPONENTES',       TRUE,  'OTROS GASTOS DE PERSONAL'),
        (232, 'VIATICOS',                TRUE,  'VIATICOS Y MOVILIDAD'),
        (239, 'VIATICOS',                TRUE,  'OTROS VIATICOS'),
        (841, 'TRANSFERENCIAS_BECAS',    FALSE, 'BECAS; no se mezcla con remuneracion principal'),
        (0,   'SIN_CLASIFICAR',          TRUE,  'OBJETO DE GASTO CERO O NO INFORMADO')
) AS t(
    objeto_gasto_codigo,
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    criterio_clasificacion
);

-- ============================================================
-- 7) Fact de remuneraciones por componente
--
-- Grano:
--   anho + mes + nivel + entidad + oee + documento + objeto_gasto
--   + importes observados.
--
-- Esta tabla conserva el detalle por objeto de gasto y permite explicar
-- la composición salarial sin romper el grano consolidado de la OBT.
-- ============================================================
CREATE OR REPLACE TABLE core.fact_remuneraciones_componentes AS
WITH base AS (
    SELECT
        f.*,
        COALESCE(f.devengado_gs, f.presupuestado_gs, 0) AS monto_componente_gs
    FROM staging.funcionarios_modelo_enriquecido f
), enriquecido AS (
    SELECT
        b.anho,
        b.mes,
        b.fecha_periodo,
        p.periodo_yyyy_mm,
        p.periodo_id,
        p.mes_nombre,
        p.trimestre,
        p.semestre,

        b.nivel,
        COALESCE(o.descripcion_nivel, b.descripcion_nivel, 'NO INFORMADO') AS descripcion_nivel,
        b.entidad,
        COALESCE(o.descripcion_entidad, b.descripcion_entidad, 'NO INFORMADO') AS descripcion_entidad,
        b.oee,
        COALESCE(o.descripcion_oee, b.descripcion_oee, 'NO INFORMADO') AS descripcion_oee,
        COALESCE(o.descripcion_corta, b.descripcion_corta_oee) AS oee_descripcion_corta,
        COALESCE(o.uri_oee, b.uri_oee) AS uri_oee,
        COALESCE(o.es_universidad_nacional, FALSE) AS es_universidad_nacional,

        b.documento,
        b.documento_hash,
        b.nombres,
        b.apellidos,
        b.estado,
        b.anho_ingreso,
        b.sexo,
        b.discapacidad,
        b.tipo_discapacidad,
        b.fuente_financiamiento,
        b.fecha_nacimiento,
        b.fecha_acto,

        CASE
            WHEN b.documento IS NULL OR TRIM(b.documento) = '' THEN 'SIN_DOCUMENTO'
            WHEN REGEXP_MATCHES(b.documento, '^[0-9]') THEN 'FUNCIONARIO_NACIONAL'
            WHEN REGEXP_MATCHES(b.documento, '^E') THEN 'FUNCIONARIO_EXTRANJERO'
            WHEN REGEXP_MATCHES(b.documento, '^V|VACAN|VACANC|VACANTE') THEN 'VACANCIA'
            WHEN REGEXP_MATCHES(b.documento, '^A') THEN 'ANONIMO_NO_CONVENCIONAL'
            ELSE 'NO_CLASIFICADO'
        END AS tipo_registro_funcionario,

        CASE
            WHEN b.documento IS NULL OR TRIM(b.documento) = '' THEN TRUE
            WHEN REGEXP_MATCHES(b.documento, '^A') THEN TRUE
            ELSE FALSE
        END AS es_registro_anonimo,
        COALESCE(b.es_vacancia, FALSE) AS es_vacancia,

        b.objeto_gasto,
        COALESCE(g.concepto_remunerativo, b.concepto_remunerativo, b.objeto_gasto_descripcion, 'SIN CLASIFICAR') AS concepto_remunerativo,
        COALESCE(g.objeto_gasto_descripcion, b.objeto_gasto_descripcion, 'SIN CLASIFICAR') AS objeto_gasto_descripcion,
        COALESCE(g.grupo_codigo, b.grupo_codigo) AS grupo_codigo,
        COALESCE(g.grupo_descripcion, b.grupo_descripcion) AS grupo_descripcion,
        COALESCE(g.subgrupo_codigo, b.subgrupo_codigo) AS subgrupo_codigo,
        COALESCE(g.subgrupo_descripcion, b.subgrupo_descripcion) AS subgrupo_descripcion,
        COALESCE(g.control_financiero_codigo, b.control_financiero_codigo) AS control_financiero_codigo,
        COALESCE(g.control_financiero_descripcion, b.control_financiero_descripcion) AS control_financiero_descripcion,
        COALESCE(g.clasificacion_gasto_descripcion, b.clasificacion_gasto_descripcion) AS clasificacion_gasto_descripcion,

        COALESCE(m.componente_remunerativo,
            CASE
                WHEN b.objeto_gasto IS NULL THEN 'SIN_CLASIFICAR'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'SUELDO|DIETA|JORNAL|HONORARIO|CONTRATACION') THEN 'SALARIO_BASICO'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'VIATIC|MOVILIDAD') THEN 'VIATICOS'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'SUBSIDIO|SALUD|SEGURO|ASIGNACION|AYUDA') THEN 'BENEFICIOS'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'BONIFIC|GRATIFIC|ADICIONAL|EXTRAORDINARIA|ESCALAFON') THEN 'BONIFICACIONES'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'REPRESENTACION') THEN 'GASTOS_REPRESENTACION'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'AGUINALDO') THEN 'AGUINALDO'
                WHEN REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'BECA') THEN 'TRANSFERENCIAS_BECAS'
                ELSE 'OTROS_COMPONENTES'
            END
        ) AS componente_remunerativo,

        COALESCE(m.incluir_en_remuneracion_principal, TRUE) AS incluir_en_remuneracion_principal,
        COALESCE(m.criterio_clasificacion, 'Clasificacion por descripcion del objeto de gasto') AS criterio_clasificacion_componente,

        CASE
            WHEN b.objeto_gasto IN (132, 148)
              OR REGEXP_MATCHES(COALESCE(g.objeto_gasto_descripcion, b.concepto_remunerativo, ''), 'DOCENTE|INSTRUCTOR|ESCALAFON DOCENTE')
            THEN TRUE
            ELSE FALSE
        END AS tiene_indicio_docente_por_objeto_gasto,

        CASE
            WHEN b.estado = 'PERMANENTE' THEN 'PERMANENTE'
            WHEN b.estado = 'CONTRATADO' THEN 'CONTRATADO'
            WHEN b.objeto_gasto BETWEEN 141 AND 148 THEN 'CONTRATADO_POR_OBJETO_GASTO'
            WHEN b.estado IS NULL THEN 'NO INFORMADO'
            ELSE b.estado
        END AS tipo_vinculo_inferido,

        -- Campos no disponibles en la fuente principal. Se preservan como
        -- compatibilidad técnica, pero no deben usarse como dimensiones reales.
        CAST(NULL AS VARCHAR) AS cargo,
        CAST(NULL AS VARCHAR) AS funcion,
        CAST(NULL AS VARCHAR) AS carga_horaria,
        CAST(NULL AS VARCHAR) AS linea,
        CAST(NULL AS INTEGER) AS linea_codigo,
        CAST(NULL AS VARCHAR) AS categoria,
        CAST(NULL AS VARCHAR) AS profesion,

        b.presupuestado_gs,
        b.devengado_gs,
        b.monto_componente_gs,
        CASE
            WHEN COALESCE(m.incluir_en_remuneracion_principal, TRUE) = TRUE THEN b.monto_componente_gs
            ELSE 0
        END AS monto_remunerativo_principal_gs,
        CASE
            WHEN COALESCE(m.componente_remunerativo, '') = 'TRANSFERENCIAS_BECAS' THEN b.monto_componente_gs
            ELSE 0
        END AS monto_beca_transferencia_gs,

        COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio) AS cotizacion_usd_promedio,
        CASE
            WHEN COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio) IS NULL
              OR COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio) = 0 THEN NULL
            ELSE ROUND(b.monto_componente_gs / COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio), 2)
        END AS monto_componente_usd,
        CASE
            WHEN COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio) IS NULL
              OR COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio) = 0 THEN NULL
            ELSE ROUND(
                CASE
                    WHEN COALESCE(m.incluir_en_remuneracion_principal, TRUE) = TRUE THEN b.monto_componente_gs
                    ELSE 0
                END / COALESCE(c.cotizacion_usd_promedio, b.cotizacion_usd_promedio),
                2
            )
        END AS monto_remunerativo_principal_usd,

        r.fecha_regimen,
        r.salario_minimo_mensual_gs,
        r.salario_por_dia_gs,
        r.jornal_por_dia_gs,
        r.salario_por_hora_gs,
        r.salario_neto_gs,
        CASE
            WHEN r.salario_minimo_mensual_gs IS NULL OR r.salario_minimo_mensual_gs = 0 THEN NULL
            ELSE ROUND(b.monto_componente_gs / r.salario_minimo_mensual_gs, 4)
        END AS monto_componente_en_salarios_minimos,

        COALESCE(b.tiene_objeto_gasto_sin_clasificar, g.objeto_gasto_codigo IS NULL) AS tiene_objeto_gasto_sin_clasificar,
        COALESCE(b.tiene_oee_sin_clasificar, o.codigo_oee IS NULL) AS tiene_oee_sin_clasificar,
        COALESCE(b.tiene_cotizacion_usd_faltante, c.cotizacion_usd_promedio IS NULL) AS tiene_cotizacion_usd_faltante,
        COALESCE(b.tiene_regimen_salarial_faltante, r.salario_minimo_mensual_gs IS NULL) AS tiene_regimen_salarial_faltante,

        b.fecha_carga AS fecha_carga_staging,
        b.fuente_archivo,
        b.hash_registro,
        b.hash_registro_enriquecido
    FROM base b
    LEFT JOIN core.dim_periodo_mensual p
           ON b.anho = p.anho
          AND b.mes = p.mes
    LEFT JOIN core.dim_institucion_oee o
           ON b.nivel = o.codigo_nivel
          AND b.entidad = o.codigo_entidad
          AND b.oee = o.codigo_oee
    LEFT JOIN core.dim_clasificador_gasto g
           ON b.objeto_gasto = g.objeto_gasto_codigo
    LEFT JOIN core.map_objeto_gasto_componente m
           ON b.objeto_gasto = m.objeto_gasto_codigo
    LEFT JOIN core.dim_cotizacion_usd_mensual c
           ON b.anho = c.anho
          AND b.mes = c.mes
    LEFT JOIN core.dim_regimen_salarial_mensual r
           ON b.anho = r.anho
          AND b.mes = r.mes
)
SELECT
    *,
    md5(
        COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
        COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
        COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
        COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
        COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
        COALESCE(CAST(documento AS VARCHAR), '') || '|' ||
        COALESCE(CAST(objeto_gasto AS VARCHAR), '') || '|' ||
        COALESCE(CAST(presupuestado_gs AS VARCHAR), '') || '|' ||
        COALESCE(CAST(devengado_gs AS VARCHAR), '')
    ) AS hash_componente,
    CURRENT_TIMESTAMP AS fecha_carga_core
FROM enriquecido;

-- ============================================================
-- 8) Fact consolidado por funcionario/registro + institución + mes
--
-- Grano:
--   anho + mes + nivel + entidad + oee + documento
--
-- Esta tabla es la base directa para la OBT del datamart.
-- ============================================================
CREATE OR REPLACE TABLE core.fact_remuneraciones_funcionario_mes AS
WITH agregado AS (
    SELECT
        anho,
        mes,
        fecha_periodo,
        MAX(periodo_yyyy_mm) AS periodo_yyyy_mm,
        MAX(periodo_id) AS periodo_id,
        MAX(mes_nombre) AS mes_nombre,
        MAX(trimestre) AS trimestre,
        MAX(semestre) AS semestre,

        nivel,
        MAX(descripcion_nivel) AS descripcion_nivel,
        entidad,
        MAX(descripcion_entidad) AS descripcion_entidad,
        oee,
        MAX(descripcion_oee) AS descripcion_oee,
        MAX(oee_descripcion_corta) AS oee_descripcion_corta,
        MAX(uri_oee) AS uri_oee,
        BOOL_OR(es_universidad_nacional) AS es_universidad_nacional,

        documento,
        MAX(documento_hash) AS documento_hash,
        MAX(nombres) AS nombres,
        MAX(apellidos) AS apellidos,
        MAX(estado) AS estado,
        MAX(anho_ingreso) AS anho_ingreso,
        MAX(sexo) AS sexo,
        MAX(discapacidad) AS discapacidad,
        MAX(tipo_discapacidad) AS tipo_discapacidad,
        MIN(fecha_nacimiento) AS fecha_nacimiento,
        MAX(fecha_acto) AS fecha_acto,
        MAX(tipo_registro_funcionario) AS tipo_registro_funcionario,
        BOOL_OR(es_vacancia) AS es_vacancia,
        BOOL_OR(es_registro_anonimo) AS es_registro_anonimo,
        BOOL_OR(tiene_indicio_docente_por_objeto_gasto) AS tiene_indicio_docente_por_objeto_gasto,

        MAX(cargo) AS cargo_principal,
        MAX(funcion) AS funcion_principal,
        MAX(carga_horaria) AS carga_horaria_principal,
        MAX(profesion) AS profesion_principal,

        CASE
            WHEN BOOL_OR(tiene_indicio_docente_por_objeto_gasto) THEN 'CON_INDICIO_DOCENTE_POR_OBJETO_GASTO'
            ELSE 'NO_DETERMINABLE_CON_FUENTE_ACTUAL'
        END AS tipo_funcionario_inferido,

        CASE
            WHEN SUM(CASE WHEN tipo_vinculo_inferido = 'PERMANENTE' THEN 1 ELSE 0 END) > 0 THEN 'PERMANENTE'
            WHEN SUM(CASE WHEN tipo_vinculo_inferido IN ('CONTRATADO', 'CONTRATADO_POR_OBJETO_GASTO') THEN 1 ELSE 0 END) > 0 THEN 'CONTRATADO'
            WHEN SUM(CASE WHEN tipo_vinculo_inferido = 'NO INFORMADO' THEN 1 ELSE 0 END) > 0 THEN 'NO INFORMADO'
            ELSE MAX(tipo_vinculo_inferido)
        END AS tipo_vinculo_inferido,

        STRING_AGG(DISTINCT CAST(objeto_gasto AS VARCHAR), ' | ') AS objetos_gasto_lista,
        STRING_AGG(DISTINCT concepto_remunerativo, ' | ') AS conceptos_remunerativos_lista,
        STRING_AGG(DISTINCT componente_remunerativo, ' | ') AS componentes_remunerativos_lista,

        COUNT(*) AS cantidad_componentes,
        COUNT(DISTINCT objeto_gasto) AS cantidad_objetos_gasto,
        COUNT(DISTINCT concepto_remunerativo) AS cantidad_conceptos,

        SUM(COALESCE(presupuestado_gs, 0)) AS remuneracion_presupuestada_total_gs,
        SUM(COALESCE(devengado_gs, 0)) AS remuneracion_devengada_total_gs,
        SUM(COALESCE(presupuestado_gs, 0)) AS total_presupuestado_gs,
        SUM(COALESCE(devengado_gs, 0)) AS total_devengado_gs,
        SUM(COALESCE(monto_remunerativo_principal_gs, 0)) AS remuneracion_total_gs,
        SUM(COALESCE(presupuestado_gs, 0)) - SUM(COALESCE(devengado_gs, 0)) AS diferencia_presupuestado_devengado_gs,

        SUM(CASE WHEN componente_remunerativo = 'SALARIO_BASICO' THEN monto_remunerativo_principal_gs ELSE 0 END) AS salario_basico_gs,
        SUM(CASE WHEN componente_remunerativo = 'HONORARIOS' THEN monto_remunerativo_principal_gs ELSE 0 END) AS honorarios_gs,
        SUM(CASE WHEN componente_remunerativo = 'VIATICOS' THEN monto_remunerativo_principal_gs ELSE 0 END) AS viaticos_gs,
        SUM(CASE WHEN componente_remunerativo = 'BENEFICIOS' THEN monto_remunerativo_principal_gs ELSE 0 END) AS beneficios_gs,
        SUM(CASE WHEN componente_remunerativo = 'BONIFICACIONES' THEN monto_remunerativo_principal_gs ELSE 0 END) AS bonificaciones_gs,
        SUM(CASE WHEN componente_remunerativo = 'GASTOS_REPRESENTACION' THEN monto_remunerativo_principal_gs ELSE 0 END) AS gastos_representacion_gs,
        SUM(CASE WHEN componente_remunerativo = 'AGUINALDO' THEN monto_remunerativo_principal_gs ELSE 0 END) AS aguinaldo_gs,
        SUM(CASE WHEN componente_remunerativo = 'OTROS_COMPONENTES' THEN monto_remunerativo_principal_gs ELSE 0 END) AS otros_componentes_puros_gs,
        SUM(CASE WHEN componente_remunerativo = 'SIN_CLASIFICAR' THEN monto_remunerativo_principal_gs ELSE 0 END) AS sin_clasificar_gs,
        SUM(CASE WHEN componente_remunerativo IN ('OTROS_COMPONENTES', 'SIN_CLASIFICAR') THEN monto_remunerativo_principal_gs ELSE 0 END) AS otros_componentes_gs,
        SUM(COALESCE(monto_beca_transferencia_gs, 0)) AS becas_transferencias_gs,

        MAX(cotizacion_usd_promedio) AS cotizacion_usd_promedio,
        MAX(fecha_regimen) AS fecha_regimen_salarial,
        MAX(salario_minimo_mensual_gs) AS salario_minimo_mensual_gs,
        MAX(salario_por_dia_gs) AS salario_por_dia_gs,
        MAX(jornal_por_dia_gs) AS jornal_por_dia_gs,
        MAX(salario_por_hora_gs) AS salario_por_hora_gs,
        MAX(salario_neto_gs) AS salario_neto_referencia_gs,

        BOOL_OR(tiene_objeto_gasto_sin_clasificar) AS tiene_objeto_gasto_sin_clasificar,
        BOOL_OR(tiene_oee_sin_clasificar) AS tiene_oee_sin_clasificar,
        BOOL_OR(tiene_cotizacion_usd_faltante) AS tiene_cotizacion_usd_faltante,
        BOOL_OR(tiene_regimen_salarial_faltante) AS tiene_regimen_salarial_faltante,

        MIN(fecha_carga_staging) AS fecha_carga_staging_min,
        MAX(fecha_carga_staging) AS fecha_carga_staging_max,
        STRING_AGG(DISTINCT fuente_archivo, ' | ') AS fuentes_archivo_lista
    FROM core.fact_remuneraciones_componentes
    GROUP BY
        anho,
        mes,
        fecha_periodo,
        nivel,
        entidad,
        oee,
        documento
), derivado AS (
    SELECT
        a.*,

        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(remuneracion_total_gs / cotizacion_usd_promedio, 2)
        END AS remuneracion_total_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(total_devengado_gs / cotizacion_usd_promedio, 2)
        END AS total_devengado_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(salario_basico_gs / cotizacion_usd_promedio, 2)
        END AS salario_basico_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(honorarios_gs / cotizacion_usd_promedio, 2)
        END AS honorarios_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(viaticos_gs / cotizacion_usd_promedio, 2)
        END AS viaticos_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(beneficios_gs / cotizacion_usd_promedio, 2)
        END AS beneficios_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(bonificaciones_gs / cotizacion_usd_promedio, 2)
        END AS bonificaciones_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(gastos_representacion_gs / cotizacion_usd_promedio, 2)
        END AS gastos_representacion_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(aguinaldo_gs / cotizacion_usd_promedio, 2)
        END AS aguinaldo_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(otros_componentes_gs / cotizacion_usd_promedio, 2)
        END AS otros_componentes_usd,
        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(becas_transferencias_gs / cotizacion_usd_promedio, 2)
        END AS becas_transferencias_usd,

        ratio_pct(salario_basico_gs, remuneracion_total_gs) AS participacion_salario_basico_pct,
        ratio_pct(honorarios_gs, remuneracion_total_gs) AS participacion_honorarios_pct,
        ratio_pct(viaticos_gs, remuneracion_total_gs) AS participacion_viaticos_pct,
        ratio_pct(beneficios_gs, remuneracion_total_gs) AS participacion_beneficios_pct,
        ratio_pct(bonificaciones_gs, remuneracion_total_gs) AS participacion_bonificaciones_pct,
        ratio_pct(gastos_representacion_gs, remuneracion_total_gs) AS participacion_gastos_representacion_pct,
        ratio_pct(aguinaldo_gs, remuneracion_total_gs) AS participacion_aguinaldo_pct,
        ratio_pct(otros_componentes_gs, remuneracion_total_gs) AS participacion_otros_componentes_pct,

        ratio_pct(salario_basico_gs, remuneracion_total_gs) AS ratio_salario_basico_sobre_remuneracion_total_pct,
        ratio_pct(bonificaciones_gs, remuneracion_total_gs) AS ratio_bonificaciones_sobre_remuneracion_total_pct,
        ratio_pct(viaticos_gs, remuneracion_total_gs) AS ratio_viaticos_sobre_remuneracion_total_pct,

        CASE
            WHEN salario_minimo_mensual_gs IS NULL OR salario_minimo_mensual_gs = 0 THEN NULL
            ELSE ROUND(remuneracion_total_gs / salario_minimo_mensual_gs, 4)
        END AS remuneracion_en_salarios_minimos,

        CASE
            WHEN fecha_nacimiento IS NULL OR fecha_periodo IS NULL THEN NULL
            WHEN fecha_nacimiento > fecha_periodo THEN NULL
            ELSE date_diff('year', fecha_nacimiento, fecha_periodo)
        END AS edad,

        CASE
            WHEN fecha_nacimiento IS NULL THEN NULL
            ELSE EXTRACT(YEAR FROM fecha_nacimiento)
        END AS anho_nacimiento,

        CASE
            WHEN anho_ingreso IS NULL OR anho IS NULL THEN NULL
            WHEN anho_ingreso = 0 THEN NULL
            WHEN anho_ingreso < 1900 THEN NULL
            WHEN anho_ingreso > anho THEN NULL
            ELSE anho - anho_ingreso
        END AS antiguedad_anhos
    FROM agregado a
), segmentado AS (
    SELECT
        d.*,
        CASE
            WHEN edad IS NULL THEN 'NO INFORMADO'
            WHEN edad < 18 THEN '<18'
            WHEN edad BETWEEN 18 AND 24 THEN '18-24'
            WHEN edad BETWEEN 25 AND 34 THEN '25-34'
            WHEN edad BETWEEN 35 AND 44 THEN '35-44'
            WHEN edad BETWEEN 45 AND 54 THEN '45-54'
            WHEN edad BETWEEN 55 AND 64 THEN '55-64'
            WHEN edad >= 65 THEN '65+'
            ELSE 'NO CLASIFICADO'
        END AS rango_etario,

        CASE
            WHEN anho_nacimiento IS NULL THEN 'NO INFORMADO'
            WHEN anho_nacimiento >= 2013 THEN 'ALPHA / FUERA DE EDAD LABORAL ESPERADA'
            WHEN anho_nacimiento BETWEEN 1997 AND 2012 THEN 'GEN Z'
            WHEN anho_nacimiento BETWEEN 1981 AND 1996 THEN 'MILLENNIALS'
            WHEN anho_nacimiento BETWEEN 1965 AND 1980 THEN 'GEN X'
            WHEN anho_nacimiento BETWEEN 1946 AND 1964 THEN 'BABY BOOMERS'
            WHEN anho_nacimiento BETWEEN 1928 AND 1945 THEN 'GENERACION SILENCIOSA'
            WHEN anho_nacimiento < 1928 THEN 'GENERACION ANTERIOR'
            ELSE 'NO CLASIFICADO'
        END AS generacion,

        CASE
            WHEN antiguedad_anhos IS NULL THEN 'NO INFORMADO'
            WHEN antiguedad_anhos < 1 THEN '<1'
            WHEN antiguedad_anhos BETWEEN 1 AND 4 THEN '1-4'
            WHEN antiguedad_anhos BETWEEN 5 AND 9 THEN '5-9'
            WHEN antiguedad_anhos BETWEEN 10 AND 19 THEN '10-19'
            WHEN antiguedad_anhos BETWEEN 20 AND 29 THEN '20-29'
            WHEN antiguedad_anhos >= 30 THEN '30+'
            ELSE 'NO CLASIFICADO'
        END AS rango_antiguedad,

        CASE
            WHEN remuneracion_total_gs IS NULL OR remuneracion_total_gs <= 0 THEN 'SIN MONTO'
            WHEN salario_minimo_mensual_gs IS NULL OR salario_minimo_mensual_gs = 0 THEN 'SIN REGIMEN SALARIAL'
            WHEN remuneracion_total_gs < salario_minimo_mensual_gs THEN 'MENOR A 1 SM'
            WHEN remuneracion_total_gs <= salario_minimo_mensual_gs * 2 THEN '1 A 2 SM'
            WHEN remuneracion_total_gs <= salario_minimo_mensual_gs * 5 THEN '2 A 5 SM'
            WHEN remuneracion_total_gs <= salario_minimo_mensual_gs * 10 THEN '5 A 10 SM'
            ELSE 'MAS DE 10 SM'
        END AS rango_salarios_minimos
    FROM derivado d
), estadisticas_institucionales AS (
    SELECT
        anho,
        mes,
        nivel,
        entidad,
        oee,
        AVG(remuneracion_total_gs) AS promedio_institucional_gs,
        MEDIAN(remuneracion_total_gs) AS mediana_institucional_gs,
        QUANTILE_CONT(remuneracion_total_gs, 0.25) AS p25_institucional_gs,
        QUANTILE_CONT(remuneracion_total_gs, 0.75) AS p75_institucional_gs,
        QUANTILE_CONT(remuneracion_total_gs, 0.90) AS p90_institucional_gs,
        QUANTILE_CONT(remuneracion_total_gs, 0.95) AS p95_institucional_gs,
        SUM(remuneracion_total_gs) AS total_institucional_gs,
        COUNT(*) AS total_registros_institucionales
    FROM segmentado
    GROUP BY anho, mes, nivel, entidad, oee
), estadisticas_tipo AS (
    SELECT
        anho,
        mes,
        tipo_funcionario_inferido,
        AVG(remuneracion_total_gs) AS promedio_tipo_funcionario_gs,
        MEDIAN(remuneracion_total_gs) AS mediana_tipo_funcionario_gs
    FROM segmentado
    GROUP BY anho, mes, tipo_funcionario_inferido
), con_estadisticas AS (
    SELECT
        s.*,
        ei.promedio_institucional_gs,
        ei.mediana_institucional_gs,
        ei.p25_institucional_gs,
        ei.p75_institucional_gs,
        ei.p90_institucional_gs,
        ei.p95_institucional_gs,
        ei.total_institucional_gs,
        ei.total_registros_institucionales,
        et.promedio_tipo_funcionario_gs,
        et.mediana_tipo_funcionario_gs
    FROM segmentado s
    LEFT JOIN estadisticas_institucionales ei
           ON s.anho = ei.anho
          AND s.mes = ei.mes
          AND s.nivel = ei.nivel
          AND s.entidad = ei.entidad
          AND s.oee = ei.oee
    LEFT JOIN estadisticas_tipo et
           ON s.anho = et.anho
          AND s.mes = et.mes
          AND s.tipo_funcionario_inferido = et.tipo_funcionario_inferido
), rankings AS (
    SELECT
        ce.*,
        CUME_DIST() OVER (
            PARTITION BY anho, mes
            ORDER BY remuneracion_total_gs
        ) AS percentil_salarial_global,
        CUME_DIST() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
            ORDER BY remuneracion_total_gs
        ) AS percentil_salarial_institucional,
        DENSE_RANK() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
            ORDER BY remuneracion_total_gs DESC
        ) AS ranking_salarial_institucion,
        DENSE_RANK() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee, cargo_principal
            ORDER BY remuneracion_total_gs DESC
        ) AS ranking_salarial_institucion_cargo,
        DENSE_RANK() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee, tipo_funcionario_inferido
            ORDER BY remuneracion_total_gs DESC
        ) AS ranking_salarial_institucion_tipo_funcionario
    FROM con_estadisticas ce
)
SELECT
    r.*,

    ROUND(remuneracion_total_gs - promedio_institucional_gs, 2) AS brecha_promedio_institucional_gs,
    ratio_pct(remuneracion_total_gs - promedio_institucional_gs, promedio_institucional_gs) AS brecha_promedio_institucional_pct,

    ROUND(remuneracion_total_gs - mediana_institucional_gs, 2) AS brecha_mediana_institucional_gs,
    ratio_pct(remuneracion_total_gs - mediana_institucional_gs, mediana_institucional_gs) AS brecha_mediana_institucional_pct,

    CASE
        WHEN remuneracion_total_gs IS NULL THEN 'SIN DATO'
        WHEN p75_institucional_gs IS NULL OR p25_institucional_gs IS NULL THEN 'SIN REFERENCIA'
        WHEN remuneracion_total_gs >= p75_institucional_gs THEN 'ALTA'
        WHEN remuneracion_total_gs < p25_institucional_gs THEN 'BAJA'
        ELSE 'MEDIA'
    END AS indicador_remuneracion_alta_media_baja,

    ratio_pct(remuneracion_total_gs, total_institucional_gs) AS participacion_en_total_institucional_pct,

    CASE
        WHEN total_registros_institucionales IS NULL OR total_registros_institucionales < 10 THEN FALSE
        WHEN ratio_pct(remuneracion_total_gs, total_institucional_gs) >= 5 THEN TRUE
        WHEN p95_institucional_gs IS NOT NULL AND remuneracion_total_gs >= p95_institucional_gs THEN TRUE
        ELSE FALSE
    END AS indicador_posible_concentracion_salarial,

    CASE WHEN percentil_salarial_institucional >= 0.90 THEN TRUE ELSE FALSE END AS es_top_10_pct_institucional,
    CASE WHEN percentil_salarial_global >= 0.99 THEN TRUE ELSE FALSE END AS es_top_1_pct_global,

    CASE
        WHEN p25_institucional_gs IS NULL OR p75_institucional_gs IS NULL THEN FALSE
        WHEN remuneracion_total_gs > p75_institucional_gs + 1.5 * (p75_institucional_gs - p25_institucional_gs) THEN TRUE
        ELSE FALSE
    END AS es_outlier_salarial_iqr,

    md5(
        COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
        COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
        COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
        COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
        COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
        COALESCE(CAST(documento AS VARCHAR), '')
    ) AS hash_funcionario_mes,

    CURRENT_TIMESTAMP AS fecha_carga_core
FROM rankings r;

-- Alias semántico usado por la capa DATAMART.
CREATE OR REPLACE VIEW core.remuneraciones_funcionario_mes AS
SELECT *
FROM core.fact_remuneraciones_funcionario_mes;

-- ============================================================
-- 9) Vistas analíticas CORE de apoyo
-- ============================================================
CREATE OR REPLACE VIEW core.vw_remuneraciones_universidades_nacionales AS
SELECT *
FROM core.fact_remuneraciones_funcionario_mes
WHERE es_universidad_nacional = TRUE;

CREATE OR REPLACE VIEW core.vw_componentes_universidades_nacionales AS
SELECT *
FROM core.fact_remuneraciones_componentes
WHERE es_universidad_nacional = TRUE;

-- ============================================================
-- 10) Controles de CORE
-- ============================================================
CREATE OR REPLACE VIEW core.vw_control_core_registros AS
SELECT 'core.dim_periodo_mensual' AS tabla, COUNT(*) AS total_registros FROM core.dim_periodo_mensual
UNION ALL
SELECT 'core.dim_institucion_oee' AS tabla, COUNT(*) AS total_registros FROM core.dim_institucion_oee
UNION ALL
SELECT 'core.dim_clasificador_gasto' AS tabla, COUNT(*) AS total_registros FROM core.dim_clasificador_gasto
UNION ALL
SELECT 'core.dim_cotizacion_usd_mensual' AS tabla, COUNT(*) AS total_registros FROM core.dim_cotizacion_usd_mensual
UNION ALL
SELECT 'core.dim_regimen_salarial_mensual' AS tabla, COUNT(*) AS total_registros FROM core.dim_regimen_salarial_mensual
UNION ALL
SELECT 'core.map_objeto_gasto_componente' AS tabla, COUNT(*) AS total_registros FROM core.map_objeto_gasto_componente
UNION ALL
SELECT 'core.fact_remuneraciones_componentes' AS tabla, COUNT(*) AS total_registros FROM core.fact_remuneraciones_componentes
UNION ALL
SELECT 'core.fact_remuneraciones_funcionario_mes' AS tabla, COUNT(*) AS total_registros FROM core.fact_remuneraciones_funcionario_mes;

CREATE OR REPLACE VIEW core.vw_control_core_componentes AS
SELECT
    componente_remunerativo,
    incluir_en_remuneracion_principal,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT documento_hash) AS total_documentos_hash,
    SUM(monto_componente_gs) AS total_componente_gs,
    SUM(monto_remunerativo_principal_gs) AS total_remunerativo_principal_gs,
    SUM(monto_beca_transferencia_gs) AS total_beca_transferencia_gs
FROM core.fact_remuneraciones_componentes
GROUP BY componente_remunerativo, incluir_en_remuneracion_principal
ORDER BY total_componente_gs DESC;

CREATE OR REPLACE VIEW core.vw_control_core_calidad_modelo AS
SELECT
    COUNT(*) AS total_registros_funcionario_mes,
    SUM(CASE WHEN descripcion_oee IS NULL OR descripcion_oee = 'NO INFORMADO' THEN 1 ELSE 0 END) AS registros_sin_descripcion_oee,
    SUM(CASE WHEN cotizacion_usd_promedio IS NULL THEN 1 ELSE 0 END) AS registros_sin_cotizacion_usd,
    SUM(CASE WHEN salario_minimo_mensual_gs IS NULL THEN 1 ELSE 0 END) AS registros_sin_regimen_salarial,
    SUM(CASE WHEN remuneracion_total_gs < 0 THEN 1 ELSE 0 END) AS registros_remuneracion_negativa,
    SUM(CASE WHEN remuneracion_total_gs = 0 THEN 1 ELSE 0 END) AS registros_remuneracion_cero,
    SUM(CASE WHEN edad IS NOT NULL AND (edad < 18 OR edad > 100) THEN 1 ELSE 0 END) AS registros_edad_sospechosa,
    SUM(CASE WHEN antiguedad_anhos IS NOT NULL AND antiguedad_anhos > 60 THEN 1 ELSE 0 END) AS registros_antiguedad_sospechosa,
    SUM(CASE WHEN tipo_funcionario_inferido = 'NO_DETERMINABLE_CON_FUENTE_ACTUAL' THEN 1 ELSE 0 END) AS registros_tipo_funcionario_no_determinable,
    SUM(CASE WHEN tiene_objeto_gasto_sin_clasificar THEN 1 ELSE 0 END) AS registros_con_objeto_gasto_sin_clasificar
FROM core.fact_remuneraciones_funcionario_mes;

CREATE OR REPLACE TABLE audit.validacion_core_cantidad_registros AS
SELECT
    CURRENT_TIMESTAMP AS fecha_validacion,
    *
FROM core.vw_control_core_registros;

-- ============================================================
-- 11) Auditoría de ejecución
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT
    CURRENT_TIMESTAMP,
    '03_core_modelo.sql',
    'core',
    'core_model',
    'ok',
    (SELECT COUNT(*) FROM core.fact_remuneraciones_funcionario_mes),
    'Modelo core generado: dimensiones, fact de componentes y consolidado funcionario/OEE/mes sin depender de cargo/funcion no disponibles';
