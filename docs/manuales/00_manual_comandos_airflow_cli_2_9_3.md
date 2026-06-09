<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# 🧾Manual Académico de Comandos Básicos de Apache Airflow 2.9.3

**Institución:** Facultad Politécnica – Universidad Nacional de Asunción  
**Proyecto:** Centro de Innovación TIC Paraguay-Corea
**Curso:** Introducción a Big Data (nivel básico) / Orquestación de Pipelines  
**Autor:** Ing. Richard D. Jiménez-R.  – Arquitecto y Analista de Datos
**Fecha:** 16/01/2026  
**Versión:** 1.0  
**Entorno de referencia:**
- Apache Airflow 2.9.3.
- Python 3.12.5 (venv, pyenv)
- PostgreSQL 15 (Metadata DB)
- Executor: LocalExecutor.
- OS: Ubuntu 22.04 sobre WSL2.

---

## 1. Introducción

**Apache Airflow** es una plataforma de **orquestación de flujos de trabajo** que permite definir, programar, ejecutar y monitorear pipelines de datos de forma declarativa mediante DAGs (_Directed Acyclic Graphs_).

El uso correcto de los **comandos de línea (`airflow CLI`)** es fundamental para:

- Administrar la plataforma.
- Diagnosticar problemas.
- Automatizar tareas operativas.
- Gobernar usuarios, roles y conexiones.
- Gestionar el ciclo de vida de los DAGs.

Este manual se centra en el **aprendizaje práctico y administrativo** de dichos comandos.

---

## 2. Estructura General del CLI de Airflow

**Airflow** organiza sus comandos en dos grandes categorías:

- **Groups** → comandos de gestión (configuración, seguridad, DAGs, metadatos)    
- **Commands** → comandos operativos y de servicio.

Además, existen **servicios principales** (`webserver` / `scheduler` / `triggerer`) que sostienen la ejecución del sistema.

### 2.1  `airflow --help` — Ayuda General del CLI de Apache Airflow

El comando:

```bash
airflow3 -h
```

permite visualizar la **ayuda general del intérprete de línea de comandos (CLI)** de Apache Airflow. Proporciona una visión estructurada de los **grupos de comandos**, **comandos operativos** y **opciones globales**, constituyendo el punto de entrada natural para la administración y exploración del sistema.

Desde una perspectiva didáctica, este comando actúa como un *mapa conceptual* del ecosistema Airflow: no ejecuta acciones, pero orienta correctamente al operador antes de hacerlo.

#### Uso General

```bash
airflow3 [-h] GROUP_OR_COMMAND ...
```

Donde `GROUP_OR_COMMAND` representa un **grupo de gestión** o un **comando operativo específico**.

## Grupos de Comandos (_Groups_)

Los **Groups** agrupan comandos relacionados con la **gestión estructural y administrativa** de Airflow.

| Grupo         | Descripción                                                                            |
| ------------- | -------------------------------------------------------------------------------------- |
| `config`      | Permite visualizar y consultar la configuración activa de Airflow (`airflow.cfg`).     |
| `connections` | Gestiona las conexiones hacia sistemas externos (bases de datos, APIs, servicios).     |
| `dags`        | Administra los DAGs: listado, activación, pausa y ejecución manual.                    |
| `db`          | Ejecuta operaciones sobre la base de datos de metadatos (inicialización, migraciones). |
| `jobs`        | Permite inspeccionar y verificar los _jobs_ internos de Airflow (scheduler, tareas).   |
| `pools`       | Gestiona _pools_ de recursos para controlar la concurrencia de tareas.                 |
| `providers`   | Muestra información sobre los providers instalados y sus versiones.                    |
| `roles`       | Administra roles y permisos bajo el modelo RBAC (Role-Based Access Control).           |
| `tasks`       | Permite listar, probar y depurar tareas individuales dentro de un DAG.                 |
| `users`       | Gestiona usuarios del sistema Airflow (creación, listado, roles).                      |
| `variables`   | Administra variables globales utilizadas para parametrizar DAGs y tareas.              |

## Comandos Operativos (_Commands_)

Los **Commands** son comandos directos que ejecutan acciones específicas sobre el entorno Airflow o sus servicios.

