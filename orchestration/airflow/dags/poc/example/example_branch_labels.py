"""
Ejemplo de DAG que demuestra el uso de etiquetas con diferentes ramas.
"""

from __future__ import annotations

from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from airflow.utils.edgemodifier import Label

with DAG(
    dag_id="example_branch_labels_id",
    dag_display_name="example_branch_labels",
    description="Ejemplo de DAG que demuestra el uso de etiquetas con diferentes ramas.",
    start_date=None,
    schedule=None,
    catchup=False,
    tags= ['poc', 'example']
) as dag:
    start = EmptyOperator(task_id="start")
    ingest = EmptyOperator(task_id="ingest")
    analyse = EmptyOperator(task_id="analyze")
    check = EmptyOperator(task_id="check_integrity")
    describe = EmptyOperator(task_id="describe_integrity")
    error = EmptyOperator(task_id="email_error")
    save = EmptyOperator(task_id="save")
    report = EmptyOperator(task_id="report")

    start >> ingest >> analyse >> check
    check >> Label("No errors") >> save >> report
    check >> Label("Errors found") >> describe >> error >> report
