/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA CREAR TIPOS DE DATOS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS.
 * 
 * Descripción: Creamos tipos de datos, funciones y procedimientos almacenados.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- ###########################################################################
-- Tabla objetivo: DIM_FECHA
-- ###########################################################################

-- SELECT * FROM datamart.dim_fecha;

-- DROP PROCEDURE IF EXISTS stage.sp_cargar_dim_fecha;

-- CREAMOS O MODIFICANOS NUESTRO PROCEDIMIENTO DE CARGA DE LA TABLA DIMENSION FECHA
CREATE OR REPLACE PROCEDURE stage.sp_cargar_dim_fecha(fdesde DATE, fhasta DATE)
	LANGUAGE plpgsql
AS $stored_procedure$
BEGIN
	
	TRUNCATE TABLE datamart.dim_fecha;

	INSERT INTO datamart.dim_fecha
	SELECT *
	FROM stage.fn_stg_fecha(fdesde, fhasta);

END; $stored_procedure$;

-- CARGAMOS LA DIMENSION FECHA PARA UN RANGO DE FECHA
CALL stage.sp_cargar_dim_fecha('1990-01-01', '2030-12-31');



-- ###########################################################################
-- Tabla objetivo: DIM_PERIODO
-- ###########################################################################

-- SELECT * FROM datamart.dim_periodo;

-- DROP PROCEDURE IF EXISTS datamart.sp_cargar_dim_periodo;

-- CREAMOS O MODIFICANOS NUESTRO PROCEDIMIENTO DE CARGA DE LA TABLA DIMENSION PERIODO
CREATE OR REPLACE PROCEDURE stage.sp_cargar_dim_periodo(fdesde DATE, fhasta DATE)
	language plpgsql
AS $stored_procedure$
BEGIN

	TRUNCATE TABLE datamart.dim_periodo;

	INSERT INTO datamart.dim_periodo
	SELECT DISTINCT
		periodo AS periodo_sk,
		anho,
		semestre,
		anho_semestre,
		cuatrimestre,
		anho_cuatrimestre,
		trimestre,
		anho_trimestre,
		mes::int2 AS mes,
		mes_nombre,
		mes_nombre_corto,
		CASE -- Períodos del año, se ajustan a su organizacion y pais.
			WHEN to_char(fecha_sk, 'MM')::int2 BETWEEN 1 AND 3 THEN 'VERANO'
		    WHEN to_char(fecha_sk, 'MM')::int2 BETWEEN 4 AND 6 THEN 'OTOÑO'
		    WHEN to_char(fecha_sk, 'MM')::int2 BETWEEN 7 AND 9 THEN 'INVIERNO'
		    WHEN to_char(fecha_sk, 'MM')::int2 BETWEEN 10 AND 12 THEN 'PRIMAVERA'
		END::varchar(16) 								AS estacion_del_anho
	FROM stage.fn_stg_fecha(fdesde, fhasta)
	ORDER BY periodo;

END; $stored_procedure$;

-- CARGAMOS LA DIMENSION PERIODO PARA UN RANGO DE FECHA
CALL stage.sp_cargar_dim_periodo('1990-01-01', '2030-12-31');



-- ###########################################################################
-- Tabla objetivo: DIM_FUENTE_FINANCIAMIENTO
-- ###########################################################################

-- SELECT * FROM datamart.dim_fuente_financiamiento;

-- CARGAMOS LAS PARAMETRICAS PARA LA DIMENSION FUENTE DE FINACIAMIENTOS 
INSERT INTO datamart.dim_fuente_financiamiento (fuente_financiamiento_codigo, fuente_financiamiento_descripcion, fecha_ultima_modificacion)
VALUES
('10', 'TESORO PUBLICO', NOW()()),
('20', 'PRESTAMOS', NOW()()),
('30', 'GENERADOS POR LAS PROPIAS INSTITUCIONES', NOW()()),
('-1', 'DESCONOCIDO', NOW()());



-- ###########################################################################
-- Tabla objetivo: DIM_ESTADO
-- ###########################################################################

-- SELECT * FROM datamart.dim_estado;

-- CARGAMOS LAS PARAMETRICAS PARA LA DIMENSION ESTADO
INSERT INTO datamart.dim_estado (estado_codigo, estado_descripcion, fecha_ultima_modificacion)
VALUES
(100, 'COMISIONADO', NOW()()),
(200, 'CONTRATADO', NOW()()),
(300, 'PERMANENTE', NOW()()),
( -1, 'DESCONOCIDO', NOW()());