| Comando             | Descripción (en español)                                                        |
| ------------------- | ------------------------------------------------------------------------------- |
| `cheat-sheet`       | Muestra un resumen rápido de los comandos más utilizados de Airflow.            |
| `dag-processor`     | Inicia una instancia independiente del procesador de DAGs.                      |
| `info`              | Muestra información detallada del entorno Airflow y del sistema.                |
| `kerberos`          | Inicia el renovador de tickets Kerberos (entornos corporativos).                |
| `plugins`           | Lista y describe los plugins cargados en Airflow.                               |
| `rotate-fernet-key` | Rota las claves Fernet utilizadas para cifrar conexiones y variables.           |
| `scheduler`         | Inicia una instancia del _Scheduler_, responsable de planificar tareas.         |
| `standalone`        | Ejecuta Airflow en modo todo-en-uno (uso educativo o de desarrollo).            |
| `sync-perm`         | Sincroniza permisos entre roles, usuarios y DAGs existentes.                    |
| `triggerer`         | Inicia el servicio _Triggerer_ para operadores diferidos y sensores asíncronos. |
| `version`           | Muestra la versión instalada de Apache Airflow.                                 |
| `webserver`         | Inicia el servidor web que provee la interfaz gráfica (UI) de Airflow.          |

Desde el punto de vista formativo, el comando `airflow -h` debería ser el **primer comando enseñado** a estudiantes y operadores principiantes. No solo reduce errores operativos, sino que fomenta una práctica profesional fundamental: _consultar la documentación antes de ejecutar acciones sobre un sistema productivo_ —costumbre simple, pero sorprendentemente escasa en la vida real.

| Opción         | Descripción                                            |
| -------------- | ------------------------------------------------------ |
| `-h`, `--help` | Muestra este mensaje de ayuda y finaliza la ejecución. |

---

# PARTE I — GROUPS (Grupos de comandos)

---

## 3. `airflow config` — Gestión de Configuración

### Propósito

Permite **consultar y depurar** la configuración activa de Airflow (`airflow.cfg`), incluyendo valores efectivos por sección.

### Comandos frecuentes

Lista toda la configuración activa:

```bash
airflow3 config list
```

Útil para verificar conexión a PostgreSQL (como en tu instalación):

```bash
airflow3 config get-value database sql_alchemy_conn
```

Útil para verificar el ecanismo de ejecución de tareas:

```bash
airflow3 config get-value core executor
```

El parámetro `executor` en la sección [core] de Apache Airflow 2.9.3 define el mecanismo de ejecución de tareas que usará el **Scheduler**. En otras palabras, indica cómo y dónde se lanzarán los tasks de tus DAGs (procesos locales, multiproceso, Celery, Kubernetes, etc.).

### Detalles del parámetro `executor` en [core]

```ini
[core]
executor = SequentialExecutor
```

- **Función principal:** Determina la estrategia de ejecución de las tareas programadas por el _scheduler_.
- **Impacto:** Cambiar este parámetro modifica la arquitectura de Airflow, ya que define si las tareas corren en el mismo proceso, en paralelo, distribuidas en un clúster, o dentro de pods en Kubernetes.

#### Tipos de `executor` disponibles

| Executor               | Descripción                                                                  | Uso típico                                     |
| ---------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------- |
| **SequentialExecutor** | Ejecuta tareas secuencialmente, una por vez.                                 | Desarrollo local, pruebas rápidas.             |
| **LocalExecutor**      | Usa múltiples procesos en la misma máquina para ejecutar tareas en paralelo. | Servidores únicos con buena capacidad de CPU.  |
| **CeleryExecutor**     | Distribuye tareas entre múltiples _workers_ usando Celery.                   | Escenarios distribuidos, clústeres de Airflow. |
| **KubernetesExecutor** | Lanza cada tarea en un pod independiente dentro de Kubernetes.               | Entornos cloud-native, escalabilidad dinámica. |
| **DebugExecutor**      | Ejecuta tareas de forma inmediata en el mismo proceso (sin scheduler real).  | Depuración y pruebas unitarias.                |

Si en tu `airflow.cfg` defines:

```ini
[core]
executor = LocalExecutor
```

