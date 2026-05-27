
DO $$
DECLARE
	msj_uno varchar(16) = 'Tabla truncada';
	msj_dos varchar(16) = 'Tabla creada';
BEGIN

    -- Inicializar parámetros de entorno
    set search_path to report;

	-- Paso 1 - Verificamos si la tabla existe
    IF EXISTS ( SELECT 1 FROM pg_tables WHERE schemaname = 'report' AND tablename = 'rpt_listado_nivel' ) THEN
        -- Si existe, la truncamos
        TRUNCATE TABLE rpt_listado_nivel RESTART IDENTITY;
        RAISE NOTICE 'Estado: %', msj_uno;
    ELSE
        -- Si no existe, la creamos
        CREATE TABLE rpt_listado_nivel (
            id SERIAL PRIMARY KEY,
            codigo INT2,
            nombre VARCHAR(64)
        );
        RAISE NOTICE 'Estado: %', msj_dos;
    END IF;

END $$;
