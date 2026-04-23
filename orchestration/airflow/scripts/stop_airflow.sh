#!/bin/bash

# Terminar servicios aiflow

pkill -9 -f "airflow-webserver"
echo "Webserver terminado."

pkill -9 -f "airflow scheduler"
echo "Scheduler terminado."

pkill -9 -f 'triggerer'
echo "Triggerer terminado."

echo "Todos los servicios se han terminado."