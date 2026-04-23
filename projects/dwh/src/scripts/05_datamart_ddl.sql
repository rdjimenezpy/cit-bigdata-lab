/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA CREAR LAS TABLAS DEL CUBO DE REMUNERACION.
 * 
 * Descripción: Creamos las dimensiones y tabla de hecho del esquema de estrella modelado.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */

SET search_path TO datamart;

/* -------------------------------------------------------
 * FACT_REMUNERACION_MENSUAL_SFP
 * ------------------------------------------------------- */
CREATE SEQUENCE fact_remuneracion_mensual_sfp_seq;

CREATE TABLE fact_remuneracion_mensual_sfp (
	remuneracion_sfp_id BIGINT NOT NULL DEFAULT nextval('fact_remuneracion_mensual_sfp_seq'),
	periodo_sk INTEGER,
	institucion_sk SMALLINT,
	funcionario_sk INTEGER,
	estado_sk SMALLINT,
	fuente_financiamiento_sk SMALLINT,
	gasto_clasificacion_sk SMALLINT,
	edad_sk SMALLINT,
	anho_nacimiento_sk SMALLINT,
	anho_ingreso SMALLINT,
	es_vacante BOOLEAN,
	es_anonimo BOOLEAN,
	monto_presupuestado BIGINT,
	monto_devengado BIGINT,
	monto_descuento BIGINT,
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT fact_remuneracion_mensual_sfp_pk PRIMARY KEY (remuneracion_sfp_id),
	CONSTRAINT fact_remuneracion_mensual_sfp_uq UNIQUE (periodo_sk, institucion_sk, funcionario_sk, estado_sk, fuente_financiamiento_sk,
		gasto_clasificacion_sk, edad_sk, anho_nacimiento_sk, anho_ingreso, es_vacante, es_anonimo, monto_presupuestado, monto_devengado, monto_descuento)
);
COMMENT ON TABLE fact_remuneracion_mensual_sfp IS 'Tabla de hecho que detalla los pagos, beneficios y deducciones de los funcionarios públicos';


/* -------------------------------------------------------
 * DIM_FECHA
 * ------------------------------------------------------- */
CREATE TABLE dim_fecha (
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
	periodo INTEGER,
	anho_calendario_semana VARCHAR(8),
	es_dia_habil BOOLEAN,
	dia_festivo_fijo BOOLEAN,
	estacion_del_anho VARCHAR(16),
	CONSTRAINT dim_fecha_pk PRIMARY KEY (fecha_sk)
);


/* -------------------------------------------------------
 * DIM_PERIODO
 * ------------------------------------------------------- */
CREATE TABLE dim_periodo (
	periodo_sk INTEGER NOT NULL,
	anho SMALLINT,
	semestre CHAR(2),
	anho_semestre VARCHAR(12),
	cuatrimestre CHAR(2),
	anho_cuatrimestre VARCHAR(8),
	trimestre CHAR(2),
	anho_trimestre VARCHAR(8),
	mes SMALLINT,
	mes_nombre VARCHAR(12),
	mes_nombre_corto CHAR(5),
	estacion_del_anho VARCHAR(16),
	CONSTRAINT dim_periodo_pk PRIMARY KEY (periodo_sk)
);


