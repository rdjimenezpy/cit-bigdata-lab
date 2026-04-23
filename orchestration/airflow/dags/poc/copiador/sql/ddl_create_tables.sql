
SET search_path TO poc;

-- raw_sfp_nomina definition

-- DROP TABLE poc.raw_sfp_nomina;

CREATE TABLE poc.raw_sfp_nomina (
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


-- raw_sfp_nomina_eliminado definition

-- DROP TABLE poc.raw_sfp_nomina_eliminado;

CREATE TABLE poc.raw_sfp_nomina_eliminado (
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