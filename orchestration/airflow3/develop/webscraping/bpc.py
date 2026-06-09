
import requests
from bs4 import BeautifulSoup

def obtener_html(url, params=None):
    """
    Realiza una petición GET a la URL especificada con los parámetros proporcionados.

    :param url: La URL de la página a la que se va a hacer la petición.
    :param params: Diccionario con los parámetros a incluir en la petición (opcional).
    :return: El contenido HTML de la respuesta.
    """
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()  # Verifica si hubo algún error en la petición
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error al obtener el HTML: {e}")
        return None

def extraer_datos_table(html):
    """
    Extrae los datos de las etiquetas <table> del HTML proporcionado.

    :param html: El contenido HTML donde buscar las tablas.
    :return: Lista de tablas con los datos extraídos.
    """
    soup = BeautifulSoup(html, 'html.parser')
    tablas = soup.find_all('table')

    datos = []

    for tabla in tablas:
        filas = tabla.find_all('tr')
        tabla_datos = []

        for fila in filas:
            columnas = fila.find_all(['td', 'th'])  # Extraer celdas de datos o encabezados
            fila_datos = [columna.get_text(strip=True) for columna in columnas]
            tabla_datos.append(fila_datos)

        datos.append(tabla_datos)

    return datos

# Ejemplo de uso
if __name__ == "__main__":
    url = "https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual/"  # Cambia por la URL real
    params = {'anho': '2024', 'mes': '09'}  # Cambia por los parámetros reales si es necesario

    html = obtener_html(url, params)

    if html:
        tablas = extraer_datos_table(html)

        # Mostrar las tablas extraídas
        for i, tabla in enumerate(tablas):
            print(f"Tabla {i + 1}:")
            for fila in tabla:
                print(fila)
            print("\n")
