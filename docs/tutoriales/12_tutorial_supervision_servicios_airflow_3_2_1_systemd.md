<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Tutorial paso a paso: Supervisión y administración de servicios de Apache Airflow 3.2.1 con systemd
**Entorno WSL2 · Ubuntu 22.04.5 LTS · Python 3.12.5 con pyenv · Apache Airflow 3.2.1 · PostgreSQL 15 · Servicios systemd para `api-server`, `scheduler`, `dag-processor` y `triggerer`**

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

Este tutorial fue elaborado para complementar el documento **`11_tutorial_instalacion_configuracion_apache_airflow_3_2_1.md`**, donde se instala Apache Airflow **3.2.1** en el entorno académico de referencia del curso **Introducción a Big Data**.

El documento anterior de supervisión con `systemd` estaba orientado a **Apache Airflow 2.9.3**, por lo que no debe reutilizarse literalmente para Airflow 3.x. En Airflow 3.x existen cambios operativos relevantes:

- el componente `airflow webserver` deja de ser el proceso principal de interfaz y se reemplaza por `airflow api-server`;
- el procesamiento de DAGs se ejecuta como servicio independiente mediante `airflow dag-processor`;
- los servicios mínimos recomendados para una operación controlada son `api-server`, `scheduler`, `dag-processor` y `triggerer`;
- las variables de configuración asociadas al antiguo bloque `[webserver]` ya no deben trasladarse sin revisión a Airflow 3.x;
- el archivo de entorno usado por el laboratorio es `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`.

Los pasos, comandos y archivos de unidad presentados aquí están diseñados para un entorno de laboratorio controlado basado en:

- Windows 11 + WSL2;
- Ubuntu 22.04.5 LTS;
- Python 3.12.5 administrado con `pyenv`;
- PostgreSQL 15 como base de datos de metadatos;
- Apache Airflow 3.2.1 instalado en `/opt/airflow/airflow_3.2.1`;
- ejecución administrada mediante `systemd`.

En un servidor institucional o ambiente productivo, se deben revisar permisos, usuarios de servicio, gestión de secretos, rotación de logs, monitoreo, hardening y políticas internas de seguridad.

---

## Tabla de contenido

