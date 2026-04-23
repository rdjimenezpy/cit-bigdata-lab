/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR LA BASE DE DATOS DE LABORATORIO Y LOS ESQUEMAS DE LA CAPA DE DATOS.
 * 
 * Descripción: Crear la estructura de la base de datos inicial.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */


-- DROP TABLESPACE dbspace

--CREATE TABLESPACE dbspace
--LOCATION 'D:\Storage\Postgresql\data\dbs';


-- DROP DATABASE bigdata;

CREATE DATABASE bigdata
	OWNER postgres
	ENCODING UTF8
	TEMPLATE template0
    LOCALE 'es_PY.utf8'
    TABLESPACE dbspace
    IS_TEMPLATE false
;
    
COMMENT ON DATABASE database IS 'Base de datos de laboratorio en PostgreSQL para las clases prácticas.';


-- DROP SCHEMA raw;

CREATE SCHEMA raw AUTHORIZATION postgres;

COMMENT ON SCHEMA raw IS 'Etapa de extracción de los datos en crudo del origen.';


-- DROP SCHEMA stage;

CREATE SCHEMA stage AUTHORIZATION postgres;

COMMENT ON SCHEMA stage IS 'Etapa de preparación de los datos.';


-- DROP SCHEMA sfp;

CREATE SCHEMA sfp AUTHORIZATION postgres;

COMMENT ON SCHEMA sfp IS 'Implementación del modelo de datos fisico de la base de datos.';


-- DROP SCHEMA public;