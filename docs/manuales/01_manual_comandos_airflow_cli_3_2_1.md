<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Manual profesional de comandos básicos y administrativos de Apache Airflow 3.2.1 CLI
**Administración, operación, diagnóstico y gestión de Apache Airflow 3.2.1 · WSL2 · Ubuntu 22.04.5 LTS · Python 3.12.5 · PostgreSQL 15 · Entorno `/opt/airflow/airflow_3.2.1`**

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
- **Documento base ajustado:** `Manual de comandos básicos de airflow CLI.md`
- **Tutorial de referencia:** `11_tutorial_instalacion_configuracion_apache_airflow_3_2_1.md`

---

## Nota sobre esta documentación

Este manual fue ajustado para administrar y gestionar **Apache Airflow 3.2.1** en el entorno técnico definido para el curso básico de **Introducción a Big Data** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**.

El documento reemplaza el enfoque previo basado en **Apache Airflow 2.9.3** y actualiza la operación para la línea **Airflow 3.x**, donde existen diferencias relevantes:

- el comando `airflow webserver` ya no debe usarse como servicio principal en esta guía;
- el componente web/API se administra mediante `airflow api-server`;
- el procesamiento de DAGs se administra explícitamente con `airflow dag-processor`;
- la base de metadatos se migra con `airflow db migrate`;
- la autoría moderna de DAGs debe apoyarse en `airflow.sdk`;
- el manejo de usuarios y roles depende del `auth_manager` configurado;
- `SimpleAuthManager` es adecuado para laboratorio y pruebas, pero no sustituye un esquema corporativo de autenticación.

Los comandos de este manual asumen el entorno de referencia:

- Windows 11 + WSL2;
- Ubuntu 22.04.5 LTS;
- Python 3.12.5 gestionado con `pyenv`;
- Apache Airflow 3.2.1 instalado en un entorno virtual dedicado;
- PostgreSQL 15 como metadata database;
- instalación aislada en `/opt/airflow/airflow_3.2.1`;
- archivo de entorno: `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`;
- alias de activación: `airflow3`.

> **Advertencia técnica:** este documento enseña administración profesional de Airflow, pero el entorno descrito sigue siendo de laboratorio. Para producción real se requieren decisiones adicionales de seguridad, observabilidad, autenticación, backups, alta disponibilidad y gestión de secretos.

---

## Tabla de contenido

