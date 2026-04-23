
-- comando para eliminar tabla
DROP TABLE IF EXISTS ods.pgn_gastos_clasificador;


-- comando para crear tabla
CREATE TABLE ods.pgn_gastos_clasificador (
	grupo_codigo TEXT,
	grupo_descripcion TEXT,
	subgrupo_codigo TEXT,
	subgrupo_descripcion TEXT,
	objeto_gasto_codigo TEXT,
	objeto_gasto_descripcion TEXT,
	control_financiero_codigo TEXT,
	control_financiero_descripcion TEXT,
	clasificacion_gasto_descripcion TEXT
);

CREATE INDEX idx_ods_pgn_gastos_clasificador_objeto_gasto_codigo ON ods.pgn_gastos_clasificador (objeto_gasto_codigo);

-- consultar tabla
SELECT * FROM ods.pgn_gastos_clasificador;