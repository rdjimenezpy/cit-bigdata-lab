"""
Tareas de transformación y carga de datafactory.
"""

from __future__ import annotations

from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

def taks_transform_load_rp_infodiaria():
    return SQLExecuteQueryOperator(
        task_id='transform_load_rp_infodiaria',
        conn_id='postgres_geopos',
        sql='rp_informacion_diaria.sql'
    )


def taks_transform_load_rp_summary_pos():
    return SQLExecuteQueryOperator(
        task_id='transform_load_rp_summary_pos',
        conn_id='postgres_geopos',
        sql='rp_operational_summary_pos.sql'
    )


def taks_transform_load_rp_summary():
    return SQLExecuteQueryOperator(
        task_id='transform_load_rp_summary',
        conn_id='postgres_geopos',
        sql='rp_operational_summary.sql'
    )


def taks_transform_load_rp_infosemanal():
    return SQLExecuteQueryOperator(
        task_id='transform_load_rp_infosemanal',
        conn_id='postgres_geopos',
        sql='rp_informacion_semanal.sql'
    )


def taks_transform_load_rp_infomensual():
    return SQLExecuteQueryOperator(
        task_id='transform_load_rp_infomensual',
        conn_id='postgres_geopos',
        sql='rp_informacion_mensual.sql'
    )