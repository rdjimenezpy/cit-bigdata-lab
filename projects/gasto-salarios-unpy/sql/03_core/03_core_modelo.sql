-- ============================================================
-- 03_core_modelo.sql
-- Capa CORE: integración, reglas de negocio y métricas analíticas
-- ============================================================

-- ============================================================
-- 1) Dimensión calendario mensual observada
-- ============================================================
CREATE OR REPLACE TABLE core.dim_calendario_mensual AS
SELECT DISTINCT
    anho,
    mes,
    fecha_periodo,
    STRFTIME(fecha_periodo, '%Y-%m') AS periodo_yyyy_mm,
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
        ELSE NULL
    END AS mes_nombre,
    CASE
        WHEN mes BETWEEN 1 AND 3 THEN 1
        WHEN mes BETWEEN 4 AND 6 THEN 2
        WHEN mes BETWEEN 7 AND 9 THEN 3
        WHEN mes BETWEEN 10 AND 12 THEN 4
        ELSE NULL
    END AS trimestre,
    CURRENT_TIMESTAMP AS fecha_carga
FROM staging.funcionarios_modelo_ext
WHERE fecha_periodo IS NOT NULL;

-- ============================================================
-- 2) Dimensión OEE integrada:
--    Usa el clasificador OEE cuando existe y complementa con lo observado
--    en la fuente de funcionarios.
-- ============================================================
CREATE OR REPLACE TABLE core.dim_oee AS
WITH observados AS (
    SELECT DISTINCT
        nivel AS codigo_nivel,
        descripcion_nivel,
        entidad AS codigo_entidad,
        descripcion_entidad,
        oee AS codigo_oee,
        descripcion_oee,
        NULL::VARCHAR AS descripcion_corta,
        NULL::VARCHAR AS uri_oee,
        'funcionarios' AS origen
    FROM staging.funcionarios_modelo_ext
),
clasificador AS (
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
    FROM staging.clasificador_oee
),
unificado AS (
    SELECT * FROM clasificador
    UNION ALL
    SELECT * FROM observados
),
priorizado AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY codigo_nivel, codigo_entidad, codigo_oee
            ORDER BY CASE WHEN origen = 'clasificador_oee' THEN 1 ELSE 2 END
        ) AS rn
    FROM unificado
)
SELECT
    codigo_nivel,
    descripcion_nivel,
    codigo_entidad,
    descripcion_entidad,
    codigo_oee,
    descripcion_oee,
    descripcion_corta,
    uri_oee,
    CASE
        WHEN REGEXP_MATCHES(COALESCE(descripcion_entidad, '') || ' ' || COALESCE(descripcion_oee, ''),
                            'UNIVERSIDAD NACIONAL|FACULTAD DE|RECTORADO')
        THEN TRUE
        ELSE FALSE
    END AS es_universidad_nacional,
    CURRENT_TIMESTAMP AS fecha_carga
FROM priorizado
WHERE rn = 1;

-- ============================================================
-- 3) Dimensión clasificador de gastos
-- ============================================================
CREATE OR REPLACE TABLE core.dim_clasificador_gastos AS
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
    CURRENT_TIMESTAMP AS fecha_carga
FROM staging.clasificador_gastos;

