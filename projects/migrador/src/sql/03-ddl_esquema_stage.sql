/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR VISTAS EN EL STAGE AREA.
 * 
 * Descripcion: Etapa de preparación de los datos.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */

SET search_path TO stage;

-- ###########################################################################
-- Preparación de tablas objetivos:
--   1-NIVEL
--   2-ENTIDAD
--   3-OEE
-- ###########################################################################

-- vw_nivel definition

-- DROP VIEW stage.vw_nivel;

-- SELECT * FROM stage.vw_nivel;

-- SELECT count(*) FROM stage.vw_nivel;

CREATE OR REPLACE VIEW stage.vw_nivel AS
SELECT DISTINCT 
	nivel AS codigo,
	descripcion_nivel AS descripcion
FROM
	raw.raw_nomina_sfp
WHERE
	nivel IS NOT NULL
	AND descripcion_nivel IS NOT NULL
ORDER BY nivel;



-- vw_entidad definition

-- DROP VIEW stage.vw_entidad;

-- SELECT * FROM stage.vw_entidad;

-- SELECT count(*) FROM stage.vw_entidad;

CREATE OR REPLACE VIEW stage.vw_entidad AS
SELECT DISTINCT 
	nivel AS nivel_codigo,
	entidad AS codigo,
	descripcion_entidad AS descripcion
FROM
	raw.raw_nomina_sfp
WHERE
	nivel IS NOT NULL
	AND entidad IS NOT NULL
	AND descripcion_entidad IS NOT NULL
ORDER BY nivel, entidad;



-- vw_oee definition

-- DROP VIEW stage.vw_oee;

-- SELECT * FROM stage.vw_oee;

-- SELECT count(*) FROM stage.vw_oee;

CREATE OR REPLACE VIEW stage.vw_oee AS
SELECT DISTINCT
	nivel AS nivel_codigo,
	entidad AS entidad_codigo,
	oee AS codigo,
	descripcion_oee AS descripcion
FROM
	raw.raw_nomina_sfp
WHERE
	nivel IS NOT NULL
	AND entidad IS NOT NULL
	AND oee IS NOT NULL
	AND descripcion_oee IS NOT NULL
ORDER BY nivel, entidad, oee;



-- ###########################################################################
-- Preparación de tablas objetivos:
--   4-PERSONA
-- ###########################################################################

-- vw_persona_auxiliar definition

-- DROP VIEW stage.vw_persona_auxiliar;

-- SELECT * FROM stage.vw_persona_auxiliar;

-- SELECT count(*) FROM stage.vw_persona_auxiliar;

CREATE OR REPLACE VIEW stage.vw_persona_auxiliar AS
SELECT
	documento,
	nombre,
	apellido,
	fecha_nacimiento,
	CASE
		WHEN sexo = 'FEMENINO' THEN 'F'
		WHEN sexo = 'MASCULINO' THEN 'M'
		ELSE 'N'
	END sexo_codigo,
	CASE 
		WHEN nacionalidad_ctrl between '1' AND '9' THEN 'PY'
		WHEN nacionalidad_ctrl = 'E' THEN 'EX'
		ELSE 'ND'
	END AS nacionalidad_codigo
FROM (
	SELECT DISTINCT 
		documento,
		TRIM(nombres) AS nombre,
		TRIM(apellidos) AS apellido,
		TRIM(sexo) AS sexo,
		fecha_nacimiento::date,
		SUBSTRING(documento, 1, 1) AS nacionalidad_ctrl
	FROM
		raw.raw_nomina_sfp
	WHERE
		documento IS NOT NULL
		AND nombres IS NOT NULL
		AND apellidos IS NOT NULL
		AND sexo IS NOT NULL
		AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V') -- no persona
	ORDER BY documento
) p;



-- vw_persona_discapacidad_auxiliar definition

-- DROP VIEW stage.vw_persona_discapacidad_auxiliar;

-- SELECT * FROM stage.vw_persona_discapacidad_auxiliar;

-- SELECT count(*) FROM stage.vw_persona_discapacidad_auxiliar;

CREATE OR REPLACE VIEW stage.vw_persona_discapacidad_auxiliar AS
SELECT
	documento,
	ARRAY_AGG(tipo_discapacidad) AS tipo_discapacidad,
	ARRAY_AGG(discapacidad) AS discapacidad 
FROM (
	SELECT DISTINCT 
		documento,
		TRIM(tipo_discapacidad) AS tipo_discapacidad,
		TRIM(discapacidad) AS discapacidad
	FROM
		raw.raw_nomina_sfp
	WHERE
		documento IS NOT NULL
		AND nombres IS NOT NULL
		AND apellidos IS NOT NULL
		AND sexo IS NOT NULL
		AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V') -- no persona
	ORDER BY documento
) pd
GROUP BY documento;



-- vw_persona

-- DROP VIEW stage.vw_persona;

-- SELECT * FROM stage.vw_persona;

