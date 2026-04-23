
-- CREATE DATABASE bigdata;

-- CREATE SCHEMA sample;

-- sample.raw_nomina_sfp definition

-- Drop table

-- DROP TABLE sample.raw_nomina_sfp;

CREATE TABLE sample.raw_nomina_sfp (
	anho text NULL,
	mes text NULL,
	nivel text NULL,
	descripcion_nivel text NULL,
	entidad text NULL,
	descripcion_entidad text NULL,
	oee text NULL,
	descripcion_oee text NULL,
	documento text NULL,
	nombres text NULL,
	apellidos text NULL,
	funcion text NULL,
	estado text NULL,
	carga_horaria text NULL,
	anho_ingreso text NULL,
	sexo text NULL,
	discapacidad text NULL,
	tipo_discapacidad text NULL,
	fuente_financiamiento text NULL,
	objeto_gasto text NULL,
	concepto text NULL,
	linea text NULL,
	categoria text NULL,
	cargo text NULL,
	presupuestado int8 NULL,
	devengado int8 NULL,
	movimiento text NULL,
	lugar text NULL,
	fecha_nacimiento text NULL,
	fec_ult_modif text NULL,
	uri text NULL,
	fecha_acto text NULL,
	correo text NULL,
	profesion text NULL,
	motivo_movimiento text NULL
);