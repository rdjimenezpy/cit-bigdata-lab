drop table if exists metadata.bcp_moneda_periodo;

-- Generar una serie de fechas desde INICIAL hasta FINAL
with tmp_periodos as (
SELECT DISTINCT
    EXTRACT(YEAR FROM fecha)::TEXT AS anho, -- Extraer el año
    (EXTRACT(MONTH FROM fecha)::TEXT) AS mes, -- Extraer el mes
    false as procesado
FROM 
    generate_series('2023-11-01'::DATE, '2024-03-31'::DATE, '1 day'::INTERVAL) AS fecha
order by anho, mes
)
select
	anho::text as anho,
	lpad(mes::text, 2, '0') as mes,
	procesado
into metadata.bcp_moneda_periodo
from tmp_periodos
where not procesado
order by anho, mes;

--Get de periodos a procesar
select
	anho::text as anho,
	lpad(mes::text, 2, '0'),
	procesado 
from metadata.bcp_moneda_periodo
where not procesado
order by anho, mes;


select * from metadata.bcp_moneda_periodo;