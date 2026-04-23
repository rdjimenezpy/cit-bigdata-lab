/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SCRIPT PARA ELIMINAR TODAS LAS TABLAS DEL ESQUEMA sfp.
 * 
 * Descripción: Borrar las tablas del esquema sfp en cascada.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */


DROP TABLE sfp.cargo CASCADE;

DROP TABLE sfp.control_financiero CASCADE;

DROP TABLE sfp.entidad CASCADE;

DROP TABLE sfp.estado CASCADE;

DROP TABLE sfp.fuente_financiamiento CASCADE;

DROP TABLE sfp.funcionario CASCADE;

DROP TABLE sfp.funcionario_puesto CASCADE;

DROP TABLE sfp.grupo_gasto CASCADE;

DROP TABLE sfp.nacionalidad CASCADE;

DROP TABLE sfp.nivel CASCADE;

DROP TABLE sfp.objeto_gasto CASCADE;

DROP TABLE sfp.oee CASCADE;

DROP TABLE sfp.periodo CASCADE;

DROP TABLE sfp.persona CASCADE;

DROP TABLE sfp.profesion CASCADE;

DROP TABLE sfp.remuneracion_cabecera CASCADE;

DROP TABLE sfp.remuneracion_detalle CASCADE;

DROP TABLE sfp.sexo CASCADE;

DROP TABLE sfp.subgrupo_gasto CASCADE;

DROP TABLE sfp.tipo_discapacidad CASCADE;