"""
DataFactory es un generador de un conjunto de datos de prueba CSV para el proyecto geopos.
"""

from __future__ import annotations

import json
import time
from datetime import timedelta
from random import randint, uniform

import pandas as pd

# Fechas de inicio y fin por defecto
ini_default, fin_default = "2020-01-01", "2025-05-31"
dates_default = pd.date_range(start=ini_default, end=fin_default, freq="D")

# ID de locales por defectos
pdv_default = [100, 131, 154, 185, 200, 205, 225, 275, 300, 310, 335, 395, 400, 412, 445, 486, 500, 515, 550, 596]

# Definir nombres de columnas (cabeceras)
columnas_infodiaria = [
    "ProInfoSistema",
    "ProInfoFecha",
    "ProInfoValorAnterior",
    "ProInfoXMLPrevio",
    "ProInfoXMLPosterior",
    "ProInfoValorActual",
    "ProInfoValorSiguiente",
    "ProInfoXMLError",
    "OpLocal"
]

columnas_summary = [
    "OP_LOCAL",
    "OP_START_DATE",
    "OP_FINAL_DATE",
    "OP_TOTAL_SALE",
    "OP_TOTAL_SERVICES",
    "OP_TOTAL_SERVICES_GIFCARD",
    "OP_TOTAL_DELIVERY",
    "OP_TOTAL_CLIENT",
    "OP_TOTAL_CLIENT_DELIVERY",
    "OP_TOTAL_ANNULMENT",
    "OP_TOTAL_SALE_ALL"
]

columnas_summary_pos = [
    "OP_LOCAL",
    "OP_START_DATE",
    "OP_POS",
    "OP_TOTAL_TX",
    "OP_LOCAL_FK",
    "OP_START_DATE_FK"
]

# Definir archivos csv de salida
# file_path = r"/mnt/d/Git/fpuna/cit_bigdata_basico/datasets/output/geopos/"
file_path = r"D:\Git\fpuna\cit_bigdata_basico\datasets\output\geopos"
csv_infodiaria = file_path + r"\proinformaciondiaria.csv"
csv_summary_pos = file_path + r"\bo_operational_summary_pos.csv"
csv_summary = file_path + r"\bo_operational_summary.csv"

# Crear indicadores con datos de pruebas en formato JSON para la columna pro_info_xml_previo
def __generar_pro_info_xml_previo():
    datos = {
        'CntProductosActivos': randint(1000, 2500),
        'CntProductosInactivos': randint(500, 1500),
        'CntProductosNoAprovechados': randint(300, 700),
        'CantidadVendidaEnPeriodo': round(uniform(25000, 40000), 4),
        'PromedioVentas': round(uniform(4000000, 7000000), 2),
        'VentasPerdidas': 0,
        'CntDiasInventarioNegativo': 0,
        'InventarioValorizado': round(uniform(100000000, 300000000), 6),
        'DiasInventario': round(uniform(20, 40), 12),
        'ValorArtInactivosConInv': randint(8000000, 150000000),
        'CntPrdInventariadosSem1': randint(5, 800),
        'CntPrdInventariadosSem2': randint(20, 700),
        'CntPrdInventariadosSem3': randint(5, 600),
        'CntPrdInventariadosSem4': randint(5, 700),
        'PrcPrdInventariadosSem1': round(uniform(0, 45), 2),
        'PrcPrdInventariadosSem2': round(uniform(1, 35), 2),
        'PrcPrdInventariadosSem3': round(uniform(0, 30), 2),
        'PrcPrdInventariadosSem4': round(uniform(0, 40), 2),
        'PAFConDesabasto': 100,
        'MermaValor': round(uniform(390000, 3000000), 3),
        'MermaPRC': round(uniform(0, 2), 2),
        'MermaAcumuladaFF': round(uniform(105000, 2000000), 2),
        'MermaFFAlimentos': round(uniform(105000, 2000000), 2),
        'MermaFFBebidas': 0,
        'HuecosReales': randint(40, 150),
        'InventarioNegativo': randint(4, 50),
        'PrcVtaPerdidaCEDIS': randint(1, 99),
        'PrcVtaPerdidaPrvDirectos': randint(30, 100),
        'PrcVtaPerdidaFF': randint(2, 40),
        'VentasPerdidaActivos': round(uniform(800000, 7000000), 12),
        'AcumuladoPeriodoActual': round(uniform(-3000, 900), 3)
    }

    # Convertir a JSON
    return json.dumps(datos, separators=(',', ':'))

# Crear un DataFrame con datos de pruebas para la tabla ods_proinformaciondiaria
def generar_data_infodiaria(locales=pdv_default, fechas=dates_default):
    # Crear una lista para almacenar los datos generados
    data = []

    for local in locales:
        for fecha in fechas:
            pro_info_sistema = 'RESUMENOPERATIVO'
            pro_info_fecha = fecha.strftime('%Y-%m-%d')
            pro_info_valor_anterior = 0
            pro_info_xml_previo = __generar_pro_info_xml_previo()
            pro_info_xml_posterior = None
            pro_info_valor_actual = 0
            pro_info_valor_siguiente = 0
            pro_info_xml_error = None
            op_local = local

            data.append([
                pro_info_sistema, pro_info_fecha, pro_info_valor_anterior, pro_info_xml_previo, pro_info_xml_posterior,
                pro_info_valor_actual, pro_info_valor_siguiente, pro_info_xml_error, op_local
            ])

    # Crear un DataFrame con los datos generados
    df = pd.DataFrame(data, columns=columnas_infodiaria)

    return df

