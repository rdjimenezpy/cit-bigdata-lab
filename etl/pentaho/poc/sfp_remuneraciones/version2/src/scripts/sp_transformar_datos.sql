-- Configurar el esquema de preparacion
SET search_path TO stage;


-- Configurar el idioma a español
SET lc_time = 'es_ES';


/* PASO 1 - Tareas de transformación y limpieza de datos
 * Para asegurar que los datos sean consistentes, precisos y útiles para análisis.
 * 
 * 1. Limpieza de datos
 *	La limpieza se enfoca en identificar y corregir problemas en los datos.
 *  Algunas tareas comunes incluyen:
 *		- Eliminación de duplicados: Remover registros repetidos para evitar inconsistencias.
 * 		- Manejo de valores nulos: Rellenar datos faltantes (por ejemplo, usando valores promedio) 
 *		o eliminarlos si es necesario.
 *		- Corrección de errores: Rectificar valores incorrectos, como fechas inválidas o formatos erróneos.
 *		- Estandarización: Uniformar formatos, como convertir todas las fechas a un mismo patrón 
 *		o unificar el uso de mayúsculas/minúsculas.
 *
 * 2. Transformación de datos
 *  La transformación adapta los datos a un formato útil o requerido por los sistemas de destino.
 *  Esto incluye:
 *		- Normalización: Reorganizar los datos para que se ajusten a reglas de diseño de bases de datos, 
 *		como descomponer tablas para evitar redundancias.
 *		- Conversión de formatos: Transformar los datos a un tipo compatible con el destino 
 *		(por ejemplo, convertir texto en números).
 *		- Enriquecimiento de datos: Agregar información adicional, como calcular nuevos campos
 *		basados en los existentes.
 *		- Integración: Combinar datos de diferentes fuentes para generar una vista consolidada.
 *		- Filtrado: Eliminar información innecesaria que no aporta valor al proceso.
 */

--DROP TABLE IF EXISTS tmp_rp_sfp_remuneraciones;

CREATE TEMPORARY TABLE tmp_rp_sfp_remuneraciones AS
SELECT
	anho AS periodo_anho,
	mes AS periodo_mes,
	UPPER(TO_CHAR((anho||'-'||mes||'-01')::date, 'TMMonth')) AS periodo_mes_nombre,
	nivel_codigo,
	entidad_codigo,
	oee_codigo,
	CASE
		WHEN LEFT(documento, 1) BETWEEN '1' AND '9' THEN 'NACIONAL'
		WHEN LEFT(documento, 1) = 'E' THEN 'EXTRANJERO'
		WHEN LEFT(documento, 1) = 'A' THEN 'ANONIMO'
		ELSE 'DESCONOCIDO'
	END AS funcionario_segmento,
	documento,
	UPPER(TRIM(nombres)) AS funcionario_nombres,
	UPPER(TRIM(apellidos)) AS funcionario_apellidos,
	UPPER(TRIM(sexo)) AS funcionario_sexo,
	COALESCE(fecha_nacimiento::date, '1900-01-01')::text AS funcionario_fecha_nacimiento,
	UPPER(TRIM(estado)) AS funcionario_estado,
	CASE 
		WHEN anho_ingreso::integer BETWEEN 1950 AND EXTRACT(year FROM CURRENT_DATE) THEN anho_ingreso
		ELSE CASE
				WHEN split_part(fecha_acto, '/', 1)::integer BETWEEN 1950 AND EXTRACT(year FROM CURRENT_DATE)
	        	THEN split_part(fecha_acto, '/', 1)
	        	ELSE '-1'
		END
	END AS funcionario_anho_ingreso,
	coalesce(rtrim(linea), '-1') AS rubro_linea,
	coalesce(rtrim(categoria), '-1') AS rubro_categoria,
	objeto_gasto_codigo,
	presupuestado AS rubro_monto_presupuestado,
	devengado AS rubro_monto_devengado
FROM stage.sfp_nomina_temporal
WHERE --eliminar registros no deseados 
	NOT (presupuestado = 0 OR presupuestado < devengado)
	AND (nivel_codigo IS NOT NULL OR entidad_codigo IS NOT NULL OR oee_codigo IS NOT NULL)
ORDER BY documento, nivel_codigo, entidad_codigo, oee_codigo;

-- Creación de indices
CREATE INDEX idx_rp_remuneraciones_documento ON tmp_rp_sfp_remuneraciones (documento);
CREATE INDEX idx_rp_remuneraciones_objeto_gasto_codigo ON tmp_rp_sfp_remuneraciones (objeto_gasto_codigo);
CREATE INDEX idx_rp_remuneraciones_nivel_entidad_oee_codigo ON tmp_rp_sfp_remuneraciones (nivel_codigo, entidad_codigo, oee_codigo);



/*PASO 2 - Tarea de corrección de errores en las variables discapacidad y tipo_discapacidad
 * Rectificar valores incorrectos para datos de discapacidad de personas.
 *	- Garantizar la calidad y confiabilidad de los datos.
 *	- Facilitar el análisis, minimizando errores y discrepancias.
 *	- Optimizar el rendimiento del sistema al proporcionar solo datos relevantes.
 */

--DROP TABLE IF EXISTS tmp_persona_discapacidad;

CREATE TEMPORARY TABLE tmp_persona_discapacidad AS
SELECT
	documento,
	CASE
		WHEN cardinality(tipo_discapacidad) = 1 THEN COALESCE(tipo_discapacidad[1], 'NINGUNO')
		WHEN cardinality(tipo_discapacidad) = 2 THEN tipo_discapacidad[1]
		WHEN cardinality(tipo_discapacidad) > 2 THEN 'MULTIPLE'
		else 'DESCONOCIDO'
	END funcionario_discapacidad_tipo,
	CASE
		WHEN cardinality(discapacidad) = 1 THEN COALESCE(discapacidad[1], 'NO')
		WHEN cardinality(discapacidad) > 1 THEN 'SI'
		else 'NO'
	END funcionario_discapacidad	
