
/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: QUERIES PARA REPORTES DE MONITOREOS Y CONTROL DEL PROCESO DE ETL.
 * 
 * Descripción: Reportes Ad Hoc.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */


/* CONTEO DE FILAS DE RAW
 */
SELECT COUNT(*) FROM raw.raw_nomina_sfp;
SELECT COUNT(*) FROM raw.raw_nomina_sfp_eliminado;



/* CONTEO DE FILAS DE CADA VISTA
 */

-- DROP MATERIALIZED VIEW stage.vm_rpt_conteo_vistas;

-- SELECT * FROM stage.vm_rpt_conteo_vistas;

-- REFRESH MATERIALIZED VIEW stage.vm_rpt_conteo_vistas;

CREATE MATERIALIZED VIEW stage.vm_rpt_conteo_vistas AS
SELECT
	tm.id,
	tm.vista,
	tm.cantidad
FROM (
	SELECT 1 AS id, 'VW_NIVEL' AS vista, COUNT(*) AS cantidad FROM stage.vw_nivel
		UNION
	SELECT 2 AS id, 'VW_ENTIDAD' AS vista, COUNT(*) AS cantidad FROM stage.vw_entidad
		UNION
	SELECT 3 AS id, 'VW_OEE' AS vista, COUNT(*) AS cantidad FROM stage.vw_oee
		UNION
	SELECT 4 AS id, 'VW_PERSONA' AS vista, COUNT(*) AS cantidad FROM stage.vw_persona
		UNION
	SELECT 5 AS id, 'VW_CARGO' AS vista, COUNT(*) AS cantidad FROM stage.vw_cargo
		UNION
	SELECT 6 AS id, 'VW_PROFESION' AS vista, COUNT(*) AS cantidad FROM stage.vw_profesion
		UNION
	SELECT 7 AS id, 'VW_FUNCIONARIO' AS vista, COUNT(*) AS cantidad FROM stage.vw_funcionario
		UNION
	SELECT 8 AS id, 'VW_FUNCIONARIO_PUESTO' AS vista, COUNT(*) AS cantidad FROM stage.vw_funcionario_puesto
		UNION
	SELECT 9 AS id, 'VM_REMUNERACION_CABECERA' AS vista, COUNT(*) AS cantidad FROM stage.vm_remuneracion_cabecera
		UNION
	SELECT 10 AS id, 'VM_REMUNERACION_DETALLE' AS vista, COUNT(*) AS cantidad FROM stage.vm_remuneracion_detalle
) tm
ORDER BY tm.id;



/* CONTEO DE FILAS DE CADA TABLA DEL sfp
 */

-- DROP VIEW stage.rpt_vm_conteo_tablas_sfp;

-- SELECT * FROM stage.rpt_vm_conteo_tablas_sfp;

-- REFRESH MATERIALIZED VIEW stage.rpt_vm_conteo_tablas_sfp;

CREATE MATERIALIZED VIEW stage.rpt_vm_conteo_tablas_sfp AS
SELECT
	tm.id,
	tm.tabla,
	tm.cantidad,
	tm.parametrica
FROM (
	SELECT 1 AS id, 'tipo_discapacidad' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.tipo_discapacidad
	  	UNION
	SELECT 2 AS id, 'sexo' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.sexo
	  	UNION
	SELECT 3 AS id, 'nacionalidad' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.nacionalidad
	  	UNION
	SELECT 4 AS id, 'estado' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.estado
	  	UNION
	SELECT 5 AS id, 'fuente_financiamiento' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.fuente_financiamiento
	  	UNION
	SELECT 6 AS id, 'periodo' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.periodo
	  	UNION
	SELECT 7 AS id, 'control_financiero' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.control_financiero
	  	UNION
	SELECT 8 AS id, 'grupo_gasto' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.grupo_gasto
	  	UNION
	SELECT 9 AS id, 'subgrupo_gasto' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.subgrupo_gasto
	  	UNION
	SELECT 10 AS id, 'objeto_gasto' tabla, COUNT(*) cantidad, true AS parametrica FROM sfp.objeto_gasto
		UNION
	SELECT 11 AS id, 'nivel' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.nivel
		UNION
	SELECT 12 AS id, 'entidad' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.entidad
		UNION
	SELECT 13 AS id, 'oee' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.oee
		UNION
	SELECT 14 AS id, 'persona' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.persona
		UNION
	SELECT 15 AS id, 'funcionario' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.funcionario
		UNION
	SELECT 16 AS id, 'cargo' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.cargo
		UNION
	SELECT 17 AS id, 'profesion' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.profesion
		UNION
	SELECT 18 AS id, 'funcionario_puesto' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.funcionario_puesto
		UNION
	SELECT 19 AS id, 'remuneracion_cabecera' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.remuneracion_cabecera
		UNION
	SELECT 20 AS id, 'remuneracion_detalle' tabla, COUNT(*) cantidad, false AS parametrica FROM sfp.remuneracion_detalle
) tm
ORDER BY tm.id;