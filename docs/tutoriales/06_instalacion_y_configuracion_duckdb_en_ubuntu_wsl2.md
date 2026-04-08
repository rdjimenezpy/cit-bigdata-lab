<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración de DuckDB en WSL2/Ubuntu
**Entorno Windows 11 + WSL2 + Ubuntu 22.04.5 LTS + Python 3.12 – Despliegue de DuckDB para uso académico en laboratorios de Big Data e Ingeniería de Datos**

---

## Datos institucionales

**Institución:** Universidad Nacional de Asunción  
**Unidad Académica:** Facultad Politécnica  
**Dependencia:** Centro de Innovación TIC (PK)  
**Área:** Big Data   **Nivel:** Básico  
**Curso:** Introducción a Big Data   **Enfoque:** Fundamentos y Pipelines de Datos con Python  
**Docente:** Prof. Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción  

---

## Fecha y versión

- **Fecha:** 19/03/2026
- **Versión:** 1.0

---

## Nota sobre esta documentación

Este tutorial fue ajustado para el **entorno técnico de referencia de la cátedra**, basado en **Windows 11 + WSL2 + Ubuntu 22.04.5 LTS**, con gestión de Python mediante **pyenv** y uso de herramientas del stack de ingeniería de datos sobre Linux.

En esta guía, **DuckDB** se instala y configura como **motor analítico embebido** para laboratorios, pruebas de concepto y ensayos. A diferencia de PostgreSQL, DuckDB **no requiere un servicio en background**, **no usa `systemd`** y **no necesita un modelo cliente-servidor** para operar. Esa diferencia es fundamental y debe quedar clara desde el inicio.

La versión original del borrador mezclaba conceptos correctos con otros que conviene separar mejor. El principal ajuste de esta versión es metodológico:

- este documento queda enfocado en **DuckDB**;
- y la ruta recomendada para el curso es instalar **dos componentes complementarios**:
  - el **CLI oficial** de DuckDB para trabajo interactivo;
  - y el **paquete Python `duckdb`** dentro de un entorno virtual para scripts, notebooks y automatización.

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

---

## 1. Introducción

**DuckDB** es un sistema gestor de bases de datos analítico, relacional, columnar y embebido, diseñado para ejecutar cargas **OLAP** de forma muy eficiente. Su propuesta es distinta a la de motores tradicionales como PostgreSQL:

- **PostgreSQL** opera como servidor y es ideal para cargas **OLTP** y multiusuario.
- **DuckDB** corre dentro del proceso de la aplicación o desde su propio cliente CLI, y está optimizado para análisis local, lectura de archivos y procesamiento analítico.

En este proyecto, DuckDB cumple el rol de **motor analítico local** para:

- exploración de datos,
- consultas SQL analíticas,
- prototipos de data warehouse,
- lectura de archivos CSV y Parquet,
- y soporte a etapas posteriores del stack con Python, dbt y orquestación.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- Comprender qué es DuckDB y cuál es su rol dentro del stack del proyecto.
- Instalar el **CLI oficial** de DuckDB en Ubuntu sobre WSL2.
- Agregar el ejecutable al `PATH` del usuario.
- Instalar el paquete **DuckDB para Python** dentro de un entorno virtual.
- Crear y abrir una base de datos persistente `.duckdb`.
- Ejecutar consultas básicas desde el CLI y desde Python.
- Entender cómo se organizan los archivos de DuckDB dentro del repositorio del proyecto.
- Aplicar buenas prácticas para no mezclar artefactos locales con código fuente versionado.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** DuckDB  
**Versión objetivo:** CLI oficial de DuckDB + paquete Python `duckdb`  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Entorno de trabajo:** `/opt/repo/cit-bigdata-lab`  
**IDE / cliente sugerido:** terminal Bash, DuckDB CLI y PyCharm  
**Tipo de uso:** instalación, configuración, validación operativa y uso base para laboratorio  

### Este tutorial cubre

- instalación del **CLI oficial** de DuckDB en Ubuntu sobre WSL2;
- instalación del paquete **DuckDB para Python** dentro de un entorno virtual;
- creación y validación de una base `.duckdb` persistente;
- consultas básicas desde CLI y desde Python;
- lineamientos iniciales de organización de artefactos DuckDB dentro del repositorio.

### Este tutorial no cubre

- integración con **MotherDuck**;
- autenticación por token o conexión a servicios cloud;
- integración con **dbt-duckdb** y herramientas BI sobre DuckDB.

---

## 4. Contexto técnico

### 4.1 Rol de DuckDB dentro del stack del proyecto

