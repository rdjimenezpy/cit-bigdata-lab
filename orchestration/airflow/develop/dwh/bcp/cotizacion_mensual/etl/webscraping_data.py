from __future__ import annotations

from datetime import datetime

import pandas as pd
import requests
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from bs4 import BeautifulSoup
from sqlalchemy import create_engine

# URL de conexión a PostgreSQL a la base de datos DWH
POSTGRES_CONN_URL=Variable.get('BIGDATA_LAB_DWH_POSTGRES_CONN_URL')

# Realiza una petición POST a la URL especificada con los parámetros proporcionados
def __get_html(anho, mes):

    # La URL de la página a la que se va a hacer la petición
    url='https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual'

    #  Diccionario con los parámetros a incluir en la petición
    params = {
        'anho': f'{str(anho)}',
        'mes': f'{str(mes).rjust(2, '0')}',
    }

    # para proporcionar metadatos adicionales sobre la petición
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    try:
        # Hacemos una solicitud POST a la página
        response = requests.post(url=url, params=params, headers=headers)

        # Verifica si hubo algún error en la petición
        response.raise_for_status()

        return response.content
    except requests.exceptions.RequestException as e:
        print(f"Error al obtener el HTML: {e}")
        return None


def __get_html2(anho, mes):
    url = 'https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual'
    data = {
        'anho': str(anho),
        'mes': str(mes).rjust(2, '0'),
        'submit': 'Consultar'  # Añadir esto si el formulario lo requiere
    }
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'es-ES,es;q=0.9',
        'Referer': 'https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual',
        'Origin': 'https://www.bcp.gov.py',
        'DNT': '1',  # Do Not Track
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
    }

    try:
        session = requests.Session()
        session.headers.update(headers)

        # Primero hacer una solicitud GET para obtener cookies si es necesario
        session.get('https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual', headers=headers)

        # Luego hacer la solicitud POST
        response = session.post(url, data=data, headers=headers)
        response.raise_for_status()

        # Verificar si la respuesta contiene datos válidos
        if not response.content or len(response.content) < 100:
            print("La respuesta no contiene datos válidos")
            return None

        return response.content

    except requests.exceptions.RequestException as e:
        print(f"Error al obtener el HTML: {e}")
        print(f"URL: {url}")
        print(f"Datos enviados: {data}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Código de estado: {e.response.status_code}")
            print(f"Contenido de la respuesta: {e.response.text[:500]}")
        return None


# --
def __do_webscraping(anho, mes, monedas):

    columns_name = ['anho', 'mes', 'moneda', 'abreviatura', 'me_usd', 'gs_me']

    html = __get_html2(anho, mes)

    # Parseamos el contenido HTML de la página
    soup = BeautifulSoup(html, 'html.parser')

    # Encontramos la tabla de cotizaciones
    # table = soup.find_all('table')
    table = soup.find('table', {'id': 'cotizacion-interbancaria'})

    # Extraemos las filas de la tabla
    rows = []
    for tr in table.find('tbody').find_all('tr'):
        cells = []
        for td in tr.find_all('td'):
            cells.append(td.text.strip())

        if len(cells) != 0:
            rows.append([anho, mes] + cells)

    # Convertimos los datos a un DataFrame de pandas
    df = pd.DataFrame(rows, columns=columns_name)

    # Filtramos las momendas a seleccionar
    divisas = df[df['abreviatura'].isin(monedas)]

    return divisas

# --
def __get_bcp_cotizacion_mensual(anho_desde, anho_hasta, monedas, conn_id):
    sql = 'SELECT MAX(periodo_sk)::VARCHAR(6) FROM datamart.fact_bcp_cotizacion_mensual;'

    hook = PostgresHook(postgres_conn_id=conn_id)
    connection = hook.get_conn()
    cursor = connection.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()
    cursor.close()

    if  result[0][0] is not None:
        anho_desde = int(result[0][0][0:4])

    df = pd.DataFrame()
    for anho in range(anho_desde, anho_hasta + 1):
        if anho == anho_hasta:
            meses = datetime.now().month
        else:
            meses = 13

        for mes in range(1, meses):
            data = __do_webscraping(anho, mes, monedas)
            if df.empty:
                df = data
            else:
                df = pd.concat([df, data])
    return df

def extract_data_to_raw(anho_desde, anho_hasta, monedas, conn_id):

    # Extraer la cotizacion mensual de la página del portal de la BCP
    data = __get_bcp_cotizacion_mensual(anho_desde, anho_hasta, monedas, conn_id)

    # Crear la conexión a la base de datos PostgreSQL
    engine = create_engine(POSTGRES_CONN_URL)

    # Cargar los datos en la tabla
    data.to_sql(name='bcp_cotizacion_referencial', con=engine, schema='raw', if_exists='replace', index=False)