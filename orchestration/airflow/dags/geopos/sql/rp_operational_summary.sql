DO $$
BEGIN

-- Esquema target
SET search_path TO analytic;

-- Eliminar tabla para reconstruir la informacion
DROP TABLE IF EXISTS  analytic.rp_operational_summary;

-- Transformar y Cargar datos
CREATE TABLE analytic.rp_operational_summary AS
SELECT
	"OP_LOCAL" AS "OpLocal",
	"OP_START_DATE"::TIMESTAMP AS "FechaApertura",
	"OP_FINAL_DATE"::TIMESTAMP AS "FechaCierre",
	"OP_TOTAL_SALE"::INT8 AS "TotalSale",
	"OP_TOTAL_SERVICES"::INT4 AS "TotalServices",
	"OP_TOTAL_SERVICES_GIFCARD"::INT4 AS "TotalServices_Gifcard",
	"OP_TOTAL_DELIVERY"::INT4 AS "TotalDelivery",
	"OP_TOTAL_CLIENT"::INT4 AS "TotalClient",
	"OP_TOTAL_CLIENT_DELIVERY"::INT4 AS "TotalClientDelivery",
	"OP_TOTAL_ANNULMENT"::INT4 AS "TotalAnnulment",
	"OP_TOTAL_SALE_ALL"::INT4 AS "TotalSaleAll"
FROM ods.ods_bo_operational_summary;

END $$