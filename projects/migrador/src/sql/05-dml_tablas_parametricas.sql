/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DML PARA CREAR LOS REGISTROS DE LAS TABLAS PARAMETRICAS.
 * 
 * Descripción: Insertar registros en las tablas paramétricas.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */

SET search_path TO sfp;

-- DROP TABLE sfp.periodo;

-- TRUNCATE TABLE sfp.periodo RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.periodo;

WITH periodo AS (
SELECT
    date_trunc('month', generate_series('2000-01-01'::date, '2030-12-31'::date, '1 month')) AS fecha
)
INSERT INTO sfp.periodo (anho, mes, mes_nombre, trimestre, cuatrimestre, semestre, usuario_creacion)
SELECT 
	EXTRACT(year FROM fecha) AS anho,
	EXTRACT(month FROM fecha) AS mes,
	UPPER(TO_CHAR(fecha, 'TMMonth')) AS mes_nombre,
	TO_CHAR(fecha, 'q') AS trimestre,
	CASE
		WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 4 THEN 1
		WHEN EXTRACT(month FROM fecha) BETWEEN 5 AND 8 THEN 2
		WHEN EXTRACT(month FROM fecha) BETWEEN 9 AND 12 THEN 3
	END AS cuatrimestre,
	CASE
		WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 6 THEN 1
		WHEN EXTRACT(month FROM fecha) BETWEEN 7 AND 12 THEN 2
	END AS semestre,
	'etlsystem' AS usuario_creacion
FROM periodo;


-- DROP TABLE sfp.tipo_discapacidad;

-- TRUNCATE TABLE sfp.tipo_discapacidad RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.tipo_discapacidad;

INSERT INTO sfp.tipo_discapacidad (codigo, descripcion, discapacidad, usuario_creacion) VALUES 
('00', 'MULTIPLE', true, 'etlsystem'),
('01', 'FISICA', true, 'etlsystem'),
('02', 'INTELECTUAL', true, 'etlsystem'),
('03', 'PSICOSOCIAL', true, 'etlsystem'),
('04', 'AUDITIVA', true, 'etlsystem'),
('05', 'VISUAL', true, 'etlsystem'),
('99', 'NINGUNA', false, 'etlsystem'),
('-1', 'DESCONOCIDO', false, 'etlsystem');


-- DROP TABLE sfp.estado;

-- TRUNCATE TABLE sfp.estado RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.estado;

INSERT INTO sfp.estado (codigo, descripcion, usuario_creacion) VALUES
('COMISIONADO', 'PERSONAL TRASLADADO PARA PRESTAR SERVICIO TEMPORAL EN OTRO OEE', 'etlsystem'),
('CONTRATADO', 'FUNCIONARIO CONTRATADO POR TIEMPO DETERMINADO PRESTA SERVICIO AL ESTADO', 'etlsystem'),
('PERMANENTE', 'FUNCIONARIO NOMBRADO PARA OCUPAR DE MANERA PERMANENTE UN CARGO', 'etlsystem'),
('DESCONOCIDO', 'FUNCIONARIO NOMBRADO PARA OCUPAR DE MANERA PERMANENTE UN CARGO', 'etlsystem');


-- DROP TABLE sfp.fuente_financiamiento;

-- TRUNCATE TABLE sfp.fuente_financiamiento RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.fuente_financiamiento;

INSERT INTO sfp.fuente_financiamiento (codigo, descripcion, usuario_creacion) VALUES
('10', 'TESORO PUBLICO', 'etlsystem'),
('20', 'PRESTAMOS', 'etlsystem'),
('30', 'GENERADOS POR LAS PROPIAS INSTITUCIONES', 'etlsystem'),
('-1', 'DESCONOCIDO', 'etlsystem');


-- DROP TABLE sfp.sexo;

-- TRUNCATE TABLE sfp.sexo RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.sexo;

INSERT INTO sfp.sexo (codigo, descripcion, usuario_creacion) VALUES
('F', 'FEMENINO', 'etlsystem'),
('M', 'MASCULINO', 'etlsystem'),
('N', 'DESCONOCIDO', 'etlsystem');


-- DROP TABLE sfp.nacionalidad;

-- TRUNCATE TABLE sfp.nacionalidad RESTART IDENTITY CASCADE;

-- SELECT * FROM sfp.nacionalidad;

INSERT INTO sfp.nacionalidad (codigo, descripcion, usuario_creacion) VALUES
('PY', 'PARAGUAYA', 'etlsystem'),
('EX', 'EXTRANJERA', 'etlsystem'),
('NA', 'NO APLICA', 'etlsystem'),
('ND', 'NO DEFINE', 'etlsystem');
