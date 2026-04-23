"""
DAG que envia una notificación por correo electrónico al finalizar la ejecución, ya sea exitosamente o en error.
"""

from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.utils.email import send_email
from airflow.utils.dates import days_ago
from airflow.utils.state import State
from airflow.models import TaskInstance
from datetime import timedelta

# Configuración de correo
EMAIL_TO = ['rjimenez@pol.una.py']


# Función que se llamará al finalizar el DAG
def notify_email(context):
    dag_run = context.get('dag_run')
    ti: TaskInstance = context.get('task_instance')

    subject = f"Airflow Alert: DAG {dag_run.dag_id} terminó con estado {dag_run.get_state()}"

    html_content = f"""
    <h3>DAG ID: {dag_run.dag_id}</h3>
    <p>Run ID: {dag_run.run_id}</p>
    <p>Estado: {dag_run.get_state()}</p>
    <p>Task ID: {ti.task_id}</p>
    <p>Fecha de ejecución: {context.get('execution_date')}</p>
    <p>Log URL: <a href="{ti.log_url}">Ver logs</a></p>
    """

    send_email(to=EMAIL_TO, subject=subject, html_content=html_content)


# Definición del DAG
with DAG(
        dag_id='sample_notificacion_email_id',
        dag_display_name='sample_notificacion_email',
        description='DAG que envía un correo al finalizar.',
        default_args={
            'owner': 'sample',
            'email_on_failure': False,
            'email_on_retry': False,
            'retries': 1,
            'retry_delay': timedelta(minutes=5)
        },
        schedule_interval=None,  # Puedes poner una cron o timedelta
        start_date=days_ago(1),
        on_success_callback=notify_email,
        on_failure_callback=notify_email,
        catchup=False,
        tags=['poc', 'sample', 'email'],
) as dag:
    start = DummyOperator(task_id='inicio')

    task = PythonOperator(
        task_id='tarea_principal',
        python_callable=lambda: print("Ejecutando tarea principal...")
    )

    end = DummyOperator(task_id='fin')

    # Estructura del DAG
    start >> task >> end
