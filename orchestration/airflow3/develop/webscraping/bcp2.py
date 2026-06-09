from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import time

def obtener_html_selenium(url, anho, mes):
    options = Options()
    options.headless = True
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')

    driver = webdriver.Chrome(options=options)

    try:
        driver.get(url)

        # Esperar a que el campo 'anho' esté presente
        wait = WebDriverWait(driver, 10)
        anho_input = wait.until(EC.presence_of_element_located((By.ID, 'anho')))
        mes_input = wait.until(EC.presence_of_element_located((By.ID, 'mes')))
        boton_buscar = wait.until(EC.element_to_be_clickable((By.ID, 'botonBuscar')))

        # Establecer los valores del formulario
        anho_input.clear()
        anho_input.send_keys(anho)
        mes_input.clear()
        mes_input.send_keys(mes)

        # Hacer clic en el botón
        boton_buscar.click()

        # Esperar que se cargue una tabla o algún contenido relevante
        wait.until(EC.presence_of_element_located((By.TAG_NAME, 'table')))
        time.sleep(1)  # Breve espera adicional para evitar errores de renderizado

        html = driver.page_source
        return html

    finally:
        driver.quit()

def extraer_datos_table(html):
    soup = BeautifulSoup(html, 'html.parser')
    tablas = soup.find_all('table')
    datos = []

    for tabla in tablas:
        filas = tabla.find_all('tr')
        tabla_datos = []

        for fila in filas:
            columnas = fila.find_all(['td', 'th'])
            fila_datos = [columna.get_text(strip=True) for columna in columnas]
            tabla_datos.append(fila_datos)

        datos.append(tabla_datos)

    return datos

# Uso principal
if __name__ == "__main__":
    url = "https://www.bcp.gov.py/webapps/web/cotizacion/monedas-mensual"
    anho = '2024'
    mes = '09'

    html = obtener_html_selenium(url, anho, mes)

    if html:
        tablas = extraer_datos_table(html)
        for i, tabla in enumerate(tablas):
            print(f"Tabla {i + 1}:")
            for fila in tabla:
                print(fila)
            print("\n")
