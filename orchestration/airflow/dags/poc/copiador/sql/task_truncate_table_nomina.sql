
DO $$
BEGIN
    SET search_path TO {{ schema }};

    -- Verificamos si la tabla target principal existe
    IF EXISTS ( SELECT 1 FROM pg_tables WHERE schemaname = '{{ schema }}' AND tablename = '{{ target_1 }}' ) THEN
        -- Si existe, la truncamos
        TRUNCATE TABLE {{ target_1 }};
    ELSE
        -- Si no existen, la creamos
        CREATE TABLE {{ target_1 }} (
            anho int2 NULL,
            mes int2 NULL,
            nivel int2 NULL,
            descripcion_nivel text NULL,
            entidad int2 NULL,
            descripcion_entidad text NULL,
            oee int2 NULL,
            descripcion_oee text NULL,
            documento text NULL,
            nombres text NULL,
            apellidos text NULL,
            sexo text NULL,
            fecha_nacimiento text NULL,
            discapacidad text NULL,
            tipo_discapacidad text NULL,
            profesion text NULL,
            anho_ingreso int2 NULL,
            cargo text NULL,
            funcion text NULL,
            estado text NULL,
            fuente_financiamiento int2 NULL,
            objeto_gasto int2 NULL,
            concepto text NULL,
            linea text NULL,
            categoria text NULL,
            presupuestado int4 NULL,
            devengado int4 NULL
        );
    END IF;

    -- Verificamos si la tabla target de eliminados existe
    IF EXISTS ( SELECT 1 FROM pg_tables WHERE schemaname = '{{ schema }}' AND tablename = '{{ target_2 }}' ) THEN
        -- Si existe, la truncamos
        TRUNCATE TABLE {{ target_2 }};
    ELSE
        -- Si no existen, la creamos
        CREATE TABLE {{ target_2 }} (
            anho int2 NULL,
            mes int2 NULL,
            nivel int2 NULL,
            descripcion_nivel text NULL,
            entidad int2 NULL,
            descripcion_entidad text NULL,
            oee int2 NULL,
            descripcion_oee text NULL,
            documento text NULL,
            nombres text NULL,
            apellidos text NULL,
            sexo text NULL,
            fecha_nacimiento text NULL,
            discapacidad text NULL,
            tipo_discapacidad text NULL,
            profesion text NULL,
            anho_ingreso int2 NULL,
            cargo text NULL,
            funcion text NULL,
            estado text NULL,
            fuente_financiamiento int2 NULL,
            objeto_gasto int2 NULL,
            concepto text NULL,
            linea text NULL,
            categoria text NULL,
            presupuestado int4 NULL,
            devengado int4 NULL
        );
    END IF;

END $$