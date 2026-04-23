/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL UTILIZADOS EN EL ETL PARA CARGAR LA TABLA DE HECHO DE REMUNERACION.
 * 
 * Descripción: Backup de los procemientos para la carga de la tabla de hecho. Esto esta incluido en el ETL.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- CONTEO DE REGISTROS RAW
-- SELECT count(*) FROM raw.raw_sfp_nomina; --856.125

-- SELECT count(*) FROM raw.raw_sfp_nomina_eliminado; -- 6.825

-- PASO 1: TRUNCAMOS LA TABLA TEMPORAL FACT REMUNERACION
TRUNCATE TABLE stage.fact_remuneracion_temporal;

-- PASO 2: CARGAMOS EN LA TABLA TEMPORAL FACT REMUNERACION CON EL PEGADO DE CLAVES SK
INSERT INTO stage.fact_remuneracion_temporal
SELECT
	stg.periodo_sk,
	stg.institucion_nivel_codigo,
	stg.institucion_entidad_codigo,
	stg.institucion_oee_codigo,
	di.institucion_sk,
	stg.funcionario_documento,
	df.funcionario_sk,
	stg.fecha_nacimiento,
	stg.edad_sk,
	stg.estado_descripcion,
	de.estado_sk,
	stg.fuente_financiamiento_codigo,
	dff.fuente_financiamiento_sk,
	stg.objeto_gasto_codigo,
	dgc.clasificacion_gasto_sk,
	stg.anho_nacimiento_sk,
	stg.anho_ingreso,
	stg.es_vacante,
	stg.es_anonimo,
	stg.monto_presupuestado,
	stg.monto_devengado,
	stg.monto_descuento
FROM
	stage.vw_stg_fact_remuneracion_temporal stg
	LEFT JOIN datamart.dim_institucion di ON di.nivel_codigo = stg.institucion_nivel_codigo AND di.entidad_codigo = stg.institucion_entidad_codigo AND di.oee_codigo = stg.institucion_oee_codigo
	LEFT JOIN datamart.dim_estado de ON de.estado_descripcion = stg.estado_descripcion
	LEFT JOIN datamart.dim_funcionario df ON df.documento = stg.funcionario_documento
	LEFT JOIN datamart.dim_fuente_financiamiento dff ON dff.fuente_financiamiento_codigo = stg.fuente_financiamiento_codigo
	LEFT JOIN datamart.dim_clasificacion_gasto dgc ON dgc.objeto_gasto_codigo = stg.objeto_gasto_codigo
;


-- CONTEO DE REGISTROS EN TEMPORAL
-- SELECT count(*) FROM stage.fact_remuneracion_temporal; --856.125

-- PASO 3: ELIMINAMOS LOS REGISTROS DE LA TABLA FACT REMUNERACION DEL PERIODO EN PROCESO
--DELETE FROM datamart.fact_remuneracion_mensual_sfp WHERE periodo_sk = (
--	SELECT (anho::TEXT || lpad(mes::TEXT, 2, '0'))::INT FROM raw.raw_sfp_nomina LIMIT 1
--);

-- PASO 3: CARGAMOS EN LA TABLA FACT REMUNERACION
INSERT INTO datamart.fact_remuneracion_mensual_sfp (
	periodo_sk,
	institucion_sk,
	funcionario_sk,
	estado_sk,
	fuente_financiamiento_sk,
	gasto_clasificacion_sk,
	edad_sk,
	anho_nacimiento_sk,
	anho_ingreso,
	es_vacante,
	es_anonimo,
	monto_presupuestado,
	monto_devengado,
	monto_descuento
)
SELECT DISTINCT 
	tmp.periodo_sk,
	tmp.institucion_sk,
	tmp.funcionario_sk,
	tmp.estado_sk,
	tmp.fuente_financiamiento_sk,
	tmp.gasto_clasificacion_sk,
	tmp.edad_sk,
	tmp.anho_nacimiento_sk,
	tmp.anho_ingreso,
	tmp.es_vacante,
	tmp.es_anonimo,
	tmp.monto_presupuestado,
	tmp.monto_devengado,
	tmp.monto_descuento
FROM stage.fact_remuneracion_temporal tmp
WHERE tmp.periodo_sk IS NOT NULL
	AND tmp.institucion_sk IS NOT NULL
	AND tmp.funcionario_sk IS NOT NULL
	AND	tmp.edad_sk IS NOT NULL
	AND tmp.estado_sk IS NOT NULL
	AND tmp.fuente_financiamiento_sk IS NOT NULL
	AND tmp.gasto_clasificacion_sk IS NOT NULL
	and tmp.anho_nacimiento_sk IS NOT NULL
	AND tmp.anho_ingreso IS NOT NULL
	AND NOT tmp.monto_presupuestado = 0
