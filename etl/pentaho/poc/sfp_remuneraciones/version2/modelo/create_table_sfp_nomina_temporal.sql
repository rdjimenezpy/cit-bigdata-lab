SET search_path TO stage;

-- comando para eliminar tabla
DROP TABLE IF EXISTS stage.sfp_nomina_temporal;

-- comando para crear tabla para guardar temporalmente
CREATE UNLOGGED TABLE stage.sfp_nomina_temporal (
	anho TEXT,
	mes TEXT,
	nivel_codigo TEXT,
	entidad_codigo TEXT,
	oee_codigo TEXT,
	documento TEXT,
	nombres TEXT,
	apellidos TEXT,
	sexo TEXT,
	fecha_nacimiento TEXT,
	discapacidad TEXT,
	tipo_discapacidad TEXT,
	estado TEXT,
	anho_ingreso TEXT,
	fecha_acto TEXT,
	linea TEXT,
	categoria TEXT,
	objeto_gasto_codigo TEXT ,
	presupuestado INT,
	devengado INT
);

-- consultas para verificar los datos
SELECT * FROM stage.sfp_nomina_temporal;

SELECT count(*) FROM stage.sfp_nomina_temporal; --2.785.413

SELECT anho, mes, count(*) FROM stage.sfp_nomina_temporal GROUP BY anho, mes;