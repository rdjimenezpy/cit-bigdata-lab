/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS DDL PARA CREAR VISTAS EN EL STAGE AREA.
 * 
 * Descripcion: Etapa de preparación de los datos.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */
 
-- ###########################################################################
-- Tabla objetivo: DIM_INSTITUCION
-- ###########################################################################
 
-- drop view stage.vw_stg_institucion;

create or replace view stage.vw_stg_institucion as
select
	nivel::int2 		as nivel_codigo,
	descripcion_nivel 	as nivel_descripcion,
	entidad::int2 		as entidad_codigo,
	descripcion_entidad as entidad_descripcion,
	oee::int2 			as oee_codigo,
	descripcion_oee 	as oee_descripcion
from raw.raw_nomina_sfp
order by nivel, entidad, oee;


-- ###########################################################################
-- Tabla objetivo: DIM_FUNCIONARIO
-- ###########################################################################

-- drop view stage.vw_temp_persona;

-- select * from stage.vw_temp_persona;

create or replace view stage.vw_temp_persona as
select
	documento,
	nombres,
	apellidos,
	fecha_nacimiento,
	sexo,
	case 
		when nacionalidad_ctrl between '1' and '9' then 'PARAGUAYA'
		when nacionalidad_ctrl = 'E' then 'EXTRANJERA'
		else 'DESCONOCIDO'
	end::varchar(12) as nacionalidad
from (
	select distinct
		documento::varchar(20)				as documento,
		upper(trim(nombres))::varchar(64)	as nombres,
		upper(trim(apellidos))::varchar(64)	as apellidos,
		upper(trim(sexo))::varchar(10)		as sexo,
		fecha_nacimiento::date				as fecha_nacimiento,
		substring(documento, 1, 1)			as nacionalidad_ctrl
	from
		raw.raw_nomina_sfp
	where
		documento is not null
		and nombres is not null
		and apellidos is not null
		and sexo is not null
		and fecha_nacimiento is not null
		and substring(documento, 1, 1) not in('A', 'V')
	order by documento
) p;


-- drop view stage.vw_temp_persona_discapacidad;

-- select * from stage.vw_temp_persona_discapacidad;

create or replace view stage.vw_temp_persona_discapacidad as
select
	documento,
	array_agg(tipo_discapacidad)	as tipo_discapacidad,
	array_agg(discapacidad)			as discapacidad 
from (
	select distinct
		documento::varchar(20)	as documento,
		trim(tipo_discapacidad)	as tipo_discapacidad,
		trim(discapacidad)		as discapacidad
	from
		raw.raw_nomina_sfp
	where
		documento is not null
		and nombres is not null
		and apellidos is not null
		and sexo is not null
		and fecha_nacimiento is not null
		and substring(documento, 1, 1) not in('A', 'V')
	order by documento
) pd
group by documento;


-- drop view stage.vw_stg_funcionario;

-- select * from stage.vw_stg_funcionario;

create or replace view stage.vw_stg_funcionario as
select
	p.documento,
	p.nombres,
	p.apellidos,
	p.fecha_nacimiento,
	p.sexo,
	p.nacionalidad,
   case
	when cardinality(pd.tipo_discapacidad) > 1 then 'DESCONOCIDO'
	else
		case
            when pd.tipo_discapacidad[1] is null         then 'NO APLICA'
            else upper(trim(pd.tipo_discapacidad[1]))
         end
   end::varchar(16) as tipo_discapacidad,
   case 
	when cardinality(pd.discapacidad) > 1 then false
	else
		case
			when pd.discapacidad[1] = 'SI' then true
			else false
		end
   end::boolean as discapacidad
from stage.vw_temp_persona p
join stage.vw_temp_persona_discapacidad pd on pd.documento = p.documento
order by documento;


-- ###########################################################################
-- Tablas objetivos: FACT_REMUNERACION_TEMPORAL
-- ###########################################################################


-- drop view stage.vw_stg_fact_remuneracion_temporal;

