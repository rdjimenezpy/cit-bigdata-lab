<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración de Apache Airflow 3.2.1 con PostgreSQL
**Entorno WSL2 · Ubuntu 22.04.5 LTS · Python 3.12.5 con pyenv · Apache Airflow 3.2.1 · PostgreSQL 15 · Despliegue aislado en `/opt/airflow`**

---

## Datos institucionales

**Institución:** Universidad Nacional de Asunción  
**Unidad Académica:** Facultad Politécnica  
**Dependencia:** Centro de Innovación TIC (PK)  
**Área:** Big Data   **Nivel:** Básico  
**Curso:** Introducción a Big Data   **Enfoque:** Fundamentos y Pipelines de Datos con Python  
**Docente:** Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción

---

## Fecha y versión

- **Fecha:** 11/05/2026
- **Versión:** 1.0

---

## Nota sobre esta documentación

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia del curso básico de **Introducción a Big Data** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

El documento toma como base la guía previa de instalación de **Apache Airflow 2.9.3**, pero no debe interpretarse como una simple actualización de número de versión. **Apache Airflow 3.x introduce cambios arquitectónicos relevantes**, especialmente en la separación de componentes, el uso de `airflow api-server`, el proceso independiente `airflow dag-processor`, la interfaz pública `airflow.sdk` para autoría de DAGs y el nuevo enfoque de autenticación.

Los pasos, comandos, rutas y configuraciones presentados fueron diseñados para un entorno de laboratorio controlado basado en:

- Windows 11 + WSL2;
- Ubuntu 22.04.5 LTS;
- Python 3.12.5 administrado con `pyenv`;
- PostgreSQL 15 como base de datos de metadatos;
- instalación aislada de Airflow bajo `/opt/airflow/airflow_3.2.1`.

Al replicar este material en otros equipos o servidores, pueden requerirse ajustes menores debido a diferencias de sistema operativo, permisos, red, políticas institucionales, versiones de software o restricciones de seguridad.

Ante diferencias puntuales durante la ejecución, se recomienda:

- leer cuidadosamente los mensajes de error;
- validar versiones de Python, Airflow y PostgreSQL;
- contrastar los comandos con la documentación oficial;
- documentar cualquier ajuste aplicado;
- no mezclar paquetes globales de Python con el entorno virtual de Airflow;
- y solicitar apoyo a través de los canales oficiales de la asignatura cuando corresponda.

---

## Tabla de contenido

