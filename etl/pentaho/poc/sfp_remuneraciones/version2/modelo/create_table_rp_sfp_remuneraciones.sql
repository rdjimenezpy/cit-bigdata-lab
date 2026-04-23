/* MODELO DE DATOS:
 * Corresponde a los datos de las remuneraciones presupuestadas y devengadas 
 * de los Funcionarios Públicos por cada organismo y entidad del estado.
*/

SET search_path TO dpl;

-- Eliminar tabla
DROP TABLE IF EXISTS dpl.rp_sfp_remuneraciones;

-- tabla temporal para cargar los datos
CREATE UNLOGGED TABLE stage.rp_sfp_remuneraciones_temporal (
	periodo_anho TEXT,
	periodo_mes TEXT,
	periodo_mes_nombre TEXT,
	institucion_nivel_codigo TEXT,
	institucion_nivel_descripcion TEXT,
	institucion_entidad_codigo TEXT,
	institucion_entidad_descripcion TEXT,
	institucion_oee_codigo TEXT,
	institucion_oee_descripcion TEXT,
	funcionario_segmento TEXT,
	funcionario_cedula TEXT,
	funcionario_nombres TEXT,
	funcionario_apellidos TEXT,
	funcionario_sexo TEXT,
	funcionario_fecha_nacimiento TEXT,
	funcionario_discapacidad TEXT,
	funcionario_discapacidad_tipo TEXT,
	funcionario_estado TEXT,
	funcionario_anho_ingreso TEXT,
	rubro_linea_codigo TEXT,
	rubro_categoria_codigo TEXT,
	rubro_objeto_gasto_codigo TEXT ,
	rubro_objeto_gasto_concepto TEXT,
	rubro_monto_presupuestado BIGINT,
	rubro_monto_devengado BIGINT
);


-- Crear tabla final para el conjunto de datos de analisis
CREATE TABLE dpl.rp_sfp_remuneraciones (
	periodo_anho TEXT,
	periodo_mes TEXT,
	periodo_mes_nombre TEXT,
	institucion_nivel_codigo TEXT,
	institucion_nivel_descripcion TEXT,
	institucion_entidad_codigo TEXT,
	institucion_entidad_descripcion TEXT,
	institucion_oee_codigo TEXT,
	institucion_oee_descripcion TEXT,
	funcionario_segmento TEXT,
	funcionario_cedula TEXT,
	funcionario_nombres TEXT,
	funcionario_apellidos TEXT,
	funcionario_sexo TEXT,
	funcionario_fecha_nacimiento TEXT,
	funcionario_discapacidad TEXT,
	funcionario_discapacidad_tipo TEXT,
	funcionario_estado TEXT,
	funcionario_anho_ingreso TEXT,
	rubro_linea_codigo TEXT,
	rubro_categoria_codigo TEXT,
	rubro_objeto_gasto_codigo TEXT ,
	rubro_objeto_gasto_concepto TEXT,
	rubro_monto_presupuestado BIGINT,
	rubro_monto_devengado BIGINT
);

-- Consultar tabla final
SELECT * FROM dpl.rp_sfp_remuneraciones;