Dentro del stack de `CIT-BIGDATA-LAB`, DuckDB cumple principalmente el papel de:

- **motor OLAP local**,
- laboratorio analítico liviano,
- soporte para pruebas SQL,
- base para transformaciones locales,
- y entorno de experimentación reproducible.

De forma resumida:

- **PostgreSQL** → capa operacional / relacional / OLTP
- **DuckDB** → capa analítica local / OLAP
- **Pentaho Data Integration** → integración y transformación
- **Apache Airflow** → orquestación
- **Python** → automatización, pruebas y utilitarios
- **DBeaver** → exploración y consulta interactiva

### 4.2 Conceptos previos que debes entender

### 4.1 DuckDB no es un servidor

Este punto es crítico.

Con DuckDB:

- no levantas un servicio con `systemctl`;
- no administras puertos como `5432`;
- no configuras `postgresql.conf` o `pg_hba.conf`;
- no necesitas un demonio residente.

DuckDB trabaja de otra forma:

- desde su **CLI**;
- desde una **librería Python**;
- o desde otros clientes compatibles.

### 4.2 DuckDB puede trabajar en memoria o sobre archivo

Tienes dos modos comunes:

- **Base temporal en memoria**: útil para pruebas rápidas.
- **Base persistente en archivo**: útil para laboratorios y ejercicios que deben conservarse.

Ejemplo de archivo persistente:

```bash
duckdb /opt/repo/cit-bigdata-lab/data/duckdb/lab.duckdb
```

### 4.3 DuckDB está optimizado para análisis

DuckDB destaca especialmente en:

- agregaciones,
- `GROUP BY`,
- joins analíticos,
- lectura directa de CSV y Parquet,
- consultas exploratorias,
- integración con Python y ecosistema analítico.

---

## 5. Requisitos previos

Antes de instalar DuckDB, verifica que ya dispones de:

- Windows 11 operativo.
- WSL2 instalado y funcional.
- Ubuntu 22.04.5 LTS operativo.
- Python 3.12.5 instalado en Linux.
- Un entorno de trabajo local, por ejemplo:
  - `/opt/repo/cit-bigdata-lab`
- Conectividad a Internet.
- Usuario Linux con acceso a `curl`.
- Conocimientos básicos de terminal Bash.

> El comando `curl` es una herramienta de línea de comandos que sirve para transferir datos hacia o desde un servidor usando URLs, soportando múltiples protocolos como HTTP, HTTPS, FTP, SFTP, entre otros.

### Verificaciones rápidas

```bash
uname -a
lsb_release -a
python --version
which python
pwd
```

---

## 6. Arquitectura o flujo de referencia

### 6.1 Estrategia recomendada de instalación para la cátedra

Para este curso, la decisión correcta no es elegir “CLI o Python”, sino instalar ambos.

### Ruta recomendada

1. **Instalar el CLI oficial de DuckDB**  
   Para trabajo interactivo en terminal y validación rápida.

2. **Instalar el paquete `duckdb` en Python**  
   Para scripts, notebooks, automatización y pasos posteriores del stack.

### ¿Por qué esta combinación?

Porque cubre dos necesidades reales del laboratorio:

- inspección rápida y aprendizaje de SQL desde terminal;
- y automatización práctica dentro de Python.

### 6.2 Consideración importante sobre versiones

Al momento de esta revisión, la documentación oficial de DuckDB muestra dos líneas de instalación visibles:

- **Current:** `1.5.0`
- **LTS:** `1.4.4`

Para un curso o cohorte, lo correcto es **fijar una versión única** cuando la reproducibilidad sea prioritaria. Si no necesitas congelar la versión del laboratorio, puedes usar la estable actual. Si quieres mayor estabilidad docente, puedes optar por la línea **LTS**.

### Recomendación pedagógica

- **Para exploración personal:** usar la estable actual.
- **Para una cohorte completa con tutoriales cerrados:** considerar congelar la versión LTS o una versión específica del curso.

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `SQL`, `Bash`, `Python`, `text` y `gitignore` → lenguajes o formatos utilizados en los ejemplos.

---

## 8. Procedimiento paso a paso

### 8.1 Paso 1 — Preparar directorios de trabajo en el repositorio

Ubícate en tu repositorio local:

```bash
cd /opt/repo/cit-bigdata-lab
```

Crea un directorio para artefactos locales de DuckDB:

```bash
mkdir -p data/duckdb
mkdir -p database/duckdb/analytical_queries
mkdir -p database/duckdb/ddl
```

### ¿Por qué separar estas rutas?

