/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR LA BASE DE DATOS DE LABORATORIO Y LOS ESQUEMAS DE LA CAPA DE DATOS.
 * 
 * Descripción: Crear la estructura de la base de datos inicial.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- DROP TABLESPACE dbspace

-- CREATE TABLESPACE dbspace
-- LOCATION 'D:\Storage\Postgresql\data\dbs'; --cambiar ubicacion


-- DROP DATABASE dwh;

CREATE DATABASE dwh
	OWNER postgres
	ENCODING UTF8
	TEMPLATE template0
    LOCALE 'es_PY.utf8'
    TABLESPACE dbspace
    IS_TEMPLATE false
;
    
COMMENT ON DATABASE dwh IS 'Base de datos en PostgreSQL para las clases práctica de data warehousing.';


-- DROP SCHEMA raw;

CREATE SCHEMA raw AUTHORIZATION postgres;

COMMENT ON SCHEMA raw IS 'Etapa de extracción de datos en bruto.';


-- DROP SCHEMA stage;

CREATE SCHEMA stage AUTHORIZATION postgres;

COMMENT ON SCHEMA stage IS 'Etapa de preparación de los datos.';


-- DROP SCHEMA datamart;

CREATE SCHEMA datamart AUTHORIZATION postgres;

COMMENT ON SCHEMA datamart IS 'Implementación de los cubos en la base de datos.';


DROP SCHEMA public;