"""
Tareas de extracción de datafactory to ods.
"""

from __future__ import annotations

import geopos.tools.datafactory_geopos as datafactory

from airflow.models.variable import Variable
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine

# URL de conexión a PostgreSQL y la base de datos geopos
postgres_conn_url = Variable.get('GEOPOS_POSTGRES_CONN_URL')


def __datafactory_to_ods_infodiaria():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Generar conjunto de datos de pruebas
    df = datafactory.generar_data_infodiaria()

    # Copiar los datos de prueba en ODS de PostgreSQL
    df.to_sql(name='ods_proinformaciondiaria', con=engine, schema='ods', if_exists='replace', index=False)


def __datafactory_to_ods_summary():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Generar conjunto de datos de pruebas
    df = datafactory.generar_data_summary()

    # Copiar los datos en tablas de ODS de PostgreSQL
    df.to_sql(name='ods_bo_operational_summary', con=engine, schema='ods', if_exists='replace', index=False)


def __datafactory_to_ods_summary_pos():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Generar conjunto de datos de pruebas
    df = datafactory.generar_data_summary_pos()

    # Copiar los datos en tablas de ODS de PostgreSQL
    df.to_sql(name='ods_bo_operational_summary_pos', con=engine, schema='ods', if_exists='replace', index=False)


def task_datafactory_ods_infodiaria():
    return PythonOperator(
        task_id="datafactory_ods_infodiaria",
        python_callable=__datafactory_to_ods_infodiaria
    )


def task_datafactory_ods_summary():
    return PythonOperator(
        task_id="datafactory_ods_summary",
        python_callable=__datafactory_to_ods_summary
    )


def task_datafactory_ods_summary_pos():
    return PythonOperator(
        task_id="datafactory_ods_summary_pos",
        python_callable=__datafactory_to_ods_summary_pos
    )
