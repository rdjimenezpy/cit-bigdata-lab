--tablas temporales se utilizan para almacenar datos de manera temporal, 
--con un alcance limitado al tiempo de vida de la sesión o transacción. 
--puedes configurar su comportamiento según tus necesidades

select * from stage.sfp_nomina_temporal limit 10;

/* 1. Tabla temporal estándar (TEMP o TEMPORARY): 
 *   -Se elimina automáticamente al finalizar la sesión.
 *   -Se puede usar para datos temporales específicos de esa sesión.
 * */

DROP TABLE IF EXISTS tmp_persona;

CREATE TEMP TABLE tmp_persona (
	documento text,
	nombres text,
	apellidos text,
	sexo text,
	fecha_nacimiento text
);


SELECT * FROM tmp_persona;

INSERT INTO tmp_persona
SELECT DISTINCT documento, nombres, apellidos, sexo, fecha_nacimiento 
FROM stage.sfp_nomina_temporal
ORDER BY documento;


/* 2. Tabla temporal con control de transacciones (): 
 *   -Puedes usar la cláusula  para definir el comportamiento de la tabla temporal durante una transacción.
 *   -Sin ON COMMIT: Si no se especifica, la tabla temporal conservará los datos hasta que la sesión finalice
 * */

--Elimina todas las filas de la tabla cuando la transacción termina, pero la estructura de la tabla permanece.
CREATE TEMP TABLE tmp_persona (
	documento text,
	nombres text,
	apellidos text,
	sexo text,
	fecha_nacimiento text
) ON COMMIT DELETE ROWS;

-- Inicia la transacción
BEGIN;

INSERT INTO tmp_persona
SELECT DISTINCT documento, nombres, apellidos, sexo, fecha_nacimiento 
FROM stage.sfp_nomina_temporal
ORDER BY documento;

SELECT count(*) FROM tmp_persona;

-- Confirmamos los cambios
COMMIT;

SELECT count(*) FROM tmp_persona;
SELECT * FROM tmp_persona;


--Elimina tanto las filas como la estructura de la tabla al finalizar la transacción
CREATE TEMP TABLE tmp_persona (
	documento text,
	nombres text,
	apellidos text,
	sexo text,
	fecha_nacimiento text
) ON COMMIT DROP;

-- Inicia la transacción
BEGIN;

INSERT INTO tmp_persona
SELECT DISTINCT documento, nombres, apellidos, sexo, fecha_nacimiento 
FROM stage.sfp_nomina_temporal
ORDER BY documento;

SELECT count(*) FROM tmp_persona;

-- Confirmamos los cambios
COMMIT;

SELECT * FROM tmp_persona;


/* Uso de tablas unlogged como alternativa: 
 *   -Aunque no son estrictamente temporales, las tablas unlogged pueden actuar como una alternativa 
 *   para datos temporales cuando buscas mayor rendimiento (pero sin durabilidad).
 * 
 *   -No se registra en el log de transacciones (WAL), por lo que son más rápidas.
 * 
 *   -Los datos se pierden si el servidor se reinicia.
 **/

DROP TABLE IF EXISTS sample.tmp_persona;

CREATE UNLOGGED TABLE sample.tmp_persona (
	documento text,
	nombres text,
	apellidos text,
	sexo text,
	fecha_nacimiento text
);

INSERT INTO sample.tmp_persona
SELECT DISTINCT documento, nombres, apellidos, sexo, fecha_nacimiento 
FROM stage.sfp_nomina_temporal
ORDER BY documento;

SELECT count(*) FROM sample.tmp_persona;