-- ###########################################################################
-- Tabla objetivo: DIM_CLASIFICACION_GASTO
-- ###########################################################################

-- SELECT * FROM datamart.dim_clasificacion_gasto;

DO $$
DECLARE
    file_path text;
BEGIN
    file_path := 'D:\Git\fpuna\cit_bigdata_basico\dataset\input\clasificacion_gastos.csv';

	--step 1
	CREATE TEMP TABLE tmp_clasificacion_gasto (
		grupo_codigo int2 NULL,
		grupo_descripcion varchar(32) NULL,
		subgrupo_codigo int2 NULL,
		subgrupo_descripcion varchar(64) NULL,
		objeto_gasto_codigo int2 NULL,
		objeto_gasto_descripcion varchar(128) NULL,
		control_financiero_codigo int2 NULL,
		control_financiero_descripcion varchar(64) NULL,
		clasificacion_gasto_descripcion varchar(16) NULL
	);

	--step 2
    EXECUTE format('COPY tmp_clasificacion_gasto FROM %L DELIMITER '';'' CSV HEADER', file_path);

	--step 3
	INSERT INTO datamart.dim_clasificacion_gasto (
		grupo_codigo,
		grupo_descripcion,
		subgrupo_codigo,
		subgrupo_descripcion,
		objeto_gasto_codigo,
		objeto_gasto_descripcion,
		control_financiero_codigo,
		control_financiero_descripcion,
		clasificacion_gasto_descripcion
	)
	SELECT
		grupo_codigo,
		UPPER(TRIM(grupo_descripcion)) AS grupo_descripcion,
		subgrupo_codigo,
		UPPER(TRIM(subgrupo_descripcion)) AS subgrupo_descripcion,
		objeto_gasto_codigo,
		UPPER(TRIM(objeto_gasto_descripcion)) AS objeto_gasto_descripcion,
		control_financiero_codigo,
		UPPER(TRIM(control_financiero_descripcion)) AS control_financiero_descripcion,
		UPPER(TRIM(clasificacion_gasto_descripcion)) AS clasificacion_gasto_descripcion
	FROM tmp_clasificacion_gasto
	ORDER BY grupo_codigo, subgrupo_codigo, objeto_gasto_codigo
	ON CONFLICT (grupo_codigo, subgrupo_codigo, objeto_gasto_codigo)
	DO UPDATE SET
		grupo_descripcion = EXCLUDED.grupo_descripcion,
		subgrupo_descripcion = EXCLUDED.subgrupo_descripcion,
		objeto_gasto_descripcion = EXCLUDED.objeto_gasto_descripcion,
		control_financiero_descripcion = EXCLUDED.control_financiero_descripcion,
		clasificacion_gasto_descripcion = EXCLUDED.clasificacion_gasto_descripcion,
		fecha_ultima_modificacion = NOW();

	--step 4
	DROP TABLE IF EXISTS tmp_clasificacion_gasto;

END $$;



-- ###########################################################################
-- Tabla objetivo: DIM_EDAD
-- ###########################################################################

-- SELECT * FROM datamart.dim_edad;

