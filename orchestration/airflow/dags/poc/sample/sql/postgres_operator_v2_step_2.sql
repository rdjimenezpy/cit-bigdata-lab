
DO $$
BEGIN

    -- Inicializar parámetros de entorno
    set search_path to report;

	-- Paso 2 - Cargamos la tabla final
   	insert into rpt_listado_nivel (codigo, nombre)
	SELECT
        nivel::INT2 as codigo,
        descripcion_nivel::VARCHAR(64) as nombre
	FROM raw.raw_sfp_nomina
    GROUP BY nivel, descripcion_nivel
    ORDER BY nivel;

END $$;