- El _scheduler_ lanzará tareas en paralelo usando procesos locales.
- Ideal si trabajas en un servidor con múltiples núcleos y quieres aprovechar concurrencia sin necesidad de un clúster externo.

En cambio, si usas:

```ini
[core]
executor = CeleryExecutor
```

- Las tareas se enviarán a un _broker_ (ej. Redis o RabbitMQ).
- Los _workers_ distribuidos las ejecutarán, permitiendo escalar horizontalmente.

#### Consideraciones importantes

- **Dependencias externas:**
    - `CeleryExecutor` requiere un _broker_ (Redis/RabbitMQ).
    - `KubernetesExecutor` necesita un clúster Kubernetes configurado.
- **Escalabilidad:**
    - Sequential → mínimo.
    - Local → limitado al servidor.
    - Celery/Kubernetes → escalable horizontalmente.
- **Uso recomendado:**
    - Desarrollo: `SequentialExecutor`.
    - Producción pequeña: `LocalExecutor`.
    - Producción grande/distribuida: `CeleryExecutor` o `KubernetesExecutor`.

### Aplicación
- Comprender el impacto de cada parámetro.
- Enseñar separación entre configuración lógica y física.
- Auditoría técnica del entorno.

---

## 4. `airflow connections` — Gestión de Conexiones

### Propósito

Administra credenciales y endpoints hacia sistemas externos (BDs, APIs, FTP, etc.).

### Listar conexiones

```bash
airflow3 connections list
```

### Crear conexión PostgreSQL

```bash
airflow3 connections add postgres_analytics \
  --conn-type postgres \
  --conn-host localhost \
  --conn-schema analytics_db \
  --conn-login user \
  --conn-password pass \
  --conn-port 5432
```

### Probar conexión

```bash
airflow3 connections test postgres_analytics
```

### Aplicación
- Externalización de credenciales.
- Principios de seguridad y desacoplamiento.
- Buenas prácticas DevOps.

---

## 5. `airflow dags` — Gestión de DAGs

### Listar DAGs disponibles

```bash
airflow3 dags list
```

### Ver detalles de un DAG

```bash
airflow3 dags show dag_etl_nomina
```

### Activar / desactivar DAG

```bash
airflow3 dags unpause dag_etl_nomina
airflow3 dags pause dag_etl_nomina
```

### Ejecutar manualmente un DAG

```bash
airflow3 dags trigger dag_etl_nomina
```

### Aplicación
- Ciclo de vida del DAG.
- Diferencia entre definición y ejecución.
- Control operacional del pipeline.

---

## 6. `airflow jobs` — Gestión de Jobs Internos

### Propósito

Gestiona procesos internos de Airflow (scheduler jobs, local task jobs, etc.).

```bash
airflow3 jobs check --job-type SchedulerJob
```

### Aplicación

- Diagnóstico de fallos.
- Comprensión de la arquitectura interna.
- Análisis de disponibilidad del sistema.

---

## 7. `airflow providers` — Gestión de Providers

### Listar providers instalados

```bash
airflow3 providers list
```

### Aplicación


- Arquitectura modular.
- Extensibilidad de Airflow.
- Integración con ecosistemas externos.

---

## 8. `airflow roles` — Gestión de Roles (RBAC)

```bash
airflow3 roles list
```

```bash
airflow3 roles create data_engineer
```

```bash
airflow3 roles add-perms data_engineer \
  --resource DAG \
  --action read
```

### Aplicación

- Control de acceso.
- Gobernanza.
- Principios de seguridad empresarial.

---

## 9. `airflow users` — Gestión de Usuarios

```bash
airflow3 users list
```

```bash
airflow3 users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@airflow3.local \
  --password admin123
```

### Aplicación

- Multiusuario.
- Separación de responsabilidades.
- Auditoría.

---

## 10. `airflow tasks` — Gestión de Tareas

```bash
airflow3 tasks list dag_etl_nomina
```

```bash
airflow3 tasks test dag_etl_nomina extract_task 2025-01-01
```

### Aplicación

- Debugging.
- Enseñar idempotencia.
- Pruebas controladas.

---

## 11. `airflow variables` — Gestión de Variables

```bash
airflow3 variables list
```

```bash
airflow3 variables set ENVIRONMENT prod
```

```bash
airflow3 variables get ENVIRONMENT
```

