"""FACULTAD POLITECNICA - UNIVERSIDAD NACIONAL DE ASUNCION (FPUNA)

Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data

Descripción:
    Este DAG realiza web scraping sobre el portal de la Banca Central del Paraguay (BCP) para extraer automáticamente
    las cotizaciones mensuales de referencia de monedas extranjeras. Los datos recopilados se almacenan para su posterior
    análisis o integración en reportes financieros.

Autor: Prof. Ing. Richard D. Jiménez-R. <rjimenez@pol.una.py>
Fecha_creación: Octubre, 2024
Fecha_ultima_modifiacion: Junio, 2025
Version: 1.1
"""

from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

import dwh.bcp.cotizacion_mensual.etl.webscraping_data as etl


# Definición de los periodos de extracción de datos
ANHO_DESDE=2001
ANHO_HASTA=datetime.now().year

# Definición de monedas extranjeras
MONEDAS=['USD', 'GBP', 'BRL', 'ARS', 'CLP', 'EUR', 'UYU', 'BOB', 'PEN', 'MXN', 'COP']
# MONEDAS=['USD', 'BRL', 'ARS', 'EUR']

# Definir argumentos por defecto para el DAG
default_args = {
    'owner': 'cit_intro_bigdata',
    'depends_on_past': False,
    'start_date': None,
    'retries': None,
}

# [START ETL PROCESS]
with DAG(
        dag_id='fact_bcp_cotizacion_etl_id',
        dag_display_name='fact_bcp_cotizacion_etl',
        description='Web scraping sobre el portal de la BCP para extraer las cotizaciones mensuales de referencia de monedas extranjeras.',
        default_args=default_args,
        template_searchpath=Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/dwh/bcp/cotizacion_mensual/sql/',
        schedule_interval=None,
        catchup=False,
        tags=['dwh', 'bcp', 'cotizacion_mensual']
) as dag:

    start = EmptyOperator(task_id="start")

    extract = PythonOperator(
        task_id='extract',
        python_callable=etl.extract_data_to_raw,
        op_kwargs={'anho_desde': ANHO_DESDE,
                   'anho_hasta': ANHO_HASTA,
                   'monedas': MONEDAS,
                   'conn_id': 'postgres_cit_intro_bigdata_dwh'},
    )

    transform = SQLExecuteQueryOperator(
        task_id='transform',
        conn_id='postgres_cit_intro_bigdata_dwh',
        sql='stg_dim_moneda_extranjera.sql',
    )

    load = SQLExecuteQueryOperator(
        task_id='load',
        conn_id='postgres_cit_intro_bigdata_dwh',
        sql='fact_bcp_cotizacion_mensual.sql',
    )

    end = EmptyOperator(task_id="end")

    start >> extract >> transform >> load >> end

# [END ETL PROCESS]