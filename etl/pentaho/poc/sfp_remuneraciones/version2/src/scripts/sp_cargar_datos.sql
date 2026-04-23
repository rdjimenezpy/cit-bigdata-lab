-- Configurar el esquema de presentacion de datos
SET search_path TO dpl;

-- Truncar la tabla final antes de cargar
TRUNCATE TABLE dpl.rp_sfp_remuneraciones;

-- Tarea de cargar los datos para almacenar en el modelo de analisis
INSERT INTO dpl.rp_sfp_remuneraciones
SELECT * FROM stage.rp_sfp_remuneraciones_temporal;