"""Descripción del DAG: ETL de Datos Simulados a GEOPOS
Este DAG gestiona un flujo de trabajo ETL automatizado en Apache Airflow. Su propósito es generar un conjunto de datos
simulados, transformarlos según criterios establecidos y almacenarlos en una base de datos PostgreSQL
para análisis posterior.
"""

from __future__ import annotations

from airflow.models import Variable
from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup

import geopos.tasks.extract_datafactory as ods
import geopos.tasks.transform_load_datafactory as rp

# Definir argumentos por defecto para el DAG
default_args = {
    'owner': 'rjimenez',
    'start_date': None,
    'retries': None,
}

# Ruta de los archivos SQL
template_searchpath = Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/geopos/sql'

# [START PROCESS ETL]
with DAG(
    dag_id='geopos_datafactory_etl_id',
    dag_display_name='geopos_datafactory_etl',
    description='Generador de datos de pruebas para el proyecto geopos.',
    default_args=default_args,
    template_searchpath=template_searchpath,
    schedule_interval=None,
    catchup=False,
    tags=['cotizacion_mensual', 'geopos', 'datafactory']
) as dag:
    start = EmptyOperator(task_id="start")

    with TaskGroup("datafactory_to_ods", tooltip="Tareas de extracción de datos") as datafactory_task:
        [ods.task_datafactory_ods_infodiaria(),
         ods.task_datafactory_ods_summary_pos(),
         ods.task_datafactory_ods_summary()]

    with TaskGroup("transform_and_load_data", tooltip="Tareas de transformación y carga de datos") as transform_and_load_task:
        [rp.taks_transform_load_rp_infodiaria() >> rp.taks_transform_load_rp_infosemanal() >> rp.taks_transform_load_rp_infomensual(),
         rp.taks_transform_load_rp_summary_pos(),
         rp.taks_transform_load_rp_summary()]

    end = EmptyOperator(task_id="end")

    # Definir orden de ejecución de las tareas
    start >> datafactory_task >> transform_and_load_task >> end

# [END PROCESS ETL]