"""
Este es un DAG de prueba con SQLExecuteQueryOperator y Scripts SQL modularizados.
"""

from __future__ import annotations

from airflow import DAG
from airflow.models import Variable
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
    dag_id="sample_excute_sql_query_op2_id",
    dag_display_name="sample_excute_sql_query_op2",
    description="DAG de prueba con SQLExecuteQueryOperator y Scripts SQL modularizados.",
    default_args=default_args,
    template_searchpath=Variable.get('dags_folder') + 'sample/sql',
    schedule_interval=None,
    catchup=False,
    tags=['poc','sample']
)

# Agregar los operadores SQLExecuteQueryOperator
with dag:

    start = EmptyOperator(task_id='start', dag=dag)

    execute_sql_step_1 = SQLExecuteQueryOperator(
        task_id='execute_sql_step_1',
        sql='postgres_operator_v2_step_1.sql'  # Ruta al archivo SQL
    )

    execute_sql_step_2 = SQLExecuteQueryOperator(
        task_id='execute_sql_step_2',
        sql='postgres_operator_v2_step_2.sql'  # Ruta al archivo SQL
    )

    end = EmptyOperator(task_id='end', dag=dag)

start >> execute_sql_step_1 >> execute_sql_step_2 >> end