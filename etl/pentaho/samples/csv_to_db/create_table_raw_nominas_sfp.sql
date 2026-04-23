
SET search_path TO sample;


DROP TABLE IF EXISTS raw_nomina_sfp;


--tabla con los datos crudo
CREATE TABLE raw_nomina_sfp
(
    anho TEXT,
    mes TEXT,
    nivel TEXT,
    descripcion_nivel TEXT,
    entidad TEXT,
    descripcion_entidad TEXT,
    oee TEXT,
    descripcion_oee TEXT,
    documento TEXT,
    nombres TEXT,
    apellidos TEXT,
    funcion TEXT,
    estado TEXT,
    carga_horaria TEXT,
    anho_ingreso TEXT,
    sexo TEXT,
    discapacidad TEXT,
    tipo_discapacidad TEXT,
    fuente_financiamiento TEXT,
    objeto_gasto TEXT,
    concepto TEXT,
    linea TEXT,
    categoria TEXT,
    cargo TEXT,
    presupuestado BIGINT,
    devengado BIGINT,
    movimiento TEXT,
    lugar TEXT,
    fecha_nacimiento TEXT,
    fec_ult_modif TEXT,
    uri TEXT,
    fecha_acto TEXT,
    correo TEXT,
    profesion TEXT,
    motivo_movimiento TEXT
);