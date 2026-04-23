/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA CREAR LAS TABLAS DEL CUBO DE REMUNERACION.
 * 
 * Descripción: Creamos las dimensiones y tabla de hecho del esquema de estrella modelado.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */
 


-- drop table if exists if exists datamart.dim_fecha cascade;

CREATE TABLE datamart.dim_fecha (
	fecha_sk DATE NOT NULL,
	anho SMALLINT,
	mes SMALLINT,
	mes_nombre VARCHAR(12),
	mes_nombre_corto CHAR(5),
	dia SMALLINT,
	dia_del_anho SMALLINT,
	dia_semana SMALLINT,
	dia_semana_nombre VARCHAR(12),
	dia_semana_nombre_corto CHAR(6),
	calendario_semana SMALLINT,
	fecha_formateada VARCHAR(12),
	trimestre CHAR(2),
	anho_trimestre VARCHAR(8),
	cuatrimestre CHAR(2),
	anho_cuatrimestre VARCHAR(8),
	semestre CHAR(2),
	anho_semestre VARCHAR(8),
	anho_mes VARCHAR(8),
	periodo INT,
	anho_calendario_semana VARCHAR(8),
	es_dia_habil BOOLEAN,
	dia_festivo_fijo BOOLEAN,
	estacion_del_anho VARCHAR(16),
	CONSTRAINT dim_fecha_pk PRIMARY KEY (fecha_sk)
);

-- drop table if exists datamart.dim_periodo cascade;

CREATE TABLE datamart.dim_periodo (
	periodo_sk INT NOT NULL,
	anho SMALLINT,
	semestre CHAR(2),
	anho_semestre VARCHAR(12),
	trimestre CHAR(2),
	anho_trimestre VARCHAR(8),
	mes SMALLINT,
	mes_nombre VARCHAR(12),
	mes_nombre_corto CHAR(5),
	cuatrimestre CHAR(2),
	anho_cuatrimestre VARCHAR(8),
	estacion_del_anho VARCHAR(16),
	CONSTRAINT dim_periodo_pk PRIMARY KEY (periodo_sk)
);

-- drop table if exists datamart.dim_institucion cascade;

CREATE SEQUENCE datamart.dim_institucion_institucion_sk_seq;

CREATE TABLE datamart.dim_institucion (
	institucion_sk SMALLINT NOT NULL DEFAULT nextval('datamart.dim_institucion_institucion_sk_seq'),
	nivel_codigo SMALLINT,
	nivel_descripcion VARCHAR(64),
	entidad_codigo SMALLINT,
	entidad_descripcion VARCHAR(82),
	oee_codigo SMALLINT,
	oee_descripcion VARCHAR(128),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_institucion_pk PRIMARY KEY (institucion_sk)
);

-- drop table if exists datamart.dim_funcionario cascade;

CREATE SEQUENCE datamart.dim_funcionario_funcionario_sk_seq;

CREATE TABLE datamart.dim_funcionario (
                funcionario_sk INTEGER NOT NULL DEFAULT nextval('datamart.dim_funcionario_funcionario_sk_seq'),
                documento VARCHAR(20),
                nombres VARCHAR(64),
                apellidos VARCHAR(64),
                sexo VARCHAR(12),
                nacionalidad VARCHAR(12),
                fecha_nacimiento DATE,
				discapacidad BOOLEAN,
				tipo_discapacidad VARCHAR(16),
                fecha_ultima_modificacion TIMESTAMP,
                CONSTRAINT dim_funcionario_pk PRIMARY KEY (funcionario_sk)
);

-- drop table if exists datamart.fuente_financiamiento cascade;

CREATE SEQUENCE datamart.dim_fuente_financiamiento_fuente_financiamiento_sk_seq;

CREATE TABLE datamart.dim_fuente_financiamiento (
                fuente_financiamiento_sk SMALLINT NOT NULL DEFAULT nextval('datamart.dim_fuente_financiamiento_fuente_financiamiento_sk_seq'),
                fuente_financiamiento_codigo SMALLINT,
                fuente_financiamiento_descripcion VARCHAR(42),
                fecha_ultima_modificacion TIMESTAMP NOT NULL,
                CONSTRAINT dim_fuente_financiamiento_pk PRIMARY KEY (fuente_financiamiento_sk)
);

-- drop table if exists datamart.dim_estado cascade;

CREATE SEQUENCE datamart.dim_estado_estado_sk_seq;

CREATE TABLE datamart.dim_estado (
                estado_sk SMALLINT NOT NULL DEFAULT nextval('datamart.dim_estado_estado_sk_seq'),
                estado_codigo SMALLINT,
                estado_descripcion VARCHAR(12),
                fecha_ultima_modificacion TIMESTAMP NOT NULL,
                CONSTRAINT dim_estado_pk PRIMARY KEY (estado_sk)
);

-- drop table if exists datamart.dim_gasto_clasificacion cascade;

CREATE SEQUENCE datamart.dim_gasto_clasificacion_gasto_clasificacion_sk_seq;

CREATE TABLE datamart.dim_gasto_clasificacion (
                gasto_clasificacion_sk SMALLINT NOT NULL DEFAULT nextval('datamart.dim_gasto_clasificacion_gasto_clasificacion_sk_seq'),
                grupo_codigo SMALLINT,
                grupo_descripcion VARCHAR(32),
                subgrupo_codigo SMALLINT,
                subgrupo_descripcion VARCHAR(64),
                objeto_gasto_codigo SMALLINT,
                objeto_gasto_descripcion VARCHAR(128),
                control_financiero_codigo SMALLINT,
                control_financiero_descripcion VARCHAR(64),
                clasificacion_gasto_descripcion VARCHAR(16),
                fecha_ultima_modificacion TIMESTAMP,
                CONSTRAINT dim_gasto_clasificacion_pk PRIMARY KEY (gasto_clasificacion_sk)
);

-- drop table if exists datamart.dim_edad cascade;

CREATE TABLE datamart.dim_edad (
                edad_sk SMALLINT,
                grupo_etario_rango VARCHAR(16),
                grupo_etario_etapa VARCHAR(16),
                franja_etaria_activa VARCHAR(16),
                fecha_ultima_modificacion TIMESTAMP,
                CONSTRAINT dim_edad_pk PRIMARY KEY (edad_sk)
);

-- drop table if exists datamart.fact_remuneracion cascade;

CREATE SEQUENCE datamart.fact_remuneracion_remuneracion_id_seq;

CREATE TABLE datamart.fact_remuneracion (
                periodo_sk INTEGER,
                institucion_sk SMALLINT,
                funcionario_sk INTEGER,
                edad_sk SMALLINT,
                estado_sk SMALLINT,
                fuente_financiamiento_sk SMALLINT,
                gasto_clasificacion_sk SMALLINT,
                anho_ingreso SMALLINT,
				es_vacante BOOLEAN,
                es_anonimo BOOLEAN,
                monto_presupuestado BIGINT,
                monto_devengado BIGINT,
                monto_descuento_total BIGINT,
				fecha_ultima_modificacion TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE datamart.fact_remuneracion IS 'Tabla de hecho que guarda los snapshot de las remuneraciones de los funcionarios públicos.';