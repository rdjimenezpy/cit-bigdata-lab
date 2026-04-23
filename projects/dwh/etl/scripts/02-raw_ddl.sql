/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS DDL PARA CREAR TABLAS EN EL ESQUEMA RAW.
 * 
 * Descripción: Etapa de extracción de datos en bruto.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- drop table if exists raw.raw_nomina_sfp;

CREATE TABLE raw.raw_nomina_sfp (
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