-- ============================================================
-- 4) Régimen salarial mensual aplicable a cada período observado
--
-- Si el régimen cambia en julio y el período analizado es marzo,
-- se toma el último régimen salarial conocido anterior o igual al mes.
-- ============================================================
CREATE OR REPLACE TABLE core.dim_regimen_salarial_mensual AS
WITH periodos AS (
    SELECT DISTINCT anho, mes, fecha_periodo
    FROM staging.funcionarios_modelo_ext
    WHERE fecha_periodo IS NOT NULL
),
candidatos AS (
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
    LEFT JOIN staging.regimen_salarial_py r
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
    CURRENT_TIMESTAMP AS fecha_carga
FROM candidatos
WHERE rn = 1;

-- ============================================================
-- 5) Fact core por componente remunerativo
--    Grano: funcionario + OEE + período + objeto_gasto + concepto + línea + categoría
-- ============================================================
CREATE OR REPLACE TABLE core.fact_remuneraciones_componentes AS
WITH base AS (
    SELECT
        f.*,
        COALESCE(f.devengado_gs, f.presupuestado_gs, 0) AS monto_base_calculo_gs
    FROM staging.funcionarios_modelo_ext f
),
clasificado AS (
    SELECT
        b.*,

        g.grupo_codigo,
        g.grupo_descripcion,
        g.subgrupo_codigo,
        g.subgrupo_descripcion,
        g.objeto_gasto_descripcion,
        g.control_financiero_codigo,
        g.control_financiero_descripcion,
        g.clasificacion_gasto_descripcion,

        o.descripcion_corta AS oee_descripcion_corta,
        COALESCE(o.es_universidad_nacional, FALSE) AS es_universidad_nacional,

        c.cotizacion_usd_promedio,

        r.fecha_regimen,
        r.salario_minimo_mensual_gs,
        r.salario_neto_gs,

        CASE
            WHEN b.objeto_gasto IN (111, 112, 141, 142, 143, 144, 145, 146, 148, 161)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'SUELDO|SALARIO BASICO|SALARIO MENSUAL|JORNAL')
            THEN 'SALARIO_BASICO'

            WHEN b.objeto_gasto IN (232, 239)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'VIATIC')
            THEN 'VIATICOS'

            WHEN b.objeto_gasto IN (131, 138, 191, 192, 193, 194, 195)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'SUBSIDIO|SEGURO|UNIDAD BASICA ALIMENTARIA|UBA|ASIG\.?FAMILIAR|AYUDA')
            THEN 'BENEFICIOS'

            WHEN b.objeto_gasto IN (123, 125, 132, 133, 135, 136, 137, 139, 182, 183, 185, 199)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'BONIF|GRATIFIC|ADICIONAL|EXTRAORDINARIA|ESCALAFON')
            THEN 'BONIFICACIONES'

            WHEN b.objeto_gasto IN (113, 162)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'REPRESENTACION')
            THEN 'GASTOS_REPRESENTACION'

            WHEN b.objeto_gasto IN (114, 163)
              OR REGEXP_MATCHES(COALESCE(b.concepto, ''), 'AGUINALDO')
            THEN 'AGUINALDO'

            ELSE 'OTROS'
        END AS tipo_componente_salarial,

        CASE
            WHEN REGEXP_MATCHES(COALESCE(b.cargo, '') || ' ' || COALESCE(b.funcion, '') || ' ' || COALESCE(b.concepto, ''),
                                'DOCENT|CATEDRA|PROFESOR|ESCALAFON DOCENTE|INSTRUCTOR')
            THEN 'DOCENTE'
            WHEN REGEXP_MATCHES(COALESCE(b.cargo, '') || ' ' || COALESCE(b.funcion, ''),
                                'ADMINISTR|SECRETAR|AUXILIAR|TECNIC|ASISTENTE|JEFE|DIRECTOR|COORDINADOR|OPERADOR|ENCARGADO')
            THEN 'ADMINISTRATIVO'
            ELSE 'OTRO / NO CLASIFICADO'
        END AS tipo_funcionario_inferido,

        CASE
            WHEN b.estado = 'PERMANENTE' THEN 'PERMANENTE'
            WHEN b.estado = 'CONTRATADO' OR b.objeto_gasto BETWEEN 141 AND 148 THEN 'CONTRATADO'
            WHEN b.estado IS NULL THEN 'NO INFORMADO'
            ELSE b.estado
        END AS tipo_vinculo_inferido

    FROM base b
    LEFT JOIN core.dim_clasificador_gastos g
      ON b.objeto_gasto = g.objeto_gasto_codigo
    LEFT JOIN core.dim_oee o
      ON b.nivel = o.codigo_nivel
     AND b.entidad = o.codigo_entidad
     AND b.oee = o.codigo_oee
    LEFT JOIN staging.cotizacion_usd_mensual c
      ON b.anho = c.anho
     AND b.mes = c.mes
    LEFT JOIN core.dim_regimen_salarial_mensual r
      ON b.anho = r.anho
     AND b.mes = r.mes
)
SELECT
    *,
    CASE
        WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
        ELSE ROUND(monto_base_calculo_gs / cotizacion_usd_promedio, 2)
    END AS monto_base_calculo_usd,
    CASE
        WHEN salario_minimo_mensual_gs IS NULL OR salario_minimo_mensual_gs = 0 THEN NULL
        ELSE ROUND(monto_base_calculo_gs / salario_minimo_mensual_gs, 4)
    END AS monto_en_salarios_minimos,
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
        COALESCE(CAST(categoria AS VARCHAR), '')
    ) AS hash_componente
