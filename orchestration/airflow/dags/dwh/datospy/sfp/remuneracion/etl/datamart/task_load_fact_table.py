from __future__ import annotations

from airflow.models import Variable
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from jinja2 import Environment, FileSystemLoader

# ID de conexión a PostgreSQL
POSTGRES_CONN_ID='postgres_dwh'

# Ubicación de archivos SQL
SQL_FILE_PATH=Variable.get("DAG_FOLDER") + 'dwh/datospy/sfp/remuneracion/cotizacion_mensual/sql/sql/'

def load_fact_table_temporal():
    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('fact_remuneracion_temporal.sql')

    rendered_sql = template.render()

    return SQLExecuteQueryOperator(
        task_id='load_fact_table_temporal',
        conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql,
    )

def load_fact_table():
    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('fact_remuneracion.sql')

    rendered_sql = template.render()

    return SQLExecuteQueryOperator(
        task_id='load_fact_table',
        conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )

def load_fact_table_pendiente():
    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('fact_remuneracion_pendiente.sql')

    rendered_sql = template.render()

    return SQLExecuteQueryOperator(
        task_id='load_fact_table_pendiente',
        conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )

def load_fact_table_duplicado():
    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('fact_remuneracion_duplicado.sql')

    rendered_sql = template.render()

    return SQLExecuteQueryOperator(
        task_id='load_fact_table_duplicado',
        conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )