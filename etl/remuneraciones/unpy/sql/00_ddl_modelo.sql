
-- CREATE DATABASE bigdata;

-- DROP TABLE IF EXISTS core.fact_remuneraciones_unpy;

-- SELECT * FROM  core.fact_remuneraciones_unpy;

CREATE TABLE core.fact_remuneraciones_unpy
(
  anho INT2
, mes INT2
, nivel_codigo INT2
, entidad_codigo INT2
, oee_codigo INT2
, tipo_documento TEXT
, documento TEXT
, nombres TEXT
, apellidos TEXT
, sexo TEXT
, fecha_nacimiento DATE
, edad INT2
, grupo_etario TEXT
, generacion TEXT
, es_discapacitado BOOLEAN
, discapacidad_descripcion TEXT
, estado TEXT
, anho_ingreso INT2
, fecha_acto_administrativo DATE
, fuente_financiamiento_codigo INT2
, fuente_financiamiento_descripcion TEXT
, subgrupo_codigo INT2
, subgrupo_descripcion TEXT
, objeto_gasto_codigo INT2
, objeto_gasto_descripcion TEXT
, presupuestado_gs BIGINT
, devengado_gs BIGINT
)
;