Porque no debes mezclar:

- **archivos fuente SQL** → `database/duckdb/...`
- **bases locales `.duckdb`** → `data/duckdb/...`

Esta separación evita desorden y mejora la trazabilidad del proyecto.

### 8.2 Paso 2 — Instalar el CLI oficial de DuckDB

La documentación oficial recomienda el script de instalación para Linux y macOS.

Ejecuta:

```bash
curl https://install.duckdb.org | sh
```

### ¿Qué hace este comando?

- descarga el ejecutable oficial;
- lo instala en el directorio del usuario;
- y crea un enlace simbólico bajo `~/.duckdb/cli/latest/`.

### Ejemplo de salida esperada

```text
Successfully installed DuckDB binary to /home/usuario/.duckdb/cli/<version>/duckdb
with a link from /home/usuario/.duckdb/cli/latest/duckdb
```

### 8.3 Paso 3 — Agregar DuckDB al `PATH`

Agrega esta línea a tu `~/.bashrc`:

```bash
echo 'exported PATH="$HOME/.duckdb/cli/latest:$PATH"' >> ~/.bashrc
```

Recarga la configuración:

```bash
source ~/.bashrc
```

Verifica que el binario esté disponible:

```bash
which duckdb
duckdb --version
```

### Resultado esperado

Deberías ver:

- una ruta válida al binario;
- y la versión instalada.

### 8.4 Paso 4 — Fijar una versión específica del CLI (opcional)

Si quieres congelar una versión concreta para la cohorte, puedes usar la variable `DUCKDB_VERSION`.

Ejemplo:

```bash
curl https://install.duckdb.org | DUCKDB_VERSION=1.4.4 sh
```

> Esta opción es útil cuando quieres que todos los estudiantes trabajen exactamente con la misma versión del cliente.

### 8.5 Paso 5 — Instalar DuckDB en Python dentro del entorno virtual

Ubícate en el repositorio:

```bash
cd /opt/repo/cit-bigdata-lab
```

Si todavía no tienes un entorno virtual local para el proyecto, créalo:

```bash
python -m venv .venv
```

Actívalo:

```bash
source .venv/bin/activate
```

Actualiza `pip`:

```bash
python -m pip install --upgrade pip
```

Instala DuckDB para Python:

```bash
pip install duckdb
```

Verifica la instalación:

```bash
python -c "import duckdb; print(duckdb.__version__)"
```

### Resultado esperado

Se debe imprimir la versión del paquete Python instalado.

### 8.6 Paso 6 — Crear tu primera base de datos DuckDB persistente

Crea y abre una base de datos persistente:

```bash
duckdb /opt/repo/cit-bigdata-lab/data/duckdb/lab.duckdb
```

Cuando el CLI se abra, ejecuta:

```sql
PRAGMA version;
SELECT current_database();
SELECT current_schema();
```

Luego crea una tabla simple:

```sql
CREATE TABLE IF NOT EXISTS demo_clientes (
    id INTEGER,
    nombre VARCHAR,
    ciudad VARCHAR
);
```

Inserta algunos datos:

```sql
INSERT INTO demo_clientes VALUES
(1, 'Ana', 'Asunción'),
(2, 'Luis', 'San Lorenzo'),
(3, 'Marta', 'Fernando de la Mora');
```

Consulta la tabla:

```sql
SELECT * FROM demo_clientes;
```

Lista tablas existentes:

```sql
.tables
```

Muestra el esquema:

```sql
.schema demo_clientes
```

Salir del CLI:

```sql
.quit
```

### 8.7 Paso 7 — Verificar persistencia del archivo

Vuelve a abrir la base:

```bash
duckdb /opt/repo/cit-bigdata-lab/data/local/duckdb/lab.duckdb
```

Verifica que la tabla siga existiendo:

```sql
SELECT * FROM demo_clientes;
```

Si la tabla aparece con los registros insertados, la base persistente está funcionando correctamente.

### 8.8 Paso 8 — Abrir una base temporal en memoria

También puedes abrir DuckDB sin persistencia en disco:

```bash
duckdb
```

O dentro del CLI:

```sql
.open
```

Esto crea una base **en memoria** que se pierde al cerrar la sesión.

### ¿Cuándo conviene usar esto?

- pruebas rápidas;
- ejemplos de clase;
- validación de sentencias SQL;
- ejercicios descartables.

### 8.9 Paso 9 — Ejecutar consultas sobre archivos locales

Una ventaja fuerte de DuckDB es que puede consultar archivos analíticos de forma directa.

### Ejemplo con CSV

