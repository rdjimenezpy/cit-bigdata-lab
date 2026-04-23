/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL UTILIZADOS EN EL ETL PARA CARGAR LA TABLA DE HECHO DE REMUNERACION.
 * 
 * Descripción: Backup de los procemientos para la carga de la tabla de hecho. Esto esta incluido en el ETL.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- CONTEO DE REGISTROS ODS
select count(*) from ods.ods_nomina_sfp;


-- PASO 1: TRUNCAMOS LA TABLA TEMPORAL FACT REMUNERACION
truncate table stage.fact_remuneracion_temporal;

-- PASO 2: CARGAMOS EN LA TABLA TEMPORAL FACT REMUNERACION CON EL PEGADO DE CLAVES SK
insert into stage.fact_remuneracion_temporal
select
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
	dgc.gasto_clasificacion_sk,
	stg.anho_ingreso,
	stg.es_vacante,
	stg.es_anonimo,
	stg.monto_presupuestado,
	stg.monto_devengado,
	stg.monto_descuento
from
	stage.vw_stg_fact_remuneracion_temporal stg
	left join datamart.dim_institucion di on di.nivel_codigo = stg.institucion_nivel_codigo and di.entidad_codigo = stg.institucion_entidad_codigo and di.oee_codigo = stg.institucion_oee_codigo
	left join datamart.dim_estado de on de.estado_descripcion = stg.estado_descripcion
	left join datamart.dim_funcionario df on df.documento = stg.funcionario_documento
	left join datamart.dim_fuente_financiamiento dff on dff.fuente_financiamiento_codigo = stg.fuente_financiamiento_codigo
	left join datamart.dim_gasto_clasificacion dgc on dgc.objeto_gasto_codigo = stg.objeto_gasto_codigo
;


-- CONTEO DE REGISTROS EN TEMPORAL
select count(*) from stage.fact_remuneracion_temporal;

-- PASO 3: ELIMINAMOS LOS REGISTROS DE LA TABLA FACT REMUNERACION DEL PERIODO EN PROCESO
delete from datamart.fact_remuneracion where periodo_sk = 202301;

-- PASO 4: CARGAMOS EN LA TABLA FACT REMUNERACION
insert into datamart.fact_remuneracion
select
	tmp.periodo_sk,
	tmp.institucion_sk,
	tmp.funcionario_sk,
	tmp.edad_sk,
	tmp.estado_sk,
	tmp.fuente_financiamiento_sk,
	tmp.gasto_clasificacion_sk,
	tmp.anho_ingreso,
	tmp.es_vacante,
	tmp.es_anonimo,
	tmp.monto_presupuestado,
	tmp.monto_devengado,
	tmp.monto_descuento
from stage.fact_remuneracion_temporal tmp
where tmp.periodo_sk is not null
	and tmp.institucion_sk is not null
	and tmp.funcionario_sk is not null
	and	tmp.edad_sk is not null
	and tmp.estado_sk is not null
	and tmp.fuente_financiamiento_sk is not null
	and tmp.gasto_clasificacion_sk is not null
	and tmp.anho_ingreso is not null
	and not tmp.monto_presupuestado = 0
;


-- CONTEO DE REGISTROS STAGE
select count(*) from datamart.fact_remuneracion;


-- PASO 5: TRUNCAMOS LA TABLA PENDIENTE FACT REMUNERACION
truncate table stage.fact_remuneracion_pendiente;


-- PASO 6:  CARGAMOS EN LA TABLA PENDIENTE FACT REMUNERACION
insert into stage.fact_remuneracion_pendiente
select
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
  tmp.anho_ingreso,
  tmp.es_vacante,
  tmp.es_anonimo,
  tmp.monto_presupuestado,
  tmp.monto_devengado,
  tmp.monto_descuento
from stage.fact_remuneracion_temporal tmp
where tmp.periodo_sk is null
  or tmp.institucion_sk is null
  or tmp.funcionario_sk is null
  or tmp.edad_sk is null
  or tmp.estado_sk is null
  or tmp.fuente_financiamiento_sk is null
  or tmp.gasto_clasificacion_sk is null
  or tmp.anho_ingreso is null
  or tmp.monto_presupuestado = 0
;


-- CONTEO DE REGISTROS EN PENDIENTE
select count(*) from stage.fact_remuneracion_pendiente;