
-- PASO 4: TRUNCAMOS LA TABLA PENDIENTE FACT REMUNERACION
TRUNCATE TABLE stage.fact_remuneracion_pendiente;

-- PASO 5:  CARGAMOS EN LA TABLA PENDIENTE FACT REMUNERACION
INSERT INTO stage.fact_remuneracion_pendiente
SELECT
    tmp.periodo_sk,
    tmp.institucion_nivel_codigo,
    tmp.institucion_entidad_codigo,
    tmp.institucion_oee_codigo,
    tmp.institucion_sk,
    tmp.funcionario_documento,
    tmp.funcionario_sk,
    tmp.fecha_nacimiento,
    tmp.edad_sk,
    tmp.estado_descripcion,
    tmp.estado_sk,
    tmp.fuente_financiamiento_codigo,
    tmp.fuente_financiamiento_sk,
    tmp.objeto_gasto_codigo,
    tmp.gasto_clasificacion_sk,
    tmp.anho_nacimiento_sk,
    tmp.anho_ingreso,
    tmp.es_vacante,
    tmp.es_anonimo,
    tmp.monto_presupuestado,
    tmp.monto_devengado,
    tmp.monto_descuento
FROM stage.fact_remuneracion_temporal tmp
WHERE tmp.periodo_sk IS NULL
   OR tmp.institucion_sk IS NULL
   OR tmp.funcionario_sk IS NULL
   OR tmp.edad_sk IS NULL
   OR tmp.estado_sk IS NULL
   OR tmp.fuente_financiamiento_sk IS NULL
   OR tmp.gasto_clasificacion_sk IS null
   OR tmp.anho_nacimiento_sk is NULL
   OR tmp.anho_ingreso IS NULL
   OR tmp.monto_presupuestado = 0
;
