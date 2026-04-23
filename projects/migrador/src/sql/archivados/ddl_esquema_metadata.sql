/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR TABLAS EN EL ESQUEMA METADATA.
 * 
 * Descripcion: Registros de los logs del Proceso de ETL.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */


-- metadata.tasks definition

-- Drop table

-- DROP TABLE metadata.tasks;

CREATE TABLE metadata.tasks (
	id_batch int4 NULL,
	channel_id varchar(255) NULL,
	transname varchar(255) NULL,
	status varchar(15) NULL,
	errors int8 NULL,
	startdate timestamp NULL,
	enddate timestamp NULL,
	logdate timestamp NULL,
	depdate timestamp NULL,
	replaydate timestamp NULL,
	log_field text NULL
);
CREATE INDEX idx_tasks_1 ON metadata.tasks USING btree (id_batch);
CREATE INDEX idx_tasks_2 ON metadata.tasks USING btree (errors, status, transname);
CREATE INDEX idx_tasks_3 ON metadata.tasks USING btree (transname, logdate);



-- metadata.step_metrics definition

-- Drop table

-- DROP TABLE metadata.step_metrics;

CREATE TABLE metadata.step_metrics (
	id_batch int4 NULL,
	channel_id varchar(255) NULL,
	log_date timestamp NULL,
	transname varchar(255) NULL,
	stepname varchar(255) NULL,
	step_copy int2 NULL,
	lines_read int8 NULL,
	lines_written int8 NULL,
	lines_updated int8 NULL,
	lines_input int8 NULL,
	lines_output int8 NULL,
	lines_rejected int8 NULL,
	errors int8 NULL
);
CREATE INDEX idx_step_metrics_1 ON metadata.step_metrics USING btree (transname, log_date);