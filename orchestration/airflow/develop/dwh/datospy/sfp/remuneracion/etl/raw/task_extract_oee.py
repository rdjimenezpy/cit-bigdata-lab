from __future__ import annotations

import pandas as pd
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from sqlalchemy import create_engine

# Parámetros de configuración inicial
TABLE_SCHEMA='etl'
TABLE_TARGET='raw_sfp_oee'

# URL de conexión a PostgreSQL
POSTGRES_CONN_URL=Variable.get('BIGDATA_LAB_DWH_POSTGRES_CONN_URL')

# Ubicación del archivo CSV
CSV_FILE_PATH=Variable.get('BIGDATA_LAB_DWH_DATASET_SFP_NOMINA')

# Tarea para truncar/crear la tabla (si no existe)
def truncate_table():
    return SQLExecuteQueryOperator(
        task_id='truncate_table',
        conn_id='postgres_dwh',
        sql=f"""
        DO $$
        BEGIN
            SET search_path TO {TABLE_SCHEMA};
            
            -- Paso 1 - Verificamos si la tabla existe
            IF EXISTS ( SELECT 1 FROM pg_tables WHERE schemaname = '{TABLE_SCHEMA}' AND tablename = '{TABLE_TARGET}' ) THEN
                -- Si existe, la truncamos
                TRUNCATE TABLE {TABLE_TARGET};
            ELSE
                -- Si no existe, la creamos
				CREATE TABLE {TABLE_TARGET} (
					codigo_nivel int2 NULL,
					descripcion_nivel varchar(64) NULL,
					codigo_entidad int2 NULL,
					descripcion_entidad varchar(76) NULL,
					codigo_oee int2 NULL,
					descripcion_oee varchar(116) NULL,
					descripcion_corta varchar(24) NULL
				);
            END IF;
        END $$   
    """
    )

def __load_csv_to_table():

    columns_name = [
        'codigo_nivel',
        'descripcion_nivel',
        'codigo_entidad',
        'descripcion_entidad',
        'codigo_oee',
        'descripcion_oee',
        'descripcion_corta'
    ]

    columns_type = {
        'codigo_nivel':'int16',
        'descripcion_nivel':'object',
        'codigo_entidad':'int16',
        'descripcion_entidad':'object',
        'codigo_oee':'int16',
        'descripcion_oee':'object',
        'descripcion_corta':'object'
    }

    # Leer el archivo CSV
    df = pd.read_csv(CSV_FILE_PATH, encoding='ISO-8859-1', usecols= columns_name, dtype=columns_type)

    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(POSTGRES_CONN_URL)

    # Cargar los datos en la tabla de PostgreSQL
    df.to_sql(name=TABLE_TARGET, con=engine, schema=TABLE_SCHEMA, if_exists='append', index=False)

def load_csv_to_table():
    return PythonOperator(
        task_id="load_csv_to_table",
        python_callable=__load_csv_to_table
    )