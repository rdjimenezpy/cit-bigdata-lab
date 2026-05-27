DO $$
BEGIN
    -- Esquema target
    SET search_path TO analytic;

    -- Eliminar tabla para reconstruir la informacion
    DROP TABLE IF EXISTS analytic.rp_informacion_semanal;

    -- Crear la tabla directamente fuera de los CTEs
    CREATE TABLE analytic.rp_informacion_semanal AS
    WITH temp_infodiaria AS (
        SELECT
            "OpLocal",
            TO_CHAR("ProInfoFecha"::date, 'YYYYMM')::int4 AS "Periodo",
            TO_CHAR("ProInfoFecha"::date, 'YYYY')::int2 AS "Anho",
            TO_CHAR("ProInfoFecha"::date, 'MM')::int2 AS "Mes",
			TO_CHAR("ProInfoFecha"::date, 'WW')::int2 AS "SemanaAnho",
            "CntProductosActivos",
            "CntProductosInactivos",
            "CantidadVendidaEnPeriodo",
            "PromedioVentas",
            "CntProductosNoAprovechados",
            "InventarioValorizado",
            "DiasInventario",
            "PAFConDesabasto",
            "MermaValor",
            "MermaPRC",
            "HuecosReales",
            "InventarioNegativo",
            "ValorArtInactivosConInv",
            "CntPrdInventariadosSem1",
            "CntPrdInventariadosSem2",
            "CntPrdInventariadosSem3",
            "CntPrdInventariadosSem4",
            "VentasPerdidaActivos",
            "AcumuladoPeriodoActual"
        FROM analytic.rp_informacion_diaria
    ),
    temp_infosemanal AS (
        SELECT
            "OpLocal", "Periodo", "Anho", "Mes", "SemanaAnho",
            SUM("CntProductosActivos") AS "SumCntProductosActivos",
            SUM("CntProductosInactivos") AS "SumCntProductosInactivos",
            SUM("CantidadVendidaEnPeriodo") AS "SumCantidadVendidaEnPeriodo",
            SUM("PromedioVentas") AS "SumPromedioVentas",
            SUM("CntProductosNoAprovechados") AS "SumCntProductosNoAprovechados",
            SUM("InventarioValorizado") AS "SumInventarioValorizado",
            SUM("DiasInventario") AS "SumDiasInventario",
            SUM("PAFConDesabasto") AS "SumPAFConDesabasto",
            SUM("MermaValor") AS "SumMermaValor",
            SUM("MermaPRC") AS "SumMermaPRC",
            SUM("HuecosReales") AS "SumHuecosReales",
            SUM("InventarioNegativo") AS "SumInventarioNegativo",
            SUM("ValorArtInactivosConInv") AS "SumValorArtInactivosConInv",
            SUM("CntPrdInventariadosSem1") AS "SumCntPrdInventariadosSem1",
            SUM("CntPrdInventariadosSem2") AS "SumCntPrdInventariadosSem2",
            SUM("CntPrdInventariadosSem3") AS "SumCntPrdInventariadosSem3",
            SUM("CntPrdInventariadosSem4") AS "SumCntPrdInventariadosSem4",
            SUM("VentasPerdidaActivos") AS "SumVentasPerdidaActivos",
            SUM("AcumuladoPeriodoActual") AS "SumAcumuladoPeriodoActual",
            AVG("CntProductosActivos") AS "AvgCntProductosActivos",
            AVG("CntProductosInactivos") AS "AvgCntProductosInactivos",
            AVG("CantidadVendidaEnPeriodo") AS "AvgCantidadVendidaEnPeriodo",
            AVG("PromedioVentas") AS "AvgPromedioVentas",
            AVG("CntProductosNoAprovechados") AS "AvgCntProductosNoAprovechados",
            AVG("InventarioValorizado") AS "AvgInventarioValorizado",
            AVG("DiasInventario") AS "AvgDiasInventario",
            AVG("PAFConDesabasto") AS "AvgPAFConDesabasto",
            AVG("MermaValor") AS "AvgMermaValor",
            AVG("MermaPRC") AS "AvgMermaPRC",
            AVG("HuecosReales") AS "AvgHuecosReales",
            AVG("InventarioNegativo") AS "AvgInventarioNegativo",
            AVG("ValorArtInactivosConInv") AS "AvgValorArtInactivosConInv",
            AVG("CntPrdInventariadosSem1") AS "AvgCntPrdInventariadosSem1",
            AVG("CntPrdInventariadosSem2") AS "AvgCntPrdInventariadosSem2",
            AVG("CntPrdInventariadosSem3") AS "AvgCntPrdInventariadosSem3",
            AVG("CntPrdInventariadosSem4") AS "AvgCntPrdInventariadosSem4",
            AVG("VentasPerdidaActivos") AS "AvgVentasPerdidaActivos",
            AVG("AcumuladoPeriodoActual") AS "AvgAcumuladoPeriodoActual"
        FROM temp_infodiaria
        GROUP BY "OpLocal", "Periodo", "Anho", "Mes", "SemanaAnho"
    )
    SELECT * FROM temp_infosemanal;
END $$;