-- SELECT count(*) FROM stage.vw_persona;

CREATE OR REPLACE VIEW stage.vw_persona AS
SELECT
	p.documento,
	p.nombre,
	p.apellido,
	p.fecha_nacimiento,
	p.sexo_codigo,
	p.nacionalidad_codigo,
   CASE
	WHEN CARDINALITY(pd.tipo_discapacidad) > 1 THEN '-1'
	ELSE
		CASE
			WHEN pd.tipo_discapacidad[1] = 'MULTIPLE'    THEN '00'
            WHEN pd.tipo_discapacidad[1] = 'FISICA'      THEN '01'
            WHEN pd.tipo_discapacidad[1] = 'INTELECTUAL' THEN '02'
            WHEN pd.tipo_discapacidad[1] = 'PSICOSOCIAL' THEN '03'
            WHEN pd.tipo_discapacidad[1] = 'AUDITIVA'    THEN '04'
            WHEN pd.tipo_discapacidad[1] = 'VISUAL'      THEN '05'
            WHEN pd.tipo_discapacidad[1] IS NULL         THEN '99'
            ELSE '-1'
         END
   END tipo_discapacidad_codigo,
   CASE 
	WHEN CARDINALITY(pd.discapacidad) > 1 THEN false
	ELSE
		CASE
			WHEN pd.discapacidad[1] = 'SI' THEN true
			ELSE false
		END
   END discapacidad
FROM stage.vw_persona_auxiliar p
JOIN stage.vw_persona_discapacidad_auxiliar pd ON pd.documento = p.documento
ORDER BY documento;



-- ###########################################################################
-- Preparación de tablas objetivos:
--   5-FUNCIONARIO
--   6-CARGO
--   7-PROFESION
--   8-FUNCIONARIO_PUESTO
-- ###########################################################################

-- vw_funcionario_puesto definition

-- DROP VIEW stage.vw_funcionario_puesto;

-- SELECT * FROM stage.vw_funcionario_puesto;

-- SELECT count(*) FROM stage.vw_funcionario_puesto;

CREATE OR REPLACE VIEW stage.vw_funcionario_puesto AS
SELECT DISTINCT 
	documento,
	nivel AS nivel_codigo,
	entidad AS entidad_codigo,
	oee AS oee_codigo,
	TRIM(estado) AS estado_codigo,
	UPPER(TRIM(TRIM('"' FROM COALESCE(profesion, 'DESCONOCIDO')))) AS profesion_descripcion,
	md5(UPPER(TRIM(TRIM('"' FROM COALESCE(profesion, 'DESCONOCIDO'))))) AS profesion_codigo,	
	UPPER(TRIM(TRIM('"' FROM COALESCE(cargo, 'DESCONOCIDO')))) AS cargo_descripcion,
	MD5(UPPER(TRIM(TRIM('"' FROM COALESCE(cargo, 'DESCONOCIDO'))))) AS cargo_codigo,
	COALESCE(anho_ingreso, 0) AS anho_ingreso,
	UPPER(TRIM(funcion)) AS funcion
FROM
	raw.raw_nomina_sfp
WHERE
	documento IS NOT NULL
	AND nivel IS NOT NULL
	AND entidad IS NOT NULL
	AND oee IS NOT NULL
	AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V') -- no  persona
ORDER BY documento, nivel, entidad, oee, anho_ingreso;



-- vw_funcionario definition

-- DROP VIEW stage.vw_funcionario;

-- SELECT * FROM stage.vw_funcionario;

-- SELECT count(*) FROM stage.vw_funcionario;

CREATE OR REPLACE VIEW stage.vw_funcionario AS
SELECT
	documento,
	nivel_codigo,
	entidad_codigo,
	oee_codigo
FROM stage.vw_funcionario_puesto
GROUP BY documento, nivel_codigo, entidad_codigo, oee_codigo
ORDER BY documento, nivel_codigo, entidad_codigo, oee_codigo;



-- vw_cargo definition

-- DROP VIEW stage.vw_cargo;

-- SELECT * FROM stage.vw_cargo;

-- SELECT count(*) FROM stage.vw_cargo;

CREATE OR REPLACE VIEW stage.vw_cargo AS
SELECT DISTINCT 
	cargo_codigo AS codigo,
	cargo_descripcion AS descripcion
FROM stage.vw_funcionario_puesto
ORDER BY cargo_descripcion;



-- vw_profesion definition

-- DROP VIEW stage.vw_profesion;

-- SELECT * FROM stage.vw_profesion;

-- SELECT count(*) FROM stage.vw_profesion;

CREATE OR REPLACE VIEW stage.vw_profesion AS
SELECT DISTINCT 
	profesion_codigo AS codigo,
	profesion_descripcion AS descripcion
FROM stage.vw_funcionario_puesto
ORDER BY profesion_descripcion;



-- ###########################################################################
-- Preparación de tablas objetivos:
--    9-REMUNERACION_CABECERA
--   10-REMUNERACION_DETALLE
-- ###########################################################################


