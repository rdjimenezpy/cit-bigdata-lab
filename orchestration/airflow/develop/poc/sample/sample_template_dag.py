"""
Ejemplo definición de un DAG básico.
"""

from __future__ import annotations

import pytz

from airflow import DAG
from datetime import timedelta, datetime
from airflow.utils.dates import days_ago
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.empty import EmptyOperator

TZ = pytz.timezone('America/Asuncion')
TODAY = datetime.now(TZ).strftime('%Y-%m-%d')

# cargar argumentos
default_args = {
    'owner': 'sample',
    'start_date': days_ago(1),
    'retries': 1,
    'retry_delay': timedelta(minutes=0.5)
}

dag = DAG(
    dag_id='sample_template_dag_id',
    dag_display_name="sample_template_dag",
    description="Ejemplo definición de un DAG básico.",
    default_args=default_args,
    schedule_interval=None,
    template_searchpath="/home/victor/airflow/SQL",  ##configuracion para que encuentre los archivos sql
    catchup=False,
    tags=['poc', 'sample']
)

##Definir operadores o task para los dags
with dag:

    ini = EmptyOperator(task_id="start", task_display_name='Inicio')

    proceso = EmptyOperator(task_id="process_main", task_display_name='Proceso principal')

    fin = EmptyOperator(task_id="end", task_display_name='Terminado')

##orden de ejecucion
ini >> proceso >> fin
