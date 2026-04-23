"""
DAG para cargar un CSV a PostgreSQL generando un archivo sql con inserts.
"""

from __future__ import annotations

from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.utils.dates import days_ago

from datetime import timedelta, datetime
import pandas as pd
import pytz

SQL_TABLE_TARGET = "etl.raw_sfp_nomina"

SQL_COLUMNS = """
	anho,
	mes,
	nivel,
	descripcion_nivel,
	entidad,
	descripcion_entidad,
	oee,
	descripcion_oee,
	documento,
	nombres,
	apellidos,
	sexo,
	fecha_nacimiento,
	discapacidad,
	tipo_discapacidad,
	profesion,
	anho_ingreso,
	cargo,
	funcion,
	estado,
	fuente_financiamiento,
	objeto_gasto,
	concepto,
	linea,
	categoria,
	presupuestado,
	devengado
"""

def get_values(row):
    return f"""
        (
            {row[0]},
            {row[1]},
            {row[2]},
            '{row[3]}',
            {row[4]},
            '{row[5]}',
            {row[6]},
            '{row[7]}',
            '{row[8]}',
            '{row[9]}',
            '{row[10]}',
            '{row[15]}',
            '{row[28]}',
            '{row[16]}',
            '{row[17]}',
            '{row[33]}',
            '{row[14]}',
            '{row[23]}',
            '{row[11]}',
            '{row[12]}',
            {row[18]},
            {row[19]},
            '{row[20]}',
            '{row[21]}',
            '{row[22]}',
            {row[24]},
            {row[25]}
        )
        """

# Definir los argumentos por defecto del DAG
default_args = {
    'owner': 'copiador',
    'start_date': None,
    'retries': None,
}

dag = DAG(
    dag_id="copy_data_with_sql_inserts_id",
    dag_display_name="copy_data_with_sql_inserts",
    description="DAG para cargar un CSV a PostgreSQL generando un archivo sql con inserts.",
    default_args=default_args,
    template_searchpath=Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/poc/copiador/sql',
    schedule_interval=None,  # DAG no programado automáticamente
    catchup=False,
    tags=['poc', 'bulk_data', 'sql_inserts']
)
# Definir funciones en python
def read_csv_to_sql_inserts():
    #Leer el archivo CSV
    csv_file_path = Variable.get('BIGDATA_LAB_DATASET_SFP_NOMINA')
    df = pd.read_csv(csv_file_path, encoding='ISO-8859-1')

    sql_file_path = Variable.get('BIGDATA_LAB_DAGS_FOLDER') + '/poc/copiador/sql/sql_inserts.sql'
    with open(sql_file_path,'w') as f:
        for index, row in df.iterrows():
            # values=f"('{row[0]}','{row[1]}','{row[2]}')"
            insert=f"INSERT INTO {SQL_TABLE_TARGET} ({SQL_COLUMNS}) VALUES {get_values(row)};\n"
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
        sql="sql_inserts.sql",
        conn_id='postgres_dwh'  # Nombre de la conexión configurada
    )

    end = EmptyOperator(task_id='end', dag=dag)
    ##operadores para pyton y sql


# Orden de ejecucion
start >> create_sql_inserts >> execute_sql_inserts >> end
# start >> create_sql_inserts >> end