### Aplicación

- Parametrización.
- Configuración por entorno.
- Buenas prácticas de diseño.

---

# PARTE II — COMMANDS (Comandos operativos)

---

## 12. `airflow cheat-sheet`

```bash
airflow3 cheat-sheet
```

Resumen rápido de comandos.  
Ideal como material de consulta para estudiantes.

---

## 13. `airflow dag-processor`

```bash
airflow3 dag-processor
```

Ejecuta un procesador de DAGs independiente.

Uso avanzado, útil para:
- Diagnóstico.
- Entornos de alto volumen.

---

## 14. `airflow info`

```bash
airflow3 info
```

Muestra **estado completo del entorno** Apache AIrflow y el sistema operativo.  

---

## 15. `airflow plugins`

```bash
airflow3 plugins
```

Lista plugins cargados.

---

## 16. `airflow rotate-fernet-key`

```bash
airflow3 rotate-fernet-key
```

Rota claves de cifrado de conexiones y variables.

Uso recomendado en entornos productivos.

---

## 17. `airflow standalone`

```bash
airflow3 standalone
```

Arranca Airflow todo-en-uno (solo desarrollo).

No recomendado para producción, pero muy útil en enseñanza.

---

## 18. `airflow sync-perm`

```bash
airflow3 sync-perm
```

Sincroniza permisos entre DAGs, roles y usuarios.

---

## 19. `airflow version`

```bash
airflow3 version
```

Salida:

```
2.9.3
```

---

# PARTE III — Servicios Principales de Airflow

---

## 20. `airflow webserver`

### Función

Interfaz gráfica (UI).

```bash
airflow3 webserver --port 8080
```

Acceso:

```
http://localhost:8080
```

---

## 21. `airflow scheduler`

### Función

Corazón del sistema:

- Decide cuándo ejecutar tareas.
- Envía tareas al `executor`.

```bash
airflow3 scheduler
```

---

## 22. `airflow triggerer`

### Función

Gestiona **deferrable operators** y sensores asíncronos.

```bash
airflow3 triggerer
```

Uso clave en pipelines modernos y eficientes.

---

## 23. Conclusión

El dominio del **CLI de Apache Airflow** no es un lujo técnico, sino una **competencia estructural** para perfiles de:

- Ingeniero de Datos.
- Arquitecto de Datos.
- Administrador de Plataformas Analíticas.

Este manual puede utilizarse:

- Como material de cátedra.
- Como guía de laboratorio.
- Como referencia operativa diaria.

# PARTE IV — Monitoreos básicos de un DAG

Para monitorear cuántas veces se lanza un DAG y qué tareas se ejecutan, Airflow te ofrece varias herramientas y prácticas:

### 1. **UI de Airflow (Webserver)**

- En la pestaña **DAGs** puedes ver:
    - El número de ejecuciones activas de cada DAG.
    - El historial de ejecuciones (ejemplo: `2026-02-16T07:30:00`, `2026-02-17T07:30:00`, etc.).
- En la vista **Graph** o **Tree** puedes inspeccionar qué tareas se lanzaron en cada ejecución y su estado (running, success, failed).

### 2. **Logs de Scheduler**

- El **scheduler** escribe en los logs cada vez que programa una ejecución de DAG.
- Busca entradas como:
    
    ```
    INFO - DAG servicios_roaming_dag is scheduled for execution at 2026-02-18T07:30:00
    ```
    
- Si ves dos entradas para la misma fecha/hora, puede indicar un bug o configuración que dispara ejecuciones duplicadas.

### 3. **Comandos CLI**

Puedes usar la CLI de Airflow para auditar ejecuciones:

- Listar ejecuciones de un DAG:
    
    ```bash
    airflow3 dags list-runs -d servicios_roaming_dag
    ```
    
    Esto muestra todas las ejecuciones con su estado y fecha.
    
- Listar tareas de una ejecución específica:
    
    ```bash
    airflow3 tasks list servicios_roaming_dag
    airflow3 tasks states servicios_roaming_dag <execution_date>
    ```
    

### 4. **Base de datos interna**

Airflow guarda todo en su **metastore** (PostgreSQL).

