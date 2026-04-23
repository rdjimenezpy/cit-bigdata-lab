
-- Verificar sufijo en documento
select right(documento, 1) as ctrl, count(*) from raw.sfp_nomina
where left(documento, 1) <> 'V' and
right(documento, 1) not between '0' and '9'
group by ctrl;

select * from stg.sfp_nomina_limpio;

---- Cruce de datos para consolidar
drop table if exists stg.persona_limpio;

create unlogged table stg.persona_limpio as
with tmp_funcionario as ( --276.059 / 275788
	select distinct documento_identidad as documento_identidad, (apellidos || ' ' || nombres) as funcionario,
	sexo, fecha_nacimiento
	from stg.sfp_nomina_limpio
	where documento_control not in('E', 'A')
), tmp_persona as (
	select
		regexp_replace(trim(documento), '^0', '') as cedula,
		(apellidos || ' ' || nombres) as persona,
		cast(fecha_nacimiento as date),
		nacionalidad,
		case when sexo = 'M' then 'MASCULINO' else 'FEMENINO' end as sexo
	from fdw.personas
)
select f.documento_identidad, f.funcionario, f.sexo, f.fecha_nacimiento,
p.cedula, p.persona, p.fecha_nacimiento as fecha_nac, p.nacionalidad, p.sexo as sex
from tmp_funcionario f
join tmp_persona p
	on p.cedula = f.documento_identidad;



--- Revisión de datos de consolidado de personas
select * from stg.persona_limpio;

select count(*) from stg.persona_limpio; -- 275.788
select count(distinct documento_identidad) from stg.persona_limpio; -- 275.788

select count(*) from stg.persona_limpio where documento_identidad is not null;
select count(*) from stg.persona_limpio where cedula is not null; -- 189.058
select * from stg.persona_limpio where fecha_nacimiento is null; -- 57

select documento_identidad, count(*) from stg.persona_limpio
group by documento_identidad having count(*) > 1;