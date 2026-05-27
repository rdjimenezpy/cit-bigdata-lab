--
--DIMENSION_FUNCIONARIO

-- Inserciones
INSERT INTO datamart.dim_funcionario (
    documento,
    nombres,
    apellidos,
    fecha_nacimiento,
    sexo,
    nacionalidad,
    tipo_discapacidad,
    discapacidad
)
SELECT
    documento,
    nombres,
    apellidos,
    fecha_nacimiento,
    sexo,
    nacionalidad,
    tipo_discapacidad,
    discapacidad
FROM stage.vw_stg_funcionario
ON CONFLICT (documento)
    DO UPDATE SET -- Actualizaciones
                  nombres = EXCLUDED.nombres,
                  apellidos = EXCLUDED.apellidos,
                  fecha_nacimiento = EXCLUDED.fecha_nacimiento,
                  tipo_discapacidad = EXCLUDED.tipo_discapacidad,
                  discapacidad = EXCLUDED.discapacidad,
                  fecha_ultima_modificacion = NOW();