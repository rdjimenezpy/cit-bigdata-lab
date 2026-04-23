/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA ELIMINAR TABLAS, VISTAS, FUNCIONES, PROCEDIMIENTOS Y OTROS OBJETOS DE LA BASE DE DATOS DWH.
 * 
 * Descripción: Para limpiar la base de datos dwh y volver a implementar los ddl.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


/* esquema: datamart */

--eliminar tablas
drop table if exists datamart.dim_fecha;

drop table if exists datamart.dim_periodo;

drop table if exists datamart.dim_institucion;

drop table if exists datamart.dim_funcionario;

drop table if exists datamart.dim_estado;

drop table if exists datamart.dim_fuente_financiamiento;

drop table if exists datamart.dim_gasto_clasificacion;

drop table if exists datamart.dim_edad;

drop table if exists datamart.fact_remuneracion;


--eliminar procedimientos almacenados
drop procedure if exists datamart.sp_cargar_dim_fecha(date, date);

drop procedure if exists datamart.sp_cargar_dim_periodo(date, date);


--eliminar secuencias
drop sequence if exists datamart.dim_institucion_institucion_sk_seq;

drop sequence if exists datamart.dim_funcionario_funcionario_sk_seq;

drop sequence if exists datamart.dim_estado_estado_sk_seq;

drop sequence if exists datamart.dim_fuente_financiamiento_fuente_financiamiento_sk_seq;

drop sequence if exists datamart.dim_gasto_clasificacion_gasto_clasificacion_sk_seq;


/* esquema: stage */

--eliminar tablas
drop table if exists stage.fact_remuneracion_temporal;

drop table if exists stage.fact_remuneracion_pendiente;


--eliminar vistas
drop view if exists stage.vw_stg_fact_remuneracion_temporal;

drop view if exists stage.vw_stg_institucion;

drop view if exists stage.vw_stg_funcionario;

drop view if exists stage.vw_temp_persona;

drop view if exists stage.vw_temp_persona_discapacidad;


--eliminar funciones
drop function if exists stage.fn_get_stg_fecha;


--eliminar tipos de datos
drop type if exists stage.datos_stg_fecha;


/* esquema: raw */
drop table if exists raw.raw_nomina_sfp;
