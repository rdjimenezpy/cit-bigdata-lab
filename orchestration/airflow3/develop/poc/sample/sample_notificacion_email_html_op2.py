"""
OP2 - DAG que envia una notificación por correo electrónico al finalizar la ejecución, ya sea exitosamente o en error.
"""
# dags/mi_dag.py

from datetime import timedelta

from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

from utils.email_notification import enviar_reporte

with DAG(
    dag_id='sample_notificacion_email_html_op2_id',
    dag_display_name='sample_notificacion_email_html_op2',
    default_args={
        'owner': 'sample',
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
    },
    description='DAG que usa notificaciones modulares',
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=['callback', 'notificacion', 'multi-dag'],
    on_success_callback=enviar_reporte,
    on_failure_callback=enviar_reporte,  # Opcional: enviar también en fallos
) as dag:

    inicio = DummyOperator(task_id='inicio')

    tarea_1 = PythonOperator(
        task_id='tarea_1',
        python_callable=lambda: print("Tarea 1 ejecutada"),
    )

    tarea_2 = PythonOperator(
        task_id='tarea_2',
        python_callable=lambda: print("Tarea 2 ejecutada"),
    )

    fin = DummyOperator(task_id='fin')

    inicio >> [tarea_1, tarea_2] >> fin
