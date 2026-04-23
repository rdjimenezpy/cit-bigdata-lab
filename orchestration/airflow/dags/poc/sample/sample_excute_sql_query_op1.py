"""
Este es un DAG de prueba con SQLExecuteQueryOperator básico.
"""

from __future__ import annotations

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable

# Define los argumentos del DAG
default_args = {
    'owner': 'sample',
    'start_date': days_ago(0),
    'retries': 0,
}

# Crea el DAG
dag = DAG(
    dag_id="sample_excute_sql_query_op1_id",
    dag_display_name="sample_excute_sql_query_op1",
    description='DAG de prueba con SQLExecuteQueryOperator básico.',
    default_args=default_args,
    template_searchpath=Variable.get("dags_folder") + 'sample/sql',
    schedule_interval=None,  # Frecuencia de ejecución del DAG (@once)
    catchup=False,
    tags=['poc', 'sample']
)

# Agrega el operador SQLExecuteQueryOperator
with dag:

    start = EmptyOperator(task_id='start', dag=dag)

    task_execute_sql = SQLExecuteQueryOperator(
        task_id='execute_sql',
        sql='postgres_operator_v1.sql',  # Ruta al archivo SQL
        conn_id='postgres_default',  # Nombre de la conexión configurada en el airflow web
    )

    end = EmptyOperator(task_id='end', dag=dag)

start >> task_execute_sql >> end