/* -------------------------------------------------------
 * DIM_INSTITUCION
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_institucion_seq;

CREATE TABLE dim_institucion (
	institucion_sk SMALLINT NOT NULL DEFAULT nextval('dim_institucion_seq'),
	nivel_codigo SMALLINT,
	nivel_descripcion VARCHAR(64),
	entidad_codigo SMALLINT,
	entidad_descripcion VARCHAR(82),
	oee_codigo SMALLINT,
	oee_descripcion VARCHAR(128),
	descripcion_corta VARCHAR(16),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_institucion_pk PRIMARY KEY (institucion_sk)
);
COMMENT ON TABLE datamart.dim_institucion IS 'Organizaciones y Entidades del Estado';


/* -------------------------------------------------------
 * DIM_FUNCIONARIO
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_funcionario_seq;

CREATE TABLE dim_funcionario (
	funcionario_sk INTEGER NOT NULL DEFAULT nextval('dim_funcionario_seq'),
	documento VARCHAR(20),
	nombres VARCHAR(64),
	apellidos VARCHAR(64),
	sexo VARCHAR(12),
	nacionalidad VARCHAR(12),
	fecha_nacimiento DATE,
	discapacidad BOOLEAN,
	tipo_discapacidad VARCHAR(16),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_funcionario_pk PRIMARY KEY (funcionario_sk),
	CONSTRAINT dim_funcionario_uq UNIQUE (documento)
);


/* -------------------------------------------------------
 * DIM_ESTADO
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_estado_seq;

CREATE TABLE dim_estado (
	estado_sk SMALLINT NOT NULL DEFAULT nextval('dim_estado_seq'),
	estado_codigo SMALLINT,
	estado_descripcion VARCHAR(12),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_estado_pk PRIMARY KEY (estado_sk)
);


/* -------------------------------------------------------
 * DIM_FUENTE_FINANCIAMIENTO
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_fuente_financiamiento_seq;

CREATE TABLE dim_fuente_financiamiento (
	fuente_financiamiento_sk SMALLINT NOT NULL DEFAULT nextval('dim_fuente_financiamiento_seq'),
	fuente_financiamiento_codigo SMALLINT,
	fuente_financiamiento_descripcion VARCHAR(42),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_fuente_financiamiento_pk PRIMARY KEY (fuente_financiamiento_sk)
);


/* -------------------------------------------------------
 * DIM_CLASIFICACION_GASTO
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_clasificacion_gasto_seq;

CREATE TABLE dim_clasificacion_gasto (
	clasificacion_gasto_sk SMALLINT NOT NULL DEFAULT nextval('dim_clasificacion_gasto_seq'),
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
	CONSTRAINT dim_clasificacion_gasto_pk PRIMARY KEY (clasificacion_gasto_sk),
	CONSTRAINT dim_clasificacion_gasto_uq UNIQUE (grupo_codigo, subgrupo_codigo, objeto_gasto_codigo)
);


/* -------------------------------------------------------
 * DIM_EDAD
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_edad_seq;

CREATE TABLE dim_edad (
	edad_sk SMALLINT NOT NULL DEFAULT nextval('dim_edad_seq'),
	grupo_etario_rango VARCHAR(16),
	grupo_etario_etapa VARCHAR(16),
	franja_etaria_activa VARCHAR(16),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_edad_pk PRIMARY KEY (edad_sk),
	CONSTRAINT dim_edad_uq UNIQUE (edad_sk)
);


/* -------------------------------------------------------
 * DIM_GENERACION
 * ------------------------------------------------------- */
CREATE SEQUENCE dim_generacion_seq;

CREATE TABLE dim_generacion (
	anho_nacimiento_sk SMALLINT NOT NULL DEFAULT nextval('dim_generacion_seq'),
	nombre_generacion VARCHAR(32),
	rango_anho_nacimiento VARCHAR(16),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_generacion_pk PRIMARY KEY (anho_nacimiento_sk),
	CONSTRAINT dim_generacion_uq UNIQUE (anho_nacimiento_sk)
);


/* -------------------------------------------------------
 * FACT_COTIZACION_MENSUAL_BCP
 * ------------------------------------------------------- */
CREATE SEQUENCE fact_cotizacion_mensual_bcp_seq;

CREATE TABLE fact_cotizacion_mensual_bcp (
	cotizacion_bcp_id SMALLINT NOT NULL DEFAULT nextval('fact_cotizacion_mensual_bcp_seq'),
	periodo_sk INTEGER NOT NULL,
	moneda_extranjera_sk SMALLINT NOT NULL,
	cotizacion INTEGER,
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT fact_cotizacion_mensual_bcp_pk PRIMARY KEY (cotizacion_bcp_id),
	CONSTRAINT fact_cotizacion_mensual_bcp_uq UNIQUE (periodo_sk, moneda_extranjera_sk)
);
COMMENT ON TABLE fact_cotizacion_mensual_bcp IS 'COTIZACION DE REFERENCIA BCP - CIERRE MENSUAL';
COMMENT ON COLUMN fact_cotizacion_mensual_bcp.cotizacion IS 'Las cotizaciones de monedas extranjeras en guaranies';


/* -------------------------------------------------------
 * DIM_MONEDA_EXTRANJERA
 * ------------------------------------------------------- */
CREATE sequence dim_moneda_extranjera_seq;

CREATE TABLE dim_moneda_extranjera (
	moneda_extranjera_sk SMALLINT NOT NULL DEFAULT nextval('dim_moneda_extranjera_seq'),
	moneda VARCHAR(8),
	descripcion VARCHAR(128),
	fecha_ultima_modificacion TIMESTAMP,
	CONSTRAINT dim_moneda_extranjera_pk PRIMARY KEY (moneda_extranjera_sk),
	CONSTRAINT dim_moneda_extranjera_uq UNIQUE (moneda)
);
