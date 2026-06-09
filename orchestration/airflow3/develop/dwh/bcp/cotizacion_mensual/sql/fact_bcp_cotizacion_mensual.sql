
---query language
--step 1: create table tempory
CREATE TEMP TABLE fact_bcp_cotizacion_mensual_temporal AS
SELECT
    stg.periodo_sk,
    dme.moneda_extranjera_sk,
    stg.cotizacion
FROM (
    SELECT DISTINCT
         (anho::text || lpad(mes::text,2,'0'))::int as periodo_sk,
         UPPER(TRIM(abreviatura)) AS moneda,
         ROUND(REPLACE(REPLACE(gs_me, '.', ''), ',', '.')::NUMERIC)::INT4 AS cotizacion
    FROM raw.raw_cotizacion_referencial_bcp
) stg
INNER JOIN datamart.dim_moneda_extranjera dme ON dme.moneda = stg.moneda
;

--step 2: load data in fact table target
INSERT INTO datamart.fact_bcp_cotizacion_mensual (periodo_sk, moneda_extranjera_sk, cotizacion)
SELECT
    periodo_sk,
    moneda_extranjera_sk,
    cotizacion
FROM fact_bcp_cotizacion_mensual_temporal
ORDER BY periodo_sk, moneda_extranjera_sk
ON CONFLICT (periodo_sk, moneda_extranjera_sk)
DO UPDATE SET
    cotizacion = EXCLUDED.cotizacion,
    fecha_ultima_modificacion = NOW()
;

--step 3: delete table tempory
DROP TABLE fact_bcp_cotizacion_mensual_temporal;