1. [Introducción](#1-introducción)  
2. [Objetivos](#2-objetivos)  
3. [Alcance del manual](#3-alcance-del-manual)  
4. [Contexto operativo de Airflow 3.2.1](#4-contexto-operativo-de-airflow-321)  
5. [Preparación obligatoria antes de usar el CLI](#5-preparación-obligatoria-antes-de-usar-el-cli)  
6. [Estructura general del CLI de Airflow 3.2.1](#6-estructura-general-del-cli-de-airflow-321)  
7. [Comandos de verificación inicial](#7-comandos-de-verificación-inicial)  
8. [Gestión de configuración con `airflow config`](#8-gestión-de-configuración-con-airflow-config)  
9. [Gestión de metadata database con `airflow db`](#9-gestión-de-metadata-database-con-airflow-db)  
10. [Administración de servicios principales](#10-administración-de-servicios-principales)  
11. [Gestión de DAGs con `airflow dags`](#11-gestión-de-dags-con-airflow-dags)  
12. [Gestión de tareas con `airflow tasks`](#12-gestión-de-tareas-con-airflow-tasks)  
13. [Gestión de backfills con `airflow backfill`](#13-gestión-de-backfills-con-airflow-backfill)  
14. [Gestión de assets con `airflow assets`](#14-gestión-de-assets-con-airflow-assets)  
15. [Gestión de conexiones con `airflow connections`](#15-gestión-de-conexiones-con-airflow-connections)  
16. [Gestión de variables con `airflow variables`](#16-gestión-de-variables-con-airflow-variables)  
17. [Gestión de pools con `airflow pools`](#17-gestión-de-pools-con-airflow-pools)  
18. [Gestión de providers con `airflow providers`](#18-gestión-de-providers-con-airflow-providers)  
19. [Gestión de autenticación, usuarios, roles y equipos](#19-gestión-de-autenticación-usuarios-roles-y-equipos)  
20. [Comandos de diagnóstico: `info`, `jobs`, `plugins`, `cheat-sheet`](#20-comandos-de-diagnóstico-info-jobs-plugins-cheat-sheet)  
21. [Seguridad operativa: Fernet, secretos y comandos peligrosos](#21-seguridad-operativa-fernet-secretos-y-comandos-peligrosos)  
22. [Supervisión con CLI, HTTP y systemd](#22-supervisión-con-cli-http-y-systemd)  
23. [Consultas SQL útiles sobre el metastore PostgreSQL](#23-consultas-sql-útiles-sobre-el-metastore-postgresql)  
24. [Secuencia operativa recomendada para el laboratorio](#24-secuencia-operativa-recomendada-para-el-laboratorio)  
25. [Problemas frecuentes y soluciones](#25-problemas-frecuentes-y-soluciones)  
26. [Buenas prácticas profesionales](#26-buenas-prácticas-profesionales)  
27. [Conclusión](#27-conclusión)  
28. [Referencias](#28-referencias)  
29. [Anexo A — Cheatsheet operativo](#anexo-a--cheatsheet-operativo)  
30. [Anexo B — Comandos que no deben usarse sin revisar](#anexo-b--comandos-que-no-deben-usarse-sin-revisar)  

---

## 1. Introducción

La línea de comandos de Apache Airflow, conocida como **Airflow CLI**, es una herramienta central para administrar, diagnosticar y operar una plataforma de orquestación de pipelines.

Aunque la interfaz web permite monitorear DAGs y ejecuciones, un operador profesional de Airflow no debe depender únicamente de la UI. En la práctica, muchas tareas críticas se resuelven con CLI:

- validar la instalación;
- inspeccionar configuración efectiva;
- verificar conexión al metastore;
- ejecutar migraciones;
- iniciar componentes;
- diagnosticar el scheduler;
- listar DAGs y errores de importación;
- probar tareas individuales;
- administrar conexiones, variables y pools;
- revisar providers instalados;
- ejecutar operaciones de mantenimiento.

En el contexto del curso **Introducción a Big Data**, dominar el CLI de Airflow permite que el estudiante entienda que un pipeline de datos no es solamente código Python o SQL, sino un proceso administrado, observable y gobernado.

---

## 2. Objetivos

Al finalizar este manual, el estudiante será capaz de:

- activar correctamente el entorno de Airflow 3.2.1;
- ejecutar comandos CLI usando la instalación aislada en `/opt/airflow/airflow_3.2.1`;
- verificar versión, configuración y conectividad del metastore;
- administrar los componentes principales: `api-server`, `scheduler`, `dag-processor` y `triggerer`;
- listar, pausar, activar, probar y disparar DAGs;
- probar tareas individuales y analizar fallos;
- gestionar conexiones, variables y pools;
- interpretar el impacto de `SimpleAuthManager` y `FabAuthManager` en comandos de usuarios y roles;
- ejecutar diagnósticos básicos de disponibilidad;
- aplicar buenas prácticas operativas para evitar errores destructivos.

---

## 3. Alcance del manual

**Herramienta / componente principal:** Apache Airflow CLI  
**Versión objetivo:** Apache Airflow 3.2.1  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Python de referencia:** Python 3.12.5 con `pyenv`  
**Base de datos de metadatos:** PostgreSQL 15  
**Entorno de trabajo:** `/opt/airflow/airflow_3.2.1`  
**Archivo de entorno:** `/opt/airflow/airflow_3.2.1/configs/airflow3_lab.env`  
**Alias esperado:** `airflow3`  
**Executor de laboratorio:** `LocalExecutor`  
**DAG de validación:** `cit_validacion_airflow3`  
**Tipo de uso:** administración, operación, diagnóstico y gestión profesional básica.

### Este manual cubre

- Comandos de operación diaria del CLI.
- Comandos de diagnóstico de configuración, base de datos y servicios.
- Comandos de gestión de DAGs, tareas, conexiones, variables, pools y providers.
- Uso de `api-server`, `scheduler`, `dag-processor` y `triggerer`.
- Comandos compatibles con el entorno académico definido en el tutorial de instalación.
- Advertencias para comandos sensibles como `db reset`, `dags delete`, `tasks clear` y `rotate-fernet-key`.

### Este manual no cubre

- Administración avanzada de KubernetesExecutor.
- Operación de CeleryExecutor con Redis/RabbitMQ.
- Helm Chart oficial de Airflow.
- Despliegue productivo de alta disponibilidad.
- Integración corporativa con LDAP, OAuth2, OIDC o SSO.
- Gestión avanzada de secretos con Vault, AWS Secrets Manager, GCP Secret Manager o similares.
- Hardening completo de seguridad para producción.

---

## 4. Contexto operativo de Airflow 3.2.1

La instalación de referencia trabaja con los siguientes componentes:

```text
Usuario / Operador
        │
        ├── airflow CLI
        │
        ├── airflow api-server
        ├── airflow scheduler
        ├── airflow dag-processor
        ├── airflow triggerer
        │
        └── PostgreSQL Metadata Database
```

En Airflow 3.2.1, la operación profesional debe entender esta separación:

| Componente | Comando | Función principal |
|---|---|---|
| API Server | `airflow api-server` | Expone la UI y API de Airflow. Sustituye el enfoque clásico centrado en `webserver`. |
| Scheduler | `airflow scheduler` | Planifica DAG Runs y Task Instances según dependencias y calendarios. |
| DAG Processor | `airflow dag-processor` | Procesa, parsea y serializa los archivos DAG. En Airflow 3.x no debe ignorarse. |
| Triggerer | `airflow triggerer` | Atiende tareas diferidas, sensores asíncronos y operadores deferrable. |
| Metadata DB | `airflow db ...` | Mantiene estado operacional, DAG Runs, Task Instances, conexiones, variables y metadatos. |

### Diferencias críticas frente a Airflow 2.9.3

| Tema | Airflow 2.9.3 | Airflow 3.2.1 |
|---|---|---|
| Servicio web | `airflow webserver` | `airflow api-server` |
| Procesador de DAGs | Menos explícito para laboratorios básicos | `airflow dag-processor` como proceso separado |
| Migración DB | `airflow db init` / `airflow db upgrade` en guías antiguas | `airflow db migrate` |
| Autoría moderna de DAGs | `airflow.models`, `airflow.decorators` | `airflow.sdk` |
| Autenticación por defecto | Frecuentemente FAB | `SimpleAuthManager` |
| Usuarios/roles CLI | Más habitual con FAB | Depende del auth manager activo |

> **Regla profesional:** si un comando fue aprendido en Airflow 2.x, no asumir que sigue siendo correcto en Airflow 3.x. Primero ejecutar `airflow --help` y contrastar con la documentación oficial.

---

## 5. Preparación obligatoria antes de usar el CLI

Antes de ejecutar cualquier comando, activar el entorno correcto.

### 5.1 Activar Airflow 3.2.1

```bash
airflow3
```

Alternativa explícita:

```bash
source /opt/airflow3/airflow_3.2.1/scripts/activate_airflow_3.2.1.sh
```

### 5.2 Cargar variables del laboratorio

```bash
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

### 5.3 Validar rutas críticas

```bash
echo "$AIRFLOW_HOME"
echo "$AIRFLOW_CONFIG"
which airflow3
which python
```

Resultado esperado:

```text
/opt/airflow/airflow_3.2.1
/opt/airflow/airflow_3.2.1/configs/airflow.cfg
/opt/airflow/airflow_3.2.1/venv/bin/airflow
/opt/airflow/airflow_3.2.1/venv/bin/python
```

### 5.4 Regla de seguridad operativa

No ejecutar comandos administrativos desde otro entorno Python. Si `which airflow` no apunta al entorno virtual de Airflow 3.2.1, detenerse y corregir antes de continuar.

---

## 6. Estructura general del CLI de Airflow 3.2.1

El CLI se invoca con:

```bash
airflow3 GROUP_OR_COMMAND [SUBCOMMAND] [OPTIONS]
```

Ayuda general:

```bash
airflow3 --help
```

Ayuda de un grupo:

```bash
airflow3 dags --help
airflow3 tasks --help
airflow3 db --help
airflow3 api-server --help
```

Ayuda de un subcomando:

```bash
airflow3 dags trigger --help
airflow3 tasks test --help
airflow3 connections add --help
```

### 6.1 Grupos y comandos relevantes en Airflow 3.2.1

| Grupo / comando | Uso principal |
|---|---|
| `api-server` | Iniciar API Server/UI. |
| `assets` | Gestionar assets/datasets modernos. |
| `backfill` | Crear backfills controlados. |
| `cheat-sheet` | Mostrar resumen de comandos. |
| `config` | Consultar, validar o listar configuración. |
| `connections` | Gestionar conexiones externas. |
| `dag-processor` | Iniciar procesador de DAGs. |
| `dags` | Gestionar DAGs y DAG Runs. |
| `db` | Gestionar metadata database. |
| `db-manager` | Administrar migraciones de componentes externos/proveedores. |
| `info` | Mostrar información completa del entorno. |
| `jobs` | Diagnosticar procesos internos. |
| `kerberos` | Gestionar renovación Kerberos. |
| `plugins` | Inspeccionar plugins cargados. |
| `pools` | Administrar pools de concurrencia. |
| `providers` | Inspeccionar providers instalados. |
| `rotate-fernet-key` | Rotar clave Fernet. |
| `scheduler` | Iniciar scheduler. |
| `standalone` | Ejecutar Airflow todo-en-uno para desarrollo. |
| `tasks` | Gestionar y depurar tareas. |
| `teams` | Gestionar equipos cuando aplica multi-team. |
| `triggerer` | Iniciar triggerer. |
| `variables` | Gestionar variables. |
| `version` | Mostrar versión instalada. |

### 6.2 Comandos que dependen del Auth Manager

En Airflow 3.2.1, algunos comandos pueden aparecer o cambiar según el `auth_manager` activo.

Validar el auth manager:

```bash
airflow3 config get-value core auth_manager
```

Valores esperados según el tutorial:

```text
airflow.api_fastapi.auth.managers.simple.simple_auth_manager.SimpleAuthManager
```

O, si se configuró FAB:

```text
airflow.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
```

> **Consecuencia práctica:** no asumir que `airflow users` y `airflow roles` estarán disponibles o serán aplicables en todos los entornos. Con `SimpleAuthManager`, los usuarios se gestionan por configuración. Con `FabAuthManager`, sí es razonable usar comandos clásicos de usuarios y roles.

---

## 7. Comandos de verificación inicial

### 7.1 Ver versión instalada

```bash
airflow3 version
```

Resultado esperado:

```text
3.2.1
```

### 7.2 Ver información completa del entorno

```bash
airflow3 info
```

Uso profesional:

- confirmar versión de Airflow;
- confirmar versión de Python;
- revisar `AIRFLOW_HOME`;
- revisar metadata database;
- revisar providers instalados;
- diagnosticar inconsistencias de entorno.

### 7.3 Validar integridad de dependencias Python

```bash
pip check
```

Resultado esperado:

```text
No broken requirements found.
```

### 7.4 Validar configuración esencial

```bash
airflow3 config get-value core executor
airflow3 config get-value core dags_folder
airflow3 config get-value core auth_manager
airflow3 config get-value database sql_alchemy_conn
airflow3 config get-value database sql_alchemy_schema
```

Resultado esperado aproximado:

```text
LocalExecutor
/opt/airflow/airflow_3.2.1/dags
airflow.api_fastapi.auth.managers.simple.simple_auth_manager.SimpleAuthManager
postgresql+psycopg2://airflow3:...
airflow3_metastore
```

### 7.5 Validar conexión al metastore

```bash
airflow3 db check
```

Si falla, revisar:

```bash
psql "postgresql://airflow3:airflow3_lab_pass@localhost:5432/airflow3_meta" \
  -c "SELECT current_database(), current_user, current_schema();"
```

---

## 8. Gestión de configuración con `airflow config`

### 8.1 Listar configuración efectiva

```bash
airflow3 config list
```

Guardar evidencia:

```bash
airflow3 config list > /tmp/airflow_3_2_1_config_$(date +%Y%m%d_%H%M%S).txt
```

### 8.2 Consultar valores específicos

```bash
airflow3 config get-value core executor
airflow3 config get-value core dags_folder
airflow3 config get-value core plugins_folder
airflow3 config get-value core load_examples
airflow3 config get-value core default_timezone
```

```bash
airflow3 config get-value database sql_alchemy_conn
airflow3 config get-value database sql_alchemy_schema
airflow3 config get-value database sql_alchemy_pool_pre_ping
```

```bash
airflow3 config get-value api host
airflow3 config get-value api port
```

```bash
airflow3 config get-value logging base_log_folder
airflow3 config get-value logging logging_level
airflow3 config get-value logging dag_processor_child_process_log_directory
```

### 8.3 Validar Auth Manager activo

```bash
airflow3 config get-value core auth_manager
```

Interpretación:

| Resultado | Interpretación |
|---|---|
| `SimpleAuthManager` | Usuarios gestionados por configuración. Adecuado para laboratorio/desarrollo. |
| `FabAuthManager` | Usuarios, roles y permisos gestionados por FAB. Más cercano al enfoque clásico de Airflow 2.x. |

### 8.4 Validar configuración de concurrencia

```bash
airflow3 config get-value core parallelism
airflow3 config get-value core max_active_tasks_per_dag
airflow3 config get-value core max_active_runs_per_dag
```

Uso profesional:

- diagnosticar cuellos de botella;
- evitar que un DAG acapare recursos;
- controlar el paralelismo en laboratorios;
- explicar por qué un DAG queda en espera aunque tenga tareas listas.

### 8.5 Revisar configuración antes de culpar al código

Cuando un DAG no ejecuta, revisar primero:

```bash
airflow3 config get-value core dags_folder
airflow3 config get-value scheduler parsing_cleanup_interval
airflow3 config get-value scheduler min_file_process_interval
airflow3 config get-value core load_examples
```

> En ingeniería de datos, muchos errores atribuidos al DAG son realmente errores de configuración o entorno.

---

## 9. Gestión de metadata database con `airflow db`

La metadata database es el núcleo operacional de Airflow. Allí se registra estado de DAGs, DAG Runs, Task Instances, conexiones, variables, jobs, pools y otros metadatos.

### 9.1 Verificar conectividad

```bash
airflow3 db check
```

### 9.2 Verificar migraciones pendientes

```bash
airflow3 db check-migrations
```

### 9.3 Aplicar migraciones

```bash
airflow3 db migrate
```

Uso:

- después de instalar Airflow 3.2.1;
- después de cambiar versión de Airflow;
- después de instalar proveedores que agregan estructuras externas;
- antes de iniciar servicios si hay sospecha de esquema inconsistente.

> **Regla profesional:** antes de migrar una base real, detener servicios y respaldar la metadata database.

### 9.4 Acceder al shell de base de datos

```bash
airflow3 db shell
```

Este comando abre una consola hacia la metadata database usando la configuración activa de Airflow.

### 9.5 Limpiar registros antiguos

```bash
airflow3 db clean --help
```

Ejecutar primero en modo revisión:

```bash
airflow3 db clean \
  --clean-before-timestamp "2026-01-01T00:00:00+00:00" \
  --dry-run
```

Si la revisión es correcta:

```bash
airflow3 db clean \
  --clean-before-timestamp "2026-01-01T00:00:00+00:00"
```

### 9.6 Comando destructivo: `db reset`

```bash
airflow3 db reset
```

No ejecutar en un entorno con historial útil. Este comando puede eliminar o recrear estructuras de metadatos. En un laboratorio puede servir para reiniciar desde cero; en un entorno real puede destruir trazabilidad operativa.

### 9.7 Comando de uso avanzado: `db downgrade`

```bash
airflow3 db downgrade --help
```

No se recomienda usarlo sin plan de rollback y backup. Las migraciones inversas pueden ser riesgosas si ya existen datos generados con una versión superior.

---

## 10. Administración de servicios principales

### 10.1 API Server

Iniciar API Server:

```bash
airflow3 api-server --host 0.0.0.0 --port 8080
```

Con opciones explícitas:

```bash
airflow3 api-server \
  --host 0.0.0.0 \
  --port 8080 \
  --workers 1 \
  --worker-timeout 120
```

Acceso:

```text
http://localhost:8080
```

Validación HTTP:

```bash
curl -f http://localhost:8080/api/v2/monitor/health
```

Con `jq`, si está instalado:

```bash
curl -s http://localhost:8080/api/v2/monitor/health | jq .
```

### 10.2 Scheduler

Iniciar Scheduler:

```bash
airflow3 scheduler
```

Función:

- detectar DAG Runs planificables;
- evaluar dependencias;
- enviar tareas listas al executor;
- mantener heartbeat en el metastore.

Verificar scheduler por CLI:

```bash
airflow3 jobs check --job-type SchedulerJob --local
```

Para entornos con más de un scheduler:

```bash
airflow3 jobs check --job-type SchedulerJob --allow-multiple --limit 100
```

### 10.3 DAG Processor

Iniciar DAG Processor:

```bash
airflow3 dag-processor
```

Función:

- procesar archivos Python en `dags_folder`;
- detectar errores de importación;
- serializar DAGs;
- alimentar al scheduler y a la UI/API con metadatos de DAGs.

Validar errores de importación:

```bash
airflow3 dags list-import-errors
```

### 10.4 Triggerer

Iniciar Triggerer:

```bash
airflow3 triggerer
```

Función:

- atender operadores diferidos;
- reducir uso de slots ocupados por sensores;
- mantener eventos asíncronos.

### 10.5 Secuencia manual recomendada

Abrir cuatro terminales. En cada una:

```bash
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

Luego:

```bash
# Terminal 1
airflow3 api-server --host 0.0.0.0 --port 8080

# Terminal 2
airflow3 scheduler

# Terminal 3
airflow3 dag-processor

# Terminal 4
airflow3 triggerer
```

### 10.6 Comando no recomendado en este manual

No usar:

```bash
airflow3 webserver
```

Para Airflow 3.2.1, este manual se alinea con `airflow api-server`.

---

## 11. Gestión de DAGs con `airflow dags`

### 11.1 Listar DAGs

```bash
airflow3 dags list
```

Filtrar el DAG de validación:

```bash
airflow3 dags list | grep cit_validacion_airflow3
```

### 11.2 Ver errores de importación

```bash
airflow3 dags list-import-errors
```

Este debe ser uno de los primeros comandos ante cualquier problema de DAG invisible en la UI.

### 11.3 Mostrar estructura de un DAG

```bash
airflow3 dags show cit_validacion_airflow3
```

Guardar salida como imagen o archivo, si el entorno lo permite:

```bash
airflow3 dags show cit_validacion_airflow3 --save /tmp/cit_validacion_airflow3.png
```

### 11.4 Pausar y activar DAGs

Pausar:

```bash
airflow3 dags pause cit_validacion_airflow3
```

Activar:

```bash
airflow3 dags unpause cit_validacion_airflow3
```

### 11.5 Disparar ejecución manual

```bash
airflow3 dags trigger cit_validacion_airflow3
```

Con `run_id` explícito:

```bash
airflow3 dags trigger cit_validacion_airflow3 \
  --run-id "manual_cli_$(date +%Y%m%d_%H%M%S)"
```

Con configuración JSON:

```bash
airflow3 dags trigger cit_validacion_airflow3 \
  --conf '{"fuente":"cli","modo":"laboratorio"}'
```

### 11.6 Listar ejecuciones de un DAG

```bash
airflow3 dags list-runs -d cit_validacion_airflow3
```

Guardar evidencia:

```bash
airflow3 dags list-runs -d cit_validacion_airflow3 \
  > /tmp/cit_validacion_airflow3_runs_$(date +%Y%m%d_%H%M%S).txt
```

### 11.7 Ver estado de un DAG en una fecha lógica

```bash
airflow3 dags state cit_validacion_airflow3 2026-01-01
```

### 11.8 Probar un DAG completo sin depender del scheduler

```bash
airflow3 dags test cit_validacion_airflow3 2026-01-01
```

Uso:

- depuración local;
- validación antes de habilitar el DAG;
- revisión de dependencias lógicas.

### 11.9 Re-serializar DAGs

```bash
airflow3 dags reserialize
```

Uso:

- después de cambios grandes en DAGs;
- cuando la UI no refleja cambios;
- cuando se sospecha inconsistencia entre archivos DAG y metadatos serializados.

### 11.10 Eliminar un DAG del metastore

```bash
airflow3 dags delete cit_validacion_airflow3
```

Advertencia: esto elimina registros del metastore asociados al DAG. No elimina necesariamente el archivo `.py`. Usarlo solo si se comprende el impacto sobre historial de ejecuciones.

---

## 12. Gestión de tareas con `airflow tasks`

### 12.1 Listar tareas de un DAG

```bash
airflow3 tasks list cit_validacion_airflow3
```

Con árbol de dependencias:

```bash
airflow3 tasks list cit_validacion_airflow3 --tree
```

### 12.2 Probar una tarea individual

```bash
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01
```

Uso:

- validar lógica de una tarea;
- depurar errores de Python;
- verificar imports y dependencias;
- ejecutar sin crear una ejecución completa normal del DAG.

### 12.3 Renderizar templates de una tarea

```bash
airflow3 tasks render cit_validacion_airflow3 extraer 2026-01-01
```

Uso:

- depurar Jinja templates;
- revisar valores de `{{ ds }}`, `{{ dag_run.conf }}`, `{{ params }}`;
- validar SQL dinámico antes de ejecutar.

### 12.4 Ver estado de una tarea

```bash
airflow3 tasks state cit_validacion_airflow3 extraer 2026-01-01
```

### 12.5 Ver estados de tareas por DAG Run

Primero listar runs:

```bash
airflow3 dags list-runs -d cit_validacion_airflow3
```

Luego usar el `run_id`:

```bash
airflow3 tasks states-for-dag-run cit_validacion_airflow3 "manual__2026-01-01T00:00:00+00:00"
```

### 12.6 Diagnosticar dependencias fallidas

```bash
airflow3 tasks failed-deps cit_validacion_airflow3 extraer 2026-01-01
```

Uso:

- revisar por qué una tarea no es planificable;
- detectar dependencias no satisfechas;
- analizar límites de concurrencia, pools, fechas, estados previos o reglas de trigger.

### 12.7 Limpiar estados de tareas

```bash
airflow3 tasks clear cit_validacion_airflow3 \
  --start-date 2026-01-01 \
  --end-date 2026-01-01
```

Antes de confirmar, revisar cuidadosamente el prompt interactivo.

Uso profesional:

- reintentar tareas fallidas;
- limpiar ejecuciones de laboratorio;
- reproducir una corrida completa.

Advertencia: limpiar tareas puede provocar re-ejecución. Si la tarea no es idempotente, puede duplicar cargas, archivos o registros.

---

## 13. Gestión de backfills con `airflow backfill`

En Airflow 3.2.1 el backfill se administra como grupo específico.

### 13.1 Ver ayuda

```bash
airflow3 backfill --help
airflow3 backfill create --help
```

### 13.2 Crear backfill

Ejemplo conceptual:

```bash
airflow3 backfill create \
  --dag-id cit_validacion_airflow3 \
  --from-date 2026-01-01 \
  --to-date 2026-01-07
```

### 13.3 Cuándo usar backfill

Usar backfill cuando se necesita reconstruir ejecuciones históricas según una ventana temporal.

Ejemplos:

- reprocesar datos de una semana;
- reconstruir particiones faltantes;
- ejecutar un DAG que estuvo pausado;
- recalcular una capa SILVER/GOLD.

### 13.4 Cuándo no usar backfill

No usar backfill para probar una tarea aislada. Para eso usar:

```bash
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01
```

No usar backfill si el DAG escribe datos de forma no idempotente y no tiene estrategia de sobrescritura, particionado o control de duplicados.

---

## 14. Gestión de assets con `airflow assets`

Airflow 3.x fortalece el concepto de assets para modelar dependencias orientadas a datos.

### 14.1 Listar assets

```bash
airflow3 assets list
```

### 14.2 Ver detalles de un asset

```bash
airflow3 assets details --help
```

### 14.3 Materializar asset

```bash
airflow3 assets materialize --help
```

### 14.4 Uso académico

En un laboratorio de ingeniería de datos, los assets permiten explicar que un pipeline no solo depende de tareas, sino también de productos de datos:

- archivo fuente descargado;
- tabla RAW actualizada;
- tabla SILVER validada;
- tabla GOLD publicada;
- datamart disponible.

---

## 15. Gestión de conexiones con `airflow connections`

Las conexiones externalizan credenciales y endpoints. Evitan hardcodear usuarios, contraseñas, hosts y puertos dentro de los DAGs.

### 15.1 Listar conexiones

```bash
airflow3 connections list
```

### 15.2 Ver una conexión

```bash
airflow3 connections get postgres_analytics
```

### 15.3 Crear conexión PostgreSQL

```bash
airflow3 connections add postgres_analytics \
  --conn-type postgres \
  --conn-host localhost \
  --conn-schema analytics_db \
  --conn-login analytics_user \
  --conn-password 'cambiar_esta_password' \
  --conn-port 5432
```

### 15.4 Crear conexión usando URI

```bash
airflow3 connections add postgres_analytics_uri \
  --conn-uri 'postgresql://analytics_user:cambiar_esta_password@localhost:5432/analytics_db'
```

### 15.5 Probar conexión

```bash
airflow3 connections test postgres_analytics
```

### 15.6 Exportar conexiones

```bash
airflow3 connections export /tmp/airflow_connections.json
```

### 15.7 Importar conexiones

```bash
airflow3 connections import /tmp/airflow_connections.json
```

### 15.8 Eliminar conexión

```bash
airflow3 connections delete postgres_analytics
```

### 15.9 Buenas prácticas con conexiones

- No versionar archivos exportados con contraseñas reales.
- Usar nombres claros: `postgres_raw`, `postgres_dw`, `sftp_fuente_x`, `api_sfp`.
- Separar conexiones por ambiente: `dev`, `des`, `pre`, `pro`.
- No poner credenciales dentro del código del DAG.

---

## 16. Gestión de variables con `airflow variables`

Las variables permiten parametrizar DAGs sin cambiar código.

### 16.1 Listar variables

```bash
airflow3 variables list
```

### 16.2 Crear o actualizar variable

```bash
airflow3 variables set ENVIRONMENT lab
```

```bash
airflow3 variables set DATA_ROOT /opt/repo/cit-bigdata-lab/projects/data
```

### 16.3 Leer variable

```bash
airflow3 variables get ENVIRONMENT
```

### 16.4 Exportar variables

```bash
airflow3 variables export /tmp/airflow_variables.json
```

### 16.5 Importar variables

```bash
airflow3 variables import /tmp/airflow_variables.json
```

### 16.6 Eliminar variable

```bash
airflow3 variables delete ENVIRONMENT
```

### 16.7 Buenas prácticas con variables

Usar variables para parámetros no sensibles:

- rutas base;
- nombres de ambiente;
- nombres lógicos de capas;
- flags de laboratorio;
- parámetros funcionales.

No usar variables para secretos críticos. Para secretos reales, usar un backend de secretos o variables de entorno gestionadas con controles apropiados.

---

## 17. Gestión de pools con `airflow pools`

Los pools controlan cuántas tareas pueden usar un recurso compartido.

### 17.1 Listar pools

```bash
airflow3 pools list
```

### 17.2 Crear o actualizar pool

```bash
airflow3 pools set postgres_pool 4 "Control de concurrencia hacia PostgreSQL"
```

```bash
airflow3 pools set api_sfp_pool 2 "Control de concurrencia hacia API o fuente externa"
```

### 17.3 Ver un pool

```bash
airflow3 pools get postgres_pool
```

### 17.4 Eliminar pool

```bash
airflow3 pools delete postgres_pool
```

### 17.5 Cuándo usar pools

Usar pools cuando varias tareas compiten por:

- una base de datos transaccional;
- una API con rate limit;
- un servidor SFTP;
- un recurso de CPU o memoria limitado;
- una herramienta externa como Pentaho Data Integration.

---

## 18. Gestión de providers con `airflow providers`

Los providers extienden Airflow con hooks, operadores, sensores, conexiones y componentes adicionales.

### 18.1 Listar providers instalados

```bash
airflow3 providers list
```

### 18.2 Ver información de un provider

```bash
airflow3 providers get apache-airflow3-providers-postgres
```

### 18.3 Listar hooks disponibles

```bash
airflow3 providers hooks
```

### 18.4 Listar auth managers disponibles por providers

```bash
airflow3 providers auth-managers
```

### 18.5 Listar executors disponibles por providers

```bash
airflow3 providers executors
```

### 18.6 Uso profesional

- Validar que un provider requerido realmente está instalado.
- Verificar compatibilidad de integración antes de escribir un DAG.
- Diagnosticar errores de imports de operadores o hooks.
- Confirmar que `postgres`, `sftp`, `fab` u otros extras quedaron instalados.

---

## 19. Gestión de autenticación, usuarios, roles y equipos

### 19.1 Ver Auth Manager activo

```bash
airflow3 config get-value core auth_manager
```

### 19.2 Caso A: SimpleAuthManager

En el tutorial de instalación de referencia se usa `SimpleAuthManager` para laboratorio.

Validar:

```bash
airflow3 config get-value core auth_manager
```

Si devuelve:

```text
airflow.api_fastapi.auth.managers.simple.simple_auth_manager.SimpleAuthManager
```

Los usuarios se gestionan desde configuración:

```bash
airflow3 config get-value core simple_auth_manager_users
```

Ejemplo de configuración en `airflow3_lab.env`:

```bash
AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:admin
AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_ALL_ADMINS=False
```

Roles predefinidos habituales:

| Rol | Uso |
|---|---|
| `viewer` | Lectura. |
| `user` | Lectura más operación básica sobre DAGs. |
| `op` | Operación ampliada sobre DAGs, conexiones, variables, pools y assets. |
| `admin` | Administración completa. |

> Con `SimpleAuthManager`, no diseñar una política de seguridad institucional. Es una opción de laboratorio, desarrollo y pruebas.

### 19.3 Caso B: FabAuthManager

Si se configuró:

```text
airflow.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
```

entonces pueden aplicar comandos clásicos como:

```bash
airflow3 users list
```

Crear usuario administrador:

```bash
airflow3 users create \
  --username admin \
  --firstname Admin \
  --lastname CIT \
  --role Admin \
  --email admin@example.org \
  --password admin
```

Listar roles:

```bash
airflow3 roles list
```

Crear rol:

```bash
airflow3 roles create data_engineer
```

> **Advertencia:** cambiar de `SimpleAuthManager` a `FabAuthManager` no es un cambio menor. Afecta usuarios, permisos y experiencia de login. En un entorno real requiere plan de migración.

### 19.4 Teams

Airflow 3.2.1 incluye comandos `teams` para escenarios multi-team.

```bash
airflow3 teams --help
airflow3 teams list
```

Crear equipo:

```bash
airflow3 teams create equipo_bigdata
```

Eliminar equipo:

```bash
airflow3 teams delete equipo_bigdata
```

Uso recomendado:

- aislar recursos por equipo;
- organizar DAGs, conexiones, variables o assets por dominio;
- simular gobierno básico de plataforma en laboratorios avanzados.

---

## 20. Comandos de diagnóstico: `info`, `jobs`, `plugins`, `cheat-sheet`

### 20.1 `airflow info`

```bash
airflow3 info
```

Usar cuando se necesita un diagnóstico general del entorno.

### 20.2 `airflow jobs check`

Scheduler local:

```bash
airflow3 jobs check --job-type SchedulerJob --local
```

Scheduler en modo tolerante a múltiples instancias:

```bash
airflow3 jobs check --job-type SchedulerJob --allow-multiple --limit 100
```

### 20.3 `airflow plugins`

```bash
airflow3 plugins
```

Uso:

- validar plugins cargados;
- detectar errores de importación;
- revisar extensiones locales.

### 20.4 `airflow cheat-sheet`

```bash
airflow3 cheat-sheet
```

Útil como recordatorio rápido, pero no sustituye `airflow <grupo> --help` ni la documentación oficial.

---

## 21. Seguridad operativa: Fernet, secretos y comandos peligrosos

### 21.1 Verificar Fernet Key

```bash
airflow3 config get-value core fernet_key
```

La clave Fernet cifra valores sensibles almacenados en Airflow, como contraseñas de conexiones.

### 21.2 Rotar Fernet Key

```bash
airflow3 rotate-fernet-key
```

No ejecutar sin comprender el procedimiento. Una rotación incorrecta puede dejar conexiones o variables sensibles ilegibles.

### 21.3 Comandos peligrosos

| Comando | Riesgo |
|---|---|
| `airflow db reset` | Puede destruir metadatos. |
| `airflow dags delete` | Elimina historial del DAG en metastore. |
| `airflow tasks clear` | Puede re-ejecutar tareas y duplicar salidas si no son idempotentes. |
| `airflow db clean` | Elimina registros históricos según ventana temporal. |
| `airflow rotate-fernet-key` | Puede afectar descifrado de secretos si se ejecuta mal. |

### 21.4 Reglas mínimas

- No usar comandos destructivos sin backup.
- No limpiar estados sin saber si las tareas son idempotentes.
- No exportar conexiones con contraseñas reales a repositorios Git.
- No mostrar `sql_alchemy_conn` completo en capturas públicas.
- No usar contraseñas didácticas fuera del laboratorio.

---

## 22. Supervisión con CLI, HTTP y systemd

### 22.1 Health check HTTP

```bash
curl -s http://localhost:8080/api/v2/monitor/health | jq .
```

Salida esperada aproximada:

```json
{
  "metadatabase": {"status": "healthy"},
  "scheduler": {"status": "healthy"},
  "triggerer": {"status": "healthy"},
  "dag_processor": {"status": "healthy"}
}
```

Si no se usa `jq`:

```bash
curl -f http://localhost:8080/api/v2/monitor/health
```

### 22.2 Health check de base de datos

```bash
airflow3 db check
```

### 22.3 Health check de scheduler

```bash
airflow3 jobs check --job-type SchedulerJob --local
```

### 22.4 Diagnóstico de procesos

```bash
pgrep -af airflow3
ps aux | grep airflow3 | grep -v grep
```

### 22.5 Diagnóstico de puerto 8080

```bash
sudo ss -tulnp | grep :8080
sudo lsof -i :8080
```

### 22.6 Supervisión con systemd

Si se aplicó el tutorial de servicios con systemd:

```bash
sudo systemctl status airflow3-api-server --no-pager
sudo systemctl status airflow3-scheduler --no-pager
sudo systemctl status airflow3-dag-processor --no-pager
sudo systemctl status airflow3-triggerer --no-pager
```

Logs:

```bash
sudo journalctl -u airflow3-api-server -f
sudo journalctl -u airflow3-scheduler -f
sudo journalctl -u airflow3-dag-processor -f
sudo journalctl -u airflow3-triggerer -f
```

Si existe un target agrupador:

```bash
sudo systemctl status airflow3.target --no-pager
sudo systemctl start airflow3.target
sudo systemctl stop airflow3.target
```

---

## 23. Consultas SQL útiles sobre el metastore PostgreSQL

> **Regla estricta:** consultar el metastore para diagnóstico es aceptable; modificarlo manualmente con `UPDATE`, `DELETE` o `INSERT` no es una práctica segura. Para cambios de estado usar CLI o UI.

### 23.1 Conectarse al metastore

```bash
psql "postgresql://airflow3:airflow3_lab_pass@localhost:5432/airflow3_meta"
```

Si se usa el esquema configurado:

```sql
SET search_path TO airflow3_metastore, public;
```

### 23.2 Ver últimas ejecuciones de un DAG

```sql
SELECT
    dag_id,
    run_id,
    run_type,
    state,
    logical_date,
    start_date,
    end_date
FROM dag_run
WHERE dag_id = 'cit_validacion_airflow3'
ORDER BY logical_date DESC
LIMIT 20;
```

### 23.3 Ver tareas por run

```sql
SELECT
    dag_id,
    task_id,
    run_id,
    map_index,
    try_number,
    state,
    start_date,
    end_date
FROM task_instance
WHERE dag_id = 'cit_validacion_airflow3'
ORDER BY run_id DESC, task_id, map_index;
```

### 23.4 Detectar posibles duplicados de DAG Run por fecha lógica

```sql
SELECT
    dag_id,
    logical_date,
    COUNT(*) AS num_runs
FROM dag_run
WHERE dag_id = 'cit_validacion_airflow3'
GROUP BY dag_id, logical_date
HAVING COUNT(*) > 1
ORDER BY logical_date DESC;
```

### 23.5 Reporte combinado de DAG Runs y Task Instances

```sql
SELECT
    dr.dag_id,
    dr.run_id,
    dr.run_type,
    dr.state AS dag_run_state,
    dr.logical_date,
    ti.task_id,
    ti.map_index,
    ti.try_number,
    ti.state AS task_state,
    ti.start_date,
    ti.end_date
FROM dag_run dr
JOIN task_instance ti
  ON dr.dag_id = ti.dag_id
 AND dr.run_id = ti.run_id
WHERE dr.dag_id = 'cit_validacion_airflow3'
ORDER BY dr.logical_date DESC, ti.task_id, ti.map_index;
```

### 23.6 Ver jobs recientes

```sql
SELECT
    job_type,
    state,
    hostname,
    latest_heartbeat,
    start_date,
    end_date
FROM job
ORDER BY latest_heartbeat DESC
LIMIT 20;
```

### 23.7 Interpretación profesional

| Síntoma | Tabla útil | Qué revisar |
|---|---|---|
| DAG no aparece | CLI primero: `airflow dags list-import-errors` | Errores de importación antes de ir a SQL. |
| DAG no ejecuta | `dag_run`, `job` | Scheduler activo, DAG unpaused, calendario válido. |
| Tarea no inicia | `task_instance`, pools | Estado, pool, dependencias, límites de concurrencia. |
| UI no refleja cambios | `serialized_dag`, `dag_processor` logs | DAG Processor activo y sin errores. |
| Scheduler parece muerto | `job.latest_heartbeat` | Heartbeat reciente. |

---

## 24. Secuencia operativa recomendada para el laboratorio

### 24.1 Inicio manual del entorno

```bash
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

which airflow3
airflow3 version
airflow3 db check
airflow3 dags list
```

Luego iniciar servicios en terminales separadas:

```bash
airflow3 api-server --host 0.0.0.0 --port 8080
```

```bash
airflow3 scheduler
```

```bash
airflow3 dag-processor
```

```bash
airflow3 triggerer
```

### 24.2 Validar salud

```bash
curl -s http://localhost:8080/api/v2/monitor/health | jq .
airflow3 jobs check --job-type SchedulerJob --local
airflow3 db check
```

### 24.3 Probar DAG de validación

```bash
airflow3 dags list | grep cit_validacion_airflow3
airflow3 tasks list cit_validacion_airflow3
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01
airflow3 dags trigger cit_validacion_airflow3
airflow3 dags list-runs -d cit_validacion_airflow3
```

### 24.4 Cierre manual

Si se ejecuta manualmente, detener cada terminal con `CTRL + C`.

Si se usa systemd:

```bash
sudo systemctl stop airflow3-triggerer
sudo systemctl stop airflow3-dag-processor
sudo systemctl stop airflow3-scheduler
sudo systemctl stop airflow3-api-server
```

---

## 25. Problemas frecuentes y soluciones

| Problema | Causa probable | Solución recomendada |
|---|---|---|
| `airflow: command not found` | Entorno virtual no activado | Ejecutar `airflow3` y validar `which airflow`. |
| `airflow version` no muestra `3.2.1` | Se está usando otra instalación | Revisar `PATH`, `venv` y alias. |
| `airflow db check` falla | PostgreSQL detenido o credenciales incorrectas | Validar `sudo systemctl status postgresql` y probar conexión con `psql`. |
| DAG no aparece | Error de importación o DAG Processor detenido | Ejecutar `airflow dag-processor` y `airflow dags list-import-errors`. |
| UI no carga | API Server detenido o puerto ocupado | Ejecutar `airflow api-server`, revisar `ss -tulnp | grep :8080`. |
| Scheduler no planifica | Scheduler detenido o DAG pausado | Ejecutar `airflow scheduler`, `airflow dags unpause <dag_id>`. |
| Triggerer unhealthy | Triggerer detenido | Ejecutar `airflow triggerer`. |
| `airflow users` no funciona | Se usa `SimpleAuthManager` | Gestionar usuarios por configuración o cambiar a FAB con planificación. |
| `airflow webserver` no corresponde | Comando de Airflow 2.x | Usar `airflow api-server`. |
| Tarea se ejecuta dos veces | Reintentos, limpieza manual o backfill | Revisar `try_number`, `run_id`, `logical_date` y configuración de retries. |
| `tasks clear` relanza cargas duplicadas | Tarea no idempotente | Diseñar tareas idempotentes antes de limpiar estados. |
| `connections test` falla | Provider faltante o endpoint inaccesible | Revisar `airflow providers list` y conectividad de red. |

---

## 26. Buenas prácticas profesionales

1. Activar siempre el entorno antes de operar:

```bash
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a
```

2. Validar versión y ruta:

```bash
which airflow3
airflow3 version
```

3. Revisar la ayuda antes de ejecutar comandos desconocidos:

```bash
airflow3 <grupo> --help
```

4. No usar comandos destructivos sin backup.

5. No modificar manualmente el metastore salvo que sea una intervención controlada y documentada.

6. Mantener DAGs idempotentes.

7. Usar conexiones para credenciales y endpoints.

8. Usar variables para parámetros no sensibles.

9. Usar pools para proteger recursos compartidos.

10. Revisar `dags list-import-errors` antes de culpar al scheduler.

11. No usar `standalone` como modo operativo permanente.

12. No mezclar dependencias del proyecto con dependencias internas de Airflow sin validar `pip check`.

13. Mantener `api-server`, `scheduler`, `dag-processor` y `triggerer` como servicios separados cuando se opera de forma profesional.

14. Documentar cada ajuste local en el repositorio del laboratorio.

15. No publicar capturas donde aparezcan credenciales, URI de conexión completas o tokens.

---

## 27. Conclusión

El CLI de Apache Airflow 3.2.1 es una herramienta esencial para operar una plataforma de orquestación de datos con criterio profesional.

La diferencia entre un uso básico y una administración seria no está en memorizar comandos, sino en entender qué componente se está administrando, qué estado se está modificando y qué impacto tiene cada acción sobre el pipeline y el metastore.

Para el entorno académico del curso, este manual deja una base clara para operar Airflow 3.2.1 con disciplina:

- entorno activado correctamente;
- configuración validada;
- metastore controlado;
- servicios separados;
- DAGs y tareas gestionados desde CLI;
- conexiones, variables y pools administrados con trazabilidad;
- diagnóstico apoyado en CLI, HTTP, systemd y SQL de solo lectura.

Este es el punto donde Airflow deja de ser una herramienta que “corre DAGs” y pasa a ser una plataforma operacional de ingeniería de datos.

---

## 28. Referencias

1. Apache Airflow. **Apache Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/

2. Apache Airflow. **Command Line Interface and Environment Variables Reference — Airflow 3.2.1**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/cli-and-env-variables-ref.html

3. Apache Airflow. **Scheduler — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/administration-and-deployment/scheduler.html

4. Apache Airflow. **Checking Airflow Health Status**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/administration-and-deployment/logging-monitoring/check-health.html

5. Apache Airflow. **Simple Auth Manager — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/core-concepts/auth-manager/simple/index.html

6. Apache Airflow. **Auth Manager — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/core-concepts/auth-manager/index.html

7. Apache Airflow. **Upgrading Airflow to a newer version — Airflow 3.2.1 Documentation**.  
   https://airflow.apache.org/docs/apache-airflow/3.2.1/installation/upgrading.html

---

## Anexo A — Cheatsheet operativo

```bash
# ==========================================================
# 1. Activación del entorno
# ==========================================================
airflow3
set -a
source /opt/airflow3/airflow_3.2.1/configs/airflow3_lab.env
set +a

# ==========================================================
# 2. Verificación básica
# ==========================================================
which airflow3
airflow3 version
airflow3 info
pip check

# ==========================================================
# 3. Configuración
# ==========================================================
airflow3 config list
airflow3 config get-value core executor
airflow3 config get-value core auth_manager
airflow3 config get-value database sql_alchemy_conn
airflow3 config get-value database sql_alchemy_schema

# ==========================================================
# 4. Base de metadatos
# ==========================================================
airflow3 db check
airflow3 db check-migrations
airflow3 db migrate

# ==========================================================
# 5. Servicios principales
# ==========================================================
airflow3 api-server --host 0.0.0.0 --port 8080
airflow3 scheduler
airflow3 dag-processor
airflow3 triggerer

# ==========================================================
# 6. Health checks
# ==========================================================
curl -f http://localhost:8080/api/v2/monitor/health
airflow3 jobs check --job-type SchedulerJob --local
airflow3 db check

# ==========================================================
# 7. DAGs
# ==========================================================
airflow3 dags list
airflow3 dags list-import-errors
airflow3 dags show cit_validacion_airflow3
airflow3 dags pause cit_validacion_airflow3
airflow3 dags unpause cit_validacion_airflow3
airflow3 dags trigger cit_validacion_airflow3
airflow3 dags list-runs -d cit_validacion_airflow3
airflow3 dags test cit_validacion_airflow3 2026-01-01

# ==========================================================
# 8. Tasks
# ==========================================================
airflow3 tasks list cit_validacion_airflow3
airflow3 tasks list cit_validacion_airflow3 --tree
airflow3 tasks test cit_validacion_airflow3 extraer 2026-01-01
airflow3 tasks render cit_validacion_airflow3 extraer 2026-01-01
airflow3 tasks failed-deps cit_validacion_airflow3 extraer 2026-01-01

# ==========================================================
# 9. Connections
# ==========================================================
airflow3 connections list
airflow3 connections get postgres_analytics
airflow3 connections test postgres_analytics
airflow3 connections export /tmp/airflow_connections.json

# ==========================================================
# 10. Variables
# ==========================================================
airflow3 variables list
airflow3 variables set ENVIRONMENT lab
airflow3 variables get ENVIRONMENT
airflow3 variables export /tmp/airflow_variables.json

# ==========================================================
# 11. Pools
# ==========================================================
airflow3 pools list
airflow3 pools set postgres_pool 4 "Control de concurrencia hacia PostgreSQL"
airflow3 pools get postgres_pool

# ==========================================================
# 12. Providers
# ==========================================================
airflow3 providers list
airflow3 providers auth-managers
airflow3 providers executors
airflow3 providers hooks
```

---

## Anexo B — Comandos que no deben usarse sin revisar

### B.1 No usar `airflow webserver` en este entorno Airflow 3.2.1

Comando heredado de Airflow 2.x:

```bash
airflow3 webserver
```

Comando correcto en esta guía:

```bash
airflow3 api-server --host 0.0.0.0 --port 8080
```

### B.2 No usar `airflow db init` como práctica principal

En Airflow 3.2.1, la guía usa:

```bash
airflow3 db migrate
```

### B.3 No ejecutar reset sin respaldo

```bash
airflow3 db reset
```

Usar únicamente en laboratorios descartables o entornos reconstruibles.

### B.4 No limpiar tareas sin idempotencia

```bash
airflow3 tasks clear cit_validacion_airflow3
```

Antes de limpiar tareas, responder:

- ¿la tarea puede ejecutarse dos veces sin duplicar datos?
- ¿la escritura es por partición?
- ¿existe `run_id` o `logical_date` como control?
- ¿hay estrategia de rollback?

### B.5 No rotar Fernet Key sin procedimiento

```bash
airflow3 rotate-fernet-key
```

Requiere respaldo, validación y conocimiento de claves previas.
