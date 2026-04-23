"""
Ejemplo DAG que demuestra el uso de SubDagOperator.
"""

from __future__ import annotations

import datetime

import poc.example.subdags.subdag as sd
from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.subdag import SubDagOperator

# [START example_subdag_operator]
dag_id = "example_subdag_operator_id"
dag_display_name = "example_subdag_operator"
description="Ejemplo DAG que demuestra el uso de SubDagOperator."
default_args = {
    'owner': 'airflow',
    'start_date': None,
    'depends_on_past': False,
    'retries': 0,
}

with DAG(
    dag_id=dag_id,
    dag_display_name=dag_display_name,
    description=description,
    default_args=default_args,
    start_date=datetime.datetime(2024, 12, 1),
    schedule=None,
    tags=['poc', 'example']
) as dag:

    start = EmptyOperator(
        task_id="start",
    )

    section_1 = SubDagOperator(
        task_id="section-1",
        subdag=sd.subdag_taks(dag_id, "section-1", dag.default_args),
    )

    some_other_task = EmptyOperator(
        task_id="some-other-task",
    )

    section_2 = SubDagOperator(
        task_id="section-2",
        subdag=sd.subdag_taks(dag_id, "section-2", dag.default_args),
    )

    end = EmptyOperator(
        task_id="end",
    )

    start >> section_1 >> some_other_task >> section_2 >> end
# [END example_subdag_operator]