ON CONFLICT (periodo_sk, institucion_sk, funcionario_sk, estado_sk, fuente_financiamiento_sk,
		gasto_clasificacion_sk, edad_sk, anho_nacimiento_sk, anho_ingreso, es_vacante, es_anonimo, monto_presupuestado, monto_devengado, monto_descuento)
DO UPDATE SET
	fecha_ultima_modificacion = NOW()
;


-- CONTEO DE REGISTROS STAGE
-- SELECT count(*) FROM datamart.fact_remuneracion_mensual_sfp; --678.231


-- PASO 4: TRUNCAMOS LA TABLA PENDIENTE FACT REMUNERACION
TRUNCATE TABLE stage.fact_remuneracion_pendiente;


-- PASO 5:  CARGAMOS EN LA TABLA PENDIENTE FACT REMUNERACION
INSERT INTO stage.fact_remuneracion_pendiente
SELECT
  tmp.periodo_sk,
  tmp.institucion_nivel_codigo,
  tmp.institucion_entidad_codigo,
  tmp.institucion_oee_codigo,
  tmp.institucion_sk,
  tmp.funcionario_documento,
  tmp.funcionario_sk,
  tmp.fecha_nacimiento,
  tmp.edad_sk,
  tmp.estado_descripcion,
  tmp.estado_sk,
  tmp.fuente_financiamiento_codigo,
  tmp.fuente_financiamiento_sk,
  tmp.objeto_gasto_codigo,
  tmp.gasto_clasificacion_sk,
  tmp.anho_nacimiento_sk,
  tmp.anho_ingreso,
  tmp.es_vacante,
  tmp.es_anonimo,
  tmp.monto_presupuestado,
  tmp.monto_devengado,
  tmp.monto_descuento
FROM stage.fact_remuneracion_temporal tmp
WHERE tmp.periodo_sk IS NULL
  OR tmp.institucion_sk IS NULL
  OR tmp.funcionario_sk IS NULL
  OR tmp.edad_sk IS NULL
  OR tmp.estado_sk IS NULL
  OR tmp.fuente_financiamiento_sk IS NULL
  OR tmp.gasto_clasificacion_sk IS null
  OR tmp.anho_nacimiento_sk is NULL
  OR tmp.anho_ingreso IS NULL
  OR tmp.monto_presupuestado = 0
;


-- CONTEO DE REGISTROS EN PENDIENTE
-- SELECT count(*) FROM stage.fact_remuneracion_pendiente; --115.342

-- PASO 6: TRUNCAMOS LA LA TABLA FCAT DE DUPLICADOS
TRUNCATE TABLE stage.fact_remuneracion_duplicado;

-- PASO 7: CARGAMOS EN LA TABLA FCAT DE DUPLICADOS
INSERT INTO stage.fact_remuneracion_duplicado
SELECT
	periodo_sk,
	institucion_sk,
	funcionario_sk,
	estado_sk,
	fuente_financiamiento_sk,
	gasto_clasificacion_sk,
	edad_sk,
	anho_nacimiento_sk,
	anho_ingreso,
	es_vacante,
	es_anonimo, 
	monto_presupuestado,
	monto_devengado,
	monto_descuento, 
	count(*) AS cantidad_duplicado
FROM stage.fact_remuneracion_temporal
WHERE periodo_sk IS NOT NULL
	AND institucion_sk IS NOT NULL
	AND funcionario_sk IS NOT NULL
	AND	edad_sk IS NOT NULL
	AND estado_sk IS NOT NULL
	AND fuente_financiamiento_sk IS NOT NULL
	AND gasto_clasificacion_sk IS NOT NULL
	and anho_nacimiento_sk IS NOT NULL
	AND anho_ingreso IS NOT NULL
	AND NOT monto_presupuestado = 0
GROUP BY periodo_sk, institucion_sk, funcionario_sk, estado_sk, fuente_financiamiento_sk,
			gasto_clasificacion_sk, edad_sk, anho_nacimiento_sk, anho_ingreso, es_vacante,
			es_anonimo, monto_presupuestado, monto_devengado, monto_descuento
HAVING count(*) > 1;

-- SELECT count(*) FROM stage.fact_remuneracion_duplicado; --53.155
-- SELECT sum(cantidad_duplicado) FROM stage.fact_remuneracion_duplicado; --115.707

-- SELECT (678231 + 115342 + 115707 - 53155); --856.125
-- SELECT (958138 - 856125) --102.013