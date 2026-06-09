"""
Ejemplo que demuestra el uso de un DAG dynamic - Opcion 2.
"""

from __future__ import annotations

import datetime

from airflow import DAG
from airflow.models.baseoperator import chain
from airflow.operators.empty import EmptyOperator

# Opcion 1
with DAG(
        dag_id="example_dag_dynamic_op2_id",
        dag_display_name="example_dag_dynamic_op2",
        description="Ejemplo que demuestra el uso de un DAG dynamic - Opcion 2.",
        start_date=datetime.datetime(2025, 12, 31),
        schedule=None,
        catchup=False,
        tags= ['poc', 'example']
):
    chain(*[EmptyOperator(task_id='task' + str(i)) for i in range(1, 6)])
