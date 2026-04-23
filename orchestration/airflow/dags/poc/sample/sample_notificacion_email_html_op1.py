"""
OP1 - DAG que envia una notificación por correo electrónico al finalizar la ejecución, ya sea exitosamente o en error.
"""

from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.utils.email import send_email
from airflow.utils.dates import days_ago
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
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {{
                font-family: 'Arial', sans-serif;
                background-color: #f4f6f8;
                padding: 20px;
                margin: 0;
            }}
            .container {{
                background-color: #ffffff;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                padding: 30px;
                max-width: 700px;
                margin: auto;
            }}
            h2 {{
                color: #2c3e50;
                text-align: center;
            }}
            .info {{
                margin-top: 20px;
                font-size: 15px;
                color: #34495e;
            }}
            .info p {{
                margin: 5px 0;
            }}
            .summary {{
                margin-top: 30px;
                background-color: #ecf0f1;
                padding: 15px;
                border-radius: 8px;
            }}
            .summary h4 {{
                margin-top: 0;
                color: #2c3e50;
            }}
            .button {{
                display: block;
                width: 100%;
                text-align: center;
                margin-top: 30px;
            }}
            .button a {{
                background-color: #3498db;
                color: white;
                padding: 12px 25px;
                text-decoration: none;
                border-radius: 5px;
                font-weight: bold;
                font-size: 16px;
            }}
            .button a:hover {{
                background-color: #2980b9;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h2>🔔 Reporte de Ejecución del DAG</h2>
            <div class="info">
                <p><strong>DAG ID:</strong> {dag_run.dag_id}</p>
                <p><strong>Run ID:</strong> {dag_run.run_id}</p>
                <p><strong>Estado final:</strong> {dag_run.get_state()}</p>
                <p><strong>Task ID actual:</strong> {ti.task_id}</p>
                <p><strong>Fecha de ejecución:</strong> {context.get('execution_date')}</p>
            </div>

            <div class="summary">
                <h4>📊 Resumen de Tareas</h4>
                <p><strong>Fecha de inicio:</strong> {dag_run.start_date}</p>
                <p><strong>Fecha de fin:</strong> {dag_run.end_date}</p>
                <p><strong>Duración:</strong> {dag_run.end_date - dag_run.start_date if dag_run.end_date and dag_run.start_date else 'N/A'}</p>
            </div>

            <div class="button">
                <a href="{ti.log_url}" target="_blank">🔎 Ver Logs del DAG</a>
            </div>
        </div>
    </body>
    </html>
    """

    send_email(to=EMAIL_TO, subject=subject, html_content=html_content)


# Definición del DAG
with DAG(
        dag_id='sample_notificacion_email_html_op1_id',
        dag_display_name='sample_notificacion_email_html_op1',
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
