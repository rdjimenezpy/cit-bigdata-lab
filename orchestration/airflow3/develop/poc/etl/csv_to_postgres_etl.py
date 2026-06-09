"""
DAG para extraer CSV, transformarlo y cargarlo en PostgreSQL diariamente a las 7 p. m., excepto los fines de semana.
"""

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

import pandas as pd
from datetime import datetime, timedelta

# Configuración básica
default_args = {
    'owner': 'cotizacion_mensual',
    'depends_on_past': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
}

# Definimos la función de extracción
def extract_csv(**kwargs):
    df = pd.read_csv('/mnt/d/Git/fpuna/cit_bigdata_basico/datasets/output/ventas_prueba.csv')
    kwargs['ti'].xcom_push(key='raw_data', value=df.to_json())

# Definimos la función de transformación
def transform_data(**kwargs):
    ti = kwargs['ti']
    raw_data_json = ti.xcom_pull(key='raw_data', task_ids='extract_csv')
    df = pd.read_json(raw_data_json)

    # Ejemplo de limpieza: eliminar nulos y columnas no deseadas
    df = df.dropna()
    df = df.drop(columns=['fecha', 'precio_unitario', 'cantidad'])  # Ajusta esto según tu CSV

    # df_grouped = (
    #     df
    #     .groupby(['fecha', 'producto', 'ciudad'])
    #     .agg(
    #         total_ventas=('total', 'sum'),
    #         cantidad_vendida=('cantidad', 'sum'),
    #         venta_promedio=('total', 'mean')
    #     )
    #     .reset_index()
    # )

    df_grouped = df.groupby(
        ['producto', 'ciudad', 'vendedor'],
        as_index=False  # Equivalente a .reset_index() después
    )['total'].sum()
    df_grouped[["producto", "ciudad"]] = df_grouped[["producto", "ciudad"]].apply(lambda x: x.str.upper())
    ti.xcom_push(key='clean_data', value=df_grouped.to_json())

# Definimos la función de carga
def load_to_postgres(**kwargs):
    ti = kwargs['ti']
    clean_data_json = ti.xcom_pull(key='clean_data', task_ids='transform_data')
    df = pd.read_json(clean_data_json)

    pg_hook = PostgresHook(postgres_conn_id='postgres_bigdata_lab')
    engine = pg_hook.get_sqlalchemy_engine()

    # Cargamos el DataFrame en la tabla deseada
    df.to_sql('rp_ventas_prueba_resumen', engine, schema='dpl', if_exists='replace', index=False)

# Definimos el DAG
with DAG(
    dag_id='csv_to_postgres_etl_id',
    dag_display_name='csv_to_postgres_etl',
    description='Extract CSV, transform, and load into PostgreSQL daily at 7 PM except weekends.',
    default_args=default_args,
    # schedule_interval='0 19 * * 1-5',  # 7 PM de lunes a viernes
    # start_date=datetime(2025, 4, 29),
    catchup=False,
    tags=['cotizacion_mensual', 'csv', 'postgres'],
) as dag:

    extract_csv_task = PythonOperator(
        task_id='extract_csv',
        python_callable=extract_csv,
        provide_context=True,
    )

    transform_data_task = PythonOperator(
        task_id='transform_data',
        python_callable=transform_data,
        provide_context=True,
    )

    load_to_postgres_task = PythonOperator(
        task_id='load_to_postgres',
        python_callable=load_to_postgres,
        provide_context=True,
    )

    # Definimos la secuencia de tareas
    extract_csv_task >> transform_data_task >> load_to_postgres_task
