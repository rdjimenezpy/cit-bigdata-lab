
-- PASO 3: CARGAMOS EN LA TABLA FACT REMUNERACION
INSERT INTO datamart.fact_remuneracion_mensual_sfp (
    periodo_sk,
    institucion_sk,
    funcionario_sk,
    estado_sk,
    fuente_financiamiento_sk,
    gasto_clasificacion_sk,
    edad_sk,
    anho_nacimiento_sk,
    anho_ingreso,
    es_vacante,
    es_anonimo,
    monto_presupuestado,
    monto_devengado,
    monto_descuento
)
SELECT DISTINCT
    tmp.periodo_sk,
    tmp.institucion_sk,
    tmp.funcionario_sk,
    tmp.estado_sk,
    tmp.fuente_financiamiento_sk,
    tmp.gasto_clasificacion_sk,
    tmp.edad_sk,
    tmp.anho_nacimiento_sk,
    tmp.anho_ingreso,
    tmp.es_vacante,
    tmp.es_anonimo,
    tmp.monto_presupuestado,
    tmp.monto_devengado,
    tmp.monto_descuento
FROM stage.fact_remuneracion_temporal tmp
WHERE tmp.periodo_sk IS NOT NULL
  AND tmp.institucion_sk IS NOT NULL
  AND tmp.funcionario_sk IS NOT NULL
  AND	tmp.edad_sk IS NOT NULL
  AND tmp.estado_sk IS NOT NULL
  AND tmp.fuente_financiamiento_sk IS NOT NULL
  AND tmp.gasto_clasificacion_sk IS NOT NULL
  and tmp.anho_nacimiento_sk IS NOT NULL
  AND tmp.anho_ingreso IS NOT NULL
  AND NOT tmp.monto_presupuestado = 0
ON CONFLICT (periodo_sk, institucion_sk, funcionario_sk, estado_sk, fuente_financiamiento_sk,
    gasto_clasificacion_sk, edad_sk, anho_nacimiento_sk, anho_ingreso, es_vacante, es_anonimo, monto_presupuestado, monto_devengado, monto_descuento)
    DO UPDATE SET
    fecha_ultima_modificacion = NOW()
;
