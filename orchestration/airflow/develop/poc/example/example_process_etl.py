"""
ETL template
"""

from airflow import DAG
from airflow.operators.subdag import SubDagOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime

import sys
sys.path.append('/home/richard/analytics/airflow_project/dags')

#from dags.template.cotizacion_mensual.subdags.etl_extract import subdag_etl_extract
#from dags.template.cotizacion_mensual.subdags.etl_load import subdag_etl_load

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 10, 8),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

with DAG(
    dag_id='example_process_etl_id',
    dag_display_name='example_process_etl',
    description='ETL Process using SubDAGs',
    default_args=default_args,
    schedule_interval='@daily',
) dag:
    # Operador de inicio y fin del DAG principal
    start_task = EmptyOperator(task_id='start')

# Operador de inicio y fin del DAG principal
    end_task = EmptyOperator(task_id='end', dag=dag)

# SubDAG para la extracción de datos
# extract_subdag = SubDagOperator(
#     task_id='etl_extract_main',
#     #subdag=subdag_etl_extract('etl_process', 'etl_extract', default_args),
#     subdag=EmptyOperator(task_id='etl_extract', dag=dag),
#     dag=dag,
# )

# Ejemplo de SubDAG para transformación (reemplazar subdag_etl_transform con tu implementación)
# transform_subdag = SubDagOperator(
#     task_id='etl_transform_main',
#     subdag=EmptyOperator(task_id='etl_transform', dag=dag),
#     dag=dag,
# )

# Ejemplo de SubDAG para la carga (reemplazar subdag_etl_load con tu implementación)
# load_subdag = SubDagOperator(
#     task_id='etl_load_main',
#     #subdag=subdag_etl_load('etl_process', 'etl_load', default_args),
#     subdag=EmptyOperator(task_id='etl_load', dag=dag),
#     dag=dag,
# )

# Definir el flujo de las tareas
# start_task >> extract_subdag >> transform_subdag >> load_subdag >> end_task
start_task >> end_task