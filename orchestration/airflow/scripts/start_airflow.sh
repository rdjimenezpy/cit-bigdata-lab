#!/bin/bash

# Activar Entorno Virtual:
source venv/bin/activate

echo "Iniciando servicios de Apache Airflow..."

airflow webserver -D
echo "Webserver iniciado."

airflow scheduler -D
sleep 2
pkill -9 -f "airflow scheduler"
sleep 2
airflow scheduler -D
echo "Scheduler iniciado."

airflow triggerer -D
pkill -9 -f 'triggerer'
airflow triggerer -D
echo "Triggerer iniciado."

echo "Todos los servicios se han iniciado."