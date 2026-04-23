/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: EVENTOS PARA ACTUALIZAR LAS VISTAS MATERIALIZADAS POR CADA EJECUCION DEL ETL.
 * 
 * Descripción: Actualizar la vistas materializadas de cabecera y detalles de remuneraciones.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */

SET search_path TO stage;

/* Crear la función que actualiza las vistas materializadas de cabeceras y detalles 
 * */

-- DROP FUNCTION IF EXISTS stage.refrescar_vm_remuneracion_cabecera_detalle();

CREATE OR REPLACE FUNCTION stage.refrescar_vm_remuneracion_cabecera_detalle() RETURNS TRIGGER AS $$
BEGIN
	-- actualizar vistas en el orden correcto
	refresh materialized VIEW stage.vm_remuneracion_detalle;

	refresh materialized VIEW stage.vm_remuneracion_cabecera;

	RETURN null;
END;
$$ LANGUAGE plpgsql;



/* Crear el evento que invoca a la función de actualización 
 * */

-- DROP TRIGGER actualizar_vm_remuneracion_cabecera_detalle ON raw.raw_nomina_sfp;

CREATE TRIGGER actualizar_vm_remuneracion_cabecera_detalle
AFTER INSERT OR UPDATE OR DELETE
-- AFTER TRUNCATE
ON raw.raw_nomina_sfp
FOR EACH STATEMENT
EXECUTE FUNCTION stage.refrescar_vm_remuneracion_cabecera_detalle();