--step 1
CREATE TEMP TABLE temp_dim_edad AS
SELECT
	edad AS edad_sk,
	CASE
		WHEN edad BETWEEN 12 AND 17 THEN '12 A 17 AÑOS'
		WHEN edad BETWEEN 18 AND 20 THEN '18 A 20 AÑOS'
		WHEN edad BETWEEN 21 AND 26 THEN '21 A 26 AÑOS'
		WHEN edad BETWEEN 27 AND 59 THEN '27 A 57 AÑOS'
		ELSE '60 A 65+ AÑOS'
	END AS grupo_etario_rango,
	CASE
		WHEN edad BETWEEN 12 AND 17 THEN 'MENORES'
		WHEN edad BETWEEN 18 AND 20 THEN 'JOVENES'
		WHEN edad BETWEEN 21 AND 26 THEN 'ADULTOS JOVENES'
		WHEN edad BETWEEN 27 AND 59 THEN 'ADULTEZ'
		ELSE 'PERSONAS MAYORES'
	END AS grupo_etario_etapa,
	CASE
		WHEN edad BETWEEN 12 AND 17 THEN 'MENORES'
		WHEN edad BETWEEN 18 AND 20 THEN '18 - 20 AÑOS'
		WHEN edad BETWEEN 21 AND 24 THEN '21 - 24 AÑOS'
		WHEN edad BETWEEN 25 AND 29 THEN '25 - 29 AÑOS'
		WHEN edad BETWEEN 30 AND 34 THEN '30 - 34 AÑOS'
		WHEN edad BETWEEN 35 AND 39 THEN '35 - 39 AÑOS'
		WHEN edad BETWEEN 40 AND 44 THEN '40 - 44 AÑOS'
		WHEN edad BETWEEN 45 AND 49 THEN '45 - 49 AÑOS'
		WHEN edad BETWEEN 50 AND 55 THEN '50 - 54 AÑOS'
		WHEN edad BETWEEN 55 AND 59 THEN '55 - 59 AÑOS'
		WHEN edad BETWEEN 60 AND 64 THEN '60 - 64 AÑOS'
		WHEN edad BETWEEN 65 AND 69 THEN '65 - 69 AÑOS'
		WHEN edad BETWEEN 70 AND 74 THEN '70 - 74 AÑOS'
		WHEN edad BETWEEN 75 AND 79 THEN '75 - 79 AÑOS'
		ELSE '80+ AÑOS'
	END AS franja_etaria_activa
FROM generate_series(12, 99) AS seq(edad);

--step 2
INSERT INTO datamart.dim_edad (
	edad_sk,
	grupo_etario_rango,
	grupo_etario_etapa,
	franja_etaria_activa
)
SELECT
	edad_sk,
	grupo_etario_rango,
	grupo_etario_etapa,
	franja_etaria_activa
FROM temp_dim_edad
ORDER BY edad_sk
ON CONFLICT (edad_sk)
DO UPDATE SET
	grupo_etario_rango = EXCLUDED.grupo_etario_rango,
	grupo_etario_etapa = EXCLUDED.grupo_etario_etapa,
	franja_etaria_activa = EXCLUDED.franja_etaria_activa,
	fecha_ultima_modificacion = NOW()
;

--step 3
DROP TABLE IF EXISTS temp_dim_edad;



-- ###########################################################################
-- Tabla objetivo: DIM_GENERACION
-- ###########################################################################

-- SELECT * FROM datamart.dim_generacion;

--step1 
CREATE TEMP TABLE temp_dim_generacion AS
SELECT 
	anho AS anho_nacimiento_sk,
	CASE 
		WHEN anho BETWEEN 1928 AND 1945 THEN 'GENERACIÓN SILENCIOSA'
		WHEN anho BETWEEN 1946 AND 1964 THEN 'BABY BOOMERS'
		WHEN anho BETWEEN 1965 AND 1980 THEN 'GENERACIÓN X'
		WHEN anho BETWEEN 1981 AND 1996 THEN 'MILLENNIALS (GENERACIÓN Y)'
		WHEN anho BETWEEN 1997 AND 2012 THEN 'GENERACIÓN Z'
		ELSE 'GENERACIÓN ALFA'
	END AS nombre_generacion,
	CASE 
		WHEN anho BETWEEN 1928 AND 1945 THEN '1928 - 1945'
		WHEN anho BETWEEN 1946 AND 1964 THEN '1946 - 1964'
		WHEN anho BETWEEN 1965 AND 1980 THEN '1965 - 1980'
		WHEN anho BETWEEN 1981 AND 1996 THEN '1981 - 1996'
		WHEN anho BETWEEN 1997 AND 2012 THEN '1997 - 2012'
		ELSE '2013 - PRESENTE'
	END AS rango_anho_nacimiento
FROM generate_series(1928, EXTRACT(YEAR FROM NOW())) AS seq(anho);

--step 2
INSERT INTO datamart.dim_generacion (
	anho_nacimiento_sk,
	nombre_generacion,
	rango_anho_nacimiento
)
SELECT
	anho_nacimiento_sk,
	nombre_generacion,
	rango_anho_nacimiento
FROM temp_dim_generacion
ORDER BY anho_nacimiento_sk
ON CONFLICT (anho_nacimiento_sk)
DO UPDATE SET 
	nombre_generacion = EXCLUDED.nombre_generacion,
	rango_anho_nacimiento = EXCLUDED.rango_anho_nacimiento,
	fecha_ultima_modificacion = NOW()
;

--step 3
DROP TABLE IF EXISTS temp_dim_generacion;