FROM clasificado;

-- ============================================================
-- 6) Tabla core consolidada por funcionario/OEE/período
--    Grano analítico recomendado:
--      anho + mes + nivel + entidad + oee + documento
-- ============================================================
CREATE OR REPLACE TABLE core.remuneraciones_funcionario_mes AS
WITH agregado AS (
    SELECT
        anho,
        mes,
        fecha_periodo,

        nivel,
        MAX(descripcion_nivel) AS descripcion_nivel,
        entidad,
        MAX(descripcion_entidad) AS descripcion_entidad,
        oee,
        MAX(descripcion_oee) AS descripcion_oee,
        MAX(oee_descripcion_corta) AS oee_descripcion_corta,
        BOOL_OR(es_universidad_nacional) AS es_universidad_nacional,

        documento,
        MAX(nombres) AS nombres,
        MAX(apellidos) AS apellidos,
        MAX(sexo) AS sexo,
        MAX(discapacidad) AS discapacidad,
        MAX(tipo_discapacidad) AS tipo_discapacidad,
        MAX(estado) AS estado,
        MAX(anho_ingreso) AS anho_ingreso,
        MIN(fecha_nacimiento) AS fecha_nacimiento,
        MAX(fecha_acto) AS fecha_acto,

        MAX(funcion) AS funcion_principal,
        MAX(cargo) AS cargo_principal,
        MAX(carga_horaria) AS carga_horaria_principal,
        MAX(profesion) AS profesion_principal,

        CASE
            WHEN SUM(CASE WHEN tipo_funcionario_inferido = 'DOCENTE' THEN 1 ELSE 0 END) > 0 THEN 'DOCENTE'
            WHEN SUM(CASE WHEN tipo_funcionario_inferido = 'ADMINISTRATIVO' THEN 1 ELSE 0 END) > 0 THEN 'ADMINISTRATIVO'
            ELSE 'OTRO / NO CLASIFICADO'
        END AS tipo_funcionario_inferido,
        CASE
            WHEN SUM(CASE WHEN tipo_vinculo_inferido = 'PERMANENTE' THEN 1 ELSE 0 END) > 0 THEN 'PERMANENTE'
            WHEN SUM(CASE WHEN tipo_vinculo_inferido = 'CONTRATADO' THEN 1 ELSE 0 END) > 0 THEN 'CONTRATADO'
            WHEN SUM(CASE WHEN tipo_vinculo_inferido = 'NO INFORMADO' THEN 1 ELSE 0 END) > 0 THEN 'NO INFORMADO'
            ELSE MAX(tipo_vinculo_inferido)
        END AS tipo_vinculo_inferido,

        COUNT(*) AS cantidad_componentes,
        COUNT(DISTINCT objeto_gasto) AS cantidad_objetos_gasto,
        COUNT(DISTINCT concepto) AS cantidad_conceptos,

        SUM(COALESCE(presupuestado_gs, 0)) AS remuneracion_presupuestada_total_gs,
        SUM(COALESCE(devengado_gs, 0)) AS remuneracion_devengada_total_gs,
        SUM(monto_base_calculo_gs) AS remuneracion_total_gs,

        SUM(CASE WHEN tipo_componente_salarial = 'SALARIO_BASICO' THEN monto_base_calculo_gs ELSE 0 END) AS salario_basico_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'VIATICOS' THEN monto_base_calculo_gs ELSE 0 END) AS viaticos_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'BENEFICIOS' THEN monto_base_calculo_gs ELSE 0 END) AS beneficios_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'BONIFICACIONES' THEN monto_base_calculo_gs ELSE 0 END) AS bonificaciones_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'GASTOS_REPRESENTACION' THEN monto_base_calculo_gs ELSE 0 END) AS gastos_representacion_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'AGUINALDO' THEN monto_base_calculo_gs ELSE 0 END) AS aguinaldo_gs,
        SUM(CASE WHEN tipo_componente_salarial = 'OTROS' THEN monto_base_calculo_gs ELSE 0 END) AS otros_componentes_gs,

        MAX(cotizacion_usd_promedio) AS cotizacion_usd_promedio,
        MAX(salario_minimo_mensual_gs) AS salario_minimo_mensual_gs,
        MAX(salario_neto_gs) AS salario_neto_referencia_gs,
        MAX(fecha_regimen) AS fecha_regimen_salarial,

        MIN(fecha_carga) AS fecha_carga_min,
        MAX(fecha_carga) AS fecha_carga_max
    FROM core.fact_remuneraciones_componentes
    GROUP BY
        anho, mes, fecha_periodo,
        nivel, entidad, oee,
        documento
),
derivado AS (
    SELECT
        a.*,

        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(remuneracion_total_gs / cotizacion_usd_promedio, 2)
        END AS remuneracion_total_usd,

        CASE
            WHEN cotizacion_usd_promedio IS NULL OR cotizacion_usd_promedio = 0 THEN NULL
            ELSE ROUND(salario_basico_gs / cotizacion_usd_promedio, 2)
        END AS salario_basico_usd,

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

        ratio_pct(salario_basico_gs, remuneracion_total_gs) AS participacion_salario_basico_pct,
        ratio_pct(viaticos_gs, remuneracion_total_gs) AS participacion_viaticos_pct,
        ratio_pct(beneficios_gs, remuneracion_total_gs) AS participacion_beneficios_pct,
        ratio_pct(bonificaciones_gs, remuneracion_total_gs) AS participacion_bonificaciones_pct,
        ratio_pct(gastos_representacion_gs, remuneracion_total_gs) AS participacion_gastos_representacion_pct,
        ratio_pct(aguinaldo_gs, remuneracion_total_gs) AS participacion_aguinaldo_pct,
        ratio_pct(otros_componentes_gs, remuneracion_total_gs) AS participacion_otros_componentes_pct,

        CASE
            WHEN salario_minimo_mensual_gs IS NULL OR salario_minimo_mensual_gs = 0 THEN NULL
            ELSE ROUND(remuneracion_total_gs / salario_minimo_mensual_gs, 4)
        END AS remuneracion_en_salarios_minimos,

        CASE
            WHEN fecha_nacimiento IS NULL OR fecha_periodo IS NULL THEN NULL
            ELSE date_diff('year', fecha_nacimiento, fecha_periodo)
        END AS edad,

        CASE
            WHEN anho_ingreso IS NULL OR anho IS NULL THEN NULL
            WHEN anho_ingreso > anho THEN NULL
            ELSE anho - anho_ingreso
        END AS antiguedad_anhos,

        CASE
            WHEN fecha_nacimiento IS NULL THEN NULL
            ELSE EXTRACT(YEAR FROM fecha_nacimiento)
        END AS anho_nacimiento
    FROM agregado a
),
segmentado AS (
    SELECT
        d.*,

        CASE
            WHEN edad IS NULL THEN 'NO INFORMADO'
            WHEN edad < 25 THEN '<25'
            WHEN edad BETWEEN 25 AND 34 THEN '25-34'
            WHEN edad BETWEEN 35 AND 44 THEN '35-44'
            WHEN edad BETWEEN 45 AND 54 THEN '45-54'
            WHEN edad BETWEEN 55 AND 64 THEN '55-64'
            WHEN edad >= 65 THEN '65+'
            ELSE 'NO CLASIFICADO'
        END AS rango_etario,

        CASE
            WHEN anho_nacimiento IS NULL THEN 'NO INFORMADO'
            WHEN anho_nacimiento >= 1997 THEN 'GEN Z'
            WHEN anho_nacimiento BETWEEN 1981 AND 1996 THEN 'MILLENNIALS'
            WHEN anho_nacimiento BETWEEN 1965 AND 1980 THEN 'GEN X'
            WHEN anho_nacimiento BETWEEN 1946 AND 1964 THEN 'BABY BOOMERS'
            WHEN anho_nacimiento BETWEEN 1928 AND 1945 THEN 'GENERACION SILENCIOSA'
            ELSE 'OTRA / NO CLASIFICADA'
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
            WHEN salario_minimo_mensual_gs IS NOT NULL
             AND remuneracion_total_gs < salario_minimo_mensual_gs THEN 'MENOR A 1 SM'
            WHEN salario_minimo_mensual_gs IS NOT NULL
             AND remuneracion_total_gs BETWEEN salario_minimo_mensual_gs AND salario_minimo_mensual_gs * 2 THEN '1 A 2 SM'
            WHEN salario_minimo_mensual_gs IS NOT NULL
             AND remuneracion_total_gs > salario_minimo_mensual_gs * 2
             AND remuneracion_total_gs <= salario_minimo_mensual_gs * 5 THEN '2 A 5 SM'
            WHEN salario_minimo_mensual_gs IS NOT NULL
             AND remuneracion_total_gs > salario_minimo_mensual_gs * 5 THEN 'MAS DE 5 SM'
            ELSE 'NO CLASIFICADO'
        END AS rango_salarios_minimos
    FROM derivado d
),
estadisticas AS (
    SELECT
        s.*,

        AVG(remuneracion_total_gs) OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
        ) AS promedio_institucional_gs,

        MEDIAN(remuneracion_total_gs) OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
        ) AS mediana_institucional_gs,

        QUANTILE_CONT(remuneracion_total_gs, 0.25) OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
        ) AS p25_institucional_gs,

        QUANTILE_CONT(remuneracion_total_gs, 0.75) OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
        ) AS p75_institucional_gs,

        SUM(remuneracion_total_gs) OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
        ) AS total_institucional_gs,

        AVG(remuneracion_total_gs) OVER (
            PARTITION BY anho, mes, tipo_funcionario_inferido
        ) AS promedio_tipo_funcionario_gs
    FROM segmentado s
)
SELECT
    e.*,

    ROUND(remuneracion_total_gs - promedio_institucional_gs, 2) AS brecha_promedio_institucional_gs,
    ratio_pct(remuneracion_total_gs - promedio_institucional_gs, promedio_institucional_gs) AS brecha_promedio_institucional_pct,

    ROUND(remuneracion_total_gs - mediana_institucional_gs, 2) AS brecha_mediana_institucional_gs,
    ratio_pct(remuneracion_total_gs - mediana_institucional_gs, mediana_institucional_gs) AS brecha_mediana_institucional_pct,

    CASE
        WHEN remuneracion_total_gs IS NULL THEN 'SIN DATO'
        WHEN remuneracion_total_gs >= p75_institucional_gs THEN 'ALTA'
        WHEN remuneracion_total_gs < p25_institucional_gs THEN 'BAJA'
        ELSE 'MEDIA'
    END AS indicador_remuneracion_alta_media_baja,

    ratio_pct(remuneracion_total_gs, total_institucional_gs) AS participacion_en_total_institucional_pct,

    CASE
        WHEN ratio_pct(remuneracion_total_gs, total_institucional_gs) >= 5 THEN TRUE
        ELSE FALSE
    END AS indicador_posible_concentracion_salarial,

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
    ) AS ranking_salarial_institucion_tipo_funcionario,

    CASE
        WHEN CUME_DIST() OVER (
            PARTITION BY anho, mes, nivel, entidad, oee
            ORDER BY remuneracion_total_gs
        ) >= 0.90 THEN TRUE
        ELSE FALSE
    END AS es_top_10_pct_institucional,

    CASE
        WHEN CUME_DIST() OVER (
            PARTITION BY anho, mes
            ORDER BY remuneracion_total_gs
        ) >= 0.99 THEN TRUE
        ELSE FALSE
    END AS es_top_1_pct_global,

    md5(
        COALESCE(CAST(anho AS VARCHAR), '') || '|' ||
        COALESCE(CAST(mes AS VARCHAR), '') || '|' ||
        COALESCE(CAST(nivel AS VARCHAR), '') || '|' ||
        COALESCE(CAST(entidad AS VARCHAR), '') || '|' ||
        COALESCE(CAST(oee AS VARCHAR), '') || '|' ||
        COALESCE(CAST(documento AS VARCHAR), '')
    ) AS hash_funcionario_mes,

    CURRENT_TIMESTAMP AS fecha_carga_core
FROM estadisticas e;

-- ============================================================
-- 7) Vista de universo de Universidades Nacionales
-- ============================================================
CREATE OR REPLACE VIEW core.vw_remuneraciones_universidades_nacionales AS
SELECT *
FROM core.remuneraciones_funcionario_mes
WHERE es_universidad_nacional = TRUE;

-- ============================================================
-- 8) Auditoría
-- ============================================================
INSERT INTO audit.etl_run_log
SELECT CURRENT_TIMESTAMP, '03_core_modelo.sql', 'core', 'core_model', 'ok', NULL,
       'Modelo core integrado y consolidado por funcionario/OEE/período';