- Tabla `dag_run`: contiene cada ejecución del DAG.
- Tabla `task_instance`: contiene cada tarea lanzada, con su estado y timestamps.  
    Puedes consultar directamente:

```sql
SELECT dag_id, execution_date, state
FROM dag_run
WHERE dag_id = 'servicios_roaming_dag'
ORDER BY execution_date DESC;
```

### 5. **Posibles causas de ejecuciones duplicadas**

- `max_active_runs_per_dag` demasiado alto (permite varias ejecuciones simultáneas).
- DAG habilitado y deshabilitado varias veces en la UI.
- Cambios en `start_date` o `schedule_interval` que generan nuevas ejecuciones.
- Bugs del scheduler (menos común, pero puede pasar en ciertas versiones).

Perfecto, aquí tienes una consulta SQL lista para pegar en el **metastore de Airflow** (PostgreSQL) y verificar si tu DAG se está ejecutando más de una vez en la misma fecha/hora:

```sql
-- Ver ejecuciones del DAG y detectar posibles duplicados
SELECT dag_id,
       execution_date,
       run_id,
       state,
       start_date,
       end_date
FROM dag_run
WHERE dag_id = 'servicios_roaming_dag'
ORDER BY execution_date DESC;
```

## DAG_RUN

Si ves **dos filas con el mismo `execution_date`**, significa que el *scheduler* lanzó más de una ejecución para la misma fecha/hora.

Para profundizar y ver las tareas asociadas a cada ejecución:

```sql
-- Ver tareas ejecutadas en cada run del DAG
SELECT dag_id,
       execution_date,
       task_id,
       state,
       start_date,
       end_date,
       try_number
FROM task_instance
WHERE dag_id = 'servicios_roaming_dag'
ORDER BY execution_date DESC, task_id;
```

### Qué observar

- **Duplicados en `execution_date`** → *scheduler* disparó dos veces el mismo run.
- **Mismo `task_id` con varios `try_number`** → la tarea se reintentó (aunque en tu *config* tienes `default_task_retries=0`, puede haber reintentos manuales o forzados).
- **Estados `running` simultáneos** → varias instancias del DAG activas al mismo tiempo.

Con esto puedes confirmar si el problema viene de un bug del *scheduler* o de la configuración de concurrencia (`max_active_runs_per_dag` demasiado alto).

Aquí tienes una consulta que te permite **detectar rápidamente si tu DAG se está lanzando más de una vez en la misma fecha/hora**. La idea es agrupar por `execution_date` y contar cuántos registros existen:

```sql
-- Contar cuántas ejecuciones hay por fecha de ejecución
SELECT dag_id,
       execution_date,
       COUNT(*) AS num_runs
FROM dag_run
WHERE dag_id = 'servicios_roaming_dag'
GROUP BY dag_id, execution_date
HAVING COUNT(*) > 1
ORDER BY execution_date DESC;
```

### Qué hace

- Agrupa todas las ejecuciones (`dag_run`) por `execution_date`.
- Cuenta cuántas veces aparece cada fecha.
- Filtra solo aquellas fechas con más de una ejecución (`HAVING COUNT(*) > 1`).
- Ordena de más reciente a más antiguo.

Si esta consulta devuelve filas, significa que el **scheduler disparó más de una ejecución para el mismo `execution_date`**, lo cual confirmaría tu sospecha de duplicados.

### Complemento: ver estados de esas ejecuciones

Para inspeccionar más a fondo los duplicados:

```sql
SELECT dag_id,
       execution_date,
       run_id,
       state,
       start_date,
       end_date
FROM dag_run
WHERE dag_id = 'servicios_roaming_dag'
  AND execution_date IN (
      SELECT execution_date
      FROM dag_run
      WHERE dag_id = 'servicios_roaming_dag'
      GROUP BY execution_date
      HAVING COUNT(*) > 1
  )
ORDER BY execution_date DESC, run_id;
```

Esto te mostrará cada ejecución duplicada con su estado (`running`, `success`, `failed`) y sus timestamps.

## TASK_INSTANCE

Aquí tienes una consulta enfocada en la tabla `task_instance` para detectar si las **tareas de tu DAG se están lanzando más de una vez dentro de un mismo run**:

