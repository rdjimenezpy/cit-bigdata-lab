"""
Ejemplo que demuestra el uso de un constructor para declarar un DAG.
"""

from __future__ import annotations

from airflow import DAG
from airflow.operators.empty import EmptyOperator

# Definir el DAG
default_args = {
    'owner': 'sample',
    'depends_on_past': False,
    'retries': 0,
}

# version 2
my_dag = DAG(
    dag_id="example_dag_constructor_id",
    dag_display_name="example_dag_constructor",
    description="Ejemplo que demuestra el uso de un constructor para declarar un DAG.",
    default_args=default_args,
    start_date=None,
    schedule=None,
    catchup=False,
    tags= ['poc', 'example']
)

start = EmptyOperator(task_id="start", dag=my_dag)

taks_process = EmptyOperator(task_id="taks_process", dag=my_dag)

end = EmptyOperator(task_id="end", dag=my_dag)

start >> taks_process >> end