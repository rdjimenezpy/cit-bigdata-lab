#!/bin/bash

# Ruta al entorno virtual de Airflow
VENV_PATH="/home/richard/analytics/airflow_project/venv"

# Activar el entorno virtual
source "$VENV_PATH/bin/activate"

# Función para verificar si un servicio está activo
check_service() {
    SERVICE_NAME=$1
    if pgrep -f "$SERVICE_NAME" > /dev/null; then
        echo "$SERVICE_NAME: En ejecución"
    else
        echo "$SERVICE_NAME: No está en ejecución"
    fi
}

echo "Verificando estado de servicios de Apache Airflow..."
check_service webserver
check_service scheduler
check_service triggerer