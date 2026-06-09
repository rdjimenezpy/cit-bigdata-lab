from __future__ import annotations

from airflow.models import Variable
from airflow.providers.postgres.operators.postgres import PostgresOperator
from jinja2 import Environment, FileSystemLoader

# ID de conexión a PostgreSQL
POSTGRES_CONN_ID='postgres_dwh'

# Ubicación de archivos SQL
SQL_FILE_PATH=Variable.get("DAG_FOLDER") + 'dwh/datospy/sfp/remuneracion/cotizacion_mensual/stage/sql/'

def load_dim_institucion():

    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('stg_dim_institucion.sql')

    rendered_sql = template.render()

    return PostgresOperator(
        task_id='load_dim_institucion',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )

def load_dim_funcionario():

    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(SQL_FILE_PATH))
    template = env.get_template('stg_dim_funcionario.sql')

    rendered_sql = template.render()

    return PostgresOperator(
        task_id='load_dim_funcionario',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql=rendered_sql
    )