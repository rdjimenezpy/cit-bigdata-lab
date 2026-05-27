"""
Ejemplo definición básica de un DAG padre y uso de SubDAGs.
"""

from __future__ import annotations

from airflow import DAG
from airflow.operators.subdag import SubDagOperator
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.utils.dates import days_ago

# [START subdag]
def subdag(parent_dag_name, child_dag_name, args):

    subdag = DAG(
        dag_id=f'{parent_dag_name}.{child_dag_name}',
        default_args=args,
        schedule=None
    )

    with subdag:

        task_1 = SQLExecuteQueryOperator(
            task_id='create_table',
            conn_id='your_postgres_conn_id',
            sql='''
                CREATE TABLE IF NOT EXISTS your_table (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(50),
                    age INT
                );
            '''
        )

        task_2 = SQLExecuteQueryOperator(
            task_id='insert_data',
            conn_id='your_postgres_conn_id',
            sql='''
                INSERT INTO your_table (name, age) VALUES ('John Doe', 30);
            '''
        )

        task_1 >> task_2

    return subdag
# [END subdag]

# [START sample_subdag]
# Define los argumentos del DAG
default_args = {
    'owner': 'sample',
    'start_date': days_ago(0),
    'retries': 0
}

# Crea el DAG padre
parent_dag = DAG(
    dag_id='parent_dag',
    dag_display_name="sample_template_subdag",
    description="Ejemplo definición básica de un DAG padre y uso de SubDAGs.",
    default_args=default_args,
    schedule=None,
    start_date=days_ago(0),
    tags = ['poc', 'sample']
)

with parent_dag:

    start = EmptyOperator(task_id='start', dag=parent_dag)

    # Crea el SubDAG
    subdag_task = SubDagOperator(
        task_id='subdag_task',
        subdag=subdag('parent_dag', 'subdag_task', default_args),
        dag=parent_dag,
    )

    end = EmptyOperator(task_id='end', dag=parent_dag)

start >> subdag_task >> end
# [END sample_subdag]