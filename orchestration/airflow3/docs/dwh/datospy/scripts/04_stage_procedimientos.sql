/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA CREAR TIPOS DE DATOS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS.
 * 
 * Descripción: Creamos tipos de datos, funciones y procedimientos almacenados.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */

-- drop type if exists stage.datos_stg_fecha cascade;

-- CREAMOS UN TIPO DE DATOS ESPECIAL PARA NUESTRA CONSULTA GET_STG_DIM_FECHA
create type stage.datos_stg_fecha as (
	fecha_sk 					date,
	anho 						int2,
	mes 						int2,
	mes_nombre 					varchar(12),
	mes_nombre_corto 			varchar(5),
	dia 						int2,
	dia_del_anho 				int2,
	dia_semana 					int2,
	dia_semana_nombre 			varchar(12),
	dia_semana_nombre_corto 	varchar(6),
	calendario_semana 			int2,
	fecha_formateada 			varchar(12),
	trimestre 					char(2),
	anho_trimestre 				varchar(8),
	cuatrimestre 				char(2),
	anho_cuatrimestre 			varchar(8),
	semestre 					char(2),
	anho_semestre 				varchar(8),
	anho_mes 					varchar(8),
	periodo						int,
	anho_calendario_semana 		varchar(8),
	es_dia_habil 				boolean,
	es_dia_festivo 				boolean,
	estacion_del_anho 			varchar(16)
);

-- drop function if exists stage.fn_get_stg_fecha;

-- CREAMOS O MODIFICANOS NUESTRA FUNCION GET_STG_DIM_FECHA
create or replace function stage.fn_get_stg_fecha(fdesde date, fhasta date)
	returns setof stage.datos_stg_fecha
	language plpgsql
as $function$
declare
   -- variable declaration
begin
   return query with tiempo as (
					select fdesde::date + sequence.dia as fecha
					from generate_series( 0, (select fhasta::date - fdesde::date) ) as sequence(dia)
				)
				select
					fecha											as fecha_sk, -- Clave subrogada
					extract(year from fecha)::int2 					as anho,
					extract(month from fecha)::int2 				as mes,
					upper(to_char(fecha, 'TMMonth'))::varchar(12)	as mes_nombre,
					to_char(fecha, 'TMMON')::varchar(5)				as mes_nombre_corto,
					extract(day from fecha)::int2					as dia,
					extract(doy from fecha)::int2 					as dia_del_anho,
					upper(to_char(fecha, 'TMD'))::int2				as dia_semana,
					upper(to_char(fecha, 'TMDay'))::varchar(12)		as dia_semana_nombre,
					upper(to_char(fecha, 'TMDY'))::varchar(6)		as dia_semana_nombre_corto,
					extract(week from fecha)::int2					as calendario_semana, -- Semana del calendario - ISO
					to_char(fecha, 'dd. mm. yyyy')::varchar(12)		as fecha_formateada,
					('T' || to_char(fecha, 'Q'))::char(2)			as trimestre,
					to_char(fecha, 'yyyy/"T"Q')::varchar(8)			as anho_trimestre,
					case
						when extract(month from fecha) between 1 and 4
							then 'C1'
						when extract(month from fecha) between 5 and 8
							then 'C2'
						else 'C3'
					end::char(2) 									as cuatrimestre,
					case
						when extract(month from fecha) between 1 and 4
							then to_char(fecha, 'yyyy')||'/C1'
						when extract(month from fecha) between 5 and 8
							then to_char(fecha, 'yyyy')||'/C2'
						else to_char(fecha, 'yyyy')||'/C3'
					end::varchar(8) 								as anho_cuatrimestre,	
					case
						when extract(month from fecha) between 1 and 6
							then 'S1'
						else 'S2' 
					end::char(2)									as semestre,
					case
						when extract(month from fecha) between 1 and 6
							then to_char(fecha, 'yyyy')||'/S1'
						else to_char(fecha, 'yyyy')||'/S2'
					end::varchar(8) 								as anho_semestre,
					to_char(fecha, 'yyyy/mm')::varchar(8) 			as anho_mes,
					to_char(fecha, 'yyyymm')::int 					as periodo,
					to_char(fecha, 'iyyy/IW')::varchar(8) 			as anho_calendario_semana, -- Año y semana del calendario - ISO
					case -- Fin de semana
						when extract(isodow from fecha) in (6, 7)
							then false
						else true
					end::boolean 									as es_dia_habil,
					case -- Días festivos fijos en Paraguay
						when to_char(fecha, 'MMDD') in ('0101', '0514', '0515', '0815', '1208', '1225')
							then true
						else false
					end::boolean 									as es_dia_festivo,
					case -- Períodos del año, se ajustan a su organizacion y pais.
						when to_char(fecha, 'MMDD') >= '1221' or to_char(fecha, 'MMDD') <= '0320' then 'VERANO'
					    when to_char(fecha, 'MMDD') between '0321' and '0620' then 'OTOÑO'
					    when to_char(fecha, 'MMDD') between '0621' and '0920' then 'INVIERNO'
					    when to_char(fecha, 'MMDD') between '0921' and '1220' then 'PRIMAVERA'
					end::varchar(16) 								as estacion_del_anho
				from tiempo;
end;
$function$
;

-- select * from stage.fn_get_stg_fecha('2024-01-01', '2024-12-31');