-- vm_remuneracion_detalle definition

-- DROP MATERIALIZED VIEW stage.vm_remuneracion_detalle;

-- SELECT * FROM stage.vm_remuneracion_detalle;

-- SELECT count(*) FROM stage.vm_remuneracion_detalle;

CREATE MATERIALIZED VIEW stage.vm_remuneracion_detalle AS
SELECT
	anho,
	mes,
	documento,
	nivel AS nivel_codigo,
	entidad AS entidad_codigo,
	oee AS oee_codigo,
	MD5(UPPER(TRIM(TRIM('"' FROM COALESCE(profesion, 'DESCONOCIDO'))))) AS profesion_codigo,
	MD5(UPPER(TRIM(TRIM('"' FROM COALESCE(cargo, 'DESCONOCIDO'))))) AS cargo_codigo,
	TRIM(estado) AS estado_codigo,
	COALESCE(anho_ingreso, 0) AS anho_ingreso,
	COALESCE(fuente_financiamiento, '-1')::CHAR(2) AS fuente_financiamiento_codigo,
	objeto_gasto::SMALLINT,
	CASE WHEN stage.isnumeric(linea) THEN linea::INT4 ELSE -1 END AS linea,
	TRIM(categoria)::varchar(16) AS categoria,
	COALESCE(presupuestado, 0) AS monto_haberes,
	COALESCE(devengado, 0) AS monto_devengado
FROM raw.raw_nomina_sfp
WHERE
	documento IS NOT NULL
	AND nivel IS NOT NULL
	AND entidad IS NOT NULL
	AND oee IS NOT NULL
	AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V') 
ORDER BY documento;



-- vm_remuneracion_cabecera definition

-- DROP MATERIALIZED VIEW stage.vm_remuneracion_cabecera;

-- SELECT * FROM stage.vm_remuneracion_cabecera;

-- SELECT count(*) FROM stage.vm_remuneracion_cabecera;

CREATE MATERIALIZED VIEW stage.vm_remuneracion_cabecera AS
SELECT
	tm.anho,
	tm.mes,
	tm.documento,
	tm.nivel_codigo,
	tm.entidad_codigo,
	tm.oee_codigo,
	tm.cargo_codigo,
	tm.profesion_codigo,
	tm.estado_codigo,
	tm.anho_ingreso,
	SUM(tm.monto_haberes) AS total_haberes,
	SUM(tm.monto_devengado) AS total_devengado
FROM (
	SELECT
		anho,
		mes,
		documento,
		nivel AS nivel_codigo,
		entidad AS entidad_codigo,
		oee AS oee_codigo,
		MD5(UPPER(TRIM(TRIM('"' FROM COALESCE(profesion, 'DESCONOCIDO'))))) AS profesion_codigo,
		MD5(UPPER(TRIM(TRIM('"' FROM COALESCE(cargo, 'DESCONOCIDO'))))) AS cargo_codigo,
		TRIM(estado) AS estado_codigo,
		COALESCE(anho_ingreso, 0) AS anho_ingreso,
		COALESCE(fuente_financiamiento, '-1')::CHAR(2) AS fuente_financiamiento_codigo,
		objeto_gasto::SMALLINT,
		CASE WHEN stage.isnumeric(linea) THEN linea::INT4 ELSE -1 END AS linea,
		TRIM(categoria)::varchar(16) AS categoria,
		COALESCE(presupuestado, 0) AS monto_haberes,
		COALESCE(devengado, 0) AS monto_devengado
	FROM raw.raw_nomina_sfp
	WHERE
		documento IS NOT NULL
		AND nivel IS NOT NULL
		AND entidad IS NOT NULL
		AND oee IS NOT NULL
		AND SUBSTRING(documento, 1, 1) NOT IN('A', 'V') 
) tm
GROUP BY tm.anho,
	tm.mes,
	tm.documento,
	tm.nivel_codigo,
	tm.entidad_codigo,
	tm.oee_codigo,
	tm.cargo_codigo,
	tm.cargo_codigo,
	tm.profesion_codigo,
	tm.estado_codigo,
	tm.anho_ingreso
ORDER BY tm.documento;


/*
CREATE MATERIALIZED VIEW stage.vm_remuneracion_cabecera AS
SELECT
	anho,
	mes,
	documento,
	nivel_codigo,
	entidad_codigo,
	oee_codigo,
	cargo_codigo,
	profesion_codigo,
	estado_codigo,
	anho_ingreso,
	SUM(monto_haberes) AS total_haberes,
	SUM(monto_devengado) AS total_devengado
FROM stage.vm_remuneracion_detalle
GROUP BY anho,
	mes,
	documento,
	nivel_codigo,
	entidad_codigo,
	oee_codigo,
	cargo_codigo,
	cargo_codigo,
	profesion_codigo,
	estado_codigo,
	anho_ingreso
ORDER BY documento;
*/