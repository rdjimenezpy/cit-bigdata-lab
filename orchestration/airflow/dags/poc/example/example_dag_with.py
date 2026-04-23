import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator

# Definir el DAG
default_args = {
    'owner': 'sample',
    'depends_on_past': False,
    'retries': 0,
}


# version 1
with DAG(
    dag_id="example_dag_with_id",
    dag_display_name="example_dag_with",
    description="Ejemplo que demuestra el uso with para declarar un DAG.",
    default_args=default_args,
    tags= ['poc', 'example']
):

    init = EmptyOperator(task_id="init")

    task1 = EmptyOperator(task_id="task1")

    task2 = EmptyOperator(task_id="task2")

    task3 = EmptyOperator(task_id="task3")

    task4 = EmptyOperator(task_id="task4")

    task5 = EmptyOperator(task_id="task5")

    end = EmptyOperator(task_id="end")

    init >> task1 >> task2 >> [task3, task4] >> task5 >> end