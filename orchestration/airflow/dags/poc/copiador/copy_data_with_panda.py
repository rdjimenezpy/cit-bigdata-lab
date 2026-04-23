"""UNIVERSIDAD NACIONAL DE ASUNCION - FACULTAD POLITECNICA (FPUNA)

Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data

Descripción:
    DAG para cargar un archivo CSV a una base de datos PostgreSQL usando pandas.to_sql()
    y configurar las columnas a insertar, sigue estos pasos:

Autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
Fecha_creación: Octubre, 2024
Fecha_ultima_modificacion: Abril, 2025
Version: 1.0
"""

from __future__ import annotations

import pandas as pd
from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
#from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from jinja2 import Environment, FileSystemLoader
from sqlalchemy import create_engine

# Parámetros de configuración inicial
table_schema = 'poc'
table_target_1 = 'raw_sfp_nomina'
table_target_2 = 'raw_sfp_nomina_eliminado'

# ID de conexión a PostgreSQL
postgres_conn_id = 'postgres_bigdata_lab'

# URL de conexión a PostgreSQL
postgres_conn_url = Variable.get('BIGDATA_LAB_POSTGRES_CONN_URL')

# Ubicación de archivos SQL
sql_file_path = Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/poc/copiador/sql'

# Ubicación del archivo CSV
csv_file_path = Variable.get('BIGDATA_LAB_DATASET_SFP_NOMINA')

csv_columns_name = [
    'anho',
    'mes',
    'nivel',
    'descripcion_nivel',
    'entidad',
    'descripcion_entidad',
    'oee',
    'descripcion_oee',
    'documento',
    'nombres',
    'apellidos',
    'sexo',
    'fecha_nacimiento',
    'discapacidad',
    'tipo_discapacidad',
    'profesion',
    'anho_ingreso',
    'cargo',
    'funcion',
    'estado',
    'fuente_financiamiento',
    'objeto_gasto',
    'concepto',
    'linea',
    'categoria',
    'presupuestado',
    'devengado'
]

csv_columns_type={
    'anho':'int16',
    'mes':'int16',
    'nivel':'int16',
    'descripcion_nivel':'object',
    'entidad':'int16',
    'descripcion_entidad':'object',
    'oee':'int16',
    'descripcion_oee':'object',
    'documento':'object',
    'nombres':'object',
    'apellidos':'object',
    'sexo':'object',
    'fecha_nacimiento':'object',
    'discapacidad':'object',
    'tipo_discapacidad':'object',
    'profesion':'object',
    'anho_ingreso':'int16',
    'cargo':'object',
    'funcion':'object',
    'estado':'object',
    'fuente_financiamiento':'object',
    'objeto_gasto':'object',
    'concepto':'object',
    'linea':'object',
    'categoria':'object',
    'presupuestado':'int32',
    'devengado':'int32'
}

# Definir argumentos por defecto para el DAG
default_args = {
    'owner': 'copiador',
    'start_date': None,
    'retries': None,
}

# Función Python para copiar el archivo CSV al servidor de PostgreSQL
def load_csv_to_postgres():

    # Leer el archivo CSV, seleccionando solo las columnas deseadas
    df = pd.read_csv(csv_file_path, encoding='ISO-8859-1', usecols=csv_columns_name, dtype=csv_columns_type)

    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(postgres_conn_url)

    # Cargar los datos en la tabla de PostgreSQL
    df1 = df.query('not (presupuestado == 0 and devengado == 0)')
    df1.to_sql(name=table_target_1, con=engine, schema=table_schema, if_exists='replace', index=False)

    # Cargar los datos en la tabla de eliminados
    df2= df.query('presupuestado == 0 and devengado == 0')
    df2.to_sql(name=table_target_2, con=engine, schema=table_schema, if_exists='replace', index=False)

# Definir el DAG
with DAG(
    dag_id="copy_data_with_panda_id",
    dag_display_name="copy_data_with_panda",
    description='DAG Bulk Data Loading CSV to PostgreSQL with panda to_sql.',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=['poc', 'bulk_data', 'panda']
) as dag:

    start = EmptyOperator(task_id='start', dag=dag)

    # Configurar Jinja2
    env = Environment(loader=FileSystemLoader(sql_file_path))
    template = env.get_template('task_truncate_table_nomina.sql')

    # Renderizar el archivo SQL con los parámetros
    rendered_sql = template.render(schema=table_schema, target_1=table_target_1, target_2=table_target_2)

    # Tarea 1: Truncar datos de la tabla Target en PostgreSQL
    truncate_data = SQLExecuteQueryOperator(
        task_id='truncate_table_data',
        conn_id=postgres_conn_id,
        sql=rendered_sql
    )

    # Tarea 2: Cargar datos masivos de CSV a PostgreSQL
    load_bulk_data = PythonOperator(
        task_id='load_csv_bulk_data',
        python_callable=load_csv_to_postgres
    )

    end = EmptyOperator(task_id='end', dag=dag)

    # Definir el orden de las tareas
    start >> truncate_data >> load_bulk_data >> end