DO $$
BEGIN

-- Esquema target
SET search_path TO analytic;

-- Eliminar tabla para reconstruir la informacion
DROP TABLE IF EXISTS analytic.rp_operational_summary_pos;

-- Transformar y Cargar datos
CREATE TABLE analytic.rp_operational_summary_pos AS
SELECT
	"OP_LOCAL"::INT AS "OpLocal",
	"OP_START_DATE"::TIMESTAMP AS "StartDate",
	"OP_POS"::INT AS "OpPos",
	"OP_TOTAL_TX"::INT AS "TotalTx"
FROM ods.ods_bo_operational_summary_pos;

END $$