# Crear un DataFrame con datos de pruebas para la tabla ods_bo_operational_summary
def generar_data_summary(locales=pdv_default, fechas=dates_default):
    # Crear una lista para almacenar los datos generados
    data = []

    for local in locales:
        for fecha in fechas:
            # end_date = fecha + timedelta(days=randint(0, 2))
            op_start_date = fecha.replace(hour=0, minute=randint(0, 59), second=randint(0, 59))
            op_final_date = fecha.replace(hour=23, minute=randint(0, 59), second=randint(0, 59))
            op_total_sale = int(uniform(2000000, 1000000))
            op_total_services = int(uniform(0, 60000))
            op_total_services_gifcard = int(uniform(0, 300000))
            op_total_delivery = 0
            op_total_client = randint(200, 999)
            op_total_client_delivery = 0
            op_total_annulment = int(uniform(0, 120000))
            op_total_sale_all = int(op_total_sale * round(uniform(1.1, 1.2), 2))

            data.append([local, op_start_date, op_final_date, op_total_sale, op_total_services,
                         op_total_services_gifcard, op_total_delivery, op_total_client, op_total_client_delivery,
                         op_total_annulment, op_total_sale_all])

            if uniform(0, 1) > 0.7:
                end_date = fecha + timedelta(days=randint(0, 2))
                op_start_date = fecha.replace(hour=randint(0, 23), minute=randint(0, 59), second=randint(0, 59))
                op_final_date = end_date.replace(hour=randint(0, 23), minute=randint(0, 59), second=randint(0, 59))
                op_total_sale = int(uniform(2000000, 1000000))
                op_total_services = int(uniform(0, 60000))
                op_total_services_gifcard = int(uniform(0, 300000))
                op_total_delivery = 0
                op_total_client = randint(200, 999)
                op_total_client_delivery = 0
                op_total_annulment = int(uniform(0, 120000))
                op_total_sale_all = int(op_total_sale * round(uniform(1.1, 1.2), 2))

                data.append([
                    local, op_start_date, op_final_date, op_total_sale, op_total_services, op_total_services_gifcard,
                    op_total_delivery, op_total_client, op_total_client_delivery, op_total_annulment, op_total_sale_all
                ])

    # Crear un DataFrame con los datos generados
    df = pd.DataFrame(data, columns=columnas_summary)

    return df

# Crear un DataFrame con datos de pruebas para la tabla ods_bo_operational_summary_pos
def generar_data_summary_pos(locales=pdv_default, fechas=dates_default):
    # Crear una lista para almacenar los datos generados
    data = []

    for local in locales:
        for fecha in fechas:
            start_date = fecha.replace(hour=randint(0, 23), minute=randint(0, 59), second=randint(0, 59))

            op_local = local
            op_start_date = start_date
            op_pos = 1
            op_total_tx = int(uniform(1, 700))
            op_local_fk = local
            op_start_date_fk = start_date

            data.append([
                op_local, op_start_date, op_pos, op_total_tx, op_local_fk, op_start_date_fk
            ])

            if uniform(0, 1) > 0.5:
                op_pos = 2
                op_total_tx = int(uniform(1, 700))

                data.append([
                    op_local, op_start_date, op_pos, op_total_tx, op_local_fk, op_start_date_fk
                ])

            if uniform(0, 1) > 0.7:
                op_start_date = fecha.replace(hour=randint(0, 23), minute=randint(0, 59), second=randint(0, 59))

                op_pos = 1
                op_total_tx = int(uniform(1, 700))
                data.append([
                    op_local, op_start_date, op_pos, op_total_tx, op_local_fk, op_start_date_fk
                ])

                op_pos = 2
                op_total_tx = int(uniform(1, 700))
                data.append([
                    op_local, op_start_date, op_pos, op_total_tx, op_local_fk, op_start_date_fk
                ])

    # Crear un DataFrame con los datos generados
    df = pd.DataFrame(data, columns=columnas_summary_pos)

    return df


# PROGRAMA MAIN PARA GENERAR DATOS DE PRUEBAS PARA GEOPOS_DB
if __name__ == "__main__":
    # Definir las fechas de inicio y fin
    fecha_ini, fecha_fin = "2020-01-01", "2025-05-31"

    # Definir los locales
    # locales = [131, 154, 185, 205, 596]
    locales = [100, 131, 154, 185, 200, 205, 225, 275, 300, 310, 335, 395, 400, 412, 445, 486, 500, 515, 550, 596]

    inicio = time.time()
    # Generar rango de fechas
    fechas = pd.date_range(start=fecha_ini, end=fecha_fin, freq="D")
    # print("Rango de fechas generado:")
    # for fecha in fechas:
    #     print(fecha)

    # Generar el DataFrame de prueba para proinformaciondiaria
    df_infodiaria = generar_data_infodiaria(locales, fechas)

    # Guardar el DataFrame en un archivo CSV
    df_infodiaria.to_csv(csv_infodiaria, index=False)

    # Generar el DataFrame de prueba para bo_operational_summary
    df_summary = generar_data_summary(locales, fechas)

    # Guardar el DataFrame en un archivo CSV
    df_summary.to_csv(csv_summary, index=False)

    # Generar el DataFrame de prueba para bo_operational_summary_pos
    df_summary_pos = generar_data_summary_pos(locales, fechas)

    # Guardar el DataFrame en un archivo CSV
    df_summary_pos.to_csv(csv_summary_pos, index=False)

    fin = time.time()
    duracion = fin - inicio
    print(f"Duración de ejecución: {duracion} segundos")