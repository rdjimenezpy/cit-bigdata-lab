/*
 ¿Qué es file_fdw?

 file_fdw es una extensión oficial que permite leer archivos (CSV, etc.) desde el sistema de archivos del servidor
 como si fueran tablas (solo lectura)

 Con file_fdw, describes la estructura de columnas y apuntas a la ruta absoluta del archivo. Opciones más usadas:

	filename (ruta absoluta en el servidor)
	format 'csv'
	header 'true'|'false'
	delimiter ',' | ';' | '\t' | ...
	quote '"', escape '"'
	null '' (valor a tratar como NULL)
	encoding 'UTF8' | 'WIN1252' | 'LATIN1' | ...

 Consejo: empieza con TEXT en todas las columnas; luego Castea en consultas o crea una vista tipificada.
*/

-- 1. Preparar el archivo en Windows

-- 2. Crear extensión y “servidor” file_fdw

-- 2.1. Extensión
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- 2.2. Esquema para tablas foráneas
CREATE SCHEMA IF NOT EXISTS fdw;

-- 2.3. Servidor file_fdw (no requiere opciones)
CREATE SERVER IF NOT EXISTS file_srv
  FOREIGN DATA WRAPPER file_fdw;

/* ==================== CLASIFICADOR_OEE ==================== */

-- 3. Definir la FOREIGN TABLE para el CSV

-- 4. DDL sugerido para oee.csv

DROP FOREIGN TABLE IF EXISTS fdw.clasificador_oee;

CREATE FOREIGN TABLE fdw.clasificador_oee (
    cod_nivel           smallint,
    nivel               text,
    cod_entidad         smallint,
    entidad             text,
    cod_oee             smallint,
    oee                 text,
    descripcion_corta   text,
    direccion           text,
    telefono            text,
    pagina_web          text,
    uri                 text
)
SERVER file_srv
OPTIONS (
    filename 'D:\\Dataset\\Opendata\\RAW\\clasificador_oee.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '"',
    null '',
    encoding 'iso-8859-1'
);

-- 5. Pruebas rápidas

SELECT * FROM fdw.clasificador_oee LIMIT 10;

SELECT * FROM fdw.clasificador_oee where cod_nivel = 90;

/* ==================== CLASIFICADOR_GASTOS ==================== */

-- Crear tabla foránea
DROP FOREIGN TABLE IF EXISTS fdw.clasificador_gastos;

CREATE FOREIGN TABLE fdw.clasificador_gastos (
    cod_grupo               smallint,
    grupo                   text,
    cod_subgrupo            smallint,
    subgrupo                text,
    cod_objeto_gasto     smallint,
    objeto_gasto            text,
    cod_control_financiero  smallint,
    control_financiero      text,
    clasificacion_gasto     text
)
SERVER file_srv
OPTIONS (
    filename 'D:\\Dataset\\Opendata\\RAW\\clasificador_gastos.csv',
    format 'csv',
    header 'true',
    delimiter ';',
    quote '"',
    escape '"',
    null '',
    encoding 'UTF8'
);

-- Pruebas rápidas
SELECT * FROM fdw.clasificador_gastos LIMIT 10;

SELECT * FROM fdw.clasificador_gastos WHERE cod_objeto_gasto = 111 or cod_objeto_gasto = 161;

/* ==================== COTIZACION_USD_MENSUAL ==================== */

-- https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual

-- Crear la tabla foránea para el CSV de la Cotización de Referencia - Cierre Mensual
DROP FOREIGN TABLE IF EXISTS fdw.cotizacion_usd_mensual;

CREATE FOREIGN TABLE fdw.cotizacion_usd_mensual (
    fecha_cierre    date,
    periodo         text,
    anho            smallint,
    mes             smallint,
    cotizacion      numeric(12, 2)
)
SERVER file_srv
OPTIONS (
    filename 'D:\\Dataset\\Opendata\\RAW\\cotizacion_usd_mensual.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '"',
    null '',
    encoding 'UTF8'
);

-- Pruebas rápidas
SELECT * FROM fdw.cotizacion_usd_mensual LIMIT 10;

SELECT * FROM fdw.cotizacion_usd_mensual WHERE anho = 2025 and mes = 11;

SELECT * FROM fdw.cotizacion_usd_mensual WHERE anho in(2025, 2024);

/* ==================== NIVEL DEL RIO DE PILAR ==================== */

-- Crear la tabla foránea para el CSV de
DROP FOREIGN TABLE IF EXISTS fdw.rio_paraguay_pilar_diario;

CREATE FOREIGN TABLE fdw.rio_paraguay_pilar_diario (
    fecha       date,
    nivel_m     numeric(12, 2)
)
SERVER file_srv
OPTIONS (
    filename 'D:\\Dataset\\Opendata\\RAW\\rio_paraguay_pilar_diario.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '"',
    null '',
    encoding 'UTF8'
);

-- Pruebas rápidas
SELECT * FROM fdw.rio_paraguay_pilar_diario LIMIT 10;

SELECT count(*) FROM fdw.rio_paraguay_pilar_diario; --16.784

-- VW CALENDARIO
CREATE OR REPLACE VIEW fdw.vw_calendario AS
WITH calendario AS (
	SELECT generate_series('1980-01-01'::date, '2025-12-23'::date, interval '1 day')::date AS fecha
)
SELECT * FROM calendario;

SELECT count(*) FROM fdw.vw_calendario; --16.794