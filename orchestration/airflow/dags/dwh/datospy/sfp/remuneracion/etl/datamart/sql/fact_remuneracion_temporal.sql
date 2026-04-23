
-- PASO 1: TRUNCAMOS LA TABLA TEMPORAL FACT REMUNERACION
TRUNCATE TABLE stage.fact_remuneracion_temporal;

-- PASO 2: CARGAMOS EN LA TABLA TEMPORAL FACT REMUNERACION CON EL PEGADO DE CLAVES SK
INSERT INTO stage.fact_remuneracion_temporal
SELECT
    stg.periodo_sk,
    stg.institucion_nivel_codigo,
    stg.institucion_entidad_codigo,
    stg.institucion_oee_codigo,
    di.institucion_sk,
    stg.funcionario_documento,
    df.funcionario_sk,
    stg.fecha_nacimiento,
    stg.edad_sk,
    stg.estado_descripcion,
    de.estado_sk,
    stg.fuente_financiamiento_codigo,
    dff.fuente_financiamiento_sk,
    stg.objeto_gasto_codigo,
    dgc.clasificacion_gasto_sk,
    stg.anho_nacimiento_sk,
    stg.anho_ingreso,
    stg.es_vacante,
    stg.es_anonimo,
    stg.monto_presupuestado,
    stg.monto_devengado,
    stg.monto_descuento
FROM
    stage.vw_stg_fact_remuneracion_temporal stg
        LEFT JOIN datamart.dim_institucion di ON di.nivel_codigo = stg.institucion_nivel_codigo AND di.entidad_codigo = stg.institucion_entidad_codigo AND di.oee_codigo = stg.institucion_oee_codigo
        LEFT JOIN datamart.dim_estado de ON de.estado_descripcion = stg.estado_descripcion
        LEFT JOIN datamart.dim_funcionario df ON df.documento = stg.funcionario_documento
        LEFT JOIN datamart.dim_fuente_financiamiento dff ON dff.fuente_financiamiento_codigo = stg.fuente_financiamiento_codigo
        LEFT JOIN datamart.dim_clasificacion_gasto dgc ON dgc.objeto_gasto_codigo = stg.objeto_gasto_codigo
;