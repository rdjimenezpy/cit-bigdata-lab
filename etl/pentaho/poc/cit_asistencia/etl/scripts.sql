

-- raw.raw_cit_asistencia definition

-- Drop table

-- DROP TABLE raw.raw_cit_asistencia;

CREATE TABLE raw.raw_cit_asistencia (
	fecha_hora timestamp NULL,
	participante varchar(64) NULL,
	duracion time NULL
);


-- raw.raw_cit_matriculado definition

-- Drop table

-- DROP TABLE raw.raw_cit_matriculado;

CREATE TABLE raw.raw_cit_matriculado (
	participante varchar(64) NULL,
	nombre varchar(32) NULL,
	apellido varchar(32) NULL
);