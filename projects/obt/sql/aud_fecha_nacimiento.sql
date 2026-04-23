select * from stg.sfp_nomina_limpio;

select min(fecha_nacimiento), max(fecha_nacimiento) from stg.sfp_nomina_limpio;

-- FechaNacimiento
select
	extract(year from fecha_nacimiento) anho_nacimiento,
	extract(year from now()) - extract(year from fecha_nacimiento) as edad,
--	round(avg(extract(year from age(now(), fecha_nacimiento)))) as edad_promedio
	count(*)
from stg.sfp_nomina_limpio
group by anho_nacimiento
order by anho_nacimiento desc;