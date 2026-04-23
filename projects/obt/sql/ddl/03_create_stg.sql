/*
* Tablas STG: Datos transformados.
*
*/
 
create schema if not exists stg;

comment on schema stg is 'Esquema que contiene tablas con datos transformados';

-- Drop table

drop table if exists stg.sfp_nomina_temporal;

-- stg.sfp_nomina_temporal

create unlogged table if not exists stg.sfp_nomina_temporal (
	anho 					smallint,
	mes 					smallint,
	nivel 					smallint,
	entidad 				smallint,
	oee 					smallint,
	documento 				text,
	nombres 				text,
	apellidos 				text,
	estado 					text,
	anho_ingreso 			smallint,
	sexo 					text,
	discapacidad 			text,
	tipo_discapacidad 		text,
	fuente_financiamiento 	text,
	objeto_gasto 			smallint,
	linea 					text,
	categoria 				text,
	cargo 					text,
	presupuestado 			int,
	devengado 				int,
	movimiento 				text,
	fecha_nacimiento 		date,
	fecha_acto 				date,
	profesion 				text,
	ctrl					char(1)
);

-- Evita vacuums innecesarios y reduce aún más el consumo de CPU y disco.

alter table stg.sfp_nomina_temporal set (autovacuum_enabled = false);

alter table stg.sfp_nomina_temporal set (toast.autovacuum_enabled = false);