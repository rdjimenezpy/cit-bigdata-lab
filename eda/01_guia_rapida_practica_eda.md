<p align="center">
  <img src="../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Metodologías de Análisis Exploratorio de Datos en Sistemas de Big Data
**Fundamentos y aplicaciones con SQL DuckDB y MotherDuck en entornos académicos y de investigación**

---

### Práctica de laboratorio sobre la fuente https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción

---

## Fecha y versión

- **Fecha:** 15/04/2026
- **Versión:** 1.0

---

## Prerequisitos

* WSL2/Ubuntu
* Python 3.12
* Duckdb
* JDK 17
* JDBC Driver 1.4 para DuckDB
* Git

---

## Preparación del entorno de trabajo

### Paso 1. Crear el directorio de trabajo para la fuente

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
cd "${RAW_DIR}/sfp_funcionarios/2026_01"
pwd
```

### Paso 2. Descargar el archivo fuente

```bash
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"
```

### Paso 3. Descomprimir el archivo CSV

```bash
unzip -o "funcionarios_2026_1.csv.zip"
```

### Paso 4. Inspección rápida del tipo de archivo

```bash
file -bi "funcionarios_2026_1.csv"
```

### Paso 5. Convertir a UTF-8

```bash
iconv -f ISO-8859-1 -t UTF-8 funcionarios_2026_1.csv -o ${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv
cd ${STG_DIR}/sfp_funcionarios/2026_01
file -bi "funcionarios_2026_1_utf8.csv"
```

### Paso 6. Revisar primeras líneas

```bash
head -n 2 funcionarios_2026_1_utf8.csv
```

### Paso 7. Crear la base de datos analítica `eda.duckdb`

```bash
duckdb "${REPO_ROOT}/data/duckdb/eda.duckdb"
```

### Paso 8. Crear el esquema `raw`

```sql
-- duckdb "/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb"

CREATE SCHEMA IF NOT EXISTS raw;
```

### Paso 9. Volcar la fuente en bruto al esquema `raw`

```sql
-- duckdb "/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb"

CREATE OR REPLACE TABLE raw.funcionarios_2026_1 AS
SELECT *
FROM read_csv(
    '/opt/repo/cit-bigdata-lab/data/staged/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);
```

---

## Guía de implementación del modelo de datos base

```sql
-- duckdb "/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb"
    
-- eda.raw.funcionarios_2026_1 definition

CREATE TABLE raw.funcionarios_2026_1(
    anho VARCHAR,
    mes VARCHAR,
    nivel VARCHAR,
    descripcion_nivel VARCHAR,
    entidad VARCHAR,
    descripcion_entidad VARCHAR,
    oee VARCHAR,
    descripcion_oee VARCHAR,
    documento VARCHAR,
    nombres VARCHAR,
    apellidos VARCHAR,
    funcion VARCHAR,
    estado VARCHAR,
    carga_horaria VARCHAR,
    anho_ingreso VARCHAR,
    sexo VARCHAR,
    discapacidad VARCHAR,
    tipo_discapacidad VARCHAR,
    fuente_financiamiento VARCHAR,
    objeto_gasto VARCHAR,
    concepto VARCHAR,
    linea VARCHAR,
    categoria VARCHAR,
    cargo VARCHAR,
    presupuestado VARCHAR,
    devengado VARCHAR,
    movimiento VARCHAR,
    lugar VARCHAR,
    fecha_nacimiento VARCHAR,
    fec_ult_modif VARCHAR,
    uri VARCHAR,
    fecha_acto VARCHAR,
    correo VARCHAR,
    profesion VARCHAR,
    motivo_movimiento VARCHAR
);
```

---

## Guía para generar una muestra aleatoria y exportarla a un archivo CSV

```sql
-- duckdb "/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb"
    
-- Ejecutar la exportación con una muestra aleatoria de 100,000 registros
COPY (
    SELECT * 
    FROM eda.raw.funcionarios_2026_1 
    USING SAMPLE 100000 ROWS
) 
TO '/opt/repo/cit-bigdata-lab/data/exported/funcionarios_2026_1_sample100k.csv' 
(HEADER, DELIMITER ',');
```

---

## Guía de Instalación y Configuración de Pentaho Data Integration (PDI) en Windows

Esta guía resume los pasos esenciales para desplegar PDI (Spoon) en un entorno Windows, asegurando la compatibilidad con **JDK 17** y la configuración inicial del entorno.

## 1. Requisitos Previos (Java JDK 17)
PDI 11.0 y versiones recientes requieren Java 17 para un funcionamiento óptimo.

1. **Descargar JDK 17**: Descarga el instalador (MSI o ZIP) de Oracle JDK 17 o OpenJDK (como Temurin de Adoptium).
2. **Instalación**: Ejecuta el instalador y anota la ruta de instalación (Ej: `C:\Program Files\Java\jdk-17`).

## 2. Configuración de Variables de Entorno
Para que Pentaho reconozca la versión correcta de Java sin interferir con otras versiones del sistema:

1. Abre el menú de inicio y busca **"Editar las variables de entorno del sistema"**.
2. Haz clic en **Variables de entorno**.
3. En **Variables del sistema**, haz clic en **Nueva**:
   - **Nombre de la variable**: `PENTAHO_JAVA_HOME`
   - **Valor de la variable**: `C:\Program Files\Java\jdk-17` (tu ruta de JDK).
4. Edita la variable `Path` y añade: `%PENTAHO_JAVA_HOME%\bin`.

## 3. Instalación de Pentaho Data Integration (PDI)
1. **Descarga**: Obtén el archivo `.zip` de Pentaho Data Integration desde el portal de Hitachi Vantara o SourceForge.
2. **Descompresión**: Extrae el contenido en una ruta corta para evitar errores de longitud de archivos (Ej: `C:\Pentaho\data-integration`).
3. **Ejecución**:
   - Localiza el archivo `spoon.bat`.
   - Haz doble clic para iniciar la interfaz gráfica (Spoon).

## 4. Conceptos Clave de PDI
*   **Transformaciones (.ktr)**: Red de tareas lógicas (steps) unidas por hops que procesan flujos de datos en paralelo.
*   **Jobs (.kjb)**: Flujos de trabajo secuenciales que coordinan recursos y dependencias de procesos ETL.
*   **Hops**: Caminos de datos que conectan pasos o entradas de trabajo.

## 5. Configuración de kettle.properties
El archivo `kettle.properties` se utiliza para definir variables globales (como credenciales de BD o rutas de carpetas) que pueden usarse en cualquier transformación o job.

*   **Ubicación**: Se encuentra en la carpeta personal del usuario: `C:\Users\<Tu_Usuario>\.kettle\kettle.properties`.
*   **Configuración común**:
    Abre el archivo con un editor de texto y añade variables con el formato `KEY = VALUE`:

```properties
# Configuración de Rutas
PATH_INPUT_FILES = C:/Proyectos/Datos/Input
PATH_OUTPUT_FILES = C:/Proyectos/Datos/Output

# Configuración de Base de Datos
DB_HOST = localhost
DB_NAME = mi_bodega_datos
DB_PORT = 5432
DB_USER = pentaho_user

# Ajustes de Memoria y Performance
KETTLE_MAX_LOG_SIZE_IN_LINES = 5000
```

---

## Guía de Despliegue en MotherDuck Cloud (Opcional)

**MotherDuck** es un almacén de datos (data warehouse) en la nube sin servidor (serverless), construido sobre **DuckDB**, diseñado para análisis SQL rápidos e interactivos sin la sobrecarga de gestionar infraestructura.

### 1. Inicio Rápido
*   **Registro**: Puedes registrarte de forma gratuita para empezar a realizar consultas en minutos sin necesidad de tarjeta de crédito.
*   **Acceso**: La plataforma permite desarrollar e iterar de forma local y escalar a la nube cuando sea necesario.

### 2. Métodos de Conexión e Interfaces
Puedes conectar con MotherDuck utilizando diversos controladores y APIs oficiales:
*   **MotherDuck UI**: Interfaz web para una navegación rápida.
*   **CLI de DuckDB**: Instalación de la interfaz de línea de comandos de DuckDB para conexión directa.
*   **Lenguajes de Programación**:
    *   **Python**: Instalación y autenticación mediante drivers específicos.
    *   **Node.js**: Utilizando el cliente DuckDB Node.js (Neo).
    *   **Golang**: Driver nativo para Go.
*   **WebAssembly (Wasm)**: Para potenciar analíticas directamente en aplicaciones del lado del cliente.
*   **SQLAlchemy**: Integración con Python para mapeo de datos.

### 3. Carga de Datos (Ingesta)
MotherDuck permite cargar datos desde diversas fuentes de almacenamiento y bases de datos:
*   **Almacenamiento en la Nube**: Integración nativa con **Amazon S3**.
*   **Bases de Datos**: Carga directa desde **PostgreSQL** y **BigQuery**.
*   **DuckLake**: Permite construir un "data lake" sobre tus propios archivos.

### 4. Integración con el Stack de Datos
Para flujos de trabajo profesionales, MotherDuck se integra con herramientas líderes:
*   **Transformación**: Soporte completo para **dbt**.
*   **Orquestación e Ingesta**: Integración con **Fivetran**.
*   **Business Intelligence (BI)**:
    *   **Tableau**: Conector dedicado para visualización.
    *   **Power BI**: Uso del conector *DuckDB Power Query*.

### 5. Tareas Comunes y Configuración
*   **Autenticación**: Uso de **tokens de acceso** para asegurar la conexión desde el CLI y los drivers.
*   **Análisis con IA**: 
    *   **MCP Server**: Permite analizar datos usando lenguaje natural.
    *   **Dives**: Generación de tableros (dashboards) interactivos mediante prompts de lenguaje natural.
*   **Compartir**: Facilidad para compartir resultados y escalar proyectos en la nube.

---

## Siguiente paso

Realice la guía práctica para la clase-taller como actividad asincrónica, disponible en ``eda/02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md``.

---

## Cierre
Para más información sobre la preparación inicial del entorno de trabajo, consulte el documento ``docs/cheatsheets/07_guia_practica_eda_duckdb.md``.