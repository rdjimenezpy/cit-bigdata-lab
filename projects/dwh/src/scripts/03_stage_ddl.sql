/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS DDL PARA CREAR VISTAS EN EL STAGE AREA.
 * 
 * Descripcion: Etapa de preparación de los datos.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */
 
-- ###########################################################################
-- Tabla objetivo: DIM_INSTITUCION
-- ###########################################################################
 
-- DROP VIEW stage.vw_stg_institucion;

-- SELECT * FROM stage.vw_stg_institucion;

CREATE OR REPLACE view stage.vw_stg_institucion AS
SELECT DISTINCT
	codigo_nivel::int2					AS nivel_codigo,
	UPPER(TRIM(descripcion_nivel))		AS nivel_descripcion,
	codigo_entidad::int2				AS entidad_codigo,
	UPPER(TRIM(descripcion_entidad))	AS entidad_descripcion,
	codigo_oee::int2					AS oee_codigo,
	UPPER(TRIM(descripcion_oee))		AS oee_descripcion,
	UPPER(TRIM(descripcion_corta))		AS descripcion_corta
FROM raw.raw_sfp_oee
WHERE
	codigo_nivel IS NOT NULL
	AND codigo_entidad IS NOT NULL
	AND codigo_oee IS NOT NULL
ORDER BY nivel_codigo, entidad_codigo, oee_codigo;


-- ###########################################################################
-- Tabla objetivo: DIM_FUNCIONARIO
-- ###########################################################################

-- DROP VIEW stage.vw_temp_persona;

-- SELECT * FROM stage.vw_temp_persona;

CREATE OR REPLACE view stage.vw_temp_persona AS
SELECT
	documento,
	nombres,
	apellidos,
	fecha_nacimiento,
	sexo,
	CASE 
		WHEN nacionalidad_ctrl BETWEEN '1' AND '9' THEN 'PARAGUAYA'
		WHEN nacionalidad_ctrl = 'E' THEN 'EXTRANJERA'
		ELSE 'DESCONOCIDO'
	END::varchar(12) AS nacionalidad
FROM (
	SELECT DISTINCT
		documento::VARCHAR(20)				AS documento,
		UPPER(TRIM(nombres))::VARCHAR(64)	AS nombres,
		UPPER(TRIM(apellidos))::VARCHAR(64)	AS apellidos,
		UPPER(TRIM(sexo))::VARCHAR(10)		AS sexo,
		fecha_nacimiento::DATE				AS fecha_nacimiento,
		SUBSTRING(documento, 1, 1)			AS nacionalidad_ctrl
	FROM
		raw.raw_sfp_nomina
	WHERE
		documento IS NOT NULL
		AND nombres IS NOT NULL
		AND apellidos IS NOT NULL
		AND sexo IS NOT NULL
		AND fecha_nacimiento IS NOT NULL
		AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V')
	ORDER BY documento
) p;


-- DROP VIEW stage.vw_temp_persona_discapacidad;

-- SELECT * FROM stage.vw_temp_persona_discapacidad;

CREATE OR REPLACE view stage.vw_temp_persona_discapacidad AS
SELECT
	documento,
	ARRAY_AGG(tipo_discapacidad)		AS tipo_discapacidad,
	ARRAY_AGG(discapacidad)				AS discapacidad 
FROM (
	SELECT DISTINCT
		documento::VARCHAR(20)			AS documento,
		UPPER(TRIM(tipo_discapacidad))	AS tipo_discapacidad,
		UPPER(TRIM(discapacidad))		AS discapacidad
	FROM
		raw.raw_sfp_nomina
	WHERE
		documento IS NOT NULL
		AND nombres IS NOT NULL
		AND apellidos IS NOT NULL
		AND sexo IS NOT NULL
		AND fecha_nacimiento IS NOT NULL
		AND SUBSTRING(documento, 1, 1) not in('A', 'V')
	ORDER BY documento
) pd
GROUP BY documento;


-- DROP VIEW stage.vw_stg_funcionario;

-- SELECT * FROM stage.vw_stg_funcionario;

CREATE OR REPLACE view stage.vw_stg_funcionario AS
SELECT
	p.documento,
	p.nombres,
	p.apellidos,
	p.fecha_nacimiento,
	p.sexo,
	p.nacionalidad,
   CASE
	WHEN CARDINALITY(pd.tipo_discapacidad) > 1 THEN 'DESCONOCIDO'
	ELSE
		CASE
            WHEN pd.tipo_discapacidad[1] IS NULL THEN 'NO APLICA'
            ELSE UPPER(TRIM(pd.tipo_discapacidad[1]))
         END
   END::VARCHAR(16) AS tipo_discapacidad,
   CASE 
	WHEN CARDINALITY(pd.discapacidad) > 1 THEN false
	ELSE
		CASE
			WHEN pd.discapacidad[1] = 'SI' THEN true
			ELSE false
		END
   END::BOOLEAN AS discapacidad
FROM stage.vw_temp_persona p
JOIN stage.vw_temp_persona_discapacidad pd ON pd.documento = p.documento
ORDER BY documento;


-- ###########################################################################
-- TablAS objetivos: FACT_REMUNERACION_TEMPORAL
-- ###########################################################################


-- DROP VIEW stage.vw_stg_fact_remuneracion_temporal;

-- SELECT * FROM stage.vw_stg_fact_remuneracion_temporal;