1. [Introducción](#1-introducción)  
2. [Objetivos](#2-objetivos)  
3. [Alcance del tutorial](#3-alcance-del-tutorial)  
4. [Contexto técnico](#4-contexto-técnico)  
5. [Requisitos previos](#5-requisitos-previos)  
6. [Arquitectura de servicios de referencia](#6-arquitectura-de-servicios-de-referencia)  
7. [Convenciones usadas en el documento](#7-convenciones-usadas-en-el-documento)  
8. [Procedimiento paso a paso](#8-procedimiento-paso-a-paso)  
9. [Validación del resultado](#9-validación-del-resultado)  
10. [Problemas frecuentes y soluciones](#10-problemas-frecuentes-y-soluciones)  
11. [Buenas prácticas](#11-buenas-prácticas)  
12. [Conclusión](#12-conclusión)  
13. [Referencias](#13-referencias)  
14. [Anexo A — Comandos rápidos de administración](#anexo-a--comandos-rápidos-de-administración)  
15. [Anexo B — Plantillas systemd multi-entorno](#anexo-b--plantillas-systemd-multi-entorno)  

---

## 1. Introducción

En una instalación manual de Apache Airflow, es común iniciar los procesos principales desde varias terminales:

```bash
airflow3 api-server --host 0.0.0.0 --port 8080
airflow3 scheduler
airflow3 dag-processor
airflow3 triggerer
```

Ese enfoque es válido para una primera validación, pero no es adecuado para operación sostenida. Un entorno de ingeniería de datos necesita que los procesos críticos se comporten como servicios administrados:

- inicio y parada controlada;
- reinicio automático ante fallos;
- logs centralizados;
- estado consultable con comandos estándar;
- separación clara entre componentes;
- menor dependencia de terminales abiertas;
- trazabilidad operativa para diagnóstico.

`systemd` permite convertir cada componente de Airflow en un servicio Linux. En este tutorial se configura Airflow 3.2.1 como un conjunto de servicios administrados:

```text
airflow3-api-server.service
airflow3-scheduler.service
airflow3-dag-processor.service
airflow3-triggerer.service
airflow3.target
```

La diferencia crítica frente a Airflow 2.9.3 es que ya no se define un servicio `webserver`. En Airflow 3.x, el servicio correspondiente es `api-server`.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- comprender el rol de `systemd` en la operación de servicios Linux;
- identificar los componentes mínimos de Apache Airflow 3.2.1 que deben ejecutarse como servicios;
- crear archivos `.service` para `api-server`, `scheduler`, `dag-processor` y `triggerer`;
- crear un archivo `.target` para administrar Airflow 3.2.1 como grupo de servicios;
- iniciar, detener, reiniciar y consultar servicios Airflow con `systemctl`;
- revisar logs de Airflow con `journalctl`;
- validar la salud operativa del API Server, scheduler, DAG Processor y triggerer;
- aplicar una política conservadora de arranque manual en WSL2 para evitar consumo innecesario de recursos;
- extender la configuración hacia escenarios multi-entorno usando unidades parametrizadas con `@`.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Apache Airflow + systemd  
**Versión objetivo:** Apache Airflow 3.2.1  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Python de referencia:** Python 3.12.5 gestionado con `pyenv`  
**Base de datos de metadatos:** PostgreSQL 15  
**Entorno de trabajo:** `/opt/airflow/airflow_3.2.1`  
**Archivo de entorno:** `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`  
**Tipo de uso:** Supervisión, administración y operación local de servicios  
**Ruta sugerida para guardar este documento en el repositorio:** `docs/02_herramientas/apache_airflow/10_tutorial_supervision_servicios_airflow_3_2_1_systemd.md`

### Este tutorial cubre

- Conceptos básicos de `systemd` aplicados a Airflow.
- Creación de unidades `.service` para Airflow 3.2.1.
- Creación de una unidad `.target` para operar Airflow como grupo de servicios.
- Comandos de administración con `systemctl`.
- Supervisión de logs con `journalctl`.
- Validación de procesos, puertos y conectividad HTTP.
- Recomendaciones para WSL2.
- Plantillas multi-entorno opcionales con unidades `@.service`.

### Este tutorial no cubre

- Despliegue productivo en Kubernetes.
- Airflow Helm Chart.
- Alta disponibilidad real del API Server, scheduler o triggerer.
- CeleryExecutor, Redis, RabbitMQ o KubernetesExecutor.
- Logging remoto en S3, GCS, Elasticsearch u OpenSearch.
- Autenticación corporativa con LDAP, OAuth2, OIDC o SSO.
- Hardening completo de seguridad para producción.
- Gestión avanzada de secretos.

---

## 4. Contexto técnico

En el tutorial de instalación de Airflow 3.2.1 se ejecutaban los componentes principales de forma separada para comprender la arquitectura real:

```bash
airflow3 api-server --host 0.0.0.0 --port 8080
airflow3 scheduler
airflow3 dag-processor
airflow3 triggerer
```

Ese procedimiento es correcto como validación inicial, pero tiene limitaciones:

- cada proceso depende de una terminal abierta;
- si se cierra la terminal, el proceso termina;
- no hay política de reinicio automático;
- los logs quedan dispersos;
- no existe una forma uniforme de consultar el estado;
- no se controla de forma centralizada el arranque y apagado.

Con `systemd`, cada componente queda bajo administración del sistema operativo:

| Componente Airflow 3.2.1 | Servicio systemd | Función principal |
|---|---|---|
| API Server | `airflow3-api-server.service` | Expone la UI, API pública y API de ejecución. |
| Scheduler | `airflow3-scheduler.service` | Evalúa DAGs, crea DAG Runs y agenda tareas. |
| DAG Processor | `airflow3-dag-processor.service` | Procesa, parsea y sincroniza archivos DAG. |
| Triggerer | `airflow3-triggerer.service` | Ejecuta triggers para operadores diferibles. |
| Grupo lógico | `airflow3.target` | Permite iniciar/detener Airflow como conjunto. |

La idea central es simple: **Airflow deja de ser un conjunto de comandos manuales y pasa a comportarse como una plataforma administrada**.

---

## 5. Requisitos previos

Antes de comenzar, se asume que ya se completó correctamente el tutorial:

```text
09_tutorial_instalacion_configuracion_apache_airflow_3_2_1.md
```

El entorno debe cumplir lo siguiente:

- Apache Airflow 3.2.1 instalado en `/opt/airflow/airflow_3.2.1`.
- Entorno virtual disponible en `/opt/airflow/airflow_3.2.1/venv`.
- Archivo de entorno disponible en `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`.
- PostgreSQL 15 activo y con la base de metadatos configurada.
- `airflow db migrate` ejecutado correctamente.
- DAG de validación disponible o al menos un DAG cargado en la carpeta `dags`.
- Usuario Linux con permisos `sudo`.
- `systemd` habilitado en Ubuntu/WSL2.

### Verificaciones rápidas

```bash
# Verificar sistema
lsb_release -a
uname -a

# Verificar systemd
ps -p 1 -o comm=
systemctl --version

# Activar Airflow 3.2.1
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh

# Cargar variables del laboratorio
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

# Validar Airflow
which airflow3
airflow3 version
airflow3 db check
airflow3 dags list
```

Resultado esperado:

```text
systemd
/opt/airflow/airflow_3.2.1/venv/bin/airflow
3.2.1
```

### Habilitar systemd en WSL2 si no está activo

Si `ps -p 1 -o comm=` devuelve `init` u otro proceso diferente a `systemd`, crear o editar:

```bash
sudo nano /etc/wsl.conf
```

Contenido:

```ini
[boot]
systemd=true
```

Luego, desde PowerShell en Windows:

```powershell
wsl --shutdown
```

Volver a abrir Ubuntu y verificar:

```bash
ps -p 1 -o comm=
```

Debe devolver:

```text
systemd
```

---

## 6. Arquitectura de servicios de referencia

La arquitectura propuesta usa cuatro servicios independientes y un target lógico:

```text
                         ┌─────────────────────────────┐
                         │        airflow3.target       │
                         └──────────────┬──────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │                               │                               │
        ▼                               ▼                               ▼
┌───────────────────┐          ┌──────────────────┐          ┌────────────────────┐
│ API Server         │          │ Scheduler         │          │ DAG Processor       │
│ airflow api-server │          │ airflow scheduler │          │ airflow dag-processor│
└─────────┬─────────┘          └─────────┬────────┘          └─────────┬──────────┘
          │                              │                             │
          └───────────────┬──────────────┴──────────────┬──────────────┘
                          │                             │
                          ▼                             ▼
                ┌─────────────────┐           ┌──────────────────┐
                │ PostgreSQL       │           │ Triggerer         │
                │ Metadata DB      │           │ airflow triggerer │
                └─────────────────┘           └──────────────────┘
```

Orden recomendado de arranque manual:

1. `airflow3-api-server`
2. `airflow3-dag-processor`
3. `airflow3-scheduler`
4. `airflow3-triggerer`

Orden recomendado de parada manual:

1. `airflow3-triggerer`
2. `airflow3-scheduler`
3. `airflow3-dag-processor`
4. `airflow3-api-server`

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal Bash.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno.
- `*.service` → unidad de servicio de `systemd`.
- `*.target` → unidad lógica de agrupación de servicios de `systemd`.
- `journalctl` → herramienta de consulta de logs del sistema.
- `AIRFLOW_HOME` → `/opt/airflow/airflow_3.2.1`.
- `AIRFLOW_CONFIG` → `/opt/airflow/airflow_3.2.1/configs/airflow.cfg`.
- `EnvironmentFile` → archivo externo desde donde `systemd` carga variables de entorno.

Variables de referencia:

| Variable | Valor |
|---|---|
| `AIRFLOW_HOME` | `/opt/airflow/airflow_3.2.1` |
| `AIRFLOW_ENV_FILE` | `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env` |
| `AIRFLOW_BIN` | `/opt/airflow/airflow_3.2.1/venv/bin/airflow` |
| `AIRFLOW_PORT` | `8080` |
| `AIRFLOW_USER` | usuario Linux actual, por ejemplo `richard` |
| `AIRFLOW_GROUP` | grupo Linux actual, por ejemplo `richard` |

---

## 8. Procedimiento paso a paso

### Paso 1 — Validar la instalación manual de Airflow 3.2.1

**Objetivo del paso:** confirmar que Airflow funciona antes de delegarlo a `systemd`.

**Instrucciones:**

```bash
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh

set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

airflow3 version
airflow3 db check
airflow3 dags list
```

**Explicación técnica:**  
`systemd` no corrige una instalación rota. Si `airflow db check` falla manualmente, también fallará como servicio.

**Resultado esperado:**

```text
3.2.1
```

Y la base de metadatos debe responder correctamente.

---

### Paso 2 — Definir usuario y grupo Linux para los servicios

**Objetivo del paso:** evitar escribir a mano el usuario del sistema dentro de cada unidad `.service`.

**Instrucciones:**

```bash
export AIRFLOW_SERVICE_USER="$(id -un)"
export AIRFLOW_SERVICE_GROUP="$(id -gn)"

echo "AIRFLOW_SERVICE_USER=${AIRFLOW_SERVICE_USER}"
echo "AIRFLOW_SERVICE_GROUP=${AIRFLOW_SERVICE_GROUP}"
```

**Resultado esperado:**

```text
AIRFLOW_SERVICE_USER=richard
AIRFLOW_SERVICE_GROUP=richard
```

**Observación:**  
Si se ejecuta en un servidor institucional, puede ser mejor crear un usuario dedicado llamado `airflow` en lugar de usar el usuario personal.

---

### Paso 3 — Revisar el archivo de entorno usado por systemd

**Objetivo del paso:** asegurar que el archivo `.env` contiene las variables necesarias para que los servicios funcionen sin depender de `.bashrc` ni de activaciones manuales.

**Archivo:**

```text
/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
```

**Validación:**

```bash
ls -lh /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env

sed -n '1,120p' /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
```

Debe contener, como mínimo, variables equivalentes a:

```bash
AIRFLOW_HOME=/opt/airflow3/airflow_3.2.1
AIRFLOW_CONFIG=/opt/airflow3/airflow_3.2.1/configs/airflow3.cfg

AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow3/airflow_3.2.1/dags
AIRFLOW__CORE__PLUGINS_FOLDER=/opt/airflow3/airflow_3.2.1/plugins
AIRFLOW__CORE__DEFAULT_TIMEZONE=America/Asuncion
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__CORE__LOAD_EXAMPLES=False
AIRFLOW__CORE__EXECUTION_API_SERVER_URL=http://localhost:8080/execution/

AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow3:airflow3_lab_pass@localhost:5432/airflow3_meta
AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA=airflow3_metastore
AIRFLOW__DATABASE__SQL_ALCHEMY_POOL_PRE_PING=True

AIRFLOW__LOGGING__BASE_LOG_FOLDER=/opt/airflow3/airflow_3.2.1/logs
AIRFLOW__LOGGING__LOGGING_LEVEL=INFO
AIRFLOW__LOGGING__DAG_PROCESSOR_CHILD_PROCESS_LOG_DIRECTORY=/opt/airflow3/airflow_3.2.1/logs/dag_processor

AIRFLOW__API__HOST=0.0.0.0
AIRFLOW__API__PORT=8080
PYTHONUNBUFFERED=1
```

Ajustar permisos:

```bash
chmod 600 /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
```

**Explicación técnica:**  
`systemd` no carga automáticamente `~/.bashrc`, alias ni activaciones de `venv`. Por eso cada servicio debe usar el binario absoluto del entorno virtual y un `EnvironmentFile` explícito.

---

### Paso 4 — Crear el servicio systemd del API Server

**Objetivo del paso:** administrar `airflow api-server` como servicio Linux.

**Archivo:**

```text
/etc/systemd/system/airflow3-api-server.service
```

**Instrucciones:**

```bash
sudo tee /etc/systemd/system/airflow3-api-server.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 API Server
Documentation=https://airflow.apache.org/docs/apache-airflow/3.2.1/
Wants=network-online.target
After=network-online.target postgresql.service
PartOf=airflow3.target

StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env

ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow api-server --host 0.0.0.0 --port 8080

KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

Restart=on-failure
RestartSec=15s
RestartPreventExitStatus=143
TimeoutStartSec=180s

UMask=0027
LimitNOFILE=65536
LimitNPROC=65536
RuntimeDirectory=airflow3-api-server
RuntimeDirectoryMode=0755

StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-api-server
LogLevelMax=info

OOMScoreAdjust=-300

[Install]
WantedBy=multi-user.target airflow3.target
EOF_SERVICE
```

**Explicación técnica:**  
Este servicio reemplaza al antiguo `airflow webserver`. En Airflow 3.x, la UI y las APIs se exponen mediante `airflow api-server`.

**Resultado esperado:**

```bash
sudo systemctl cat airflow3-api-server.service
```

Debe mostrar la unidad recién creada.

---

### Paso 5 — Crear el servicio systemd del Scheduler

**Objetivo del paso:** administrar `airflow scheduler` como servicio Linux.

**Archivo:**

```text
/etc/systemd/system/airflow3-scheduler.service
```

**Instrucciones:**

```bash
sudo tee /etc/systemd/system/airflow3-scheduler.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 Scheduler
Documentation=https://airflow.apache.org/docs/apache-airflow/3.2.1/administration-and-deployment/scheduler.html
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server.service
PartOf=airflow3.target

StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env

ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow scheduler

KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

Restart=on-failure
RestartSec=15s
RestartPreventExitStatus=143
TimeoutStartSec=180s

UMask=0027
LimitNOFILE=65536
LimitNPROC=65536
RuntimeDirectory=airflow3-scheduler
RuntimeDirectoryMode=0755

StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-scheduler
LogLevelMax=info

OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target airflow3.target
EOF_SERVICE
```

**Explicación técnica:**  
El scheduler es el componente que evalúa DAGs, crea DAG Runs y agenda tareas listas para ejecución. Si este servicio está detenido, la UI puede abrir, pero los DAGs no se ejecutarán de forma calendarizada.

---

### Paso 6 — Crear el servicio systemd del DAG Processor

**Objetivo del paso:** administrar `airflow dag-processor` como servicio independiente.

**Archivo:**

```text
/etc/systemd/system/airflow3-dag-processor.service
```

**Instrucciones:**

```bash
sudo tee /etc/systemd/system/airflow3-dag-processor.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 DAG Processor
Documentation=https://airflow.apache.org/docs/apache-airflow/3.2.1/
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server.service
PartOf=airflow3.target

StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env

ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow dag-processor

KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

Restart=on-failure
RestartSec=15s
RestartPreventExitStatus=143
TimeoutStartSec=180s

UMask=0027
LimitNOFILE=65536
LimitNPROC=65536
RuntimeDirectory=airflow3-dag-processor
RuntimeDirectoryMode=0755

StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-dag-processor
LogLevelMax=info

OOMScoreAdjust=-400

[Install]
WantedBy=multi-user.target airflow3.target
EOF_SERVICE
```

**Explicación técnica:**  
En Airflow 3.x, el DAG Processor no debe omitirse. Es responsable de procesar los archivos Python de la carpeta `dags`, detectar errores de importación y sincronizar la representación de DAGs con la base de metadatos.

---

### Paso 7 — Crear el servicio systemd del Triggerer

**Objetivo del paso:** administrar `airflow triggerer` como servicio Linux.

**Archivo:**

```text
/etc/systemd/system/airflow3-triggerer.service
```

**Instrucciones:**

```bash
sudo tee /etc/systemd/system/airflow3-triggerer.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 Triggerer
Documentation=https://airflow.apache.org/docs/apache-airflow/3.2.1/authoring-and-scheduling/deferring.html
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server.service
PartOf=airflow3.target

StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env

ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow triggerer

KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

Restart=on-failure
RestartSec=15s
RestartPreventExitStatus=143
TimeoutStartSec=180s

UMask=0027
LimitNOFILE=65536
LimitNPROC=65536
RuntimeDirectory=airflow3-triggerer
RuntimeDirectoryMode=0755

StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-triggerer
LogLevelMax=info

OOMScoreAdjust=-350

[Install]
WantedBy=multi-user.target airflow3.target
EOF_SERVICE
```

**Explicación técnica:**  
El triggerer permite ejecutar operadores diferibles sin consumir recursos innecesarios de workers o procesos bloqueados. Aunque en laboratorios simples puede parecer prescindible, conviene levantarlo para que el entorno represente mejor una arquitectura real de Airflow 3.x.

---

### Paso 8 — Crear el target lógico airflow3.target

**Objetivo del paso:** administrar todos los servicios de Airflow 3.2.1 como una sola unidad lógica.

**Archivo:**

```text
/etc/systemd/system/airflow3.target
```

**Instrucciones:**

```bash
sudo tee /etc/systemd/system/airflow3.target > /dev/null <<'EOF_TARGET'
[Unit]
Description=Apache Airflow 3.2.1 Service Group
Documentation=https://airflow.apache.org/docs/apache-airflow/3.2.1/
Wants=airflow3-api-server.service airflow3-dag-processor.service airflow3-scheduler.service airflow3-triggerer.service
After=network-online.target

[Install]
WantedBy=multi-user.target
EOF_TARGET
```

**Explicación técnica:**  
Un `.target` de `systemd` no ejecuta un proceso propio. Su función es agrupar servicios relacionados. Con esto se puede usar:

```bash
sudo systemctl start airflow3.target
sudo systemctl stop airflow3.target
sudo systemctl status airflow3.target
```

---

### Paso 9 — Recargar systemd y verificar unidades

**Objetivo del paso:** registrar las nuevas unidades en `systemd` y validar que el contenido fue cargado correctamente.

**Instrucciones:**

```bash
sudo systemctl daemon-reload

sudo systemctl cat airflow3-api-server.service
sudo systemctl cat airflow3-scheduler.service
sudo systemctl cat airflow3-dag-processor.service
sudo systemctl cat airflow3-triggerer.service
sudo systemctl cat airflow3.target
```

Verificar archivos disponibles:

```bash
systemctl list-unit-files --type=service 'airflow3*'
systemctl list-unit-files --type=target 'airflow3*'
```

**Resultado esperado:**  
Deben aparecer las unidades `airflow3-*` como archivos conocidos por `systemd`.

---

### Paso 10 — Iniciar servicios manualmente

**Objetivo del paso:** iniciar Airflow 3.2.1 bajo control de `systemd` sin habilitarlo todavía al arranque.

**Opción A — Iniciar servicio por servicio:**

```bash
sudo systemctl start airflow3-api-server.service
sudo systemctl start airflow3-dag-processor.service
sudo systemctl start airflow3-scheduler.service
sudo systemctl start airflow3-triggerer.service
```

**Opción B — Iniciar el grupo completo:**

```bash
sudo systemctl start airflow3.target
```

**Validar estado:**

```bash
systemctl status airflow3-api-server.service --no-pager
systemctl status airflow3-dag-processor.service --no-pager
systemctl status airflow3-scheduler.service --no-pager
systemctl status airflow3-triggerer.service --no-pager
```

**Resultado esperado:**  
Los servicios deben quedar en estado `active (running)`.

---

### Paso 11 — Consultar logs con journalctl

**Objetivo del paso:** revisar logs centralizados de los componentes de Airflow.

**API Server:**

```bash
sudo journalctl -u airflow3-api-server.service -f
sudo journalctl -u airflow3-api-server.service -e -n 100
sudo journalctl -u airflow3-api-server.service --since "10 minutes ago"
```

**Scheduler:**

```bash
sudo journalctl -u airflow3-scheduler.service -f
sudo journalctl -u airflow3-scheduler.service -e -n 100
sudo journalctl -u airflow3-scheduler.service --priority=3 --since "today"
```

**DAG Processor:**

```bash
sudo journalctl -u airflow3-dag-processor.service -f
sudo journalctl -u airflow3-dag-processor.service -e -n 100
sudo journalctl -u airflow3-dag-processor.service --priority=3 --since "today"
```

**Triggerer:**

```bash
sudo journalctl -u airflow3-triggerer.service -f
sudo journalctl -u airflow3-triggerer.service -e -n 100
sudo journalctl -u airflow3-triggerer.service --priority=3 --since "today"
```

**Todos los servicios Airflow 3:**

```bash
sudo journalctl -u airflow3-api-server.service \
                -u airflow3-scheduler.service \
                -u airflow3-dag-processor.service \
                -u airflow3-triggerer.service \
                -f
```

---

### Paso 12 — Validar puerto, procesos y endpoint HTTP

**Objetivo del paso:** verificar que Airflow está activo desde el sistema operativo y desde HTTP.

**Procesos:**

```bash
pgrep -af airflow3
ps aux | grep '[a]irflow'
```

**Puerto 8080:**

```bash
sudo ss -tuln | grep ':8080'
sudo lsof -i :8080
```

**Health check del API Server:**

```bash
curl -fsS http://localhost:8080/api/v2/monitor/health | python -m json.tool
```

**Acceso desde navegador:**

```text
http://localhost:8080
```

**Observación:**  
En Airflow 3.x el endpoint de salud recomendado para el API Server es:

```text
/api/v2/monitor/health
```

No conviene asumir automáticamente que todo comportamiento de `/health` de versiones anteriores se mantiene igual.

---

### Paso 13 — Validar DAGs y scheduler desde CLI

**Objetivo del paso:** comprobar que Airflow puede leer DAGs y que el scheduler está operativo.

**Instrucciones:**

```bash
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh

set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

airflow3 db check
airflow3 dags list
airflow3 dags list-import-errors
```

Si existe el DAG de validación del tutorial anterior:

```bash
airflow3 tasks list cit_validacion_airflow3
airflow3 dags trigger cit_validacion_airflow3
airflow3 dags list-runs -d cit_validacion_airflow3
```

Validación opcional del scheduler:

```bash
airflow3 jobs check --job-type SchedulerJob --hostname "$(hostname)"
```

Validación opcional del triggerer:

```bash
airflow3 jobs check --job-type TriggererJob --hostname "$(hostname)"
```

Si algún comando `jobs check` cambia entre versiones, revisar:

```bash
airflow3 jobs check --help
```

---

### Paso 14 — Detener y reiniciar servicios

**Objetivo del paso:** practicar la operación diaria de los servicios Airflow.

**Reiniciar un servicio individual:**

```bash
sudo systemctl restart airflow3-api-server.service
sudo systemctl restart airflow3-scheduler.service
sudo systemctl restart airflow3-dag-processor.service
sudo systemctl restart airflow3-triggerer.service
```

**Detener en orden conservador:**

```bash
sudo systemctl stop airflow3-triggerer.service
sudo systemctl stop airflow3-scheduler.service
sudo systemctl stop airflow3-dag-processor.service
sudo systemctl stop airflow3-api-server.service
```

**Reiniciar todo el grupo:**

```bash
sudo systemctl restart airflow3.target
```

**Detener todo el grupo:**

```bash
sudo systemctl stop airflow3.target
```

**Resetear estado de fallo:**

```bash
sudo systemctl reset-failed airflow3-api-server.service
sudo systemctl reset-failed airflow3-scheduler.service
sudo systemctl reset-failed airflow3-dag-processor.service
sudo systemctl reset-failed airflow3-triggerer.service
```

---

### Paso 15 — Mantener arranque manual en WSL2

**Objetivo del paso:** evitar que Airflow consuma recursos cada vez que se inicia Ubuntu/WSL2.

En un laboratorio académico local, se recomienda **no habilitar arranque automático** por defecto. Usar inicio manual cuando se vaya a trabajar con Airflow.

Verificar si están habilitados:

```bash
systemctl is-enabled airflow3-api-server.service || true
systemctl is-enabled airflow3-scheduler.service || true
systemctl is-enabled airflow3-dag-processor.service || true
systemctl is-enabled airflow3-triggerer.service || true
systemctl is-enabled airflow3.target || true
```

Deshabilitar arranque automático:

```bash
sudo systemctl disable airflow3-api-server.service || true
sudo systemctl disable airflow3-scheduler.service || true
sudo systemctl disable airflow3-dag-processor.service || true
sudo systemctl disable airflow3-triggerer.service || true
sudo systemctl disable airflow3.target || true
```

Iniciar manualmente cuando sea necesario:

```bash
sudo systemctl start airflow3.target
```

Detener al finalizar el laboratorio:

```bash
sudo systemctl stop airflow3.target
```

---

### Paso 16 — Habilitar arranque automático solo si corresponde

**Objetivo del paso:** dejar documentada la opción de arranque automático para servidores o entornos persistentes.

Solo aplicar si se desea que Airflow arranque con el sistema:

```bash
sudo systemctl enable airflow3-api-server.service
sudo systemctl enable airflow3-dag-processor.service
sudo systemctl enable airflow3-scheduler.service
sudo systemctl enable airflow3-triggerer.service
sudo systemctl enable airflow3.target
```

También se puede habilitar e iniciar en una sola operación:

```bash
sudo systemctl enable --now airflow3.target
```

**Advertencia:**  
En WSL2, el arranque automático puede ser innecesario y consumir memoria/CPU en segundo plano. Para laboratorios locales, la política recomendada es arranque manual.

---

### Paso 17 — Actualizar servicios después de cambios de configuración

**Objetivo del paso:** aplicar cambios cuando se edita el archivo `.env` o una unidad `.service`.

Si se cambia `airflow3_lab.env`:

```bash
sudo systemctl restart airflow3.target
```

Si se cambia un archivo `.service` o `.target`:

```bash
sudo systemctl daemon-reload
sudo systemctl restart airflow3.target
```

Verificar:

```bash
systemctl status airflow3.target --no-pager
systemctl list-units --type=service 'airflow3*'
```

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- `systemd` está activo en Ubuntu/WSL2.
- Las unidades `airflow3-*` existen y se cargan sin errores.
- `airflow3-api-server.service` inicia correctamente.
- `airflow3-scheduler.service` inicia correctamente.
- `airflow3-dag-processor.service` inicia correctamente.
- `airflow3-triggerer.service` inicia correctamente.
- El puerto `8080` está escuchando.
- La UI responde en `http://localhost:8080`.
- El endpoint `http://localhost:8080/api/v2/monitor/health` responde.
- `airflow dags list` muestra los DAGs esperados.
- `journalctl` permite consultar logs por servicio.

### Comandos de validación

```bash
ps -p 1 -o comm=

systemctl list-unit-files 'airflow3*'
systemctl list-units --type=service 'airflow3*'

systemctl status airflow3-api-server.service --no-pager
systemctl status airflow3-scheduler.service --no-pager
systemctl status airflow3-dag-processor.service --no-pager
systemctl status airflow3-triggerer.service --no-pager

sudo ss -tuln | grep ':8080'
curl -fsS http://localhost:8080/api/v2/monitor/health | python -m json.tool

source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

airflow3 db check
airflow3 dags list
airflow3 dags list-import-errors
```

### Evidencia esperada

```text
systemd
active (running)
LISTEN 0.0.0.0:8080
```

Y una respuesta JSON del endpoint de salud.

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `System has not been booted with systemd` | systemd no está habilitado en WSL2 | Configurar `/etc/wsl.conf` con `[boot] systemd=true` y ejecutar `wsl --shutdown` desde PowerShell |
| `airflow3-api-server.service` falla al iniciar | `EnvironmentFile` incorrecto o base de datos no disponible | Revisar `journalctl -u airflow3-api-server -e -n 100` y ejecutar manualmente `airflow db check` |
| `airflow: command not found` dentro del servicio | `ExecStart` usa `airflow` sin ruta absoluta | Usar `/opt/airflow/airflow_3.2.1/venv/bin/airflow` |
| API Server inicia pero la UI no responde | Puerto ocupado, firewall o proceso caído | Revisar `sudo ss -tuln | grep ':8080'` y logs del API Server |
| Scheduler activo pero los DAGs no se actualizan | `dag-processor` detenido o con errores de importación | Iniciar `airflow3-dag-processor.service` y ejecutar `airflow dags list-import-errors` |
| DAGs no aparecen en UI | Ruta `DAGS_FOLDER` incorrecta o error Python en DAG | Validar `AIRFLOW__CORE__DAGS_FOLDER` y revisar logs del DAG Processor |
| `Permission denied` en logs o DAGs | Usuario del servicio no tiene permisos sobre `/opt/airflow/airflow_3.2.1` | Ejecutar `sudo chown -R usuario:grupo /opt/airflow/airflow_3.2.1` ajustando usuario/grupo reales |
| Cambié un `.service` pero systemd no toma cambios | No se ejecutó `daemon-reload` | Ejecutar `sudo systemctl daemon-reload` y reiniciar servicios |
| El servicio reinicia en bucle | Error persistente de configuración o DB | Revisar `StartLimit`, logs y ejecutar manualmente el comando `ExecStart` |
| `airflow users create` no funciona | El entorno usa `SimpleAuthManager` | Usar configuración del Simple Auth Manager o cambiar explícitamente a `FabAuthManager` si corresponde |
| Variables `AIRFLOW__WEBSERVER__...` no tienen efecto | Se copiaron variables de Airflow 2.x | En Airflow 3.x revisar configuración bajo `[api]` y variables `AIRFLOW__API__...` |
| `postgresql.service` no existe | PostgreSQL corre externo, en Docker o con otro nombre de servicio | Eliminar `postgresql.service` del campo `After=` o ajustarlo al servicio real |

---

## 11. Buenas prácticas

- No reutilizar unidades `airflow2-webserver.service` en Airflow 3.2.1.
- Usar `airflow api-server`, no `airflow webserver`.
- Ejecutar `airflow dag-processor` como servicio independiente.
- Usar rutas absolutas en `ExecStart`.
- No depender de alias como `airflow3` dentro de `systemd`.
- Cargar configuración mediante `EnvironmentFile`.
- Mantener permisos restrictivos sobre archivos con credenciales.
- No habilitar arranque automático en WSL2 salvo necesidad real.
- Verificar primero el funcionamiento manual antes de crear servicios.
- Usar `journalctl` como fuente principal de diagnóstico operativo.
- Separar claramente logs, DAGs, plugins y configuración.
- Documentar cualquier cambio de puerto, usuario, ruta o base de datos.
- No guardar contraseñas reales en repositorios Git.
- Usar un usuario de servicio dedicado en servidores institucionales.
- Evitar hardening excesivo en laboratorios si puede bloquear tareas de los DAGs.
- Para producción, complementar con monitoreo, backup, rotación de logs, métricas y gestión de secretos.

### Ajuste recomendado de permisos

```bash
sudo chown -R "$(id -un):$(id -gn)" /opt/airflow3/airflow_3.2.1
chmod 700 /opt/airflow3/airflow_3.2.1/configs
chmod 600 /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
```

### Inspección rápida de consumo de recursos

```bash
systemctl status airflow3.target --no-pager
ps -o pid,ppid,cmd,%mem,%cpu -C python
free -h
df -h /opt/airflow3
```

---

## 12. Conclusión

Con esta configuración, Apache Airflow 3.2.1 queda integrado al sistema operativo mediante `systemd`, con servicios separados para `api-server`, `scheduler`, `dag-processor` y `triggerer`.

El cambio más importante respecto a Airflow 2.9.3 es conceptual y operativo: **Airflow 3.x no debe administrarse copiando la estructura del antiguo `webserver`**. El API Server ocupa ese lugar, y el DAG Processor debe ejecutarse explícitamente.

La configuración propuesta permite:

- iniciar Airflow como grupo mediante `airflow3.target`;
- operar cada componente por separado;
- centralizar logs con `journalctl`;
- diagnosticar fallos con mayor claridad;
- mantener una política de arranque manual apropiada para WSL2;
- preparar una base sólida para laboratorios más avanzados de orquestación de pipelines.

El resultado esperado es un entorno más profesional, observable y alineado con la arquitectura real de Airflow 3.2.1.

---

## 13. Referencias

1. Apache Airflow. **Apache Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/

2. Apache Airflow. **Command Line Interface and Environment Variables Reference — Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/cli-and-env-variables-ref.html

3. Apache Airflow. **Scheduler — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/administration-and-deployment/scheduler.html

4. Apache Airflow. **Upgrading to Airflow 3 — Startup scripts**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/installation/upgrading_to_airflow3.html

5. Apache Airflow. **Web Stack — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/administration-and-deployment/web-stack.html

6. Apache Airflow. **Deferrable Operators & Triggers — Triggerer HA**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/authoring-and-scheduling/deferring.html

7. Apache Airflow. **Quick Start — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/start.html

8. systemd. **systemd.service — Service unit configuration**.  
   https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html

9. systemd. **systemctl — Control the systemd system and service manager**.  
   https://www.freedesktop.org/software/systemd/man/latest/systemctl.html

---

## Anexo A — Comandos rápidos de administración

### Iniciar Airflow 3.2.1

```bash
sudo systemctl start airflow3.target
```

### Detener Airflow 3.2.1

```bash
sudo systemctl stop airflow3.target
```

### Reiniciar Airflow 3.2.1

```bash
sudo systemctl restart airflow3.target
```

### Ver estado general

```bash
systemctl status airflow3.target --no-pager
systemctl list-units --type=service 'airflow3*'
```

### Ver estado por componente

```bash
systemctl status airflow3-api-server.service --no-pager
systemctl status airflow3-scheduler.service --no-pager
systemctl status airflow3-dag-processor.service --no-pager
systemctl status airflow3-triggerer.service --no-pager
```

### Ver logs por componente

```bash
sudo journalctl -u airflow3-api-server.service -f
sudo journalctl -u airflow3-scheduler.service -f
sudo journalctl -u airflow3-dag-processor.service -f
sudo journalctl -u airflow3-triggerer.service -f
```

### Ver logs recientes con errores

```bash
sudo journalctl -u airflow3-api-server.service --priority=3 --since "today"
sudo journalctl -u airflow3-scheduler.service --priority=3 --since "today"
sudo journalctl -u airflow3-dag-processor.service --priority=3 --since "today"
sudo journalctl -u airflow3-triggerer.service --priority=3 --since "today"
```

### Validar API Server

```bash
curl -fsS http://localhost:8080/api/v2/monitor/health | python -m json.tool
```

### Validar procesos

```bash
pgrep -af airflow3
sudo ss -tuln | grep ':8080'
```

### Recargar cambios de unit files

```bash
sudo systemctl daemon-reload
sudo systemctl restart airflow3.target
```

### Deshabilitar arranque automático

```bash
sudo systemctl disable airflow3.target || true
sudo systemctl disable airflow3-api-server.service || true
sudo systemctl disable airflow3-scheduler.service || true
sudo systemctl disable airflow3-dag-processor.service || true
sudo systemctl disable airflow3-triggerer.service || true
```

---

## Anexo B — Plantillas systemd multi-entorno

Este anexo es opcional. Se recomienda aplicarlo solo cuando se necesiten varios entornos lógicos en una misma máquina, por ejemplo:

- `lab`
- `dev`
- `des`
- `pre`
- `pro`

La idea es usar unidades parametrizadas de `systemd` con `@`. En lugar de crear muchos archivos duplicados, se define una plantilla y se invoca con un nombre de instancia:

```bash
sudo systemctl start airflow3-api-server@lab
sudo systemctl start airflow3-api-server@des
sudo systemctl start airflow3-api-server@pro
```

### Requisito para multi-entorno

Cada entorno debe tener su propio archivo de variables:

```text
/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env
/opt/airflow/airflow_3.2.1/configs/airflow3_des.env
/opt/airflow/airflow_3.2.1/configs/airflow3_pre.env
/opt/airflow/airflow_3.2.1/configs/airflow3_pro.env
```

Cada archivo debe definir, como mínimo:

```bash
AIRFLOW_HOME=/opt/airflow3/airflow_3.2.1
AIRFLOW_CONFIG=/opt/airflow3/airflow_3.2.1/configs/airflow3.cfg
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://usuario:password@localhost:5432/base
AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA=esquema
AIRFLOW__API__PORT=8080
AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow3/airflow_3.2.1/dags
AIRFLOW__LOGGING__BASE_LOG_FOLDER=/opt/airflow3/airflow_3.2.1/logs
PYTHONUNBUFFERED=1
```

**Advertencia crítica:**  
Si se levantan varios API Server al mismo tiempo, cada entorno debe usar un puerto diferente, por ejemplo `8080`, `8081`, `8082`. Si comparten la misma base de metadatos y el mismo esquema, no son entornos aislados.

---

### B.1 Plantilla API Server

Archivo:

```text
/etc/systemd/system/airflow3-api-server@.service
```

Contenido:

```bash
sudo tee /etc/systemd/system/airflow3-api-server@.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 API Server - entorno %i
Wants=network-online.target
After=network-online.target postgresql.service
PartOf=airflow3@%i.target

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_%i.env
ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow api-server
Restart=on-failure
RestartSec=15s
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
LimitNOFILE=65536
LimitNPROC=65536
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-api-server-%i

[Install]
WantedBy=multi-user.target airflow3@%i.target
EOF_SERVICE
```

---

### B.2 Plantilla Scheduler

Archivo:

```text
/etc/systemd/system/airflow3-scheduler@.service
```

Contenido:

```bash
sudo tee /etc/systemd/system/airflow3-scheduler@.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 Scheduler - entorno %i
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server@%i.service
PartOf=airflow3@%i.target

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_%i.env
ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow scheduler
Restart=on-failure
RestartSec=15s
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
LimitNOFILE=65536
LimitNPROC=65536
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-scheduler-%i

[Install]
WantedBy=multi-user.target airflow3@%i.target
EOF_SERVICE
```

---

### B.3 Plantilla DAG Processor

Archivo:

```text
/etc/systemd/system/airflow3-dag-processor@.service
```

Contenido:

```bash
sudo tee /etc/systemd/system/airflow3-dag-processor@.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 DAG Processor - entorno %i
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server@%i.service
PartOf=airflow3@%i.target

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_%i.env
ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow dag-processor
Restart=on-failure
RestartSec=15s
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
LimitNOFILE=65536
LimitNPROC=65536
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-dag-processor-%i

[Install]
WantedBy=multi-user.target airflow3@%i.target
EOF_SERVICE
```

---

### B.4 Plantilla Triggerer

Archivo:

```text
/etc/systemd/system/airflow3-triggerer@.service
```

Contenido:

```bash
sudo tee /etc/systemd/system/airflow3-triggerer@.service > /dev/null <<EOF_SERVICE
[Unit]
Description=Apache Airflow 3.2.1 Triggerer - entorno %i
Wants=network-online.target
After=network-online.target postgresql.service airflow3-api-server@%i.service
PartOf=airflow3@%i.target

[Service]
Type=simple
User=${AIRFLOW_SERVICE_USER}
Group=${AIRFLOW_SERVICE_GROUP}
WorkingDirectory=/opt/airflow/airflow_3.2.1
EnvironmentFile=/opt/airflow/airflow_3.2.1/configs/airflow3_%i.env
ExecStartPre=/opt/airflow/airflow_3.2.1/venv/bin/airflow db check
ExecStart=/opt/airflow/airflow_3.2.1/venv/bin/airflow triggerer
Restart=on-failure
RestartSec=15s
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
LimitNOFILE=65536
LimitNPROC=65536
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow3-triggerer-%i

[Install]
WantedBy=multi-user.target airflow3@%i.target
EOF_SERVICE
```

---

### B.5 Target multi-entorno

Archivo:

```text
/etc/systemd/system/airflow3@.target
```

Contenido:

```bash
sudo tee /etc/systemd/system/airflow3@.target > /dev/null <<'EOF_TARGET'
[Unit]
Description=Apache Airflow 3.2.1 Service Group - entorno %i
Wants=airflow3-api-server@%i.service airflow3-dag-processor@%i.service airflow3-scheduler@%i.service airflow3-triggerer@%i.service
After=network-online.target

[Install]
WantedBy=multi-user.target
EOF_TARGET
```

---

### B.6 Administración multi-entorno

Recargar `systemd`:

```bash
sudo systemctl daemon-reload
```

Iniciar entorno `lab`:

```bash
sudo systemctl start airflow3@lab.target
```

Ver estado:

```bash
systemctl status airflow3-api-server@lab --no-pager
systemctl status airflow3-scheduler@lab --no-pager
systemctl status airflow3-dag-processor@lab --no-pager
systemctl status airflow3-triggerer@lab --no-pager
```

Ver logs:

```bash
sudo journalctl -u airflow3-api-server@lab -f
sudo journalctl -u airflow3-scheduler@lab -f
sudo journalctl -u airflow3-dag-processor@lab -f
sudo journalctl -u airflow3-triggerer@lab -f
```

Detener entorno `lab`:

```bash
sudo systemctl stop airflow3@lab.target
```

Iniciar entorno `des`:

```bash
sudo systemctl start airflow3@des.target
```

Detener entorno `des`:

```bash
sudo systemctl stop airflow3@des.target
```

---

### B.7 Recomendación final para multi-entorno

Para un curso básico, usar primero la configuración simple con:

```text
airflow3-api-server.service
airflow3-scheduler.service
airflow3-dag-processor.service
airflow3-triggerer.service
airflow3.target
```

La configuración multi-entorno debe reservarse para laboratorios más avanzados, pruebas de migración o separación real entre desarrollo, preproducción y producción.
