/*
 * Tablas RAW: Datos en bruto.
 * 
 *
 * Notas:
 * 
 * - Las tablas UNLOGGED no generan WAL, lo que ya reduce mucho el overhead.
 * 
 * - Las tablas RAW son solo para carga y lectura rápida, y luego se borra o reemplaza, entonces 
 * se desactivar autovacuum para evitar que PostgreSQL pierda tiempo analizando esa tabla.
 *
 */
 
create schema if not exists raw;

comment on schema raw is 'Esquema que contiene tablas con datos en bruto';

-- Drop table

drop table if exists raw.sfp_nomina;

-- raw.sfp_nomina definition

create unlogged table if not exists raw.sfp_nomina (
	anho 					text,
	mes 					text,
	nivel 					text,
	entidad 				text,
	oee 					text,
	documento 				text,
	nombres 				text,
	apellidos 				text,
	estado 					text,
	anho_ingreso 			text,
	sexo 					text,
	discapacidad 			text,
	tipo_discapacidad 		text,
	fuente_financiamiento 	text,
	objeto_gasto 			text,
	linea 					text,
	categoria 				text,
	cargo 					text,
	presupuestado 			text,
	devengado 				text,
	movimiento 				text,
	fecha_nacimiento 		text,
	fecha_acto 				text,
	profesion 				text
);

-- Evita vacuums innecesarios y reduce aún más el consumo de CPU y disco.

alter table raw.sfp_nomina set (autovacuum_enabled = false);

--alter table raw.sfp_nomina set (toast.autovacuum_enabled = false);