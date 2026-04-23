

select distinct anho_ingreso from stage.sfp_nomina_temporal
order by anho_ingreso desc;

select distinct fecha_acto from stage.sfp_nomina_temporal
order by fecha_acto desc;

select distinct extarct(year from fecha_acto) from stage.sfp_nomina_temporal
order by anho_ingreso desc;

select distinct length(fecha_acto) from stage.sfp_nomina_temporal;

select fecha_acto from stage.sfp_nomina_temporal where length(fecha_acto) = 23;

select string_to_array(fecha_acto, '/'), 
	substring(fecha_acto FROM '^(.*?)/') AS resultado,
	split_part(fecha_acto, '/', 1)
from stage.sfp_nomina_temporal;


with my_table as (
	SELECT 
	    fecha_acto,
	    CASE 
	        WHEN CAST(split_part(fecha_acto, '/', 1) AS INTEGER) > 0
	             AND CAST(split_part(fecha_acto, '/', 1) AS INTEGER) <= EXTRACT(YEAR FROM CURRENT_DATE)
	        THEN 'Año válido'
	        ELSE 'Año no válido'
	    END AS validacion_año,
	    split_part(fecha_acto, '/', 1) AS año_extraído
	from stage.sfp_nomina_temporal
)
select * from my_table
where validacion_año = 'Año no válido';

--2013/07/01 00:00:00.000 (23)
--20213/11/10 00:00:00.000 (24)
--202023/12/04 00:00:00.000 (25)