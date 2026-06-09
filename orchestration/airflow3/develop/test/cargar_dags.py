
from __future__ import annotations

from airflow.models import DagBag

# Cargar el DagBag
dag_bag = DagBag()

# Verificar si hay errores
if dag_bag.import_errors:
    print("Errores al cargar DAGs:")
    for dag_id, error in dag_bag.import_errors.items():
        print(f"{dag_id}: {error}")
else:
    print("DAGs cargados correctamente:")
    for dag_id in dag_bag.dags:
        print(dag_id)
