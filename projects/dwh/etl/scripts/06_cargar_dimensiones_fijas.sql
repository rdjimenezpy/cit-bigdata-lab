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


-- ###########################################################################
-- Tabla objetivo: DIM_FECHA
-- ###########################################################################

-- drop procedure if exists datamart.sp_cargar_dim_fecha;

-- CREAMOS O MODIFICANOS NUESTRO PROCEDIMIENTO DE CARGA DE LA TABLA DIMENSION FECHA
create or replace procedure datamart.sp_cargar_dim_fecha(fdesde date, fhasta date)
	language plpgsql
as $stored_procedure$
begin

	truncate table datamart.dim_fecha restart identity;

	insert into datamart.dim_fecha 
	select *
	from stage.fn_get_stg_fecha(fdesde, fhasta);

end; $stored_procedure$;

-- CARGAMOS LA DIMENSION FECHA PARA UN RANGO DE FECHA
call datamart.sp_cargar_dim_fecha('2010-01-01', '2030-12-31');

-- select * from datamart.dim_fecha;


-- ###########################################################################
-- Tabla objetivo: DIM_PERIODO
-- ###########################################################################

-- drop procedure if exists datamart.sp_cargar_dim_periodo;

-- CREAMOS O MODIFICANOS NUESTRO PROCEDIMIENTO DE CARGA DE LA TABLA DIMENSION PERIODO
create or replace procedure datamart.sp_cargar_dim_periodo(fdesde date, fhasta date)
	language plpgsql
as $stored_procedure$
begin

	truncate table datamart.dim_periodo restart identity;

	insert into datamart.dim_periodo
	select distinct
		periodo as periodo_sk,
		anho,
		semestre,
		anho_semestre,
		trimestre,
		anho_trimestre,
		mes,
		mes_nombre,
		mes_nombre_corto,
		cuatrimestre,
		anho_cuatrimestre,
		case -- Períodos del año, se ajustan a su organizacion y pais.
			when to_char(fecha_sk, 'MM')::int2 between 1 and 3 then 'VERANO'
		    when to_char(fecha_sk, 'MM')::int2 between 4 and 6 then 'OTOÑO'
		    when to_char(fecha_sk, 'MM')::int2 between 7 and 9 then 'INVIERNO'
		    when to_char(fecha_sk, 'MM')::int2 between 10 and 12 then 'PRIMAVERA'
		end::varchar(16) 								as estacion_del_anho
	from stage.fn_get_stg_fecha(fdesde, fhasta)
	order by periodo;

end; $stored_procedure$;

-- CARGAMOS LA DIMENSION PERIODO PARA UN RANGO DE FECHA
call datamart.sp_cargar_dim_periodo('2010-01-01', '2030-12-31');

-- select * from datamart.dim_periodo;


-- ###########################################################################
-- Tabla objetivo: DIM_FUENTE_FINANCIAMIENTO
-- ###########################################################################

-- CARGAMOS LAS PARAMETRICAS PARA LA DIMENSION FUENTE DE FINACIAMIENTOS 
insert into datamart.dim_fuente_financiamiento (fuente_financiamiento_codigo, fuente_financiamiento_descripcion, fecha_ultima_modificacion) values
('10', 'TESORO PUBLICO', now()),
('20', 'PRESTAMOS', now()),
('30', 'GENERADOS POR LAS PROPIAS INSTITUCIONES', now()),
('-1', 'DESCONOCIDO', now());


-- ###########################################################################
-- Tabla objetivo: DIM_ESTADO
-- ###########################################################################

-- CARGAMOS LAS PARAMETRICAS PARA LA DIMENSION ESTADO
insert into datamart.dim_estado (estado_codigo, estado_descripcion, fecha_ultima_modificacion) values
(100, 'COMISIONADO', now()),
(200, 'CONTRATADO', now()),
(300, 'PERMANENTE', now()),
( -1, 'DESCONOCIDO', now());