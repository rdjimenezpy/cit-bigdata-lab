
-- comando para eliminar tabla
DROP TABLE IF EXISTS ods.sfp_oee;

-- comando para crear tabla
CREATE TABLE ods.sfp_oee (
	nivel_codigo TEXT,
	nivel_descripcion TEXT,
	entidad_codigo TEXT,
	entidad_descripcion TEXT,
	oee_codigo TEXT,
	oee_descripcion TEXT,
	descripcion_corta TEXT
);

CREATE INDEX idx_ods_sfp_oee_nivel_entidad_oee_codigo ON ods.sfp_oee (nivel_codigo, entidad_codigo, oee_codigo);

-- consultar tabla
SELECT * FROM ods.sfp_oee;