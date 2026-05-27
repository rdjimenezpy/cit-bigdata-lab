"""
Ejemplo XComs: Almacenan pequeñas cantidades de datos que pueden ser utilizados por otras tareas.
"""

from __future__ import annotations

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

# Definir el DAG
default_args = {
    'owner': 'airflow',
    'start_date': None,
    'depends_on_past': False,
    'retries': 0,
}

# Función para ejecutar la consulta y guardar el resultado en XCom
def extract_data_from_postgres(**kwargs):
    hook = PostgresHook(postgres_conn_id='postgres_default')
    sql = "SELECT DISTINCT descripcion_oee FROM etl.raw_sfp_nomina WHERE nivel = 28 and entidad = 1;"
    connection = hook.get_conn()
    cursor = connection.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()  # Extrae todos los resultados
    cursor.close()

    # Guarda el resultado en XCom usando kwargs['ti'].xcom_push
    kwargs['ti'].xcom_push(key='postgres_data', value=result)

# Función para recibir los datos desde XCom
def use_data_from_xcom(**kwargs):
    # Recupera los datos desde XCom usando kwargs['ti'].xcom_pull
    result = kwargs['ti'].xcom_pull(task_ids='extract_data', key='postgres_data')
    print("Data from XCom:", result)
    # Aquí puedes procesar los datos como sea necesario.

with DAG(
        dag_id='example_postgres_xcom_id',
        dag_display_name="example_postgres_xcom",
        description='XComs: Almacenan pequeñas cantidades de datos que pueden ser utilizados por otras tareas.',
        default_args=default_args,
        schedule_interval=None,  # DAG manual o puedes poner un cron si lo deseas
        catchup=False,
        tags= ['poc', 'example']
) as dag:

    # Tarea para extraer datos desde Postgres y guardarlos en XCom
    extract_data = PythonOperator(
        task_id='extract_data',
        python_callable=extract_data_from_postgres,
        provide_context=True
    )

    # Tarea para usar los datos guardados en XCom
    use_data = PythonOperator(
        task_id='use_data',
        python_callable=use_data_from_xcom,
        provide_context=True
    )

    # Define la secuencia de ejecución
    extract_data >> use_data