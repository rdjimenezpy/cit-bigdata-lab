/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: SENTENCIAS SQL PARA CREAR TIPOS DE DATOS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS.
 * 
 * Descripción: Creamos tipos de datos, funciones y procedimientos almacenados.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


/* -------------------------------------------------------
 * STAGE TO DIM_FECHA
 * ------------------------------------------------------- */

-- dt_fecha DEFINITION

-- DROP TYPE IF EXISTS stage.dt_fecha cascade;

-- CREAMOS UN TIPO DE DATOS ESPECIAL PARA NUESTRA CONSULTA FN_STG_FECHA
CREATE TYPE stage.dt_fecha AS (
    fecha_sk                DATE,
    anho                    INT2,
    mes                     INT2,
    mes_nombre              VARCHAR(12),
    mes_nombre_corto        VARCHAR(5),
    dia                     INT2,
    dia_del_anho            INT2,
    dia_semana              INT2,
    dia_semana_nombre       VARCHAR(12),
    dia_semana_nombre_corto VARCHAR(6),
    calendario_semana       INT2,
    fecha_formateada        VARCHAR(12),
    trimestre               CHAR(2),
    anho_trimestre          VARCHAR(8),
    cuatrimestre            CHAR(2),
    anho_cuatrimestre       VARCHAR(8),
    semestre                CHAR(2),
    anho_semestre           VARCHAR(8),
    anho_mes                VARCHAR(8),
    periodo                 INT,
    anho_calendario_semana  VARCHAR(8),
    es_dia_habil            BOOLEAN,
    es_dia_festivo          BOOLEAN,
    estacion_del_anho       VARCHAR(16)
);


-- fn_stg_fecha DEFINITION

-- DROP FUNCTION IF EXISTS stage.fn_stg_fecha;

-- SELECT * FROM stage.fn_stg_fecha('2024-01-01', '2024-12-31');

-- CREAMOS O MODIFICANOS NUESTRA FUNCION GET STG_DIM_FECHA
CREATE OR REPLACE FUNCTION stage.fn_stg_fecha(fdesde DATE, fhasta DATE)
    RETURNS SETOF stage.dt_fecha
    LANGUAGE plpgsql
AS $function$
DECLARE
   -- variable declaration
BEGIN
	RETURN query WITH tiempo AS (
		SELECT fdesde::DATE + seq.dia AS fecha
		FROM generate_series( 0, (SELECT fhasta::DATE - fdesde::DATE) ) AS seq(dia)
	)
	SELECT
	    fecha                                           AS fecha_sk, -- Clave subrogada
	    EXTRACT(year FROM fecha)::INT2                  AS anho,
	    EXTRACT(month FROM fecha)::INT2                 AS mes,
	    UPPER(TO_CHAR(fecha, 'TMMonth'))::VARCHAR(12)   AS mes_nombre,
	    TO_CHAR(fecha, 'TMMON')::VARCHAR(5)             AS mes_nombre_corto,
	    EXTRACT(day FROM fecha)::INT2                   AS dia,
	    EXTRACT(doy FROM fecha)::INT2                   AS dia_del_anho,
	    UPPER(TO_CHAR(fecha, 'TMD'))::INT2              AS dia_semana,
	    UPPER(TO_CHAR(fecha, 'TMDay'))::VARCHAR(12)     AS dia_semana_nombre,
	    UPPER(TO_CHAR(fecha, 'TMDY'))::VARCHAR(6)       AS dia_semana_nombre_corto,
	    EXTRACT(week FROM fecha)::INT2                  AS calendario_semana, -- Semana del calendario - ISO
	    TO_CHAR(fecha, 'dd. mm. yyyy')::VARCHAR(12)     AS fecha_formateada,
	    ('T' || TO_CHAR(fecha, 'Q'))::CHAR(2)           AS trimestre,
	    TO_CHAR(fecha, 'yyyy/"T"Q')::VARCHAR(8)         AS anho_trimestre,
	    CASE
	        WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 4 THEN 'C1'
	        WHEN EXTRACT(month FROM fecha) BETWEEN 5 AND 8 THEN 'C2'
	        ELSE 'C3'
	    END::CHAR(2)                                    AS cuatrimestre,
	    CASE
	        WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 4 THEN to_char(fecha, 'yyyy')||'/C1'
	        WHEN EXTRACT(month FROM fecha) BETWEEN 5 AND 8 THEN to_char(fecha, 'yyyy')||'/C2'
	        ELSE TO_CHAR(fecha, 'yyyy')||'/C3'
	    END::VARCHAR(8)                                 AS anho_cuatrimestre,   
	    CASE
	        WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 6 THEN 'S1'
	        ELSE 'S2' 
	    END::CHAR(2)                                    AS semestre,
	    CASE
	        WHEN EXTRACT(month FROM fecha) BETWEEN 1 AND 6 THEN TO_CHAR(fecha, 'yyyy')||'/S1'
	        ELSE TO_CHAR(fecha, 'yyyy')||'/S2'
	    END::VARCHAR(8)                                 AS anho_semestre,
	    TO_CHAR(fecha, 'yyyy/mm')::VARCHAR(8)           AS anho_mes,
	    TO_CHAR(fecha, 'yyyymm')::INT                   AS periodo,
	    TO_CHAR(fecha, 'iyyy/IW')::VARCHAR(8)           AS anho_calendario_semana, -- Año y semana del calENDario - ISO
	    CASE -- Fin de semana
	        WHEN extract(isodow FROM fecha) in (6, 7)
	            THEN false
	        ELSE true
	    END::BOOLEAN                                    AS es_dia_habil,
	    CASE -- Días festivos fijos en Paraguay
	        WHEN TO_CHAR(fecha, 'MMDD') in ('0101', '0514', '0515', '0815', '1208', '1225') THEN true
	        ELSE false
	    END::BOOLEAN                                    AS es_dia_festivo,
	    CASE -- Períodos del año, se ajustan a su organizacion y pais.
	        WHEN TO_CHAR(fecha, 'MMDD') >= '1221' or to_char(fecha, 'MMDD') <= '0320' THEN 'VERANO'
	        WHEN TO_CHAR(fecha, 'MMDD') BETWEEN '0321' AND '0620' THEN 'OTOÑO'
	        WHEN TO_CHAR(fecha, 'MMDD') BETWEEN '0621' AND '0920' THEN 'INVIERNO'
	        WHEN TO_CHAR(fecha, 'MMDD') BETWEEN '0921' AND '1220' THEN 'PRIMAVERA'
	    END::VARCHAR(16)                                AS estacion_del_anho
	FROM tiempo;
END;
$function$
;
