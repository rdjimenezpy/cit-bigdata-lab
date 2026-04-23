"""
DAG para cargar datos en PostgreSQL usando Airflow.
"""

from __future__ import annotations

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.utils.dates import days_ago

#Define los argumentos del DAG
default_args = {
    'owner': 'sample',
    'start_date': days_ago(0),
    'retries': 0,
}

# Crea el DAG
dag = DAG(
    dag_id="sample_load_data_farmacia_id",
    dag_display_name="sample_load_data_farmacia",
    description="Cargar datos en PostgreSQL usando Airflow.",
    default_args=default_args,
    schedule_interval=None,  # Frecuencia de ejecución del DAG (@once)
    template_searchpath="/home/richard/analytics/airflow_project/dags/sample/sql",
    catchup=False,
    tags=['poc', 'sample']
)

# Agrega el operador PostgresOperator
with dag:
    start = EmptyOperator(task_id='start', dag=dag)

    execute_sql_task = SQLExecuteQueryOperator(
        task_id='ejecutar_sql',
        sql='cargar_postgres.sql'# Ruta al archivo SQL
        #conn_id='postgres_defaul',# Nombre de la conexión configurada
        #dag=dag
    )

    end = EmptyOperator(task_id='end', dag=dag)

start >> execute_sql_task >> end