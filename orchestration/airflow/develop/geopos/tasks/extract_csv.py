"""
Tareas de extracción de csv_data to ods.
"""

from __future__ import annotations

import os
import re

import pandas as pd
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine

# Denifir op_local
locales = [131, 154, 185, 205, 596]

# URL de conexión a PostgreSQL y la base de datos geopos
postgres_conn_url = Variable.get('GEOPOS_POSTGRES_CONN_URL')

# Definir directorio root
directorio_principal = r"/mnt/d/Git/fpuna/cit_bigdata_basico/datasets/output/geopos"

# Definir ubicacion de los archivos csv de pruebas generados
csv_infodiaria = Variable.get('GEOPOS_DATASETS_PATH_BASE') + "proinformaciondiaria.csv"
csv_summary_pos = Variable.get('GEOPOS_DATASETS_PATH_BASE') + "bo_operational_summary_pos.csv"
csv_summary = Variable.get('GEOPOS_DATASETS_PATH_BASE') + "bo_operational_summary.csv"

# Patrones de nombres de archivos csv
patrones = [
    'proinformaciondiaria_'
]

# Definir nombres de tablas para guardar en ODS
tablas = {
    'proinformaciondiaria': 'proinformaciondiaria_',
    'bo_operational_summary': r'^bo_operational_summary_\d+\.csv$',
    'bo_operational_summary_pos': r'^bo_operational_summary_pos_\d+\.csv$'
}


def __buscar_y_filtrar_csv(directorio, patron=None):
    archivos_csv = []
    regex = re.compile(patron)
    for ruta_directorio, subdirectorios, archivos in os.walk(directorio):
        for archivo in archivos:
            if archivo.endswith('.csv'):
                ruta_completa = os.path.join(ruta_directorio, archivo)
                if patron is None:
                    archivos_csv.append(ruta_completa)
                elif regex.match(archivo):
                    archivos_csv.append(ruta_completa)

    return archivos_csv


def __copy_folders_csv_to_ods():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    for nombre_tabla, nombre_archivo_rgx in tablas.items():
        archivos_encontrados = __buscar_y_filtrar_csv(directorio_principal, nombre_archivo_rgx)

        df_concatenado, i = None, 0
        for archivo in archivos_encontrados:
            # Leer el archivo CSV
            df = pd.read_csv(archivo, encoding='ISO-8859-1', sep='|', quotechar='"')

            if nombre_tabla == "proinformaciondiaria":
                df['OpLocal'] = locales[i]
                i += 1

            df_concatenado = pd.concat([df_concatenado, df], ignore_index=True)

        # Copiar los datos en tablas de ODS de PostgreSQL
        df_concatenado.to_sql(name='ods_' + nombre_tabla, con=engine, schema='ods', if_exists='replace', index=False)


def __copy_csv_to_ods_infodiaria():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Leer el archivo CSV
    df = pd.read_csv(csv_infodiaria, encoding='ISO-8859-1', sep=',', quotechar='"')

    # Copiar los datos en ODS de PostgreSQL
    df.to_sql(name='ods_proinformaciondiaria', con=engine, schema='ods', if_exists='replace', index=False)


def __copy_csv_to_ods_summary():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Leer el archivo CSV
    df = pd.read_csv(csv_summary, encoding='ISO-8859-1', sep=',', quotechar='"')

    # Copiar los datos en tablas de ODS de PostgreSQL
    df.to_sql(name='ods_bo_operational_summary', con=engine, schema='ods', if_exists='replace', index=False)


def __copy_csv_to_ods_summary_pos():
    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Leer el archivo CSV
    df = pd.read_csv(csv_summary_pos, encoding='ISO-8859-1', sep=',', quotechar='"')

    # Copiar los datos en tablas de ODS de PostgreSQL
    df.to_sql(name='ods_bo_operational_summary_pos', con=engine, schema='ods', if_exists='replace', index=False)


def task_folders_csv_to_ods():
    return PythonOperator(
        task_id="folders_csv_to_ods",
        python_callable=__copy_folders_csv_to_ods
    )


def task_csv_to_ods_infodiaria():
    return PythonOperator(
        task_id="csv_to_ods_infodiaria",
        python_callable=__copy_csv_to_ods_infodiaria
    )


def task_csv_to_ods_summary():
    return PythonOperator(
        task_id="csv_to_ods_summary",
        python_callable=__copy_csv_to_ods_summary
    )


def task_csv_to_ods_summary_pos():
    return PythonOperator(
        task_id="csv_to_ods_summary_pos",
        python_callable=__copy_csv_to_ods_summary_pos
    )