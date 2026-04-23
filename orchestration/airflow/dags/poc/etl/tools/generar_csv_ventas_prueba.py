"""
Un ejemplo de cómo generar un archivo CSV con datos de prueba de ventas utilizando Python.

Este script generará un archivo CSV con los siguientes campos:

    fecha: Fecha de la venta (en el último año)

    producto: Nombre del producto vendido

    precio_unitario: Precio por unidad del producto

    cantidad: Cantidad vendida

    total: Total de la venta (precio_unitario × cantidad)

    ciudad: Ciudad donde se realizó la venta

    vendedor: Identificador del vendedor

Puedes modificar:

    NUM_REGISTROS para cambiar la cantidad de datos generados

    PRODUCTOS para añadir o quitar productos

    CIUDADES para cambiar las ubicaciones
"""

import csv
import random
from datetime import datetime, timedelta

# Configuración
NUM_REGISTROS = 1000  # Número de registros a generar
PRODUCTOS = [
    ("Laptop", 1200),
    ("Teléfono", 800),
    ("Tablet", 400),
    ("Monitor", 300),
    ("Teclado", 50),
    ("Mouse", 30),
    ("Auriculares", 150),
    ("Impresora", 200),
    ("Altavoz", 120),
    ("Cámara", 600)
]
CIUDADES = ["Asunción", "San Lorenzo", "Capiatá", "Lambaré", "Areguá", "Ñeemby", "Villa Elisa", "Luque", "Itá", "Ypané"]
ARCHIVO_SALIDA = "D:/Git/fpuna/cit_bigdata_basico/datasets/output/ventas_prueba.csv"


# Generar fechas aleatorias dentro del último año
def fecha_aleatoria():
    hoy = datetime.now()
    dias_atras = random.randint(1, 365)
    return hoy - timedelta(days=dias_atras)


# Generar datos de ventas
datos_ventas = []
for _ in range(NUM_REGISTROS):
    producto, precio = random.choice(PRODUCTOS)
    cantidad = random.randint(1, 5)
    ciudad = random.choice(CIUDADES)
    fecha = fecha_aleatoria()

    datos_ventas.append({
        "fecha": fecha.strftime("%Y-%m-%d"),
        "producto": producto,
        "precio_unitario": precio,
        "cantidad": cantidad,
        "total": precio * cantidad,
        "ciudad": ciudad,
        "vendedor": f"V-{str(random.randint(1, 10)).zfill(2)}"
    })

# Escribir archivo CSV
with open(ARCHIVO_SALIDA, mode='w', newline='', encoding='utf-8') as archivo:
    campos = ["fecha", "producto", "precio_unitario", "cantidad", "total", "ciudad", "vendedor"]
    escritor = csv.DictWriter(archivo, fieldnames=campos)

    escritor.writeheader()
    escritor.writerows(datos_ventas)

print(f"Archivo '{ARCHIVO_SALIDA}' generado con {NUM_REGISTROS} registros de ventas.")