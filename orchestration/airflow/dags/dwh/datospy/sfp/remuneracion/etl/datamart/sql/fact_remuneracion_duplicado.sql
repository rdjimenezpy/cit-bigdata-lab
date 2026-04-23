
INSERT INTO stage.fact_remuneracion_duplicado
SELECT
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
    monto_descuento,
    count(*) AS cantidad_duplicado
FROM stage.fact_remuneracion_temporal
WHERE periodo_sk IS NOT NULL
  AND institucion_sk IS NOT NULL
  AND funcionario_sk IS NOT NULL
  AND	edad_sk IS NOT NULL
  AND estado_sk IS NOT NULL
  AND fuente_financiamiento_sk IS NOT NULL
  AND gasto_clasificacion_sk IS NOT NULL
  and anho_nacimiento_sk IS NOT NULL
  AND anho_ingreso IS NOT NULL
  AND NOT monto_presupuestado = 0
GROUP BY periodo_sk, institucion_sk, funcionario_sk, estado_sk, fuente_financiamiento_sk,
         gasto_clasificacion_sk, edad_sk, anho_nacimiento_sk, anho_ingreso, es_vacante,
         es_anonimo, monto_presupuestado, monto_devengado, monto_descuento
HAVING count(*) > 1;