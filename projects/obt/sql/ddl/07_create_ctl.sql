/*
 * Tabla de control de cargas de archivos:
 */
 
create schema if not exists ctl;

create table if not exists ctl.cargas_nomina_sfp (
    id_carga        bigserial primary key,
    anio            int not null,
    mes             int not null,
    nombre_archivo  text,
    fecha_proceso  timestamptz default now(),
    estado          varchar(20) default 'DESCARGADO', -- DESCARGADO, RAW_OK, STG_OK, CORE_OK, ERROR
    mensaje_error   text
);
