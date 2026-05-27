"""Descripción del DAG: ETL de CSV a GEOPOS
Este DAG gestiona un flujo de trabajo ETL automatizado en Apache Airflow. Su propósito es cargar un conjunto de datos
CSV, transformarlos según criterios establecidos y almacenarlos en una base de datos PostgreSQL para análisis posterior.
"""

from __future__ import annotations

from airflow.models import Variable
from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup

import geopos.tasks.extract_csv as ods
import geopos.tasks.transform_load_datafactory as rp

# Definir argumentos por defecto para el DAG
default_args = {
    'owner': 'rjimenez',
    'start_date': None,
    'retries': None,
}

# Ruta de los archivos SQL
template_searchpath = Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/geopos/sql'

# [START PROCESS]
with DAG(
        dag_id='geopos_csv_to_postgres_etl_id',
        dag_display_name='geopos_csv_to_postgres_etl',
        description='ETL de CSV a GEOPOS',
        default_args=default_args,
        template_searchpath=template_searchpath,
        schedule_interval=None,
        catchup=False,
        tags=['cotizacion_mensual', 'geopos', 'csv_to_postgres']
) as dag:
    start = EmptyOperator(task_id="start")

    with TaskGroup("csv_to_ods", tooltip="Tareas de extracción de datos") as csv_to_ods_task:
        [ods.task_csv_to_ods_infodiaria(),
        ods.task_csv_to_ods_summary(),
        ods.task_csv_to_ods_summary_pos()]

    with TaskGroup("transform_and_load_data", tooltip="Tareas de transformación y carga de datos") as transform_and_load_task:
        [rp.taks_transform_load_rp_infodiaria() >> rp.taks_transform_load_rp_infosemanal() >> rp.taks_transform_load_rp_infomensual(),
         rp.taks_transform_load_rp_summary_pos(),
         rp.taks_transform_load_rp_summary()]

    end = EmptyOperator(task_id="end")

    # Definir orden de ejecución de tareas
    start >> csv_to_ods_task >> transform_and_load_task >> end

# [END PROCESS]