"""
Ejemplo DAG que demuestra el uso de DAG decorator.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

import httpx
import pendulum

from airflow.decorators import dag, task
from airflow.models.baseoperator import BaseOperator
from airflow.operators.email import EmailOperator

if TYPE_CHECKING:
    from airflow.utils.context import Context


class GetRequestOperator(BaseOperator):
    """Operador personalizado para enviar una solicitud GET a la URL proporcionada"""

    def __init__(self, *, url: str, **kwargs):
        super().__init__(**kwargs)
        self.url = url

    def execute(self, context: Context):
        return httpx.get(self.url).json()

# version 3
# [START dag_decorator_usage]
@dag(
    dag_id="example_dag_decorator_id",
    dag_display_name="example_dag_decorator",
    description="Ejemplo DAG que demuestra el uso de DAG decorator.",
    start_date=pendulum.datetime(2025, 12, 31, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=['poc', 'example']
)
def example_dag_decorator(email: str = "example@example.com"):
    """
    DAG to send server IP to email.

    :param email: Email to send IP to. Defaults to example@example.com.
    """
    get_ip = GetRequestOperator(task_id="get_ip", url="http://httpbin.org/get")

    @task(multiple_outputs=True)
    def prepare_email(raw_json: dict[str, Any]) -> dict[str, str]:
        external_ip = raw_json["origin"]
        return {
            "subject": f"Servidor conectado desde {external_ip}",
            "body": f"Parece que hoy su servidor que ejecuta Airflow está conectado desde IP {external_ip}<br>",
        }

    email_info = prepare_email(get_ip.output)

    EmailOperator(
        task_id="send_email", to=email, subject=email_info["subject"], html_content=email_info["body"]
    )


example_dag = example_dag_decorator()
# [END dag_decorator_usage]