CREATE OR REPLACE view stage.vw_stg_fact_remuneracion_temporal AS
SELECT
	(anho::char(4) || LPAD(mes::CHAR(2),2,'0'))::INT	AS periodo_sk,
	nivel::INT2 										AS institucion_nivel_codigo,
	entidad::INT2 										AS institucion_entidad_codigo,
	oee::INT2 											AS institucion_oee_codigo,
	CASE
		WHEN SUBSTRING(documento, 1, 1) in('A') THEN '-1' --ANONIMO
		WHEN SUBSTRING(documento, 1, 1) in('V') THEN '-2' --VACANTE
		WHEN SUBSTRING(documento, 1, 1) in('E') THEN '-3' --EXTRANJEROS
		ELSE documento::VARCHAR(20)
	END													AS funcionario_documento,	
	fecha_nacimiento::date								AS fecha_nacimiento,
	COALESCE(EXTRACT(YEAR 
		FROM AGE((anho::TEXT || '-' || mes::TEXT || '-' || '28')::DATE, 
			fecha_nacimiento::DATE)
	), -1)												AS edad_sk,
	UPPER(TRIM(estado))::VARCHAR(12)					AS estado_descripcion,
	CASE
		WHEN COALESCE(anho_ingreso, -1)::INT2 < 1900 THEN -1
		ELSE anho_ingreso::INT2
	END													AS anho_ingreso,
	COALESCE(fuente_financiamiento, '-1')::INT2			AS fuente_financiamiento_codigo,
	COALESCE(objeto_gasto, -1)::INT2					AS objeto_gasto_codigo,
	EXTRACT(YEAR FROM fecha_nacimiento::DATE) 			AS anho_nacimiento_sk,
	CASE
		WHEN SUBSTRING(documento, 1, 1) in('V') THEN true
		ELSE false
	END::BOOLEAN										AS es_vacante,
	CASE
		WHEN SUBSTRING(documento, 1, 1) in('A') THEN true
		ELSE false
	END::boolean										AS es_anonimo,
	COALESCE(presupuestado, 0)							AS monto_presupuestado,
	COALESCE(devengado, 0)								AS monto_devengado,
	COALESCE(presupuestado, 0) - COALESCE(devengado, 0)	AS monto_descuento
FROM raw.raw_sfp_nomina;


-- stage.fact_remuneracion_temporal definition

-- DROP TABLE if exists stage.fact_remuneracion_temporal;

-- SELECT * FROM  stage.fact_remuneracion_temporal;

CREATE TABLE stage.fact_remuneracion_temporal (
	periodo_sk INTEGER,
	institucion_nivel_codigo SMALLINT,
	institucion_entidad_codigo SMALLINT,
	institucion_oee_codigo SMALLINT,
	institucion_sk SMALLINT,
	funcionario_documento VARCHAR(20),
	funcionario_sk INTEGER,
	fecha_nacimiento DATE,
	edad_sk SMALLINT,
	estado_descripcion VARCHAR(20),
	estado_sk SMALLINT,
	fuente_financiamiento_codigo SMALLINT,
	fuente_financiamiento_sk SMALLINT,
	objeto_gasto_codigo SMALLINT,
	gasto_clasificacion_sk SMALLINT,
	anho_nacimiento_sk SMALLINT,
	anho_ingreso SMALLINT,
	es_vacante BOOLEAN,
	es_anonimo BOOLEAN,
	monto_presupuestado BIGINT,
	monto_devengado BIGINT,
	monto_descuento BIGINT
);


-- fact_remuneracion_pendiente definition

-- DROP TABLE IF exists stage.fact_remuneracion_pendiente;

-- SELECT * FROM stage.fact_remuneracion_pendiente;

CREATE TABLE stage.fact_remuneracion_pendiente (
	periodo_sk INTEGER,
	institucion_nivel_codigo SMALLINT,
	institucion_entidad_codigo SMALLINT,
	institucion_oee_codigo SMALLINT,
	institucion_sk SMALLINT,
	funcionario_documento VARCHAR(20),
	funcionario_sk INTEGER,
	fecha_nacimiento DATE,
	edad_sk SMALLINT,
	estado_descripcion VARCHAR(20),
	estado_sk SMALLINT,
	fuente_financiamiento_codigo SMALLINT,
	fuente_financiamiento_sk SMALLINT,
	objeto_gasto_codigo SMALLINT,
	gasto_clasificacion_sk SMALLINT,
	anho_nacimiento_sk SMALLINT,
	anho_ingreso SMALLINT,
	es_vacante BOOLEAN,
	es_anonimo BOOLEAN,
	monto_presupuestado BIGINT,
	monto_devengado BIGINT,
	monto_descuento BIGINT
);



-- fact_remuneracion_duplicado definition

-- DROP TABLE IF exists stage.fact_remuneracion_duplicado;

-- SELECT * FROM stage.fact_remuneracion_duplicado;

CREATE TABLE stage.fact_remuneracion_duplicado (
	periodo_sk int4 NULL,
	institucion_sk int2 NULL,
	funcionario_sk int4 NULL,
	estado_sk int2 NULL,
	fuente_financiamiento_sk int2 NULL,
	gasto_clasificacion_sk int2 NULL,
	edad_sk int2 NULL,
	anho_nacimiento_sk int2 NULL,
	anho_ingreso int2 NULL,
	es_vacante bool NULL,
	es_anonimo bool NULL,
	monto_presupuestado int8 NULL,
	monto_devengado int8 NULL,
	monto_descuento int8 NULL,
	cantidad_duplicado int2
);