```sql
SELECT *
FROM read_csv_auto('/opt/repo/cit-bigdata-lab/data/exported/sample_clientes.csv')
LIMIT 10;
```

### Ejemplo con Parquet

```sql
SELECT COUNT(*)
FROM read_parquet('/opt/repo/cit-bigdata-lab/data/sample_ventas.parquet');
```

### Observación técnica

No necesitas “importar” los archivos como paso obligatorio previo en todos los casos. DuckDB puede consultarlos directamente.

### 8.10 Paso 10 — Instalar y cargar extensiones manualmente

DuckDB soporta extensiones oficiales. Algunas se cargan automáticamente al primer uso, pero conviene que el estudiante aprenda el mecanismo explícito.

### Ejemplo con `httpfs`

Dentro del CLI:

```sql
INSTALL httpfs;
LOAD httpfs;
```

Con esa extensión puedes trabajar con recursos HTTP(S) y almacenamiento compatible con S3 en distintos escenarios.

### Verificar extensiones instaladas

```sql
SELECT * FROM duckdb_extensions();
```

### 8.11 Paso 11 — Probar DuckDB desde Python

Crea un script de prueba:

```bash
mkdir -p /opt/repo/cit-bigdata-lab/python/scripts
nano /opt/repo/cit-bigdata-lab/python/scripts/check_duckdb.py
```

Contenido sugerido:

```python
import duckdb

DB_PATH = "/opt/repo/cit-bigdata-lab/data/duckdb/lab_python.duckdb"

con = duckdb.connect(DB_PATH)

con.execute(
    """
    CREATE TABLE IF NOT EXISTS ventas_demo (
        id INTEGER,
        producto VARCHAR,
        importe DOUBLE
    )
    """
)

con.execute(
    """
    INSERT INTO ventas_demo VALUES
    (1, 'Notebook', 3500.00),
    (2, 'Monitor', 1200.00),
    (3, 'Mouse', 150.00)
    """
)

resultado = con.execute(
    """
    SELECT producto, importe
    FROM ventas_demo
    ORDER BY importe DESC
    """
).fetchall()

print("Resultado:", resultado)

con.close()
```

Ejecuta el script:

```bash
source /opt/repo/cit-bigdata-lab/.venv/bin/activate
python /opt/repo/cit-bigdata-lab/scripts/python/check_duckdb.py
```

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- el comando `which duckdb` devuelve una ruta válida al binario instalado;
- el comando `duckdb --version` muestra una versión operativa del CLI;
- el comando `python -c "import duckdb; print(duckdb.__version__)"` responde correctamente dentro del entorno virtual;
- la base persistente creada puede reabrirse y conserva la tabla `demo_clientes`;
- el script de prueba en Python ejecuta consultas y devuelve resultados sin errores.

### Comandos de validación

```bash
which duckdb
duckdb --version
python -c "import duckdb; print(duckdb.__version__)"
duckdb /opt/repo/cit-bigdata-lab/data/duckdb/bigdata-lab.duckdb
source /opt/repo/cit-bigdata-lab/.venv/bin/activate
python /opt/repo/cit-bigdata-lab/scripts/python/check_duckdb.py
```

### Evidencia esperada

La validación se considera satisfactoria cuando:

- el CLI de DuckDB está accesible desde el `PATH`;
- el paquete Python `duckdb` puede importarse sin errores;
- la base `.duckdb` abre correctamente y conserva objetos creados en pasos anteriores;
- y el script Python imprime un resultado similar a una lista ordenada de registros.

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `duckdb: command not found` | El binario no fue agregado correctamente al `PATH`. | `echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> ~/.bashrc && source ~/.bashrc && which duckdb` |
| El CLI funciona, pero Python no encuentra el módulo | `duckdb` no fue instalado en el entorno virtual activo. | `source /opt/repo/cit-bigdata-lab/.venv/bin/activate && pip install duckdb && python -c "import duckdb; print(duckdb.__version__)"` |
| La versión del CLI y la del paquete Python no coinciden | Son mecanismos de distribución distintos. | Congelar explícitamente ambas versiones si se requiere máxima reproducibilidad para el laboratorio. |
| Fallan `INSTALL` o `LOAD` de extensiones | Problemas de conectividad, proxy o descarga temporal. | Verificar conectividad, reintentar y documentar el error exacto. |
| El estudiante intenta “levantar el servicio de DuckDB” | Confusión conceptual con PostgreSQL u otros motores cliente-servidor. | Recordar que DuckDB se usa desde el cliente o desde librerías, no como servicio Linux estándar. |

