
---query language
--step 1: create table tempory
CREATE TEMP TABLE tmp_moneda_extranjera AS
SELECT DISTINCT
    UPPER(TRIM(abreviatura))	AS moneda,
    UPPER(TRIM(
            REPLACE(REPLACE(REPLACE(moneda, ' ', ''), '*', ''), E'\n', '')
          )) AS descripcion
FROM
    raw.bcp_cotizacion_mensual_referencial
WHERE
    anho = EXTRACT(year FROM now())
  AND mes = EXTRACT(month FROM now()) - 1
ORDER BY moneda
;

--step 2: load data in dim table target
INSERT INTO datamart.dim_moneda_extranjera (moneda, descripcion)
SELECT moneda, descripcion FROM tmp_moneda_extranjera
ON CONFLICT (moneda)
DO UPDATE SET
    descripcion = EXCLUDED.descripcion,
    fecha_ultima_modificacion = NOW()
;

--step 3: delete table tempory
DROP TABLE tmp_moneda_extranjera;