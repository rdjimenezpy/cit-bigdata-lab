"""
DAG para cargar un CSV a PostgreSQL generando un archivo sql con inserts.
"""

from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.utils.dates import days_ago

from datetime import timedelta, datetime
import pandas as pd
import pytz

TZ = pytz.timezone('America/Asuncion')
TODAY = datetime.now(TZ).strftime('%Y-%m-%d')

# Definir los argumentos por defecto del DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(0),
    'retries': 0,
}

dag = DAG(
    dag_id='sample_load_csv_to_postgres_op2_id',
    dag_display_name="sample_load_csv_to_postgres_op2",
    description='DAG para cargar un CSV a PostgreSQL generando un archivo sql con inserts.',
    default_args=default_args,
    template_searchpath=Variable.get("dags_folder") + 'sample/sql',
    schedule_interval=None,  # DAG no programado automáticamente
    catchup=False,
    tags=['poc', 'sample']
)
# Definir funciones en python
def read_csv_to_sql_inserts():
    #Leer el archivo CSV
    csv_file_path = '/home/richard/analytics/dataset/input/sample.csv'
    df = pd.read_csv(csv_file_path)

    sql_file_path = Variable.get('dags_folder') + 'sample/sql/postgres_sql_inserts.sql'
    with open(sql_file_path,'w') as f:
        for index, row in df.iterrows():
            values=f"('{row[0]}','{row[1]}','{row[2]}')"
            insert=f"INSERT INTO sample.test_persona (nombre, apellido, sexo) values {values};\n"
            f.write(insert)

# Definir operadores o task para los dags
with dag:

    start = EmptyOperator(task_id='START', dag=dag)

    create_sql_inserts = PythonOperator(
        task_id='create_sql_inserts',
        task_display_name='Create SQL inserts test_persona',
        python_callable =read_csv_to_sql_inserts
    )

    execute_sql_inserts = SQLExecuteQueryOperator(
        task_id='execute_sql_inserts',
        task_display_name='Execute SQL inserts batch',
        sql="postgres_sql_inserts.sql",
        conn_id='postgres_default'  # Nombre de la conexión configurada
    )

    end = EmptyOperator(task_id='end', dag=dag)
    ##operadores para pyton y sql


# Orden de ejecucion
start >> create_sql_inserts >> execute_sql_inserts >> end