---

## 11. Buenas prácticas

### 11.1 Buenas prácticas para organizar DuckDB dentro del repo

### 19.1 Qué sí debe ir versionado

Sí conviene versionar:

- scripts SQL;
- documentación;
- semillas pequeñas de datos;
- scripts Python;
- notebooks de apoyo;
- plantillas y ejemplos.

### 19.2 Qué no debe ir versionado

No conviene subir al repositorio:

- archivos `.duckdb` generados localmente;
- artefactos grandes de prueba;
- cachés temporales;
- salidas intermedias pesadas.

### 19.3 Recomendación de `.gitignore`

Agrega al `.gitignore` del proyecto algo como:

```gitignore
# DuckDB
data/duckdb/*.duckdb
data/duckdb/*.duckdb.wal
```

### 19.4 Estructura sugerida

```text
/opt/repo/cit-bigdata-lab
├── data/
│   └── duckdb/
│       └── lab.duckdb
├── database/
│   └── duckdb/
│       ├── ddl/
│       └── analytical_queries/
└── scripts/
    └── python/
```

### 11.2 Uso recomendado con PyCharm

Como vas a trabajar con **PyCharm** para gestionar el repositorio:

- abre el proyecto desde `/opt/repo/cit-bigdata-lab`;
- selecciona el intérprete asociado a `.venv`;
- deja DuckDB instalado dentro de ese entorno virtual;
- y usa scripts Python para validaciones reproducibles.

### Recomendación práctica

No dependas solo del CLI. Usa ambos enfoques:

- **CLI** para exploración rápida;
- **Python** para automatización reproducible.

---

## 12. Conclusión

### 12.1 Qué conviene hacer después de este tutorial

Una vez completado este documento, el siguiente paso lógico no es “seguir instalando por instalar”. Lo correcto es comenzar a usar DuckDB de forma controlada en el proyecto:

1. crear archivos `.duckdb` locales de laboratorio;
2. cargar archivos CSV o Parquet;
3. diseñar consultas analíticas;
4. organizar scripts SQL en `database/duckdb`;
5. y preparar la transición hacia herramientas como dbt, Pentaho o procesos Python.

### 12.2 Conclusión

DuckDB es una pieza muy útil dentro del stack porque resuelve un problema diferente al de PostgreSQL. No compiten directamente; se complementan.

La mejora clave de esta versión del tutorial frente al borrador original es que el documento queda mejor delimitado:

- explica qué es DuckDB sin mezclarlo innecesariamente con MotherDuck;
- separa el uso del **CLI** y del **paquete Python**;
- alinea el tutorial con el entorno real del proyecto;
- y deja una estructura de trabajo más sana para el repositorio local.

En otras palabras: queda menos “apunte suelto” y más **manual técnico reproducible**.

---

## 13. Referencias

1. DuckDB Foundation. **DuckDB Installation**.  
   https://duckdb.org/install/

2. DuckDB Foundation. **Install Script**.  
   https://duckdb.org/docs/stable/operations_manual/installing_duckdb/install_script

3. DuckDB Foundation. **Command Line Client**.  
   https://duckdb.org/docs/stable/clients/cli/overview

4. DuckDB Foundation. **Python API**.  
   https://duckdb.org/docs/stable/clients/python/overview

5. DuckDB Foundation. **Installing Extensions**.  
   https://duckdb.org/docs/stable/extensions/installing_extensions.html

6. DuckDB Foundation. **httpfs Extension**.  
   https://duckdb.org/docs/stable/core_extensions/httpfs/overview

7. DuckDB Foundation. **Extensions Overview**.  
   https://duckdb.org/docs/stable/extensions/overview.html

---

## Anexo opcional A — Alternativa para instalar el CLI con `pip` (opcional)

La documentación actual también muestra una vía alternativa para instalar el CLI usando `pip`.

Ejemplo:

```bash
pip install duckdb-cli
```

Esta opción puede ser útil en algunos entornos, pero para esta cátedra se mantiene como ruta principal el **script oficial de instalación** del CLI, porque deja más clara la separación entre:

- cliente interactivo;
- entorno Python;
- y gestión de versiones del laboratorio.

---

## Anexo opcional B — Qué queda fuera de este tutorial

Este documento **no cubre** todavía:

- MotherDuck;
- autenticación por token;
- conexión a servicios cloud;
- integración con dbt-duckdb;
- ni configuración de herramientas BI sobre archivos DuckDB.

Eso se deja deliberadamente para tutoriales posteriores, porque mezclar todo aquí degrada la claridad técnica del material.

---