1. [Introducción](#1-introducción)  
2. [Objetivos](#2-objetivos)  
3. [Alcance del tutorial](#3-alcance-del-tutorial)  
4. [Contexto técnico](#4-contexto-técnico)  
5. [Requisitos previos](#5-requisitos-previos)  
6. [Arquitectura o flujo de referencia](#6-arquitectura-o-flujo-de-referencia)  
7. [Convenciones usadas en el documento](#7-convenciones-usadas-en-el-documento)  
8. [Procedimiento paso a paso](#8-procedimiento-paso-a-paso)  
9. [Validación del resultado](#9-validación-del-resultado)  
10. [Problemas frecuentes y soluciones](#10-problemas-frecuentes-y-soluciones)  
11. [Buenas prácticas](#11-buenas-prácticas)  
12. [Conclusión](#12-conclusión)  
13. [Referencias](#13-referencias)  
14. [Anexo A — Comandos rápidos](#anexo-a--comandos-rápidos)  
15. [Anexo B — Plantillas systemd opcionales](#anexo-b--plantillas-systemd-opcionales)  

---

## 1. Introducción

Apache Airflow es una plataforma de orquestación de workflows basada en DAGs (*Directed Acyclic Graphs*). En ingeniería de datos se utiliza para definir, calendarizar, ejecutar, monitorear y administrar pipelines de datos, procesos ETL/ELT, integraciones entre sistemas, cargas analíticas y tareas operativas recurrentes.

En el contexto del curso **Introducción a Big Data**, Airflow permite que el estudiante comprenda un principio fundamental de la ingeniería de datos moderna: **un pipeline no es solamente un script que se ejecuta, sino un proceso administrado, observable, versionable, recuperable y gobernable**.

Apache Airflow **3.2.1** pertenece a la línea mayor 3.x, la cual consolida cambios introducidos desde Airflow 3.0: arquitectura más orientada a servicios, API Server, Task SDK, separación del procesamiento de DAGs y una interfaz pública más estable para la autoría de DAGs. Estos cambios hacen que el procedimiento recomendado difiera del enfoque clásico usado en Airflow 2.x.

Este tutorial instala Airflow 3.2.1 en un entorno local académico, usando PostgreSQL como base de datos de metadatos y una estructura aislada en `/opt/airflow` para evitar contaminación con paquetes globales o con otras versiones de Airflow.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- instalar Apache Airflow **3.2.1** de forma aislada y reproducible;
- usar un entorno virtual Python dedicado para Airflow;
- descargar y aplicar el archivo oficial de *constraints* para Python 3.12;
- configurar `AIRFLOW_HOME` y `AIRFLOW_CONFIG` bajo `/opt/airflow/airflow_3.2.1`;
- configurar PostgreSQL como base de datos de metadatos;
- inicializar o migrar el esquema de metadatos con `airflow db migrate`;
- ejecutar los componentes principales de Airflow 3.x: `api-server`, `scheduler`, `dag-processor` y `triggerer`;
- crear un DAG mínimo usando la interfaz pública `airflow.sdk`;
- validar el funcionamiento de la instalación desde CLI y desde la interfaz web;
- aplicar buenas prácticas mínimas para operación local, reproducibilidad y mantenimiento.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Apache Airflow  
**Versión objetivo:** 3.2.1  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Python de referencia:** Python 3.12.5 gestionado con `pyenv`  
**Base de datos de metadatos:** PostgreSQL 15  
**Entorno de trabajo:** `/opt/airflow/airflow_3.2.1`  
**IDE / cliente sugerido:** Terminal Bash, DBeaver Community, PyCharm o VS Code  
**Tipo de uso:** Instalación, configuración, validación y administración básica de laboratorio  

### Este tutorial cubre

- Instalación local con `pip` y archivo oficial de *constraints*.
- Configuración de directorios y variables de entorno.
- Uso de PostgreSQL como metadata database.
- Ejecución manual de los componentes principales de Airflow 3.2.1.
- Creación de un DAG académico mínimo con `airflow.sdk`.
- Validaciones básicas por CLI y navegador.
- Plantillas opcionales para `systemd`.

### Este tutorial no cubre

- Instalación productiva sobre Kubernetes o Helm Chart.
- Despliegue con CeleryExecutor, Redis, RabbitMQ o KubernetesExecutor.
- Alta disponibilidad del scheduler, API Server o base de datos.
- Integración con LDAP, OAuth2, SSO corporativo o proveedores externos de identidad.
- Configuración avanzada de logging remoto en S3, GCS, Elasticsearch u OpenSearch.
- Hardening completo de seguridad para producción.
- Migración automática desde una base real de Airflow 2.x a Airflow 3.x.

---

## 4. Contexto técnico

Dentro del stack académico de Big Data, Airflow cumple el rol de **orquestador de pipelines**. Su responsabilidad no es reemplazar a Python, SQL, PostgreSQL, DuckDB, Pentaho Data Integration, dbt o herramientas de visualización, sino coordinar su ejecución de forma ordenada.

Un flujo típico de laboratorio puede ser:

1. Descargar o recibir archivos fuente.
2. Validar estructura, codificación y disponibilidad.
3. Ingerir datos hacia una zona RAW.
4. Ejecutar limpieza y estandarización.
5. Aplicar transformaciones de modelo analítico.
6. Generar datamarts o tablas OBT.
7. Ejecutar controles de calidad.
8. Publicar resultados para análisis, visualización o ciencia de datos.

Airflow permite representar ese flujo como un DAG, definir dependencias explícitas entre tareas, programar ejecuciones, observar fallos, reintentar tareas y mantener trazabilidad operativa.

En Airflow 3.x hay cambios importantes frente a Airflow 2.x:

| Aspecto | Airflow 2.x | Airflow 3.x |
|---|---|---|
| Componente web principal | `airflow webserver` | `airflow api-server` |
| Procesamiento de DAGs | Integrado o menos explícito según despliegue | `airflow dag-processor` separado |
| Autoría recomendada de DAGs | `airflow.models`, `airflow.decorators` | `airflow.sdk` |
| Inicialización/migración de DB | `airflow db init` / `airflow db upgrade` en versiones antiguas | `airflow db migrate` |
| Autenticación por defecto | FAB en muchas instalaciones 2.x | Simple Auth Manager por defecto |
| Enfoque arquitectónico | Más monolítico | Más orientado a servicios |

La consecuencia práctica es clara: **una guía de Airflow 2.9.3 no debe reutilizarse sin ajustes para Airflow 3.2.1**.

---

## 5. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- WSL2 instalado y funcionando.
- Ubuntu 22.04.5 LTS o versión equivalente.
- Usuario Linux con permisos `sudo`.
- Python 3.12.5 instalado mediante `pyenv`.
- PostgreSQL 15 instalado y activo.
- Cliente `psql` disponible.
- Acceso a internet para descargar paquetes y el archivo oficial de *constraints*.
- Conocimientos básicos de terminal Linux, Python virtual environments y PostgreSQL.

### Verificaciones rápidas

```bash
lsb_release -a
uname -a

pyenv versions
python --version

# Servicio PostgreSQL ejecudandose en WSL/Ubuntu
psql --version
sudo systemctl status postgresql --no-pager

# Servicio PostgreSQL ejecudandose en Windows

# Obtener la IP de Windows desde WSL
ip route show | grep -i default | awk '{ print $3 }'

# Variables de conexión
PGHOST="172.24.16.1"
PGPORT="5432"
PGUSER="postgres"
PGDATABASE="postgres"

# Ejecutar psql y mostrar la versión
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT version();"
```

### Dependencias básicas del sistema

```bash
sudo apt update
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  libpq-dev \
  postgresql-client-15
```

**Explicación técnica:**  
Airflow se instala desde PyPI, pero algunos proveedores o dependencias pueden requerir compilación o librerías de sistema. `libpq-dev` es útil para integraciones PostgreSQL; `postgresql-client-15` permite validar conectividad con `psql`.

---

## 6. Arquitectura o flujo de referencia

La instalación local propuesta usa los siguientes componentes:

```text
Usuario / navegador
        │
        ▼
Apache Airflow API Server
        │
        ├── Scheduler
        │
        ├── DAG Processor
        │
        ├── Triggerer
        │
        └── Metadata Database PostgreSQL

DAGs del curso
        │
        ├── Python
        ├── SQL
        ├── scripts Bash
        ├── Pentaho / procesos externos
        └── herramientas analíticas del laboratorio
```

Estructura de referencia:

```text
/opt/airflow/
└── airflow_3.2.1/
    ├── venv/
    ├── configs/
    │   ├── airflow_lab.cfg
    │   ├── airflow3_lab.env
    │   └── simple_auth_manager_passwords.json.generated
    ├── dags/
    ├── logs/
    ├── plugins/
    ├── scripts/
    │   └── activate_airflow_3.2.1.sh
    ├── data/
    │   └── constraints-3.12.txt
    └── outputs/
```

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal Bash.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno de trabajo.
- `{{valor}}` → valor que debe ser reemplazado por el usuario.
- `SQL` → sentencia a ejecutar en PostgreSQL mediante `psql`.
- `INI` → configuración de Airflow o archivo de entorno.
- `LAB` → nombre lógico del entorno de laboratorio.

Variables utilizadas en los ejemplos:

| Variable          | Valor de referencia                                  |
| ----------------- | ---------------------------------------------------- |
| `AIRFLOW_VERSION` | `3.2.1`                                              |
| `PYTHON_VERSION`  | `3.12`                                               |
| `AIRFLOW_BASE`    | `/opt/airflow`                                       |
| `AIRFLOW_HOME`    | `/opt/airflow/airflow_3.2.1`                         |
| `AIRFLOW_CONFIG`  | `/opt/airflow/airflow_3.2.1/configs/airflow_lab.cfg` |
| `AIRFLOW_PORT`    | `8080`                                               |
| `POSTGRES_DB`     | `airflow3_meta`                                      |
| `POSTGRES_USER`   | `airflow3`                                           |
| `POSTGRES_SCHEMA` | `airflow3_metastore`                                 |

---

## 8. Procedimiento paso a paso

### Paso 1 — Crear la estructura base de Airflow 3.2.1

**Objetivo del paso:** preparar una instalación aislada para Airflow 3.2.1 sin interferir con versiones previas.

**Instrucciones:**

```bash
sudo mkdir -p /opt/airflow3
sudo chown -R "$USER:$USER" /opt/airflow3

mkdir -p /opt/airflow3/airflow_3.2.1/{venv,configs,dags,logs,plugins,scripts,data,outputs}
```

**Explicación técnica:**  
Cada versión de Airflow debe vivir en su propio directorio. Esto permite comparar versiones, migrar con menor riesgo y eliminar una instalación sin romper otra.

**Resultado esperado:**

```bash
ls -la /opt/airflow3/airflow_3.2.1
```

Debe observarse una estructura con carpetas `venv`, `configs`, `dags`, `logs`, `plugins`, `scripts`, `data` y `outputs`.

---

### Paso 2 — Seleccionar Python 3.12.5 con pyenv

**Objetivo del paso:** asegurar que el entorno virtual se cree con la versión correcta de Python.

**Instrucciones:**

```bash
pyenv shell 3.12.5
python --version
```

**Resultado esperado:**

```text
Python 3.12.5
```

**Observación crítica:**  
No conviene instalar Airflow con el Python global del sistema si se busca reproducibilidad. El aislamiento del runtime es una condición básica para evitar conflictos de dependencias.

---

### Paso 3 — Crear el entorno virtual dedicado

**Objetivo del paso:** crear un entorno Python exclusivo para Airflow 3.2.1.

**Instrucciones:**

```bash
python -m venv /opt/airflow3/airflow_3.2.1/venv
source /opt/airflow3/airflow_3.2.1/venv/bin/activate

python --version
which python
which pip
```

**Resultado esperado:**

```text
/opt/airflow/airflow_3.2.1/venv/bin/python
/opt/airflow/airflow_3.2.1/venv/bin/pip
```

---

### Paso 4 — Crear el script de activación del entorno

**Objetivo del paso:** facilitar la activación repetible del entorno de Airflow.

**Archivo:**  
`/opt/airflow/airflow_3.2.1/scripts/activate_airflow3_lab.sh`

**Instrucciones:**

```bash
cat > /opt/airflow3/airflow_3.2.1/scripts/activate_airflow3_lab.sh <<'EOF_SCRIPT'
#!/bin/bash

source /opt/airflow/airflow_3.2.1/venv/bin/activate

export AIRFLOW_HOME=/opt/airflow/airflow_3.2.1
export AIRFLOW_CONFIG=/opt/airflow/airflow_3.2.1/configs/airflow_lab.cfg
export AIRFLOW_VERSION=3.2.1
export PYTHON_VERSION=3.12
export POSTGRES_IPHOST=172.24.16.1
export POSTGRES_PORT=5432

cd /opt/airflow/airflow_3.2.1

echo "Instancia de Apache Airflow ${AIRFLOW_VERSION} activado."
echo "Entorno: Laboratorio"
echo "Repositorio: cit-bigdata-lab/main"
echo "AIRFLOW_HOME=${AIRFLOW_HOME}"
echo "AIRFLOW_CONFIG=${AIRFLOW_CONFIG}"
echo "AIRFLOW_DAGS_FOLDER=${AIRFLOW__CORE__DAGS_FOLDER}"
echo "AIRFLOW_PORT=$AIRFLOW__API__PORT"
EOF_SCRIPT
```

Luego:

```bash
chmod +x /opt/airflow3/airflow_3.2.1/scripts/activate_airflow3_lab.sh
```

Activar:

```bash
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow3_lab.sh
```

**Resultado esperado:**  
El prompt debe quedar dentro del entorno virtual y las variables `AIRFLOW_HOME` y `AIRFLOW_CONFIG` deben apuntar a la instalación 3.2.1.

---

### Paso 5 — Crear un alias de activación rápida

**Objetivo del paso:** permitir activar Airflow 3.2.1 con un comando corto.

**Instrucciones:**

```bash
cat >> ~/.bashrc <<'EOF_ALIAS'

# Apache Airflow 3.2.1 - laboratorio CIT Big Data
alias airflow3-lab='source /opt/airflow/airflow_3.2.1/scripts/activate_airflow3_lab.sh'
EOF_ALIAS
```

Luego:

```bash
source ~/.bashrc
```

Verificar:

```bash
airflow3-lab
```

**Resultado esperado:**  
Al ejecutar `airflow3`, se activa el entorno virtual y se configuran las variables principales.

---

### Paso 6 — Descargar el archivo oficial de constraints para Python 3.12

**Objetivo del paso:** garantizar una instalación reproducible usando el archivo oficial de restricciones de dependencias de Airflow 3.2.1.

**Instrucciones:**

```bash
cd /opt/airflow3/airflow_3.2.1/data

curl -fL \
  "https://raw.githubusercontent.com/apache/airflow/constraints-3.2.1/constraints-3.12.txt" \
  -o constraints-3.12.txt

head -n 5 constraints-3.12.txt
```

**Explicación técnica:**  
Airflow es al mismo tiempo una aplicación y una librería Python. Por eso, una instalación sin *constraints* puede resolver dependencias incompatibles. El archivo `constraints-3.12.txt` congela una combinación probada de paquetes para Airflow 3.2.1 sobre Python 3.12.

**Resultado esperado:**  
Debe existir el archivo:

```bash
ls -lh /opt/airflow3/airflow_3.2.1/data/constraints-3.12.txt
```

---

### Paso 7 — Actualizar herramientas base de Python

**Objetivo del paso:** instalar versiones recientes de `pip`, `setuptools` y `wheel` dentro del entorno virtual.

**Instrucciones:**

```bash
pip install --upgrade pip setuptools wheel
pip --version
```

**Resultado esperado:**  
`pip` debe ejecutarse desde `/opt/airflow/airflow_3.2.1/venv/bin/pip`.

---

### Paso 8 — Instalar Apache Airflow 3.2.1 con extras recomendados

**Objetivo del paso:** instalar Airflow con proveedores y extras adecuados para un laboratorio de ingeniería de datos.

**Instrucciones:**

```bash
export AIRFLOW_VERSION=3.2.1
export PYTHON_VERSION="$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
export CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

pip install \
  "apache-airflow[async,standard,postgres,statsd,sftp,fab,pandas]==${AIRFLOW_VERSION}" \
  --constraint "${CONSTRAINT_URL}"
```

**Extras usados:**

| Extra      | Uso                                                                                 |
| ---------- | ----------------------------------------------------------------------------------- |
| `async`    | Workers asíncronos para Gunicorn/API Server.                                        |
| `standard` | Operadores y hooks estándar.                                                        |
| `postgres` | Integración con PostgreSQL.                                                         |
| `statsd`   | Métricas vía StatsD.                                                                |
| `sftp`     | Hooks, operadores y sensores SFTP.                                                  |
| `fab`      | Flask AppBuilder Auth Manager para gestión clásica de usuarios y roles.             |
| `pandas`   | Para manipular, limpiar y analizar datos estructurados de forma rápida y eficiente. |

**Validación:**

```bash
which airflow3
airflow3 version
pip check
```

**Resultado esperado:**

```text
/opt/airflow/airflow_3.2.1/venv/bin/airflow
3.2.1
No broken requirements found.
```

**Advertencia técnica:**  
No instalar dependencias adicionales mezcladas en el mismo comando inicial si no son necesarias. Primero se instala Airflow con *constraints*. Luego, si se requieren paquetes extra del laboratorio, se instalan en comandos separados fijando `apache-airflow==3.2.1` para evitar actualizaciones o degradaciones accidentales.

Ejemplo:

```bash
pip install "apache-airflow==3.2.1" duckdb python-dotenv
```

---

### Paso 9 — Generar configuración inicial de Airflow

**Objetivo del paso:** crear `airflow_lab.cfg` en la ruta de entorno definida (`AIRFLOW_CONFIG`).

**Instrucciones:**

```bash
airflow3 config list --defaults > /opt/airflow3/airflow_3.2.1/configs/airflow_lab.cfg

airflow3 db check || true
```

**Inicializar el archivo `airflow_lab.cfg`:**

- Airflow genera automáticamente el archivo `airflow.cfg` con los valores predeterminados la primera vez que se invoca un 
comando si detecta que el archivo no existe en la ruta especificada. Puedes usar un comando inofensivo como `airflow version` o `airflow info`

**Consideraciones para Airflow 3.1.8:**

* **Aislamiento:** Al usar una ruta personalizada fuera del `$AIRFLOW_HOME` estándar, asegúrese de que sus sesiones de terminal siempre tengan cargada la variable `AIRFLOW_CONFIG` para que Airflow reconozca sus ajustes.
* **Actualización de parámetros (2.x --> 3.x):** Una vez creado el archivo `airflow.cfg`, se recomienda ejecutar el comando `airflow config update --fix`. Este comando ajustará automáticamente el contenido de su nuevo `airflow.cfg` para que sea plenamente compatible con la arquitectura de la versión 3.0+, como el cambio de nomenclatura de `webserver` a `api_server`. Este comando está diseñado para facilitar la migración de tu archivo de configuración (`airflow.cfg`) de la versión 2.x a la 3.0+.

---

### Paso 10 — Crear base de datos y usuario PostgreSQL

**Objetivo del paso:** configurar PostgreSQL como base de datos de metadatos para Airflow. Cada estudiante puede decidir si utilizar una instancia de PostgreSQL 15 en su entorno de WSL o directamente en Windows. En este tutorial, el profesor eligió desplegar PostgreSQL en el entorno de Windows.

Ejecutar las siguientes instrucciones:

```sql
# Paso 1. Crear usuario y credencial para la base de datos metadata de airflow
CREATE USER airflow3 WITH PASSWORD 'airflow3_lab_pass';

# Paso 2. Crear la base de datos para guardar el metada de airflow3
CREATE DATABASE airflow3_meta OWNER airflow3;

# Paso 3. Crear el esquema para la instancia de airflow3-lab
CREATE SCHEMA IF NOT EXISTS airflow3_lab_metastore AUTHORIZATION airflow3;

# Paso 4. Privilegios para crear las tablas de airflow3 en el esquema airflow3_lab
GRANT ALL PRIVILEGES ON SCHEMA airflow3_lab_metastore TO airflow3;
ALTER ROLE airflow3 SET search_path = airflow3_lab_metastore, public;
```

**Validación:**

```bash
psql "postgresql://airflow3:airflow3_lab_pass@172.24.16.1:5432/airflow3_meta" \
  -c "SELECT current_database(), current_user, current_schema();"
```

**Resultado esperado:**  
Debe conectarse sin error y mostrar la base `airflow3_meta`, el usuario `airflow3` y el esquema `airflow3_metastore`.

**Advertencia:**  
La contraseña usada en este tutorial es didáctica. En un ambiente institucional real debe reemplazarse por una contraseña robusta y gestionarse mediante variables de entorno, gestor de secretos o política interna de credenciales.

---

### Paso 11 — Crear archivo de variables de entorno del laboratorio

**Objetivo del paso:** centralizar la configuración del entorno sin editar manualmente todo el archivo `airflow.cfg`.

**Archivo:**  
`/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`

**Instrucciones:**

```bash
cat > /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env <<'EOF_ENV'
# ==========================================================
# Apache Airflow 3.2.1 - entorno LAB
# ==========================================================

AIRFLOW_HOME=/opt/airflow/airflow_3.2.1
AIRFLOW_CONFIG=/opt/airflow/airflow_3.2.1/configs/airflow_lab.cfg

# Core
AIRFLOW__CORE__DAGS_FOLDER=/opt/repo/cit-bigdata-lab/orchestration/airflow3/dags
AIRFLOW__CORE__PLUGINS_FOLDER=/opt/airflow/airflow_3.2.1/plugins
AIRFLOW__CORE__DEFAULT_TIMEZONE=America/Asuncion
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__CORE__LOAD_EXAMPLES=False # True para cargar y mirar lois DAGs de ejemplos
AIRFLOW__CORE__PARALLELISM=16
AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG=8
AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG=4
AIRFLOW__CORE__EXECUTION_API_SERVER_URL=http://localhost:8080/execution/

# Auth Manager por defecto en Airflow 3.x: SimpleAuthManager
# Para laboratorio local controlado se define un usuario administrador simple.
AIRFLOW__CORE__AUTH_MANAGER=airflow.api_fastapi.auth.managers.simple.simple_auth_manager.SimpleAuthManager
AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:admin
AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_ALL_ADMINS=False

# Metadata database PostgreSQL
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow3:airflow3_lab_pass@172.24.16.1:5432/airflow3_meta
AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA=airflow3_lab_metastore
AIRFLOW__DATABASE__SQL_ENGINE_ENCODING=utf-8
AIRFLOW__DATABASE__SQL_ALCHEMY_POOL_PRE_PING=True

# Logging local
AIRFLOW__LOGGING__BASE_LOG_FOLDER=/opt/airflow/airflow_3.2.1/logs
AIRFLOW__LOGGING__LOGGING_LEVEL=WARNING
AIRFLOW__LOGGING__FAB_LOGGING_LEVEL=WARNING
AIRFLOW__LOGGING__DAG_PROCESSOR_CHILD_PROCESS_LOG_DIRECTORY=/opt/airflow/airflow_3.2.1/logs/dag_processor

# Metrics desactivadas por defecto para laboratorio local
AIRFLOW__METRICS__STATSD_ON=False

# API Server
AIRFLOW__API__HOST=0.0.0.0
AIRFLOW__API__PORT=8081

# Definir usuario y grupo Linux para los servicios
AIRFLOW_SERVICE_USER="$(id -un)"
AIRFLOW_SERVICE_GROUP="$(id -gn)"
EOF_ENV
```

Luego:

```bash
chmod 600 /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
```

Cargar variables en la sesión actual:

```bash
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

**Validación:**

```bash
airflow3 config get-value core executor
airflow3 config get-value database sql_alchemy_conn
airflow3 config get-value core auth_manager
```

**Resultado esperado:**

```text
LocalExecutor
postgresql+psycopg2://airflow3:airflow3_lab_pass@172.24.16.1:5432/airflow3_meta
airflow.api_fastapi.auth.managers.simple.simple_auth_manager.SimpleAuthManager
```

---

### Paso 12 — Alternativa de autenticación con FAB Auth Manager (Opcional)

**Objetivo del paso:** documentar la alternativa clásica de usuarios, roles y permisos mediante Flask AppBuilder.

Airflow 3.x usa `SimpleAuthManager` por defecto. Si se desea mantener una experiencia más parecida a Airflow 2.x con el comando `airflow users create`, debe usarse FAB.

**Configurar FAB:**

```bash
export AIRFLOW__CORE__AUTH_MANAGER=airflow3.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
```

O editar `airflow3_lab.env`:

```bash
AIRFLOW__CORE__AUTH_MANAGER=airflow3.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
```

Luego cargar de nuevo variables:

```bash
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

**Advertencia crítica:**  
No cambiar de `SimpleAuthManager` a `FabAuthManager` en un entorno con usuarios reales sin plan de migración. El modelo de autenticación afecta experiencia de inicio de sesión, permisos y administración de usuarios.

---

### Paso 13 — Inicializar o migrar la base de metadatos

**Pre-requisito:**

```bash
# Cargar las variables de la instancia de airflow3-lab
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env

# Verificar conexión a la base de datos configurado en AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
airflow3 db check
```

**Objetivo del paso:** crear las tablas internas de Airflow en PostgreSQL.

**Instrucciones:**

```bash
airflow3 db migrate
```

**Explicación técnica:**  
En Airflow moderno se debe usar `airflow db migrate`. Los comandos antiguos como `airflow db init` o `airflow db upgrade` pertenecen a prácticas previas y no deben ser la opción principal para Airflow 3.2.1.

**Validación:**

```bash
psql "postgresql://airflow3:airflow3_lab_pass@$POSTGRES_IPHOST:$POSTGRES_PORT/airflow3_meta" \
  -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'airflow3_lab_metastore' ORDER BY tablename LIMIT 10;"
```

**Resultado esperado:**  
Deben existir tablas internas de Airflow dentro del esquema `airflow3_metastore`.

---

### Paso 14 — Crear usuario administrador si se usa FAB (Opcional. Si se optó por el Paso 12)

**Objetivo del paso:** crear un usuario administrador para la interfaz web cuando se usa `FabAuthManager`.

**Aplicar solo si `auth_manager` es FAB:**

```bash
airflow3 config get-value core auth_manager
```

Debe devolver:

```text
airflow.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
```

Crear usuario:

```bash
airflow3 users create \
  --username admin \
  --firstname Admin \
  --lastname CIT \
  --role Admin \
  --email admin@example.org \
  --password admin
```

**Si se usa `SimpleAuthManager`:**  
No usar `airflow users create`. En ese caso el usuario se controla con:

```bash
AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:admin
```

La contraseña será generada o administrada por el Simple Auth Manager según la configuración del entorno.

---

### Paso 15 — Ejecutar prueba rápida con standalone (Opcional)

**Objetivo del paso:** validar que Airflow puede iniciar en modo local todo-en-uno.

**Instrucciones:**

```bash
airflow3 standalone
```

**Explicación técnica:**  
`airflow standalone` inicializa la base, crea un usuario y levanta los componentes principales para pruebas locales. Es útil para validación rápida, pero **no debe ser el modo de operación recomendado para un despliegue controlado**.

**Acceso web:**

```text
http://localhost:8080
```

Detener con `CTRL + C` una vez validado.

---

### Paso 16 — Ejecutar componentes principales por separado (Recomendado)


**Objetivo del paso:** ejecutar Airflow 3.2.1 de forma más cercana a un despliegue controlado.

**Pre-requisitos:**

Abrir cuatro terminales distintas. En cada una ejecutar:

```bash
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

#### Terminal 1 — API Server

```bash
airflow3 api-server -D --host 0.0.0.0 --port 8080
```

#### Terminal 2 — Scheduler

```bash
airflow3 scheduler -D
```

#### Terminal 3 — DAG Processor

```bash
airflow3 dag-processor -D
```

#### Terminal 4 — Triggerer

```bash
airflow3 triggerer -D
```

**Resultado esperado:**  
La interfaz debe estar disponible en:

```text
http://localhost:8080
```

**Observación crítica:**  
En Airflow 3.x, el `dag-processor` ya no debe ignorarse. Si este proceso no está activo, la detección y procesamiento de DAGs puede fallar o quedar incompleta.

---

### Paso 17 — Crear un DAG mínimo usando `airflow.sdk`

**Objetivo del paso:** validar la autoría de DAGs usando la interfaz pública recomendada en Airflow 3.x.

**Archivo:**  
`/opt/airflow/airflow_3.2.1/dags/cit_validacion_airflow3.py`

**Instrucciones:**

```bash
cat > /opt/airflow3/airflow_3.2.1/dags/cit_validacion_airflow3.py <<'EOF_DAG'
from __future__ import annotations

import pendulum
from airflow.sdk import dag, task


@dag(
    dag_id="cit_validacion_airflow3",
    schedule="@daily",
    start_date=pendulum.datetime(2026, 1, 1, tz="America/Asuncion"),
    catchup=False,
    tags=["cit", "bigdata", "airflow3"],
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
EOF_DAG
```

**Validar importación del DAG:**

```bash
python /opt/airflow3/airflow_3.2.1/dags/cit_validacion_airflow3.py
airflow3 dags list | grep cit_validacion_airflow3
```

**Resultado esperado:**  
El DAG `cit_validacion_airflow3` debe aparecer listado en Airflow.

---

### Paso 18 — Ejecutar prueba de tarea y DAG

**Objetivo del paso:** comprobar que las tareas se pueden ejecutar.

**Instrucciones:**

```bash
airflow3 tasks list cit_validacion_airflow3

airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01
```

Ejecutar un DAG manualmente desde CLI:

```bash
airflow3 dags trigger cit_validacion_airflow3
```

Ver estado:

```bash
airflow3 dags list-runs -d cit_validacion_airflow3
```

**Resultado esperado:**  
Debe observarse una ejecución del DAG y logs asociados en `/opt/airflow/airflow_3.2.1/logs`.

---

### Paso 19 — Configurar instalación de paquetes adicionales del laboratorio

**Objetivo del paso:** instalar dependencias útiles sin romper la instalación base de Airflow.

**Instrucciones:**

```bash
pip install \
  "apache-airflow==3.2.1" \
  pandas \
  duckdb \
  python-dotenv

pip check
```

**Explicación técnica:**  
Luego de instalar Airflow con *constraints*, las dependencias adicionales deben instalarse en comandos separados. Se fija `apache-airflow==3.2.1` para evitar que `pip` cambie accidentalmente la versión de Airflow al resolver dependencias.

---

### Paso 20 — Comandos de administración básica

**Objetivo del paso:** disponer de comandos frecuentes para operación local.

```bash
# Activar entorno
airflow3

# Ver versión
airflow3 version

# Ver configuración efectiva
airflow3 config list

# Ver un valor específico
airflow3 config get-value core executor
airflow3 config get-value core auth_manager
airflow3 config get-value database sql_alchemy_conn

# Validar base de datos
airflow3 db check

# Aplicar migraciones
airflow3 db migrate

# Listar DAGs
airflow3 dags list

# Listar tareas de un DAG
airflow3 tasks list cit_validacion_airflow3

# Probar una tarea
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01

# Lanzar un DAG manualmente
airflow3 dags trigger cit_validacion_airflow3

# Listar ejecuciones
airflow3 dags list-runs -d cit_validacion_airflow3
```

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- Airflow 3.2.1 está instalado dentro del entorno virtual correcto.
- `pip check` no reporta dependencias rotas.
- PostgreSQL acepta conexión desde el usuario `airflow3`.
- `airflow db migrate` crea las tablas internas en el esquema definido.
- `airflow api-server`, `airflow scheduler`, `airflow dag-processor` y `airflow triggerer` inician sin errores críticos.
- La interfaz web responde en `http://localhost:8080`.
- El DAG `cit_validacion_airflow3` aparece en la lista de DAGs.
- Al menos una tarea se ejecuta correctamente con `airflow tasks test`.

### Comandos de validación

```bash
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

which airflow3
airflow3 version
pip check

airflow3 db check
airflow3 config get-value core executor
airflow3 config get-value core auth_manager
airflow3 dags list | grep cit_validacion_airflow3
```

### Evidencia esperada

```text
/opt/airflow/airflow_3.2.1/venv/bin/airflow
3.2.1
No broken requirements found.
LocalExecutor
cit_validacion_airflow3
```

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `airflow: command not found` | Entorno virtual no activado o PATH incorrecto | Ejecutar `airflow3` o `source /opt/airflow/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh` |
| Airflow instala otra versión | `pip` resolvió dependencias sin fijar versión | Reinstalar usando `apache-airflow==3.2.1` y el archivo oficial de *constraints* |
| `pip check` muestra conflictos | Dependencias adicionales rompieron el entorno | Revisar último paquete instalado, desinstalarlo o crear un entorno limpio |
| Error de conexión a PostgreSQL | Usuario, contraseña, host, puerto o base incorrectos | Validar con `psql "postgresql://airflow3:airflow3_lab_pass@localhost:5432/airflow3_meta"` |
| Tablas no aparecen en el esquema esperado | `SQL_ALCHEMY_SCHEMA` no fue configurado o no se cargó el `.env` | Cargar `airflow3_lab.env` y ejecutar `airflow db migrate` |
| `airflow users create` no existe o falla | Se está usando `SimpleAuthManager` | Usar `FabAuthManager` o administrar usuarios mediante variables del Simple Auth Manager |
| DAG no aparece en la UI | `dag-processor` detenido, error de importación o archivo fuera de `dags_folder` | Ejecutar `airflow dag-processor`, revisar `airflow dags list-import-errors` y validar el archivo Python |
| El puerto 8080 está ocupado | Otro servicio usa el mismo puerto | Usar `lsof -i :8080` y cambiar puerto con `airflow api-server --port 8081` |
| El DAG falla al importar `airflow.sdk` | Instalación incompleta o versión incorrecta | Verificar `airflow version` y reinstalar Airflow 3.2.1 |
| WSL no responde desde navegador Windows | Problema de redirección o firewall local | Probar `localhost:8080`, `127.0.0.1:8080` y revisar reglas de firewall |

---

## 11. Buenas prácticas

- Mantener cada versión de Airflow en un directorio independiente: `/opt/airflow/airflow_X.Y.Z`.
- No instalar Airflow en el Python global del sistema.
- Usar siempre el archivo oficial de *constraints* correspondiente a la versión de Airflow y Python.
- Ejecutar `pip check` después de instalar paquetes adicionales.
- No mezclar dependencias del proyecto de datos con dependencias internas de Airflow si pueden entrar en conflicto.
- Usar `airflow.sdk` para nuevos DAGs en Airflow 3.x.
- Evitar acceso directo desde tareas al metadata database de Airflow.
- Mantener `dags`, `plugins`, `logs` y `configs` separados.
- No usar credenciales débiles fuera de laboratorios locales.
- No usar `airflow standalone` como modo operativo permanente.
- Ejecutar `api-server`, `scheduler`, `dag-processor` y `triggerer` como procesos separados para entender la arquitectura real.
- Documentar toda modificación local de configuración.
- Versionar DAGs, scripts y configuraciones no sensibles en Git.
- Excluir credenciales, logs y archivos generados del repositorio.

Ejemplo recomendado de `.gitignore` para una carpeta de laboratorio:

```gitignore
# Airflow runtime
logs/
*.pid
*.db
*.sqlite
simple_auth_manager_passwords.json.generated

# Python
venv/
__pycache__/
*.pyc

# Secrets
.env
*.env
!example.env

# Outputs temporales
outputs/
tmp/
```

---

## 12. Conclusión

Con este procedimiento se deja preparada una instalación académica y reproducible de **Apache Airflow 3.2.1** sobre **Python 3.12.5**, usando **PostgreSQL 15** como base de metadatos y una estructura profesional bajo `/opt/airflow`.

El punto más importante no es solo que Airflow quede instalado, sino que el estudiante comprenda la lógica operativa detrás del orquestador: separación de componentes, dependencia de la base de metadatos, control de configuración, reproducibilidad de dependencias, autoría de DAGs con interfaz estable y validación del pipeline desde CLI y UI.

El siguiente paso recomendado es construir un DAG real del curso que integre descarga de archivos, validación de codificación, ingesta a una zona RAW, ejecución SQL de transformación y generación de controles de calidad.

---

## 13. Referencias

1. Apache Airflow. **Apache Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/

2. Apache Airflow. **Installation of Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/installation/index.html

3. Apache Airflow. **Installation from PyPI — Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/installation/installing-from-pypi.html

4. Apache Airflow. **Setting up the database — Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/installation/setting-up-the-database.html

5. Apache Airflow. **Release Notes — Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/release_notes.html

6. Apache Airflow. **Apache Airflow Task SDK Documentation**.  
   https://airflow.apache.org/docs/task-sdk/stable/index.html

7. Apache Airflow. **Constraints file for Airflow 3.2.1 and Python 3.12**.  
   https://raw.githubusercontent.com/apache/airflow/constraints-3.2.1/constraints-3.12.txt

---

## Anexo A — Comandos rápidos

```bash
# Activar entorno
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh

# Cargar variables del laboratorio
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

# Verificar versión
airflow3 version

# Validar base
airflow3 db check

# Migrar metadata database
airflow3 db migrate

# Ejecutar componentes principales
# Terminal 1
airflow3 api-server --host 0.0.0.0 --port 8080

# Terminal 2
airflow3 scheduler

# Terminal 3
airflow3 dag-processor

# Terminal 4
airflow3 triggerer

# Validar DAGs
airflow3 dags list

# Probar tarea
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01

# Disparar DAG
airflow3 dags trigger cit_validacion_airflow3
```

---

## Anexo B — Plantillas systemd opcionales

> Uso recomendado solo después de validar manualmente la instalación. En WSL2, `systemd` debe estar habilitado. En servidores Linux tradicionales, ajustar el usuario, rutas y políticas internas.

### 1. Archivo de entorno para systemd

Usar el mismo archivo:

```text
/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
```

Asegurar permisos:

```bash
chmod 600 /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
```

### 2. Servicio API Server

Archivo:

```text
/etc/systemd/system/airflow3-api-server.service
```

Contenido:

```ini
[Unit]
Description=Apache Airflow 3.2.1 API Server
After=network.target postgresql.service

[Service]
Type=simple
User={{usuario_linux}}
Group={{grupo_linux}}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow api-server --host 0.0.0.0 --port 8080
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 3. Servicio Scheduler

Archivo:

```text
/etc/systemd/system/airflow3-scheduler.service
```

Contenido:

```ini
[Unit]
Description=Apache Airflow 3.2.1 Scheduler
After=network.target postgresql.service airflow3-api-server.service

[Service]
Type=simple
User={{usuario_linux}}
Group={{grupo_linux}}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow scheduler
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 4. Servicio DAG Processor

Archivo:

```text
/etc/systemd/system/airflow3-dag-processor.service
```

Contenido:

```ini
[Unit]
Description=Apache Airflow 3.2.1 DAG Processor
After=network.target postgresql.service airflow3-api-server.service

[Service]
Type=simple
User={{usuario_linux}}
Group={{grupo_linux}}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow dag-processor
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 5. Servicio Triggerer

Archivo:

```text
/etc/systemd/system/airflow3-triggerer.service
```

Contenido:

```ini
[Unit]
Description=Apache Airflow 3.2.1 Triggerer
After=network.target postgresql.service airflow3-api-server.service

[Service]
Type=simple
User={{usuario_linux}}
Group={{grupo_linux}}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow triggerer
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 6. Activar servicios

Reemplazar primero `{{usuario_linux}}` y `{{grupo_linux}}` por el usuario real del sistema.

```bash
sudo systemctl daemon-reload

sudo systemctl start airflow3-api-server
sudo systemctl start airflow3-scheduler
sudo systemctl start airflow3-dag-processor
sudo systemctl start airflow3-triggerer

sudo systemctl status airflow3-api-server --no-pager
sudo systemctl status airflow3-scheduler --no-pager
sudo systemctl status airflow3-dag-processor --no-pager
sudo systemctl status airflow3-triggerer --no-pager
```

### 7. Ver logs

```bash
sudo journalctl -u airflow3-api-server -f
sudo journalctl -u airflow3-scheduler -f
sudo journalctl -u airflow3-dag-processor -f
sudo journalctl -u airflow3-triggerer -f
```

### 8. Detener servicios

```bash
sudo systemctl stop airflow3-triggerer
sudo systemctl stop airflow3-dag-processor
sudo systemctl stop airflow3-scheduler
sudo systemctl stop airflow3-api-server
```

### 9. Nota operativa

Para un laboratorio académico en WSL2, no se recomienda habilitar automáticamente los servicios al arranque si el objetivo es preservar recursos. Es preferible iniciarlos manualmente cuando se trabaja con los laboratorios de orquestación.

```bash
# Solo si se desea arranque automático
sudo systemctl enable airflow3-api-server
sudo systemctl enable airflow3-scheduler
sudo systemctl enable airflow3-dag-processor
sudo systemctl enable airflow3-triggerer
```