-- select * from stage.vw_stg_fact_remuneracion_temporal;

create or replace view stage.vw_stg_fact_remuneracion_temporal as
select
	(anho::char(4) || lpad(mes::char(2),2,'0'))::int	as periodo_sk,
	nivel::int2 										as institucion_nivel_codigo,
	entidad::int2 										as institucion_entidad_codigo,
	oee::int2 											as institucion_oee_codigo,
	case
		when substring(documento, 1, 1) in('A') then '-1' --ANONIMO
		when substring(documento, 1, 1) in('V') then '-2' --VACANTE
		when substring(documento, 1, 1) in('E') then '-3' --EXTRANJEROS
		else documento::varchar(20)
	end													as funcionario_documento,	
	fecha_nacimiento::date								as fecha_nacimiento,
	coalesce(extract(year 
		from age((anho::text || '-' || mes::text || '-' || '28')::date, 
			fecha_nacimiento::date)
	), -1)												as edad_sk,
	upper(trim(estado))::varchar(12)					as estado_descripcion,
	case
		when coalesce(anho_ingreso, -1)::int2 < 1900 then -1
		else anho_ingreso::int2
	end													as anho_ingreso,
	coalesce(fuente_financiamiento, '-1')::int2			as fuente_financiamiento_codigo,
	coalesce(objeto_gasto, -1)::int2					as objeto_gasto_codigo,
	case
		when substring(documento, 1, 1) in('V') then true
		else false
	end::boolean										as es_vacante,
	case
		when substring(documento, 1, 1) in('A') then true
		else false
	end::boolean										as es_anonimo,
	coalesce(presupuestado, 0)							as monto_presupuestado,
	coalesce(devengado, 0)								as monto_devengado,
	coalesce(presupuestado, 0) - coalesce(devengado, 0)	as monto_descuento
from raw.raw_nomina_sfp;


-- drop table if exists stage.fact_remuneracion_temporal;

CREATE TABLE stage.fact_remuneracion_temporal (
                periodo_sk INTEGER,
                institucion_nivel_codigo SMALLINT,
                institucion_entidad_codigo SMALLINT,
                institucion_oee_codigo SMALLINT,
                institucion_sk SMALLINT,
                funcionario_documento VARCHAR(20),
                funcionario_sk INTEGER,
                fecha_nacimiento DATE,
				edad_sk SMALLINT,
                estado_descripcion VARCHAR(20),
                estado_sk SMALLINT,
                fuente_financiamiento_codigo SMALLINT,
				fuente_financiamiento_sk SMALLINT,
                objeto_gasto_codigo SMALLINT,
				gasto_clasificacion_sk SMALLINT,
                anho_ingreso SMALLINT,
                es_vacante BOOLEAN,
                es_anonimo BOOLEAN,
                monto_presupuestado BIGINT,
                monto_devengado BIGINT,
                monto_descuento BIGINT
);

-- drop table if exists stage.fact_remuneracion_pendiente;

CREATE TABLE stage.fact_remuneracion_pendiente (
                periodo_sk INTEGER,
                institucion_nivel_codigo SMALLINT,
                institucion_entidad_codigo SMALLINT,
                institucion_oee_codigo SMALLINT,
                institucion_sk SMALLINT,
                funcionario_documento VARCHAR(20),
                funcionario_sk INTEGER,
                fecha_nacimiento DATE,
				edad_sk SMALLINT,
                estado_descripcion VARCHAR(20),
                estado_sk SMALLINT,
                fuente_financiamiento_codigo SMALLINT,
				fuente_financiamiento_sk SMALLINT,
                objeto_gasto_codigo SMALLINT,
				gasto_clasificacion_sk SMALLINT,
                anho_ingreso SMALLINT,
                es_vacante BOOLEAN,
                es_anonimo BOOLEAN,
                monto_presupuestado BIGINT,
                monto_devengado BIGINT,
                monto_descuento BIGINT
);
