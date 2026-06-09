<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# 📘Tutorial paso a paso: Instalación y Configuración de Apache Airflow 2.9.3 con PostgreSQL  
**Entorno WSL – Ubuntu 22.04.5 LTS – Python 3.12.5 (pyenv) – Despliegue de Apache Airflow 2.9.3 en /opt/airflow**

---

## Institución  
Facultad Politécnica – Universidad Nacional de Asunción  
Centro de Innovación CIT Paraguay–Corea. [Sitio oficial del CIT](https://cit.pol.una.py/)

## Curso  
Introducción a Big Data (nivel básico) – Arquitectura de Datos y Orquestación de Pipelines  

## Autor  
Richard D. Jiménez-R.
Ingeniero en Informática – Arquitecto y Analista de Datos  

## Contacto
rjimenez@pol.una.py

## Fecha y versión
* Fecha: 14/01/2026
* Versión: 1.0

---

🗒️ **Nota sobre esta documentación:**

Este documento fue elaborado a partir de pruebas de concepto realizadas durante la instalación y configuración de **Apache Airflow 2.9.3** en **Ubuntu 22.04** bajo **WSL2**, utilizando **Python 3.12.5** y **PostgreSQL 15**.  

Al replicar los pasos descritos, podrían ser necesarios ajustes adicionales según las características específicas del entorno, la distribución de Linux o políticas internas de seguridad.  

Para mayor detalle y actualizaciones, se recomienda consultar la documentación oficial del proyecto [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/2.9.3/index.html#)

---

## 1. Introducción

Apache Airflow es una plataforma de orquestación de workflows basada en DAGs (Directed Acyclic Graphs), ampliamente utilizada en arquitecturas modernas de datos para la automatización, monitoreo y escalado de pipelines ETL/ELT.

Este documento describe **paso a paso** la instalación de **Apache Airflow 2.9.3**, utilizando:

- Python **3.12.5** gestionado con **pyenv**
- Base de datos de metadatos en **PostgreSQL 15**
- Estructura profesional bajo `/opt/airflow`
- Entornos virtuales independientes por versión de Airflow

En caso de necesitar apoyo adicional para reproducir el tutorial, el estudiante deberá contactar con el profesor del curso o solicitar ayuda a través de los canales disponibles del mismo.

---

## 2. Objetivos

- Instalar Apache Airflow 2.9.3 de forma aislada y reproducible
- Utilizar PostgreSQL como backend de metadatos
- Implementar una estructura de directorios profesional en `/opt/airflow`
- Configurar variables de entorno por instalación
- Preparar el entorno para futuras versiones (Airflow 3.x)

---

## 3. Prerrequisitos

Se asume que el sistema ya cuenta con:

- WSL2 operativo (Ubuntu 22.04 LTS)
- Python 3.12.5 instalado vía `pyenv`
- PostgreSQL 15 instalado y en ejecución
- Usuario con permisos `sudo`
- Acceso a internet

Verificaciones rápidas:

```bash
python --version
pyenv versions
psql --version
```

Guía clara y práctica con los comandos esenciales para gestionar **PostgreSQL (psql)** en Debian/Ubuntu:

```bash
# Actualizar lista de paquetes
sudo apt update

# Instalar el cliente psql
sudo apt install postgresql-contrib -y

# Actualizar el cliente psql
sudo apt upgrade postgresql-client -y

# Si quieres instalar o actualizar a una versión específica (ej. PostgreSQL 15):
sudo apt install postgresql-client-15 -y

# Ver la versión de psql
psql --version
psql -V

# Manual de ayuda de psql
psql --help

# Entrar al cliente psql
psql

# Salir de psql
\q

# Manual completo (man page)
man psql

# Dentro de psql:
\?        # Muestra todos los comandos internos
\h        # Muestra ayuda sobre sentencias SQL 
\h SELECT # Ejemplo: ayuda específica para SELECT

# Listar bases de datos
\l

# Conectarse a una base de datos
\c nombre_base

# Listar tablas
\dt

# === Actualizar a postgresql-client-15 ====

# 1. Agregar el repositorio oficial de PostgreSQL
cd /etc/apt/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg
echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# 2. Actualizar la lista de paquetes
sudo apt update

# 3. Instalar únicamente el cliente v15
sudo apt install postgresql-client-15

# 4. ¿Cómo verificar que funcionó?
psql --version

# 5. ¿Cómo verificar qué versiones tienes instaladas?
dpkg -l | grep postgresql-client

# 6. Elimina las otras versiones que no se necesitan y el metapaquete
sudo apt remove postgresql-client-14
sudo apt remove postgresql-client-18 postgresql-client
```

---

## 4. Estructura de directorios propuesta

Cada versión de Airflow es una **instancia completamente independiente**:

```text
/opt/airflow/
├── airflow_2.9.3/
│   ├── venv/
│   ├── configs/
│	│   ├── airflow.cfg
│	│   ├── airflow_cit.cfg
│	│   ├── airflow_des.cfg
│	│   ├── airflow_pre.cfg
│	│   ├── airflow_pro.cfg
│	│   ├── webserver_config.cfg
│   │   └── airflow.db
│   ├── dags/
│   ├── logs/
│   ├── plugins/
│   ├── scripts/
│	│   ├── activate_airflow_2.9.3.sh
│	│   ├── activate_airflow2_cit.sh
│	│   ├── activate_airflow2_des.sh
│	│   ├── activate_airflow2_pre.sh
│   │   └── activate_airflow2_pro.sh
│   ├── data/
│   │   └── constraints-3.12.txt
│   ├── outputs/
│   └── venv/
├── airflow_2.11.2/
├── airflow_3.1.8/
├── airflow_3.2.1/
```

Este diseño evita conflictos, facilita *upgrades* y permite *rollback* controlado.  
La simplicidad aquí no es pobreza conceptual, es disciplina.

---

## 5. Creación del directorio base y permisos

```bash
sudo mkdir -p /opt/airflow3
sudo chown -R $USER:$USER /opt/airflow3
```

Crear estructura para Airflow 2.9.3:

```bash
mkdir -p /opt/airflow3/airflow_2.9.3/{venv,configs,dags,logs,plugins,scripts,data,outputs}
```

---

## 6. Creación del entorno virtual con pyenv

Seleccionar Python 3.12.5:

```bash
pyenv shell 3.12.5
```

Crear el entorno virtual:

```bash
python -m venv /opt/airflow3/airflow_2.9.3/venv
```

---

## 7. Script de activación del entorno Airflow 2.9.3

Archivo:  
`/opt/airflow/airflow_2.9.3/scripts/activate_airflow_2.9.3.sh`

```bash
#!/bin/bash
source /opt/airflow3/airflow_2.9.3/venv/bin/activate

export AIRFLOW_HOME=/opt/airflow3/airflow_2.9.3
export AIRFLOW_CONFIG=/opt/airflow3/airflow_2.9.3/configs/airflow3.cfg

echo "Entorno de Airflow 2.9.3 activado."
```

Permisos:

```bash
chmod +x /opt/airflow3/airflow_2.9.3/scripts/activate_airflow_2.9.3.sh
```

Activación manual:

```bash
source /opt/airflow3/airflow_2.9.3/scripts/activate_airflow_2.9.3.sh
```

Para salir o desactivar un entorno virtual de Python (venv)

```bash
deactivate
```

---

## 8. Alias para activación rápida

Agregar a `~/.bashrc`:

```bash
nano ~/.bashrc

# Alias para activar entornos de Airflow
alias airflow2='source /opt/airflow3/airflow_2.9.3/scripts/activate_airflow_2.9.3.sh'
```

Recargar:

```bash
source ~/.bashrc
```

Prueba:

```bash
airflow2
```

---

## 9. Descarga del archivo de *constraints*

```bash
cd /opt/airflow3/airflow_2.9.3/data

wget https://github.com/apache/airflow/blob/constraints-2.9.3/constraints-3.12.txt?raw=true \
     -O constraints-3.12.txt
```

---

## 10. Instalación de Apache Airflow 2.9.3

Actualizar `pip`:

```bash
pip install --upgrade pip setuptools wheel
```

Instalación con extras recomendados:

```bash
pip install \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt" \
  "apache-airflow[async,postgres,statsd,datadog,sftp]==2.9.3" \
  psycopg2-binary
```

Verificación:

```bash
which airflow3
airflow3 version
```

Para instalar **pandas** respetando las restricciones de versiones que Airflow publica en su archivo de _constraints_, el comando correcto sería:

```bash
pip install \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt" \
  pandas
```

Si quieres confirmar que el paquete se instaló:

```bash
pip show pandas

pip list | grep pandas
```

- El mensaje mostrado no es un error, sino una advertencia (`RemovedInAirflow3Warning`). Airflow está avisando que el validador básico de métricas (basic metric validator) será eliminado en la versión 3.
- Puedes filtrar advertencias de tipo  en tu configuración de logging, aunque lo recomendable es adaptar la configuración en lugar de ocultar el aviso.

### 10.1 Adoptar la configuración recomendada (si usas métricas/Datadog):
En tu archivo `airflow.cfg`, dentro de la sección `[metrics]`, agrega o modifica la opción:

```bash
[metrics]
metrics_use_pattern_match = True
```

Esto activa el nuevo sistema de validación de métricas por patrones, adelantándote a lo que será obligatorio en Airflow 3.

### 10.2 Deshabilitar explícitamente métricas si molestan los logs:

 - En tu archivo `airflow.cfg`, busca la sección `[metrics]` y asegúrate de que esté configurada así:

```bash
[metrics]
statsd_on = False
```

---

## 11. Prueba inicial (standalone)

> Uso exclusivo para validación rápida del entorno

```bash
airflow3 standalone
```

Esto levanta temporalmente:
- Webserver.
- Scheduler.
- SQLite.
- Usuario `admin` autogenerado.

Finalizada la prueba, detener procesos y continuar.

---

## 12. Configuración de PostgreSQL como metadata database

Crear base y usuario:

```sql
-- 1. Crear la base de datos
CREATE DATABASE airflow_metadata;

-- 2. Crear esquema para tablas de airflow3
CREATE SCHEMA airflow2;

-- 3. Crear un usuario dedicado (opcional pero recomendado)
CREATE USER airflow_user WITH PASSWORD 'airflow_pass';

-- 4. Dar permisos al usuario sobre el esquema
GRANT ALL PRIVILEGES ON DATABASE airflow_metadata TO airflow_user;
GRANT ALL PRIVILEGES ON SCHEMA airflow2 TO airflow_user;
ALTER USER airflow_user SET search_path TO airflow2;

-- 5. Ver la configuración activa en la sesión
SHOW search_path;

SELECT current_setting('search_path');

SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname = 'airflow_user';
```

---

## 13. Inicialización del archivo `airflow.cfg`

Mover el archivo generado:

```bash
mv $AIRFLOW_HOME/airflow3.cfg $AIRFLOW_HOME/configs/airflow3.cfg
```

Editar en `airflow.cfg`:

```bash
[database]
sql_alchemy_conn = postgresql+psycopg2://airflow_user:airflow_pass@localhost:5432/airflow_meta?options=-csearch_path=airflow2
sql_alchemy_schema = airflow2
```

Este es el método recomendado porque te muestra el valor real que Airflow está interpretando, ya sea que venga de una variable de entorno o del archivo `airflow.cfg`.

```bash
airflow3 config get-value database sql_alchemy_conn
```

## 14. Inicialización de la base de datos

```bash
# 1. Verificar conexión airflow3
airflow3 db check

# 2. Aplicar esquema
airflow3 db migrate

# 3. Crear el usuario administrador (necesario para la UI)
airflow3 users create \
    --username admin \
    --firstname Richard \
    --lastname Jiménez \
    --role Admin \
    --email rjimenez@pol.una.py \
    --password admin
```

Verificar la creación real del usuario

```bash
airflow3 users list
```

---

## 15. Instalación de dependencias adicionales (opcional)

StatsD:

```bash
pip install statsd==4.0.1 \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt"
```

Pandas:

```bash
pip install pandas==2.1.4 \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt"
```

---

## 16. Providers PostgreSQL

Verificar `provider` actual:

```bash
airflow3 providers list | grep -i postgres || true
```

Instalar versión recomendada:

```bash
pip install "apache-airflow-providers-postgres==5.11.2" \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt"
```

Rollback (si es necesario):

```bash
pip install "apache-airflow-providers-postgres==5.11.2" \
  --constraint "/opt/airflow/airflow_2.9.3/data/constraints-3.12.txt"

pip check
```

---

## 17. Arranque manual de servicios

En terminales separadas:

```bash
airflow3 webserver -D
```

```bash
airflow3 scheduler -D
```

Acceso web:

```text
http://localhost:8080
```

---

## 18. Limpieza de instalaciones globales (opcional)

```bash
pip uninstall apache-airflow3
rm -rf ~/.local/lib/python3.12/site-packages/apache_airflow*
```

---

## 19. Configuración de variables de entorno

Editar archivo `airflow.cfg` o .`env`:

```bash
# [core]
AIRFLOW_HOME=/opt/airflow3/airflow_2.9.3
AIRFLOW_CONFIG=/opt/airflow3/airflow_2.9.3/configs/airflow3.cfg

AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow3/airflow_2.9.3/dags
AIRFLOW__CORE__DEFAULT_TIMEZONE="America/Asuncion"
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__CORE__PARALLELISM=32
AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG=16
AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG=16
AIRFLOW__CORE__LOAD_EXAMPLES=False
AIRFLOW__CORE__PLUGINS_FOLDER=/opt/airflow3/airflow_2.9.3/plugins
AIRFLOW__CORE__EXECUTE_TASKS_NEW_PYTHON_INTERPRETER=False
AIRFLOW__CORE__TASK_RUNNER=StandardTaskRunner
AIRFLOW__CORE__DEFAULT_TASK_EXECUTION_TIMEOUT=
AIRFLOW__CORE__CHECK_SLAS=True

# [database]
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://[user]:[pass]@[iphost]:5432/[airflow_meta]?options=-csearch_path=[shema_name]
AIRFLOW__DATABASE__SQL_ENGINE_ENCODING=utf-8
AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA=[shema_name]

# [logging]
AIRFLOW__LOGGING__BASE_LOG_FOLDER=/opt/airflow3/airflow_2.9.3/logs
AIRFLOW__LOGGING__LOGGING_LEVEL=INFO
AIRFLOW__LOGGING__FAB_LOGGING_LEVEL=WARNING
AIRFLOW__LOGGING__TASK_LOG_PREFIX_TEMPLATE={ti.dag_id}-{ti.task_id}-{execution_date}-{try_number}
AIRFLOW__LOGGING__DAG_PROCESSOR_MANAGER_LOG_LOCATION=/opt/airflow3/airflow_2.9.3/logs/dag_processor_manager/dag_processor_manager.log
AIRFLOW__LOGGING__EXTRA_LOGGER_NAMES=connexion,sqlalchemy
AIRFLOW__LOGGING__WORKER_LOG_SERVER_PORT=8793
AIRFLOW__LOGGING__TRIGGER_LOG_SERVER_PORT=8794

# [metrics]
AIRFLOW__METRICS__STATSD_ON=True
AIRFLOW__METRICS__STATSD_HOST=127.0.0.1
AIRFLOW__METRICS__STATSD_PORT=8125
AIRFLOW__METRICS__STATSD_PREFIX=airflow3
AIRFLOW__METRICS__STATSD_DISABLED_TAGS=job_id,run_id,dag_id,task_id

[cli]
AIRFLOW__CLI__ENDPOINT_URL=http://localhost:8080

[operators]
AIRFLOW__OPERATORS__DEFAULT_DEFERRABLE=false
AIRFLOW__OPERATORS__DEFAULT_CPUS=1
AIRFLOW__OPERATORS__DEFAULT_RAM=512
AIRFLOW__OPERATORS__DEFAULT_DISK=512
AIRFLOW__OPERATORS__DEFAULT_GPUS=0

# [webserver]
AIRFLOW__WEBSERVER__ACCESS_DENIED_MESSAGE=Acceso denegado
AIRFLOW__WEBSERVER__CONFIG_FILE=/opt/airflow3/airflow_2.9.3/configs/webserver_config.py
AIRFLOW__WEBSERVER__BASE_URL=http://localhost:8080
AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE="America/Asuncion"
AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0
AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080
AIRFLOW__WEBSERVER__SESSION_BACKEND=database		# command <<--- airflow3 db clean --table session
AIRFLOW__WEBSERVER__WEB_SERVER_WORKER_TIMEOUT=120
AIRFLOW__WEBSERVER__WORKER_REFRESH_BATCH_SIZE=1
AIRFLOW__WEBSERVER__WORKER_REFRESH_INTERVAL=600
AIRFLOW__WEBSERVER__WORKERS=4
AIRFLOW__WEBSERVER__WORKER_CLASS=sync
AIRFLOW__WEBSERVER__EXPOSE_CONFIG=non-sensitive-only
AIRFLOW__WEBSERVER__EXPOSE_HOSTNAME=True
AIRFLOW__WEBSERVER__NAVBAR_COLOR=#fff
AIRFLOW__WEBSERVER__DEFAULT_DAG_RUN_DISPLAY_NUMBER=25
AIRFLOW__WEBSERVER__SHOW_RECENT_STATS_FOR_COMPLETED_RUNS=True
AIRFLOW__WEBSERVER__SESSION_LIFETIME_MINUTES=43200
AIRFLOW__WEBSERVER__INSTANCE_NAME=Proyecto Centro de Innovación TIC Paraguay-Corea
AIRFLOW__WEBSERVER__AUTO_REFRESH_INTERVAL=3

[scheduler]
AIRFLOW__SCHEDULER__JOB_HEARTBEAT_SEC=5
AIRFLOW__SCHEDULER__SCHEDULER_HEARTBEAT_SEC=5
AIRFLOW__SCHEDULER__SCHEDULER_HEALTH_CHECK_SERVER_PORT=8974
AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY=/opt/airflow3/airflow_2.9.3/logs/scheduler

[triggerer]
AIRFLOW__TRIGGERER__DEFAULT_CAPACITY=1000
AIRFLOW__TRIGGERER__JOB_HEARTBEAT_SEC=5
AIRFLOW__TRIGGERER__TRIGGERER_HEALTH_CHECK_THRESHOLD=30
```

---

## 20. Recursos oficiales

- Documentación Apache Airflow 2.9.3  
    [https://airflow.apache.org/docs/apache-airflow/2.9.3/index.html](https://airflow.apache.org/docs/apache-airflow/2.9.3/index.html)
    
- Repositorio oficial  
    [https://github.com/apache/airflow/tree/v2-9-stable](https://github.com/apache/airflow/tree/v2-9-stable)
    
- Constraints Python 3.12  
    [https://github.com/apache/airflow/blob/constraints-2.9.3/constraints-3.12.txt](https://github.com/apache/airflow/blob/constraints-2.9.3/constraints-3.12.txt)