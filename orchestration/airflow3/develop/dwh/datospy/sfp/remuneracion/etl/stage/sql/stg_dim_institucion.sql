--
--DIMENSION_INSTITUCION_SFP

-- Inserciones
INSERT INTO datamart.dim_institucion (
    nivel_codigo,
    nivel_descripcion,
    entidad_codigo,
    entidad_descripcion,
    oee_codigo,
    oee_descripcion,
    descripcion_corta
)
SELECT
    nivel_codigo,
    nivel_descripcion,
    entidad_codigo,
    entidad_descripcion,
    oee_codigo,
    oee_descripcion,
    descripcion_corta
FROM stage.vw_stg_institucion
ON CONFLICT (nivel_codigo, entidad_codigo, oee_codigo)
    DO UPDATE SET -- Actualizaciones
                  nivel_descripcion = EXCLUDED.nivel_descripcion,
                  entidad_descripcion = EXCLUDED.entidad_descripcion,
                  descripcion_corta = EXCLUDED.descripcion_corta,
                  fecha_ultima_modificacion = NOW();