```sql
-- Contar cuántas veces se ejecuta cada tarea por fecha de ejecución
SELECT dag_id,
       execution_date,
       task_id,
       COUNT(*) AS num_task_instances
FROM task_instance
WHERE dag_id = 'servicios_roaming_dag'
GROUP BY dag_id, execution_date, task_id
HAVING COUNT(*) > 1
ORDER BY execution_date DESC, task_id;
```

### Qué hace

- Agrupa por `dag_id`, `execution_date` y `task_id`.
- Cuenta cuántas instancias de cada tarea existen en un mismo run.
- Filtra solo aquellas con más de una ejecución (`HAVING COUNT(*) > 1`).
- Ordena para que veas primero las más recientes.

### Interpretación

- Si aparece un `task_id` con `num_task_instances > 1` en la misma `execution_date`, significa que esa tarea se lanzó más de una vez.
- Puede deberse a reintentos manuales, a que el scheduler disparó duplicados, o a que la tarea se marcó como “rescheduled” por algún motivo interno.

### Complemento: ver detalles de esas instancias

```sql
SELECT dag_id,
       execution_date,
       task_id,
       try_number,
       state,
       start_date,
       end_date,
       run_id
FROM task_instance
WHERE dag_id = 'servicios_roaming_dag'
  AND (dag_id, execution_date, task_id) IN (
      SELECT dag_id, execution_date, task_id
      FROM task_instance
      WHERE dag_id = 'servicios_roaming_dag'
      GROUP BY dag_id, execution_date, task_id
      HAVING COUNT(*) > 1
  )
ORDER BY execution_date DESC, task_id, try_number;
```

Esto te mostrará cada intento (`try_number`) y su estado (`running`, `success`, `failed`) para las tareas duplicadas.

---

Con estas consultas puedes confirmar si el problema está en **ejecuciones duplicadas del DAG** o en **tareas que se relanzan dentro de un mismo run**.

## Reporte `dag_run` y `task_instance`

Aquí tienes una consulta que combina **`dag_run`** y **`task_instance`** en un solo reporte, para que puedas ver de inmediato qué ejecuciones del DAG se duplican y qué tareas se lanzaron más de una vez:

```sql
-- Reporte combinado de runs y tareas duplicadas
SELECT dr.dag_id,
       dr.execution_date,
       dr.run_id,
       dr.state AS dag_state,
       ti.task_id,
       ti.try_number,
       ti.state AS task_state,
       ti.start_date,
       ti.end_date
FROM dag_run dr
JOIN task_instance ti
  ON dr.dag_id = ti.dag_id
 AND dr.execution_date = ti.execution_date
WHERE dr.dag_id = 'servicios_roaming_dag'
  AND (
        -- Detectar runs duplicados
        dr.execution_date IN (
            SELECT execution_date
            FROM dag_run
            WHERE dag_id = 'servicios_roaming_dag'
            GROUP BY execution_date
            HAVING COUNT(*) > 1
        )
        OR
        -- Detectar tareas duplicadas dentro de un run
        (ti.dag_id, ti.execution_date, ti.task_id) IN (
            SELECT dag_id, execution_date, task_id
            FROM task_instance
            WHERE dag_id = 'servicios_roaming_dag'
            GROUP BY dag_id, execution_date, task_id
            HAVING COUNT(*) > 1
        )
      )
ORDER BY dr.execution_date DESC, ti.task_id, ti.try_number;
```

### Qué obtendrás

- Cada fila corresponde a una tarea (`task_instance`) dentro de un run (`dag_run`).
- Podrás ver:
    - **`dag_state`**: estado del run completo (ej. `running`, `success`, `failed`).
    - **`task_state`**: estado de cada tarea.
    - **`try_number`**: cuántas veces se intentó ejecutar esa tarea.
- El filtro asegura que solo se muestren:
    - Runs duplicados (mismo `execution_date` con más de un `run_id`).
    - Tareas duplicadas (mismo `task_id` ejecutado más de una vez en un run).

Con este reporte combinado puedes identificar de un vistazo si el problema viene de **ejecuciones duplicadas del DAG** o de **tareas relanzadas dentro de un mismo run**.

¿Quieres que te prepare también una versión resumida que solo muestre el **conteo de duplicados por run y por tarea**, para que tengas una visión más compacta antes de entrar en los detalles?
