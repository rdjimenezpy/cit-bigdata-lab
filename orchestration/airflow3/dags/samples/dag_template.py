"""
Ejemplo de definición de un DAG básico compatible con Apache Airflow 3.2.1.
"""

from __future__ import annotations

from datetime import timedelta

import pendulum

from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.sdk import DAG


TZ = "America/Asuncion"


# Argumentos por defecto aplicados a las tareas del DAG.
default_args = {
    "owner": "sample",
    "retries": 1,
    "retry_delay": timedelta(seconds=30),
}


# Definición del DAG.
with DAG(
    dag_id="sample_template_dag_id",
    dag_display_name="sample_template_dag",
    description="Ejemplo de definición de un DAG básico compatible con Apache Airflow 3.2.1.",
    doc_md=__doc__,
    default_args=default_args,
    start_date=pendulum.datetime(2026, 1, 1, tz=TZ),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["poc", "sample", "airflow-3"],
) as dag:
    # Definición de tareas.
    ini = EmptyOperator(
        task_id="start",
        task_display_name="Inicio",
    )

    proceso = EmptyOperator(
        task_id="process_main",
        task_display_name="Proceso principal",
    )

    fin = EmptyOperator(
        task_id="end",
        task_display_name="Terminado",
    )

    # Orden de ejecución.
    ini >> proceso >> fin