FROM (
	SELECT
		documento,
		array_agg(DISTINCT tipo_discapacidad) AS tipo_discapacidad,
		array_agg(DISTINCT discapacidad) AS discapacidad 
	FROM stage.sfp_nomina_temporal
	GROUP BY documento
) tt
ORDER BY documento;

-- Creación de indices
CREATE INDEX idx_persona_discapacidad_documento ON tmp_persona_discapacidad (documento);



/* PASO 3 - Tarea de transformacion final
 * Generar el conjunto de datos final de calidad y confiabilidad para el análisis.
 *
 *  QUERY VERSION-2: Estrategias de optimización
 *
 *  La instrucción SET synchronous_commit TO OFF
 *		-Las transacciones son confirmadas inmediatamente sin esperar que los datos 
 *		se hayan escrito en disco.
 *		En lugar de garantizar la durabilidad inmediata, los datos se escriben en memoria 
 *		y serán persistidos en disco posteriormente por el proceso de escritura automática.
 *		-Ventajas: Es ideal para operaciones donde la velocidad es más importante que la 
 *		durabilidad, como en sistemas con tolerancia a pérdidas de datos temporales 
 *		(por ejemplo, registros temporales o análisis).
 *		-Desventajas: En caso de falla del servidor, las transacciones confirmadas podrían perderse porque no se han escrito aún en disco.
 *
 *  La instrucción SET work_mem TO '64MB'
 *		En PostgreSQL se utiliza para definir cuánta memoria puede utilizar una operación 
 *		individual para tareas intermedias como ordenamiento (sort) y operaciones de hash 
 *		antes de recurrir a la creación de archivos temporales en disco.
 * 			-Ámbito: Este ajuste afecta las operaciones de ordenamiento, agrupamiento 
 *			y uniones con hash, por cada operación individual. Por lo tanto, si una 
 *			consulta ejecuta varias de estas operaciones, cada una puede utilizar hasta 
 *			el límite de work_mem.
 *			-Impacto en el rendimiento: Al asignar más memoria, se reduce la necesidad de 
 *			escribir datos temporales al disco, lo que mejora el rendimiento. 
 *			Sin embargo, asignar demasiada memoria puede sobrecargar el sistema 
 *			si hay muchas operaciones simultáneas.
 *			En un servidor con mucha memoria, valores como 64MB a 256MB suelen ser buenos para operaciones complejas.
 *			En sistemas con muchas conexiones concurrentes, valores más bajos como 8MB a 32MB son preferibles para evitar saturación.
 *
 *  La instrucción SET enable_nestloo
 *	 En PostgreSQL sirve para controlar el uso de un tipo específico de estrategia de 
 *   ejecución de consultas conocida como Nested Loop Join.
 *		-Al usar esta configuración, PostgreSQL no considerará el Nested Loop Join en los planes de ejecución.
*/

--Esto mejora el rendimiento porque elimina la espera por la operación de escritura en disco,
--especialmente en sistemas con alta carga de transacciones.
SET synchronous_commit TO OFF;

--Puedes ajustar este parámetro en el archivo postgresql.conf para aplicar un valor predeterminado
SET work_mem TO '128MB'; -- Ajusta según la memoria disponible.

--Al usar esta configuración, PostgreSQL no considerará el Nested Loop Join en los planes de ejecución.
SET enable_nestloop TO OFF;

--EXPLAIN ANALYZE
WITH temp_remuneraciones AS (
    SELECT tmp.*, per.funcionario_discapacidad, per.funcionario_discapacidad_tipo FROM tmp_rp_sfp_remuneraciones tmp
    JOIN tmp_persona_discapacidad per ON per.documento = tmp.documento
)
INSERT INTO stage.rp_sfp_remuneraciones_temporal
SELECT
    tmp.periodo_anho,
    tmp.periodo_mes,
    tmp.periodo_mes_nombre,
    sfp.nivel_codigo AS institucion_nivel_codigo,
    sfp.nivel_descripcion AS institucion_nivel_descripcion,
    sfp.entidad_codigo AS institucion_entidad_codigo,
    sfp.entidad_descripcion AS institucion_entidad_descripcion,
    sfp.oee_codigo AS institucion_oee_codigo,
    sfp.oee_descripcion AS institucion_oee_descripcion,
    tmp.funcionario_segmento,
    tmp.documento AS funcionario_cedula,
    tmp.funcionario_nombres,
    tmp.funcionario_apellidos,
    tmp.funcionario_sexo,
    tmp.funcionario_fecha_nacimiento,
    tmp.funcionario_discapacidad,
	tmp.funcionario_discapacidad_tipo,
    tmp.funcionario_estado,
    tmp.funcionario_anho_ingreso,
    tmp.rubro_linea,
    tmp.rubro_categoria,
    pgn.objeto_gasto_codigo AS rubro_objeto_gasto_codigo,
    pgn.objeto_gasto_descripcion AS rubro_objeto_gasto_concepto,
    tmp.rubro_monto_presupuestado,
    tmp.rubro_monto_devengado
FROM temp_remuneraciones tmp
JOIN ods.sfp_oee sfp ON sfp.nivel_codigo = tmp.nivel_codigo 
	AND sfp.entidad_codigo = tmp.entidad_codigo AND sfp.oee_codigo = tmp.oee_codigo
JOIN ods.pgn_gastos_clasificador pgn ON pgn.objeto_gasto_codigo = tmp.objeto_gasto_codigo
;