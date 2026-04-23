/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS DDL PARA CREAR TABLAS EN EL ESQUEMA RAW.
 * 
 * Descripción: Etapa de extracción de datos en bruto.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- raw_sfp_oee DEFINITION

-- DROP TABLE raw.raw_sfp_oee;

CREATE TABLE raw.raw_sfp_oee (
	codigo_nivel SMALLINT,
	descripcion_nivel VARCHAR(64),
	codigo_entidad SMALLINT,
	descripcion_entidad VARCHAR(76),
	codigo_oee SMALLINT,
	descripcion_oee VARCHAR(116),
	descripcion_corta VARCHAR(24)
);


-- raw_sfp_nomina DEFINITION

-- drop table if exists raw.raw_sfp_nomina;

CREATE TABLE raw.raw_sfp_nomina (
	anho int2 NULL,
	mes int2 NULL,
	nivel int2 NULL,
	descripcion_nivel text NULL,
	entidad int2 NULL,
	descripcion_entidad text NULL,
	oee int2 NULL,
	descripcion_oee text NULL,
	documento text NULL,
	nombres text NULL,
	apellidos text NULL,
	sexo text NULL,
	fecha_nacimiento text NULL,
	discapacidad text NULL,
	tipo_discapacidad text NULL,
	profesion text NULL,
	anho_ingreso int2 NULL,
	cargo text NULL,
	funcion text NULL,
	estado text NULL,
	fuente_financiamiento int2 NULL,
	objeto_gasto int2 NULL,
	concepto text NULL,
	linea text NULL,
	categoria text NULL,
	presupuestado int4 NULL,
	devengado int4 NULL
);


-- raw_sfp_nomina_eliminado DEFINITION

-- drop table if exists raw.raw_sfp_nomina_eliminado;

CREATE TABLE raw.raw_sfp_nomina_eliminado (
	anho int2 NULL,
	mes int2 NULL,
	nivel int2 NULL,
	descripcion_nivel text NULL,
	entidad int2 NULL,
	descripcion_entidad text NULL,
	oee int2 NULL,
	descripcion_oee text NULL,
	documento text NULL,
	nombres text NULL,
	apellidos text NULL,
	sexo text NULL,
	fecha_nacimiento date NULL,
	discapacidad text NULL,
	tipo_discapacidad text NULL,
	profesion text NULL,
	anho_ingreso int2 NULL,
	cargo text NULL,
	funcion text NULL,
	estado text NULL,
	fuente_financiamiento int2 NULL,
	objeto_gasto int2 NULL,
	concepto text NULL,
	linea text NULL,
	categoria text NULL,
	presupuestado int4 NULL,
	devengado int4 NULL
);


-- raw.raw_cotizacion_referencial_bcp DEFINITION

-- DROP TABLE raw.raw_cotizacion_referencial_bcp;

CREATE TABLE raw.raw_cotizacion_referencial_bcp (
	anho int2 NULL,
	mes int2 NULL,
	moneda text NULL,
	abreviatura text NULL,
	me_usd text NULL,
	gs_me text NULL
);