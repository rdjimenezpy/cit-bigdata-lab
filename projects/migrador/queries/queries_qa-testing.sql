/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: QUERIES VARIOS PARA ANALISIS DE LA CALIDAD DE LOS DATOS.
 * 
 * Descripción: Consultas varios.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */

/*
 * ANSLISIS vw_persona
 */

-- opcion 1

select
	documento,
	nombres as nombre,
	apellidos as apellido,
	fecha_nacimiento,
	case
		when sexo = 'FEMENINO' then 'F'
		when sexo = 'MASCULINO' then 'M'
		else 'N'
	end sexo_codigo,
	case 
		when ctrl between '1' and '9' then 'PY'
		when ctrl = 'E' then 'EX'
		else 'ND'
	end as nacionalidad_codigo,
	coalesce(tipo_discapacidad, 'CAPACIDAD') tipo_discapacidad_codigo,
	discapacidad
from
	(
		select distinct
			documento,
			nombres,
			apellidos,
			trim(sexo) as sexo,
			fecha_nacimiento::date,
			trim(tipo_discapacidad) as tipo_discapacidad,
			trim(discapacidad) as discapacidad,
			substring(documento, 1, 1) as ctrl
		from
			ods.ods_nomina_sfp
		where
			documento is not null
			and nombres is not null
			and apellidos is not null
			and sexo is not null
		order by documento
	) tmp
where
	ctrl not in('A', 'V')
;

-- select count(*) from stage.vw_persona; --271.192
-- select documento, count(documento) from stage.vw_persona group by documento having count(documento) > 1;
-- select distinct sexo_codigo from stage.vw_persona;
-- select distinct nacionalidad_codigo from stage.vw_persona;
-- select distinct discapacidad, tipo_discapacidad_codigo from stage.vw_persona;

select *
from stage.vw_persona p
join (select documento from stage.vw_persona group by documento having count(documento) > 1) t on p.documento = t.documento;


-- opcion 2
-- 301.794 / 270.997
select documento, count(documento) 
from (
	select distinct
		documento,
		nombres,
		apellidos,
		trim(sexo) as sexo,
		fecha_nacimiento::date,
		substring(documento, 1, 1) as nacionalidad_ctrl
	from
		ods.ods_nomina_sfp
	where
		documento is not null
		and nombres is not null
		and apellidos is not null
		and sexo is not null
		and fecha_nacimiento is not null
		and substring(documento, 1, 1) not in('A', 'V')
	order by documento
) p group by documento having count(documento) > 1;


/* analisis auxiliar */

select count(*) from stage.vw_auxiliar_persona; --270.997

select count(*) from stage.vw_auxiliar_persona_discapacidad; --270.997

select count(*) from stage.vw_persona; --270997

select documento, tipo_discapacidad, tipo_discapacidad[1], cardinality(tipo_discapacidad)
from stage.vw_auxiliar_persona_discapacidad where cardinality(tipo_discapacidad) = 1 and tipo_discapacidad[1] is not null;



EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)


CREATE view vw_cantidad_funcionarios_sexo AS(
select mes, sexo, count(distinct documento)
from historico_nomina_funcionarios_idx
where descripcion_oee = 'FACULTAD DE CIENCIAS MEDICAS (FCM)'
group by sexo, mes
order by mes
);

CREATE materialized view view_cantidad_funcionarios_sexo AS(
select mes, sexo, count(distinct documento)
from historico_nomina_funcionarios_idx
where descripcion_oee = 'FACULTAD DE CIENCIAS MEDICAS (FCM)'
group by sexo, mes
order by mes
);



