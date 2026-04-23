/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SCRIPT PARA ELIMINAR LOS REGISTROS DE LAS TABLAS DEL ESQUEMA sfp.
 * 
 * Descripción: Vaciar las tablas del esquema sfp en cascada.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */


-- 
-- TABLAS CARGADAS CON EL ETL
--

-- TRUNCATE TABLE sfp.nivel RESTART IDENTITY CASCADE;
SELECT * FROM sfp.nivel;
SELECT count(*) FROM sfp.nivel;


-- TRUNCATE TABLE sfp.entidad RESTART IDENTITY CASCADE;
SELECT * FROM sfp.entidad;
SELECT count(*) FROM sfp.entidad;


-- TRUNCATE TABLE sfp.oee RESTART IDENTITY CASCADE;
SELECT * FROM sfp.oee;
SELECT count(*) FROM sfp.oee;


-- TRUNCATE TABLE sfp.persona RESTART IDENTITY CASCADE;
SELECT * FROM sfp.persona;
SELECT count(*) FROM sfp.persona;


-- TRUNCATE TABLE sfp.cargo RESTART IDENTITY CASCADE;
SELECT * FROM sfp.cargo;
SELECT count(*) FROM sfp.cargo;


-- TRUNCATE TABLE sfp.profesion RESTART IDENTITY CASCADE;
SELECT * FROM sfp.profesion;
SELECT count(*) FROM sfp.profesion;


-- TRUNCATE TABLE sfp.funcionario RESTART IDENTITY CASCADE;
SELECT * FROM sfp.funcionario;
SELECT count(*) FROM sfp.funcionario;


-- TRUNCATE TABLE sfp.funcionario_puesto RESTART IDENTITY CASCADE;
SELECT * FROM sfp.funcionario_puesto;
SELECT count(*) FROM sfp.funcionario_puesto;


-- TRUNCATE TABLE sfp.remuneracion_cabecera RESTART IDENTITY CASCADE;
SELECT * FROM sfp.remuneracion_cabecera;
SELECT count(*) FROM sfp.remuneracion_cabecera;


-- TRUNCATE TABLE sfp.remuneracion_detalle RESTART IDENTITY CASCADE;
SELECT * FROM sfp.remuneracion_detalle;
SELECT count(*) FROM sfp.remuneracion_detalle;


-- TRUNCATE TABLE sfp.funcionario_puesto RESTART IDENTITY CASCADE;
SELECT * FROM sfp.funcionario_puesto;
SELECT count(*) FROM sfp.funcionario_puesto;


--
-- TABLAS PARAMÉTRICAS
--

SELECT * FROM sfp.tipo_discapacidad;


SELECT * FROM sfp.sexo;


SELECT * FROM sfp.nacionalidad;


SELECT * FROM sfp.estado;


SELECT * FROM sfp.fuente_financiamiento;


SELECT * FROM sfp.periodo;


SELECT * FROM sfp.control_financiero;


SELECT * FROM sfp.grupo_gasto;


SELECT * FROM sfp.subgrupo_gasto;


SELECT * FROM sfp.objeto_gasto;