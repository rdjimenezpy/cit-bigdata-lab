/*
 ¿Qué es postgres_fdw?

 postgres_fdw es una extensión oficial de PostgreSQL que implementa un Foreign Data Wrapper (FDW) especializado para
 conectarse a otras bases de datos PostgreSQL y consultarlas como si fueran tablas locales.
*/

-- 1. Entrar a la base destino y crear el esquema fwd

SET search_path TO raw;

CREATE SCHEMA if NOT EXISTS fdw;

COMMENT ON SCHEMA fdw IS 'Esquema que contiene tablas foráneas para la integración lógica de fuentes distribuidas
sin replicar los datos.';

-- 2. Crear la extensión en la base donde se va a consumir las tablas remotas

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 3. Crear el “servidor foráneo” apuntando a la BD origen

CREATE SERVER personas_srv
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (
    host 'localhost',
    dbname 'personas',
    port '5432'
  );

-- 4. Crear el user mapping (mapeo de usuario)
-- el servidor foráneo necesita saber con qué usuario va a entrar a la BD origen

CREATE USER MAPPING FOR "postgres"
  SERVER personas_srv
  OPTIONS (
    user 'postgres',
    password 'postgres'
  );

-- 5. Crear la tabla foránea propiamente dicha (Importar la tabla)
-- desde la DB destino se crea un objeto que describe la tabla remota

-- Opción A: Crear la tabla foránea a mano

DROP FOREIGN TABLE IF EXISTS fdw.personas;

CREATE FOREIGN TABLE fdw.personas (
    cedula            varchar(20)  OPTIONS (column_name 'cedula'),
    apellidos         varchar(100) OPTIONS (column_name 'apellido'),
    nombres           varchar(100) OPTIONS (column_name 'nombres'),
    fecha_nacimiento  date         OPTIONS (column_name 'fech_nacim'),
    lugar_nacimiento  varchar(100) OPTIONS (column_name 'lugar_nacim'),
    nacionalidad      varchar(100) OPTIONS (column_name 'nacionalidad'),
    sexo              varchar(1)   OPTIONS (column_name 'sexo'),
    estado_civil      varchar(10)  OPTIONS (column_name 'estado_civil')
)
SERVER personas_srv
OPTIONS (
    schema_name 'public',
    table_name  'cedulas'
);

-- Opción B: Importar el esquema automáticamente

IMPORT FOREIGN SCHEMA public
  LIMIT TO (cedulas)
  FROM SERVER personas_srv
  INTO public;

-- 6. Revisar permisos en la base origen

GRANT SELECT ON TABLE public.persona TO postgres;

-- 7. Probar

SELECT * FROM fdw.personas limit 100;

-- 8. Consideraciones de rendimiento

-- Ventaja: Acceso a múltiples bases PostgreSQL sin replicar datos.

-- Empuje de filtros (WHERE, LIMIT, AGGREGATE) al remoto.

-- Una FOREIGN TABLE no es una copia: cada consulta va a ir a la BD personas. Para análisis pesados, quizá quieras
-- hacer una tabla local y un INSERT INTO ... SELECT ... periódico.

-- PostgreSQL 15 empuja bastante los filtros (WHERE) hacia el servidor remoto, así que un WHERE id_persona = 10
-- debería ejecutarse casi como local.

-- Para ETL con Airflow/PDI después, puedes usar esta foreign table como origen.

-- Índices: los índices que ya tienes en la tabla origen ayudan, porque PostgreSQL empuja el filtro al remoto y
-- el remoto puede usar esos índices.

-- postgres_fdw es la versión moderna, optimizada y mantenida oficialmente por el propio equipo de PostgreSQL
-- (supera al viejo dblink).

-- 9. ¿Y si las bases están en distintos servidores/puertos?

CREATE SERVER personas_srv
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (
    host '192.168.1.50',
    dbname 'personas',
    port '5433'
  );

-- 10. Otras soluciones

-- postgres_fdw: Conecta PostgreSQL <--> PostgreSQL (ETL/ELT, federación de datos)

-- file_fdw: Lee archivos CSV como tablas (cargas temporales, staging)

-- oracle_fdw, mysql_fdw: Conectores externos (migraciones, integración)

-- dblink: Ejecución remota sin definir tablas (tareas puntuales (menos eficiente))