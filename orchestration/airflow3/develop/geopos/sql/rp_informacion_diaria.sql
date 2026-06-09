DO $$
BEGIN

-- Esquema target
SET search_path TO analytic;

-- Eliminar tabla para reconstruir la informacion
DROP TABLE IF EXISTS analytic.rp_informacion_diaria;

-- Transformar y Cargar datos
CREATE TABLE analytic.rp_informacion_diaria AS
SELECT
	info."OpLocal",
	info."ProInfoFecha",
    metrica."CntProductosActivos",
    metrica."CntProductosInactivos",
    metrica."CntProductosNoAprovechados",
    CAST(metrica."CantidadVendidaEnPeriodo" AS FLOAT) AS "CantidadVendidaEnPeriodo",
    CAST(metrica."PromedioVentas" AS FLOAT) AS "PromedioVentas",
    metrica."VentasPerdidas",
    metrica."CntDiasInventarioNegativo",
    CAST(metrica."InventarioValorizado" AS FLOAT) AS "InventarioValorizado",
    CAST(CAST(metrica."DiasInventario" AS FLOAT) AS INT) AS "DiasInventario",
    metrica."ValorArtInactivosConInv",
    metrica."CntPrdInventariadosSem1",
    metrica."CntPrdInventariadosSem2",
    metrica."CntPrdInventariadosSem3",
    metrica."CntPrdInventariadosSem4",
    CAST(metrica."PrcPrdInventariadosSem1" AS FLOAT) AS "PrcPrdInventariadosSem1",
    CAST(metrica."PrcPrdInventariadosSem2" AS FLOAT) AS "PrcPrdInventariadosSem2",
    CAST(metrica."PrcPrdInventariadosSem3" AS FLOAT) AS "PrcPrdInventariadosSem3",
    CAST(metrica."PrcPrdInventariadosSem4" AS FLOAT) AS "PrcPrdInventariadosSem4",
    metrica."PAFConDesabasto",
    CAST(metrica."MermaValor" AS FLOAT),
    CAST(metrica."MermaPRC" AS FLOAT),
    CAST(metrica."MermaAcumuladaFF" AS FLOAT),
    CAST(metrica."MermaFFAlimentos" AS FLOAT),
    CAST(metrica."MermaFFBebidas" AS FLOAT),
    metrica."HuecosReales",
    metrica."InventarioNegativo",
    metrica."PrcVtaPerdidaCEDIS",
    metrica."PrcVtaPerdidaPrvDirectos",
    metrica."PrcVtaPerdidaFF",
    CAST(metrica."VentasPerdidaActivos" AS FLOAT) AS "VentasPerdidaActivos",
    CAST(metrica."AcumuladoPeriodoActual" AS FLOAT) AS "AcumuladoPeriodoActual"
FROM
	ods.ods_proinformaciondiaria info,
	LATERAL jsonb_to_record(info."ProInfoXMLPrevio"::JSONB) AS metrica(
        "CntProductosActivos" INT,
        "CntProductosInactivos" INT,
        "CntProductosNoAprovechados" INT,
        "CantidadVendidaEnPeriodo" TEXT,
        "PromedioVentas" TEXT,
        "VentasPerdidas" INT,
        "CntDiasInventarioNegativo" INT,
        "InventarioValorizado" TEXT,
        "DiasInventario" TEXT,
        "ValorArtInactivosConInv" INT,
        "CntPrdInventariadosSem1" INT,
        "CntPrdInventariadosSem2" INT,
        "CntPrdInventariadosSem3" INT,
        "CntPrdInventariadosSem4" INT,
        "PrcPrdInventariadosSem1" TEXT,
        "PrcPrdInventariadosSem2" TEXT,
        "PrcPrdInventariadosSem3" TEXT,
        "PrcPrdInventariadosSem4" TEXT,
        "PAFConDesabasto" INT,
        "MermaValor" TEXT,
        "MermaPRC" TEXT,
        "MermaAcumuladaFF" TEXT,
        "MermaFFAlimentos" TEXT,
        "MermaFFBebidas" TEXT,
        "HuecosReales" INT,
        "InventarioNegativo" INT,
        "PrcVtaPerdidaCEDIS" INT,
        "PrcVtaPerdidaPrvDirectos" INT,
        "PrcVtaPerdidaFF" INT,
        "VentasPerdidaActivos" TEXT,
        "AcumuladoPeriodoActual" TEXT
	);

END $$