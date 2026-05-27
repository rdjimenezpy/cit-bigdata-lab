from __future__ import annotations

import pendulum
from airflow.sdk import dag, task


@dag(
    dag_id="cit_validacion_airflow3",
    schedule="@daily",
    start_date=pendulum.datetime(2026, 1, 1, tz="America/Asuncion"),
    catchup=False,
    tags=["cit", "bigdata", "airflow3", "sample"],
)
def cit_validacion_airflow3():
    @task
    def extraer():
        return {"fuente": "laboratorio", "registros": 10}

    @task
    def transformar(payload: dict) -> dict:
        return {
            "fuente": payload["fuente"],
            "registros_originales": payload["registros"],
            "registros_procesados": payload["registros"] * 2,
        }

    @task
    def cargar(resultado: dict) -> None:
        print("Resultado del pipeline académico:", resultado)

    cargar(transformar(extraer()))


cit_validacion_airflow3()
