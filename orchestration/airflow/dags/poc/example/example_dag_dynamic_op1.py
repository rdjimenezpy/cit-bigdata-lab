"""
Ejemplo que demuestra el uso de un DAG dynamic - Opcion 1.
"""

from __future__ import annotations

import datetime

from airflow import DAG
from airflow.models.baseoperator import chain
from airflow.operators.empty import EmptyOperator

# Opcion 2
with DAG(
        dag_id="example_dag_dynamic_op1_id",
        dag_display_name= "example_dag_dynamic_op1",
        description="Ejemplo que demuestra el uso de un DAG dynamic - Opcion 1.",
        start_date=None,
        schedule=None,
        catchup=False,
        tags= ['poc', 'example']
):
    first = EmptyOperator(task_id="first")
    last = EmptyOperator(task_id="last")

    options = ["branch_a", "branch_b", "branch_c", "branch_d", "branch_z"]
    for option in options:
        t = EmptyOperator(task_id=option, task_display_name=option)
        first >> t >> last