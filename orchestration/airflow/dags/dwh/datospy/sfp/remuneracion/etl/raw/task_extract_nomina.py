from __future__ import annotations

import os

from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from jinja2 import Environment, FileSystemLoader

# Parámetros de configuración inicial
TABLE_SCHEMA='etl'
TABLE_TEMP='temp_sfp_nomina'
TABLE_TARGET_1='raw_sfp_nomina'
TABLE_TARGET_2='raw_sfp_nomina_eliminado'

# ID de conexión a PostgreSQL
POSTGRES_CONN_ID='postgres_dwh'

# Ubicación del archivo CSV
CSV_FILE_PATH=Variable.get('DATASET_SFP_NOMINA')

# Ubicación de archivos SQL
SQL_FILE_PATH=Variable.get("DAG_FOLDER") + 'dwh/datospy/sfp/remuneracion/cotizacion_mensual/etl/sql'

SQL_CREATE_TEMP_TABLE=f"""
    CREATE TEMP TABLE {TABLE_TEMP} (
        anho int2,
        mes int2,
        nivel int2,
        descripcion_nivel text,
        entidad int2,
        descripcion_entidad text,
        oee int2,
        descripcion_oee text,
        documento text,
        nombres text,
        apellidos text,
        funcion text,
        estado text,
        carga_horaria text,
        anho_ingreso int2,
        sexo text,
        discapacidad text,
        tipo_discapacidad text,
        fuente_financiamiento int2,
        objeto_gasto int2,
        concepto text,
        linea text,
        categoria text,
        cargo text,
        presupuestado int4,
        devengado int4,
        movimiento text,
        lugar text,
        fecha_nacimiento text,
        fec_ult_modif text,
        uri text,
        fecha_acto text,
        correo text,
        profesion text,
        motivo_movimiento text
    );        
"""

SQL_LOAD_TABLE= f"""
    INSERT INTO {TABLE_SCHEMA}.{TABLE_TARGET_1}
    SELECT
        anho,
        mes,
        nivel,
        descripcion_nivel,
        entidad,
        descripcion_entidad,
        oee,
        descripcion_oee,
        documento,
        nombres,
        apellidos,
        sexo,
        fecha_nacimiento,
        discapacidad,
        tipo_discapacidad,
        profesion,
        anho_ingreso,
        cargo,
        funcion,
        estado,
        fuente_financiamiento,
        objeto_gasto,
        concepto,
        linea,
        categoria,
        presupuestado,
        devengado
    FROM {TABLE_TEMP}
    WHERE NOT (presupuestado = 0 AND devengado = 0);
"""

SQL_LOAD_TABLE_ELIMINADO= f"""
    INSERT INTO {TABLE_SCHEMA}.{TABLE_TARGET_2}
    SELECT
        anho,
        mes,
        nivel,
        descripcion_nivel,
        entidad,
        descripcion_entidad,
        oee,
        descripcion_oee,
        documento,
        nombres,
        apellidos,
        sexo,
        fecha_nacimiento,
        discapacidad,
        tipo_discapacidad,
        profesion,
        anho_ingreso,
        cargo,
        funcion,
        estado,
        fuente_financiamiento,
        objeto_gasto,
        concepto,
        linea,
        categoria,
        presupuestado,
        devengado
    FROM {TABLE_TEMP}
    WHERE presupuestado = 0 AND devengado = 0;
"""

# Tarea para crear la tabla (si no existe)
def truncate_table():

    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('task_truncate_table_nomina.sql')

    # Renderizar el archivo SQL con los parámetros
    rendered_sql = template.render(schema=TABLE_SCHEMA, target_1=TABLE_TARGET_1, target_2=TABLE_TARGET_2)

    return SQLExecuteQueryOperator(
        task_id='truncate_table',
        conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )

def __load_csv_to_table():
    # Crear la conexión a PostgreSQL (usando el ID de la conexión configurada en Airflow)
    hook = PostgresHook(postgres_conn_id=POSTGRES_CONN_ID)

    # Crear la consulta de carga masiva usando el comando COPY de PostgreSQL
    copy_sql = f"""
        COPY {TABLE_TEMP} FROM stdin WITH(FORMAT csv, HEADER true, DELIMITER ',');
    """

    # Abrir archivo CSV y cargarlo a PostgreSQL
    if os.path.exists(CSV_FILE_PATH):
        with open(CSV_FILE_PATH, 'r', encoding='ISO-8859-1') as f:
            conn = hook.get_conn()
            cursor = conn.cursor()
            try:
                cursor.execute(SQL_CREATE_TEMP_TABLE)
                cursor.copy_expert(sql=copy_sql, file=f)
                cursor.execute(SQL_LOAD_TABLE)
                cursor.execute(SQL_LOAD_TABLE_ELIMINADO)
                conn.commit()
                print('Proceso de copiado nomina exitosamente')
            except Exception as e:
                conn.rollback()
                print(f'Error copiado nomina: {e}')
            finally:
                cursor.close()
                conn.close()
    else:
        print(f"El archivo {CSV_FILE_PATH} no existe.")

def load_csv_to_table():
    return PythonOperator(
        task_id="load_csv_to_table",
        python_callable=__load_csv_to_table
    )