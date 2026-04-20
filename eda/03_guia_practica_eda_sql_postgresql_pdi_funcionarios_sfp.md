<div align="center">
  <img src="../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
  <h1>FPUNA · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Guía práctica paso a paso: Análisis Exploratorio de Datos (EDA) con SQL sobre PostgreSQL e ingesta con Pentaho Data Integration

### Práctica de laboratorio sobre la fuente `https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip`

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción

---

## Fecha y versión

- **Fecha:** 20/04/2026
- **Versión:** 1.0
- **Herramientas principales:** PostgreSQL, Pentaho Data Integration, DBeaver Community, SQL

---

## Nota sobre esta documentación

Esta guía adapta la práctica de EDA originalmente planteada para **DuckDB** y la traslada a un flujo más cercano a un laboratorio de **ingeniería de datos tradicional**, donde la ingesta se realiza con **Pentaho Data Integration (PDI / Kettle)** y el análisis se ejecuta con **SQL sobre PostgreSQL**.

La diferencia principal es metodológica:

- en DuckDB se podía cargar el CSV directamente desde SQL con `read_csv()`;
- en PostgreSQL se recomienda preparar previamente la tabla destino y usar un proceso de ingesta controlado con PDI;
- el EDA se ejecuta luego contra una capa `raw` preservada y una vista `staging` tipada defensivamente.

Esta práctica está pensada para un entorno académico sobre **Windows 11 + WSL2 Ubuntu 22.04 LTS**, aunque los comandos pueden adaptarse a Linux nativo. Se asume PostgreSQL 15 o superior y Pentaho Data Integration 11 o equivalente.

---

## 1. Propósito de la práctica

Esta guía orienta paso a paso el desarrollo de una clase práctica de **Análisis Exploratorio de Datos (EDA)** con **SQL sobre PostgreSQL**, cargando previamente la fuente pública de **remuneraciones de funcionarios públicos** mediante **Pentaho Data Integration**.

La práctica tiene cinco metas concretas:

1. preparar el dataset en un entorno reproducible de laboratorio;
2. validar el archivo fuente antes de cargarlo;
3. crear una base de datos PostgreSQL con esquemas `raw`, `staging` y `analytics`;
4. ingestar el CSV con Pentaho Data Integration sin alterar destructivamente el dato original;
5. explorar estructura, calidad, granularidad, duplicados, nulos y valores atípicos para sustentar un modelado analítico posterior.

---

## 2. Introducción breve: qué es un EDA y por qué importa

Un **EDA** es una etapa de reconocimiento, diagnóstico y razonamiento sobre los datos. No busca todavía construir dashboards ni modelos finales, sino responder preguntas fundamentales:

- qué contiene realmente la fuente;
- cuál es su granularidad;
- qué columnas son confiables;
- dónde hay nulos, atípicos, duplicados o inconsistencias;
- qué reglas de limpieza y consolidación serán necesarias;
- qué modelo analítico tiene sentido construir después.

En ingeniería de datos, el EDA evita **modelar a ciegas**. Si el equipo asume mal el grano de la fuente, interpreta mal una métrica o no detecta duplicidades de negocio, todo el modelo analítico queda contaminado desde el inicio.

En esta práctica, PostgreSQL cumple el rol de motor relacional persistente para almacenar, explorar y preparar los datos antes de un futuro modelo dimensional, esquema en estrella u OBT (*One Big Table*).

---

## 3. Objetivos

### 3.1. Objetivo general

Realizar un análisis exploratorio de datos del archivo `funcionarios_2026_1.csv.zip` utilizando **Pentaho Data Integration para la ingesta** y **SQL sobre PostgreSQL para el análisis**, identificando estructura, calidad, patrones y hallazgos clave para un futuro modelado analítico.

### 3.2. Objetivos específicos

1. Descargar y validar técnicamente el archivo fuente.
2. Verificar integridad básica del ZIP y codificación del CSV.
3. Crear una base de datos PostgreSQL para el laboratorio.
4. Crear los esquemas `raw`, `staging`, `analytics` y `control`.
5. Crear una tabla `raw` con todos los campos como `TEXT` para preservar la fuente.
6. Configurar una transformación PDI para cargar el CSV en PostgreSQL.
7. Construir una vista tipada de apoyo para facilitar el EDA.
8. Detectar nulos, duplicados, formatos defectuosos y valores improbables.
9. Explorar distribuciones y relaciones entre variables clave.
10. Formular reglas preliminares para limpieza, consolidación y modelado analítico.

---

## 4. Base de conocimiento previa a la práctica

## 4.1. Contexto institucional de la fuente

La fuente pertenece al ecosistema histórico de datos abiertos de la función pública paraguaya y se distribuye en archivos CSV comprimidos por año y mes.

Para esta práctica se utilizará el recurso:

```text
https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip
```

Desde el punto de vista funcional, esta fuente permite analizar remuneraciones reportadas por organismos públicos por período, incluyendo variables institucionales, personales, laborales y presupuestarias.

---

## 4.2. Naturaleza del dataset

La fuente no debe interpretarse como una tabla lista para BI. La lectura más prudente del grano es:

**una fila por componente remunerativo de un funcionario en un período y contexto institucional determinado**.

Esto implica que:

- una persona puede aparecer varias veces dentro del mismo mes;
- las métricas monetarias deben interpretarse con cuidado;
- contar filas no equivale a contar funcionarios;
- el modelo analítico final debe consolidar los registros antes de ser usado en BI.

---

## 4.3. Columnas observadas en la fuente

La fuente contiene 35 columnas principales:

```text
anho, mes, nivel, descripcion_nivel, entidad, descripcion_entidad, oee, descripcion_oee,
documento, nombres, apellidos, funcion, estado, carga_horaria, anho_ingreso, sexo,
discapacidad, tipo_discapacidad, fuente_financiamiento, objeto_gasto, concepto, linea,
categoria, cargo, presupuestado, devengado, movimiento, lugar, fecha_nacimiento,
fec_ult_modif, uri, fecha_acto, correo, profesion, motivo_movimiento
```

---

## 4.4. Variables críticas para el EDA

Las columnas de mayor interés para esta práctica son:

- **Temporales:** `anho`, `mes`.
- **Institucionales:** `nivel`, `descripcion_nivel`, `entidad`, `descripcion_entidad`, `oee`, `descripcion_oee`.
- **Identificación:** `documento`, `nombres`, `apellidos`.
- **Laborales:** `estado`, `cargo`, `funcion`, `anho_ingreso`.
- **Segmentación básica:** `sexo`, `discapacidad`, `tipo_discapacidad`.
- **Remunerativas:** `fuente_financiamiento`, `objeto_gasto`, `concepto`, `linea`, `categoria`, `presupuestado`, `devengado`.
- **Fechas y trazabilidad:** `fecha_nacimiento`, `fec_ult_modif`, `fecha_acto`, `uri`.

---

## 4.5. Riesgos y advertencias metodológicas

Antes de ejecutar una sola consulta, estas advertencias deben quedar claras:

1. El campo `documento` no necesariamente representa solo cédulas convencionales.
2. La tabla cruda no debe usarse para contar personas sin control de duplicidad.
3. `presupuestado` y `devengado` no son equivalentes.
4. Campos como `cargo`, `funcion`, `profesion`, `movimiento`, `lugar` y `motivo_movimiento` pueden tener calidad heterogénea.
5. Las fechas deben parsearse de forma defensiva.
6. Los montos cero o extremos no deben descartarse automáticamente.
7. La fuente es operativa, no dimensional.
8. La ingesta con PDI debe preservar trazabilidad: ruta del archivo, fecha de carga, cantidad de filas y errores.

---

## 4.6. Hipótesis iniciales de exploración

Durante la práctica se buscará validar o refutar estas hipótesis:

- H1. La fuente contiene más filas que personas por la existencia de múltiples componentes remunerativos.
- H2. Existen columnas con alta proporción de nulos o baja utilidad analítica inicial.
- H3. Los montos `devengado` presentan asimetría y valores extremos.
- H4. La distribución de remuneraciones cambia según institución, tipo de vínculo y objeto de gasto.
- H5. Algunas columnas administrativas deben quedar fuera del primer modelo analítico.
- H6. El grano apropiado para una consolidación mensual general será distinto del grano crudo.
- H7. PDI permite construir una ingesta repetible y auditable, pero el tipado analítico debe resolverse en `staging`.

---

## 5. Supuestos y limitaciones de esta guía

1. Se asume un entorno **Ubuntu sobre WSL2** o Linux nativo con acceso a terminal.
2. Se asume PostgreSQL 15 o superior instalado y operativo.
3. Se asume Pentaho Data Integration instalado localmente.
4. Se asume DBeaver Community como cliente SQL recomendado.
5. Se asume conectividad para descargar el archivo fuente.
6. Esta guía usará como ruta base el repositorio:

```bash
cd /opt/repo/cit-bigdata-lab
```

7. La práctica prioriza una carga conservadora: primero se preserva el dato bruto como texto y luego se tipa en una vista.
8. La guía no resuelve todavía el modelado final; prepara el terreno para hacerlo correctamente.

---

## 6. Requisitos del entorno

## 6.1. Verificar sistema operativo

```bash
uname -a
lsb_release -a
pwd
```

## 6.2. Verificar PostgreSQL

```bash
psql --version
sudo systemctl status postgresql --no-pager
```

Si PostgreSQL no está activo:

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

> En WSL2 puede ser preferible no habilitar servicios al inicio automáticamente. En ese caso, usar solo `start` cuando se necesite ejecutar la práctica.

## 6.3. Verificar Pentaho Data Integration

Ubica el directorio donde se encuentra PDI y valida que `spoon.sh` pueda abrirse:

```bash
cd /opt/pentaho/data-integration
./spoon.sh
```

En Windows, abrir `Spoon.bat` desde el directorio de instalación de PDI.

## 6.4. Verificar driver JDBC de PostgreSQL para PDI

PDI requiere el driver JDBC de PostgreSQL en el directorio `lib/`.

Ruta típica en Linux:

```text
/opt/pentaho/data-integration/lib/postgresql-42.x.x.jar
```

Ruta típica en Windows:

```text
C:\pentaho\data-integration\lib\postgresql-42.x.x.jar
```

Si el driver no existe, descargarlo desde el sitio oficial de PostgreSQL JDBC y copiarlo al directorio `lib/`. Luego reiniciar Spoon.

---

## 6.5. Estructura mínima recomendada del repositorio

```text
/opt/repo/cit-bigdata-lab/
├── data/
│   ├── raw/
│   ├── staged/
│   ├── processed/
│   └── exported/
├── etl/
│   └── pdi/
│       ├── transformations/
│       └── jobs/
├── sql/
│   ├── ddl/
│   ├── staging/
│   └── eda/
└── docs/
```

Crear estructura:

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged
export PDI_DIR=${REPO_ROOT}/etl/pdi
export SQL_DIR=${REPO_ROOT}/sql

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${PDI_DIR}/transformations"
mkdir -p "${PDI_DIR}/jobs"
mkdir -p "${SQL_DIR}/ddl" "${SQL_DIR}/staging" "${SQL_DIR}/eda"
```

---

## 7. Preparación del archivo fuente

## Paso 1. Crear el directorio de trabajo para la fuente

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
cd "${RAW_DIR}/sfp_funcionarios/2026_01"
pwd
```

### Qué se espera observar

```text
/opt/repo/cit-bigdata-lab/data/raw/sfp_funcionarios/2026_01
```

---

## Paso 2. Descargar el archivo fuente

```bash
# Actualizar certificados
sudo apt-get update
sudo apt-get install --reinstall ca-certificates -y
sudo update-ca-certificates

# Descargar el archivo fuente
curl -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" \
     -o "funcionarios_2026_1.csv.zip"
```

Si el entorno presenta problemas de certificados, usar temporalmente:

```bash
# Solo para laboratorio. No recomendado en producción.
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" \
     -o "funcionarios_2026_1.csv.zip"
```

Verificar descarga:

```bash
ls -lh
```

---

## Paso 3. Verificar integridad básica del ZIP

```bash
sudo apt-get install unzip -y
unzip -l "funcionarios_2026_1.csv.zip"
unzip -t "funcionarios_2026_1.csv.zip"
```

Si `unzip -t` reporta errores, detener la práctica y repetir la descarga.

### Verificación opcional con MD5

```bash
curl -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip.md5" \
     -o "funcionarios_2026_1.csv.zip.md5"

cat funcionarios_2026_1.csv.zip.md5
md5sum funcionarios_2026_1.csv.zip
```

---

## Paso 4. Descomprimir el CSV

```bash
unzip -o "funcionarios_2026_1.csv.zip"
ls -lh
```

Debe aparecer:

```text
funcionarios_2026_1.csv
```

---

## Paso 5. Validar codificación y convertir a UTF-8 si corresponde

```bash
file -bi "funcionarios_2026_1.csv"
```

Si el resultado indica `charset=iso-8859-1`, convertir a UTF-8:

```bash
iconv -f ISO-8859-1 -t UTF-8 \
  funcionarios_2026_1.csv \
  -o ${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv
```

Si ya está en UTF-8, copiar igualmente a `staged` para mantener el flujo estándar:

```bash
cp funcionarios_2026_1.csv \
  ${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv
```

Validar UTF-8:

```bash
cd ${STG_DIR}/sfp_funcionarios/2026_01
file -bi "funcionarios_2026_1_utf8.csv"
iconv -f UTF-8 -t UTF-8 "funcionarios_2026_1_utf8.csv" > /dev/null && \
echo "Validación UTF-8: OK"
head -n 2 "funcionarios_2026_1_utf8.csv"
```

---

## 8. Preparación de PostgreSQL

## Paso 6. Crear base de datos y usuario de laboratorio

Entrar como usuario `postgres`:

```bash
sudo -u postgres psql
```

Ejecutar:

```sql
CREATE DATABASE eda;

CREATE USER postgres WITH PASSWORD 'postgres';

GRANT ALL PRIVILEGES ON DATABASE eda TO postgres;
```

Salir:

```sql
\q
```

Conectarse a la base:

```bash
psql -h localhost -p 5432 -U cit_bigdata -d cit_bigdata_lab
```

Si el usuario no puede crear esquemas, otorgar permisos desde `postgres`:

```bash
sudo -u postgres psql -d cit_bigdata_lab
```

```sql
GRANT CREATE ON DATABASE cit_bigdata_lab TO cit_bigdata;
ALTER DATABASE cit_bigdata_lab OWNER TO cit_bigdata;
```

---

## Paso 7. Crear esquemas de trabajo

```sql
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS control;
```

### Propósito de cada esquema

| Esquema | Propósito |
|---|---|
| `raw` | Preservar el dato tal como llega desde el archivo fuente. |
| `staging` | Aplicar limpieza, tipado defensivo y reglas de calidad. |
| `analytics` | Crear vistas o tablas consolidadas para análisis posterior. |
| `control` | Registrar metadatos de ingesta, auditoría y control de ejecución. |

---

## Paso 8. Crear tabla `raw` para carga desde PDI

La tabla `raw` debe recibir todos los campos como `TEXT`. Esto evita conversiones agresivas durante la ingesta y permite que el tipado analítico se realice posteriormente en `staging`.

```sql
DROP TABLE IF EXISTS raw.funcionarios_2026_1;

CREATE TABLE raw.funcionarios_2026_1 (
    anho TEXT,
    mes TEXT,
    nivel TEXT,
    descripcion_nivel TEXT,
    entidad TEXT,
    descripcion_entidad TEXT,
    oee TEXT,
    descripcion_oee TEXT,
    documento TEXT,
    nombres TEXT,
    apellidos TEXT,
    funcion TEXT,
    estado TEXT,
    carga_horaria TEXT,
    anho_ingreso TEXT,
    sexo TEXT,
    discapacidad TEXT,
    tipo_discapacidad TEXT,
    fuente_financiamiento TEXT,
    objeto_gasto TEXT,
    concepto TEXT,
    linea TEXT,
    categoria TEXT,
    cargo TEXT,
    presupuestado TEXT,
    devengado TEXT,
    movimiento TEXT,
    lugar TEXT,
    fecha_nacimiento TEXT,
    fec_ult_modif TEXT,
    uri TEXT,
    fecha_acto TEXT,
    correo TEXT,
    profesion TEXT,
    motivo_movimiento TEXT
);
```

Verificar estructura:

```sql
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'funcionarios_2026_1'
ORDER BY ordinal_position;
```

---

## Paso 9. Crear tabla de control de ingesta

```sql
CREATE TABLE IF NOT EXISTS control.ingesta_archivos (
    id_ingesta BIGSERIAL PRIMARY KEY,
    fuente TEXT NOT NULL,
    periodo_anho INTEGER,
    periodo_mes INTEGER,
    archivo TEXT NOT NULL,
    ruta_archivo TEXT,
    herramienta TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    estado TEXT DEFAULT 'INICIADO',
    filas_leidas BIGINT,
    filas_insertadas BIGINT,
    observacion TEXT
);
```

Esta tabla no reemplaza el log de PDI, pero permite documentar de forma simple qué archivo fue cargado, cuándo y con qué resultado.

---

## 9. Ingesta con Pentaho Data Integration

## Paso 10. Crear conexión PostgreSQL en Spoon

Abrir Spoon:

```bash
cd /opt/pentaho/data-integration
./spoon.sh
```

En Windows, abrir `Spoon.bat`.

Crear una nueva conexión:

| Parámetro | Valor sugerido       |
|---|----------------------|
| Connection Name | `pg_cit_bigdata_lab` |
| Connection Type | `PostgreSQL`         |
| Access | `Native (JDBC)`      |
| Host Name | `localhost`          |
| Database Name | `eda`                |
| Port Number | `5432`               |
| Username | `cit_bigdata`        |
| Password | `cit_bigdata`        |

Presionar **Test**. Si falla, revisar:

- servicio PostgreSQL activo;
- puerto correcto;
- usuario y contraseña;
- driver JDBC copiado en `data-integration/lib/`;
- acceso desde Windows hacia WSL2 si PDI se ejecuta en Windows y PostgreSQL en WSL2.

---

## Paso 11. Crear transformación PDI `tr_load_funcionarios_raw.ktr`

Crear una transformación nueva y guardarla como:

```text
/opt/repo/cit-bigdata-lab/etl/pdi/transformations/tr_load_funcionarios_raw.ktr
```

### 11.1. Definir parámetro de archivo

En la transformación, ir a:

```text
Edit → Settings → Parameters
```

Crear el parámetro:

| Parámetro | Valor por defecto |
|---|---|
| `P_CSV_FILE` | `/opt/repo/cit-bigdata-lab/data/staged/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv` |

Esto permite reutilizar la transformación con otros meses.

---

### 11.2. Paso PDI: Text File Input

Agregar el step:

```text
Input → Text file input
```

Configuración recomendada:

| Opción | Valor |
|---|---|
| Step name | `leer_csv_funcionarios` |
| File or directory | `${P_CSV_FILE}` |
| Regular expression | vacío |
| File type | `CSV` |
| Separator | `,` |
| Enclosure | `"` |
| Encoding | `UTF-8` |
| Header | `Sí` |
| Number of header lines | `1` |
| Format | `Unix` o `Mixed` |
| Lazy conversion | `Sí` |
| Trim type | `both` |

Presionar **Get Fields** para obtener los 35 campos.

Todos los campos deben quedar como tipo `String`. No convertir fechas ni montos dentro del step de entrada.

### Campos esperados

```text
anho
mes
nivel
descripcion_nivel
entidad
descripcion_entidad
oee
descripcion_oee
documento
nombres
apellidos
funcion
estado
carga_horaria
anho_ingreso
sexo
discapacidad
tipo_discapacidad
fuente_financiamiento
objeto_gasto
concepto
linea
categoria
cargo
presupuestado
devengado
movimiento
lugar
fecha_nacimiento
fec_ult_modif
uri
fecha_acto
correo
profesion
motivo_movimiento
```

---

### 11.3. Paso PDI: Select Values

Agregar el step:

```text
Transform → Select values
```

Nombre sugerido:

```text
seleccionar_campos_raw
```

Usarlo para:

- asegurar orden de columnas;
- remover campos accidentales;
- mantener todos los campos como `String`;
- evitar conversiones implícitas.

No cambiar nombres si el encabezado ya coincide con la tabla destino.

---

### 11.4. Paso PDI: Table Output

Agregar el step:

```text
Output → Table output
```

Configuración:

| Opción | Valor |
|---|---|
| Step name | `insertar_raw_postgresql` |
| Connection | `pg_cit_bigdata_lab` |
| Target schema | `raw` |
| Target table | `funcionarios_2026_1` |
| Commit size | `10000` |
| Truncate table | `Sí`, solo si se desea recargar completamente el período |
| Specify database fields | `Sí` |
| Use batch update | `Sí`, si está disponible |

Presionar **Database fields** y mapear cada campo de entrada con su columna destino.

> Para laboratorio, se recomienda activar `Truncate table` si la práctica será repetida varias veces. En un pipeline histórico real, no debe truncarse sin una estrategia por partición, período o archivo.

---

### 11.5. Flujo final de la transformación

```text
Text file input
      ↓
Select values
      ↓
Table output
```

Ejecutar la transformación y validar que el log indique filas leídas e insertadas sin errores.

---

## Paso 12. Validar carga en PostgreSQL

Desde DBeaver o `psql`:

```sql
SELECT COUNT(*) AS total_filas
FROM raw.funcionarios_2026_1;
```

```sql
SELECT *
FROM raw.funcionarios_2026_1
LIMIT 10;
```

Verificar cantidad de columnas:

```sql
SELECT COUNT(*) AS total_columnas
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'funcionarios_2026_1';
```

Debe devolver:

```text
35
```

---

## Paso 13. Registrar control de ingesta

Después de validar la carga, registrar manualmente la ingesta:

```sql
INSERT INTO control.ingesta_archivos (
    fuente,
    periodo_anho,
    periodo_mes,
    archivo,
    ruta_archivo,
    herramienta,
    fecha_fin,
    estado,
    filas_insertadas,
    observacion
)
SELECT
    'datos.sfp.gov.py/data/funcionarios',
    2026,
    1,
    'funcionarios_2026_1.csv',
    '/opt/repo/cit-bigdata-lab/data/staged/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv',
    'Pentaho Data Integration',
    CURRENT_TIMESTAMP,
    'FINALIZADO',
    COUNT(*),
    'Carga inicial raw como TEXT para EDA sobre PostgreSQL'
FROM raw.funcionarios_2026_1;
```

Consultar auditoría:

```sql
SELECT *
FROM control.ingesta_archivos
ORDER BY id_ingesta DESC;
```

---

# 10. Construcción de funciones seguras para tipado defensivo

PostgreSQL no tiene una función nativa equivalente a `try_cast()` en todas sus versiones. Por eso se crearán funciones auxiliares para convertir datos sin romper la consulta cuando aparezcan valores inválidos.

## Paso 14. Crear funciones `try_*`

```sql
CREATE OR REPLACE FUNCTION staging.try_int(p_text TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN v_text::INTEGER;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$;
```

```sql
CREATE OR REPLACE FUNCTION staging.try_numeric(p_text TEXT)
RETURNS NUMERIC
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN v_text::NUMERIC;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$;
```

```sql
CREATE OR REPLACE FUNCTION staging.try_date(p_text TEXT)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;

    BEGIN
        RETURN v_text::DATE;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            RETURN TO_DATE(SUBSTRING(v_text FROM 1 FOR 10), 'YYYY/MM/DD');
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END;
END;
$$;
```

```sql
CREATE OR REPLACE FUNCTION staging.empty_to_null(p_text TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT NULLIF(BTRIM(p_text), '')
$$;
```

---

# 11. Crear vista tipada de apoyo para el EDA

## Paso 15. Crear vista `staging.v_funcionarios_2026_1_typed`

```sql
CREATE OR REPLACE VIEW staging.v_funcionarios_2026_1_typed AS
SELECT
    staging.try_int(anho) AS anho,
    staging.try_int(mes) AS mes,
    staging.try_int(nivel) AS nivel,
    staging.empty_to_null(descripcion_nivel) AS descripcion_nivel,
    staging.try_int(entidad) AS entidad,
    staging.empty_to_null(descripcion_entidad) AS descripcion_entidad,
    staging.try_int(oee) AS oee,
    staging.empty_to_null(descripcion_oee) AS descripcion_oee,
    staging.empty_to_null(documento) AS documento,
    staging.empty_to_null(nombres) AS nombres,
    staging.empty_to_null(apellidos) AS apellidos,
    staging.empty_to_null(funcion) AS funcion,
    UPPER(staging.empty_to_null(estado)) AS estado,
    staging.empty_to_null(carga_horaria) AS carga_horaria,
    staging.try_int(anho_ingreso) AS anho_ingreso,
    UPPER(staging.empty_to_null(sexo)) AS sexo,
    UPPER(staging.empty_to_null(discapacidad)) AS discapacidad,
    staging.empty_to_null(tipo_discapacidad) AS tipo_discapacidad,
    staging.try_int(fuente_financiamiento) AS fuente_financiamiento,
    staging.try_int(objeto_gasto) AS objeto_gasto,
    staging.empty_to_null(concepto) AS concepto,
    staging.empty_to_null(linea) AS linea,
    staging.empty_to_null(categoria) AS categoria,
    staging.empty_to_null(cargo) AS cargo,
    staging.try_numeric(presupuestado) AS presupuestado,
    staging.try_numeric(devengado) AS devengado,
    staging.empty_to_null(movimiento) AS movimiento,
    staging.empty_to_null(lugar) AS lugar,
    staging.empty_to_null(fecha_nacimiento) AS fecha_nacimiento_raw,
    staging.try_date(fecha_nacimiento) AS fecha_nacimiento,
    staging.empty_to_null(fec_ult_modif) AS fec_ult_modif_raw,
    staging.empty_to_null(uri) AS uri,
    staging.empty_to_null(fecha_acto) AS fecha_acto_raw,
    staging.try_date(fecha_acto) AS fecha_acto,
    staging.empty_to_null(correo) AS correo,
    staging.empty_to_null(profesion) AS profesion,
    staging.empty_to_null(motivo_movimiento) AS motivo_movimiento
FROM raw.funcionarios_2026_1;
```

Validar:

```sql
SELECT *
FROM staging.v_funcionarios_2026_1_typed
LIMIT 10;
```

```sql
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'v_funcionarios_2026_1_typed'
ORDER BY ordinal_position;
```

---

# 12. Crear vista enriquecida para EDA

## Paso 16. Agregar variables derivadas

```sql
CREATE OR REPLACE VIEW analytics.v_funcionarios_2026_1_eda AS
SELECT
    t.*,
    (t.presupuestado - t.devengado) AS descuento,
    CASE
        WHEN t.presupuestado IS NOT NULL
         AND t.presupuestado <> 0
         AND t.devengado IS NOT NULL
        THEN ROUND(((t.presupuestado - t.devengado) / t.presupuestado) * 100, 2)
        ELSE NULL
    END AS porcentaje_descuento,
    CASE
        WHEN t.fecha_nacimiento IS NOT NULL
        THEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, t.fecha_nacimiento))::INTEGER
        ELSE NULL
    END AS edad,
    CASE
        WHEN t.anho IS NOT NULL
         AND t.anho_ingreso IS NOT NULL
         AND t.anho_ingreso BETWEEN 1900 AND t.anho
        THEN t.anho - t.anho_ingreso
        ELSE NULL
    END AS antiguedad,
    UPPER(LEFT(t.documento, 1)) AS tipo_identificador,
    CASE
        WHEN UPPER(LEFT(t.documento, 1)) BETWEEN '1' AND '9'
            THEN 'DOCUMENTO NACIONAL'
        WHEN UPPER(LEFT(t.documento, 1)) = 'E'
            THEN 'DOCUMENTO EXTRANJERO'
        WHEN UPPER(LEFT(t.documento, 1)) = 'V'
            THEN 'VACANCIA INSTITUCIONAL'
        WHEN UPPER(LEFT(t.documento, 1)) = 'A'
            THEN 'ANONIMATO ADMINISTRATIVO'
        ELSE 'NO CLASIFICADO'
    END AS clasificacion_documento
FROM staging.v_funcionarios_2026_1_typed t;
```

### Nota metodológica sobre `antiguedad`

La antigüedad debe calcularse con `anho_ingreso`, no con `fecha_acto`. El campo `fecha_acto` representa el acto administrativo vigente y puede corresponder a nombramientos, ascensos, traslados o renovaciones contractuales posteriores al ingreso original.

---

# 13. Exploración estructural inicial

## Paso 17. Conteo general

```sql
SELECT COUNT(*) AS total_filas
FROM analytics.v_funcionarios_2026_1_eda;
```

## Paso 18. Conteo por período

```sql
SELECT
    anho,
    mes,
    COUNT(*) AS total_filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY anho, mes
ORDER BY anho, mes;
```

## Paso 19. Revisión de columnas y tipos

```sql
SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema IN ('raw', 'staging', 'analytics')
  AND table_name IN (
      'funcionarios_2026_1',
      'v_funcionarios_2026_1_typed',
      'v_funcionarios_2026_1_eda'
  )
ORDER BY table_schema, table_name, ordinal_position;
```

---

# 14. Detectar la granularidad real de observación

## Paso 20. Filas versus documentos únicos

```sql
SELECT
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS documentos_unicos,
    COUNT(*) - COUNT(DISTINCT documento) AS diferencia,
    ROUND(
        100.0 * COUNT(DISTINCT documento) / NULLIF(COUNT(*), 0),
        2
    ) AS porcentaje_documentos_unicos,
    ROUND(
        100.0 * (COUNT(*) - COUNT(DISTINCT documento)) / NULLIF(COUNT(*), 0),
        2
    ) AS porcentaje_diferencia
FROM analytics.v_funcionarios_2026_1_eda;
```

### Interpretación esperada

Si `filas` es mayor que `documentos_unicos`, entonces la tabla no está consolidada a nivel persona. Este resultado suele confirmar que el grano crudo corresponde a componentes remunerativos.

---

## Paso 21. Funcionarios con múltiples filas en el mismo período

```sql
SELECT
    documento,
    anho,
    mes,
    COUNT(*) AS filas_por_documento_mes
FROM analytics.v_funcionarios_2026_1_eda
WHERE documento IS NOT NULL
GROUP BY documento, anho, mes
HAVING COUNT(*) > 1
ORDER BY filas_por_documento_mes DESC, documento
LIMIT 50;
```

---

## Paso 22. Ver componentes remunerativos de casos repetidos

```sql
SELECT
    documento,
    nombres,
    apellidos,
    descripcion_oee,
    objeto_gasto,
    concepto,
    categoria,
    presupuestado,
    devengado,
    descuento
FROM analytics.v_funcionarios_2026_1_eda
WHERE documento IN (
    SELECT documento
    FROM analytics.v_funcionarios_2026_1_eda
    WHERE documento IS NOT NULL
    GROUP BY documento, anho, mes
    HAVING COUNT(*) > 1
)
ORDER BY documento, objeto_gasto, concepto
LIMIT 100;
```

---

# 15. Clasificación semántica del campo `documento`

## Paso 23. Contar filas por tipo de identificador

```sql
SELECT
    tipo_identificador,
    clasificacion_documento,
    COUNT(*) AS cantidad_filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY tipo_identificador, clasificacion_documento
ORDER BY tipo_identificador;
```

## Paso 24. Cuantificar registros con montos cero por tipo de identificador

```sql
SELECT
    tipo_identificador,
    clasificacion_documento,
    COUNT(*) AS cantidad_filas
FROM analytics.v_funcionarios_2026_1_eda
WHERE presupuestado = 0
  AND devengado = 0
GROUP BY tipo_identificador, clasificacion_documento
ORDER BY tipo_identificador;
```

## Paso 25. Métrica objetiva de registros sin monto

```sql
WITH total AS (
    SELECT COUNT(*) AS total_filas
    FROM analytics.v_funcionarios_2026_1_eda
), basura AS (
    SELECT COUNT(*) AS filas_sin_monto
    FROM analytics.v_funcionarios_2026_1_eda
    WHERE presupuestado = 0
      AND devengado = 0
)
SELECT
    t.total_filas,
    b.filas_sin_monto,
    ROUND(100.0 * b.filas_sin_monto / NULLIF(t.total_filas, 0), 2) AS porcentaje_sin_monto
FROM total t
CROSS JOIN basura b;
```

### Tabla de interpretación de `tipo_identificador`

| Valor | Significado técnico | Interpretación en datos | Uso en auditoría / ETL |
|---|---|---|---|
| `1–9` | Documento nacional | Cédula paraguaya | Clasificación de identidad válida |
| `E` | Documento extranjero | Funcionario extranjero | Control de registros internacionales |
| `V` | Vacancia institucional | Cargo presupuestado sin titular | Detección de puestos vacantes |
| `A` | Anonimato administrativo | Cargo ocupado sin identidad publicada | Requiere revisión de calidad |

---

# 16. Calidad de datos: nulos, vacíos e inconsistencias

## Paso 26. Nulos en columnas críticas

```sql
SELECT 'documento' AS columna, COUNT(*) AS nulos
FROM analytics.v_funcionarios_2026_1_eda
WHERE documento IS NULL
UNION ALL
SELECT 'nombres', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE nombres IS NULL
UNION ALL
SELECT 'apellidos', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE apellidos IS NULL
UNION ALL
SELECT 'estado', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE estado IS NULL
UNION ALL
SELECT 'sexo', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE sexo IS NULL
UNION ALL
SELECT 'objeto_gasto', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE objeto_gasto IS NULL
UNION ALL
SELECT 'concepto', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE concepto IS NULL
UNION ALL
SELECT 'presupuestado', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE presupuestado IS NULL
UNION ALL
SELECT 'devengado', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NULL
UNION ALL
SELECT 'fecha_acto', COUNT(*)
FROM analytics.v_funcionarios_2026_1_eda
WHERE fecha_acto IS NULL
ORDER BY nulos DESC, columna;
```

---

## Paso 27. Campos descriptivos vacíos

```sql
SELECT
    SUM(CASE WHEN cargo IS NULL THEN 1 ELSE 0 END) AS cargo_vacio,
    SUM(CASE WHEN funcion IS NULL THEN 1 ELSE 0 END) AS funcion_vacia,
    SUM(CASE WHEN profesion IS NULL THEN 1 ELSE 0 END) AS profesion_vacia,
    SUM(CASE WHEN correo IS NULL THEN 1 ELSE 0 END) AS correo_vacio,
    SUM(CASE WHEN carga_horaria IS NULL THEN 1 ELSE 0 END) AS carga_horaria_vacia,
    SUM(CASE WHEN tipo_discapacidad IS NULL THEN 1 ELSE 0 END) AS tipo_discapacidad_vacia
FROM analytics.v_funcionarios_2026_1_eda;
```

---

## Paso 28. Fechas no parseadas correctamente

```sql
SELECT
    SUM(
        CASE
            WHEN fecha_nacimiento_raw IS NOT NULL
             AND fecha_nacimiento IS NULL
            THEN 1 ELSE 0
        END
    ) AS fecha_nacimiento_invalida,
    SUM(
        CASE
            WHEN fecha_acto_raw IS NOT NULL
             AND fecha_acto IS NULL
            THEN 1 ELSE 0
        END
    ) AS fecha_acto_invalida
FROM analytics.v_funcionarios_2026_1_eda;
```

---

## Paso 29. Duplicados exactos mediante hash de fila

PostgreSQL no tiene `GROUP BY ALL` como DuckDB. Una forma práctica para EDA es calcular un hash de toda la fila cruda.

```sql
WITH filas_hash AS (
    SELECT
        MD5(ROW_TO_JSON(r)::TEXT) AS row_hash
    FROM raw.funcionarios_2026_1 r
), conteo AS (
    SELECT
        row_hash,
        COUNT(*) AS cantidad
    FROM filas_hash
    GROUP BY row_hash
)
SELECT
    COUNT(*) FILTER (WHERE cantidad > 1) AS grupos_duplicados,
    SUM(cantidad - 1) FILTER (WHERE cantidad > 1) AS filas_duplicadas_exactas
FROM conteo;
```

---

## Paso 30. Posibles duplicados de negocio

```sql
SELECT
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    linea,
    categoria,
    COUNT(*) AS repeticiones
FROM analytics.v_funcionarios_2026_1_eda
WHERE documento IS NOT NULL
GROUP BY
    anho,
    mes,
    nivel,
    entidad,
    oee,
    documento,
    objeto_gasto,
    linea,
    categoria
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC, documento
LIMIT 50;
```

### Qué debe concluir el estudiante

- No todo duplicado es error.
- Debe distinguirse entre duplicado exacto y multiplicidad legítima del negocio.
- La definición de clave depende del grano que se quiera modelar.
- En esta fuente, el grano crudo no equivale al grano analítico final.

---

# 17. Exploración univariada de métricas monetarias

## Paso 31. Estadísticos descriptivos de `devengado`

```sql
SELECT
    COUNT(devengado) AS filas_con_devengado,
    MIN(devengado) AS min_devengado,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY devengado) AS q1_devengado,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY devengado) AS mediana_devengado,
    AVG(devengado) AS promedio_devengado,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY devengado) AS q3_devengado,
    MAX(devengado) AS max_devengado,
    STDDEV_SAMP(devengado) AS desvio_devengado
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NOT NULL;
```

---

## Paso 32. Estadísticos descriptivos de `presupuestado`

```sql
SELECT
    COUNT(presupuestado) AS filas_con_presupuestado,
    MIN(presupuestado) AS min_presupuestado,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY presupuestado) AS q1_presupuestado,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY presupuestado) AS mediana_presupuestado,
    AVG(presupuestado) AS promedio_presupuestado,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY presupuestado) AS q3_presupuestado,
    MAX(presupuestado) AS max_presupuestado,
    STDDEV_SAMP(presupuestado) AS desvio_presupuestado
FROM analytics.v_funcionarios_2026_1_eda
WHERE presupuestado IS NOT NULL;
```

---

## Paso 33. Estadísticos descriptivos de edad y antigüedad

```sql
SELECT
    COUNT(edad) AS filas_con_edad,
    MIN(edad) AS min_edad,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY edad) AS q1_edad,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY edad) AS mediana_edad,
    AVG(edad) AS promedio_edad,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY edad) AS q3_edad,
    MAX(edad) AS max_edad
FROM analytics.v_funcionarios_2026_1_eda
WHERE edad IS NOT NULL;
```

```sql
SELECT
    COUNT(antiguedad) AS filas_con_antiguedad,
    MIN(antiguedad) AS min_antiguedad,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY antiguedad) AS q1_antiguedad,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY antiguedad) AS mediana_antiguedad,
    AVG(antiguedad) AS promedio_antiguedad,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY antiguedad) AS q3_antiguedad,
    MAX(antiguedad) AS max_antiguedad
FROM analytics.v_funcionarios_2026_1_eda
WHERE antiguedad IS NOT NULL;
```

---

## Paso 34. Frecuencias de variables categóricas relevantes

### Estado

```sql
SELECT
    estado,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY estado
ORDER BY filas DESC;
```

### Sexo

```sql
SELECT
    sexo,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY sexo
ORDER BY filas DESC;
```

### Objeto de gasto

```sql
SELECT
    objeto_gasto,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY objeto_gasto
ORDER BY filas DESC
LIMIT 20;
```

### Concepto

```sql
SELECT
    concepto,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_eda
GROUP BY concepto
ORDER BY filas DESC
LIMIT 20;
```

---

# 18. Exploración bivariada y multivariada

## Paso 35. Remuneración por institución

```sql
SELECT
    descripcion_oee,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY devengado) AS mediana_devengado
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NOT NULL
GROUP BY descripcion_oee
ORDER BY total_devengado DESC
LIMIT 20;
```

---

## Paso 36. Remuneración por estado laboral

```sql
SELECT
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY devengado) AS mediana_devengado
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NOT NULL
GROUP BY estado
ORDER BY total_devengado DESC;
```

---

## Paso 37. Remuneración por sexo y estado

```sql
SELECT
    sexo,
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    AVG(devengado) AS promedio_devengado,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY devengado) AS mediana_devengado
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NOT NULL
GROUP BY sexo, estado
ORDER BY sexo, estado;
```

---

## Paso 38. Comparación entre `presupuestado` y `devengado`

```sql
SELECT
    SUM(presupuestado) AS total_presupuestado,
    SUM(devengado) AS total_devengado,
    SUM(descuento) AS diferencia_total,
    ROUND(
        100.0 * SUM(descuento) / NULLIF(SUM(presupuestado), 0),
        2
    ) AS porcentaje_descuento_total
FROM analytics.v_funcionarios_2026_1_eda
WHERE presupuestado IS NOT NULL
  AND devengado IS NOT NULL;
```

---

## Paso 39. Comportamiento por objeto de gasto

```sql
SELECT
    objeto_gasto,
    concepto,
    COUNT(*) AS filas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado
FROM analytics.v_funcionarios_2026_1_eda
WHERE devengado IS NOT NULL
GROUP BY objeto_gasto, concepto
ORDER BY total_devengado DESC
LIMIT 30;
```

---

# 19. Detección de anomalías y casos extremos

## Paso 40. Montos negativos o iguales a cero

```sql
SELECT
    SUM(CASE WHEN presupuestado < 0 THEN 1 ELSE 0 END) AS presupuestado_negativo,
    SUM(CASE WHEN devengado < 0 THEN 1 ELSE 0 END) AS devengado_negativo,
    SUM(CASE WHEN presupuestado = 0 THEN 1 ELSE 0 END) AS presupuestado_cero,
    SUM(CASE WHEN devengado = 0 THEN 1 ELSE 0 END) AS devengado_cero
FROM analytics.v_funcionarios_2026_1_eda
WHERE presupuestado IS NOT NULL
   OR devengado IS NOT NULL;
```

---

## Paso 41. Outliers por criterio IQR sobre `devengado`

```sql
WITH limites AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY devengado) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY devengado) AS q3
    FROM analytics.v_funcionarios_2026_1_eda
    WHERE devengado IS NOT NULL
), limites_iqr AS (
    SELECT
        q1,
        q3,
        q3 - q1 AS iqr,
        q1 - 1.5 * (q3 - q1) AS limite_inferior,
        q3 + 1.5 * (q3 - q1) AS limite_superior
    FROM limites
)
SELECT
    t.documento,
    t.nombres,
    t.apellidos,
    t.descripcion_oee,
    t.estado,
    t.objeto_gasto,
    t.concepto,
    t.devengado,
    l.limite_inferior,
    l.limite_superior
FROM analytics.v_funcionarios_2026_1_eda t
CROSS JOIN limites_iqr l
WHERE t.devengado IS NOT NULL
  AND (
        t.devengado < l.limite_inferior
        OR t.devengado > l.limite_superior
      )
ORDER BY t.devengado DESC
LIMIT 100;
```

---

## Paso 42. Cuantificación de outliers

```sql
WITH limites AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY devengado) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY devengado) AS q3
    FROM analytics.v_funcionarios_2026_1_eda
    WHERE devengado IS NOT NULL
), limites_iqr AS (
    SELECT
        q1 - 1.5 * (q3 - q1) AS limite_inferior,
        q3 + 1.5 * (q3 - q1) AS limite_superior
    FROM limites
), marcados AS (
    SELECT
        t.*,
        CASE
            WHEN t.devengado < l.limite_inferior
              OR t.devengado > l.limite_superior
            THEN 1 ELSE 0
        END AS es_outlier
    FROM analytics.v_funcionarios_2026_1_eda t
    CROSS JOIN limites_iqr l
    WHERE t.devengado IS NOT NULL
)
SELECT
    COUNT(*) AS filas_con_devengado,
    SUM(es_outlier) AS filas_outlier,
    ROUND(100.0 * SUM(es_outlier) / NULLIF(COUNT(*), 0), 2) AS porcentaje_outlier
FROM marcados;
```

### Interpretación correcta

Un valor extremo no debe eliminarse automáticamente. Primero debe clasificarse como:

- error de carga;
- caso administrativo especial;
- pago extraordinario;
- o valor legítimo del fenómeno observado.

---

# 20. Consolidación preliminar por persona, institución y período

## Paso 43. Crear vista consolidada mensual

Esta vista no reemplaza el modelo final. Sirve para entender cómo cambia el análisis cuando se pasa del grano crudo al grano consolidado.

```sql
CREATE OR REPLACE VIEW analytics.v_funcionarios_2026_1_persona_oee_mes AS
SELECT
    anho,
    mes,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    documento,
    MAX(nombres) AS nombres,
    MAX(apellidos) AS apellidos,
    MAX(sexo) AS sexo,
    MAX(estado) AS estado,
    MAX(anho_ingreso) AS anho_ingreso,
    MAX(edad) AS edad,
    MAX(antiguedad) AS antiguedad,
    MAX(tipo_identificador) AS tipo_identificador,
    MAX(clasificacion_documento) AS clasificacion_documento,
    COUNT(*) AS cantidad_componentes,
    SUM(presupuestado) AS total_presupuestado,
    SUM(devengado) AS total_devengado,
    SUM(descuento) AS total_descuento
FROM analytics.v_funcionarios_2026_1_eda
WHERE documento IS NOT NULL
GROUP BY
    anho,
    mes,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    documento;
```

Validar:

```sql
SELECT COUNT(*) AS filas_consolidadas
FROM analytics.v_funcionarios_2026_1_persona_oee_mes;
```

Comparar grano crudo versus consolidado:

```sql
SELECT
    'crudo_componentes' AS grano,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_eda
UNION ALL
SELECT
    'persona_oee_mes' AS grano,
    COUNT(*) AS filas
FROM analytics.v_funcionarios_2026_1_persona_oee_mes;
```

---

## Paso 44. Ranking de remuneración consolidada

```sql
SELECT
    documento,
    nombres,
    apellidos,
    descripcion_oee,
    estado,
    cantidad_componentes,
    total_presupuestado,
    total_devengado,
    total_descuento
FROM analytics.v_funcionarios_2026_1_persona_oee_mes
ORDER BY total_devengado DESC
LIMIT 50;
```

---

## Paso 45. Multivinculación institucional preliminar

```sql
SELECT
    documento,
    MAX(nombres) AS nombres,
    MAX(apellidos) AS apellidos,
    COUNT(DISTINCT oee) AS cantidad_oee,
    SUM(total_devengado) AS total_devengado_mes
FROM analytics.v_funcionarios_2026_1_persona_oee_mes
GROUP BY documento
HAVING COUNT(DISTINCT oee) > 1
ORDER BY cantidad_oee DESC, total_devengado_mes DESC
LIMIT 100;
```

### Advertencia metodológica

La multivinculación no implica automáticamente irregularidad. Es una señal para revisar el caso con contexto institucional, régimen laboral, objeto de gasto y normativa aplicable.

---

# 21. Consultas auxiliares para DBeaver

## Paso 46. Exportar resultados desde DBeaver

En DBeaver:

1. Ejecutar la consulta deseada.
2. Click derecho sobre la grilla de resultados.
3. Seleccionar **Export Data**.
4. Elegir formato `CSV` o `XLSX`.
5. Guardar en:

```text
/opt/repo/cit-bigdata-lab/data/exported/
```

Consultas recomendadas para exportar:

```sql
SELECT *
FROM analytics.v_funcionarios_2026_1_persona_oee_mes
ORDER BY total_devengado DESC
LIMIT 1000;
```

```sql
SELECT
    descripcion_oee,
    COUNT(*) AS personas_oee_mes,
    SUM(total_devengado) AS masa_salarial_devengada
FROM analytics.v_funcionarios_2026_1_persona_oee_mes
GROUP BY descripcion_oee
ORDER BY masa_salarial_devengada DESC;
```

---

# 22. Problemas frecuentes en PDI y cómo resolverlos

## 22.1. Error de conexión JDBC

### Síntoma

PDI no logra conectarse a PostgreSQL.

### Causas probables

- Driver JDBC no copiado en `data-integration/lib/`.
- PostgreSQL no está activo.
- Puerto incorrecto.
- Usuario o contraseña incorrectos.
- PostgreSQL corre en WSL2 y PDI en Windows, pero se usa `localhost` de forma incorrecta.

### Solución

1. Verificar servicio:

```bash
sudo systemctl status postgresql --no-pager
```

2. Verificar conexión con `psql`:

```bash
psql -h localhost -p 5432 -U cit_bigdata -d cit_bigdata_lab
```

3. Reiniciar Spoon después de copiar el driver JDBC.

---

## 22.2. Error de cantidad de columnas

### Síntoma

PDI informa que la fila tiene más o menos campos que la tabla destino.

### Causas probables

- Separador incorrecto.
- Enclosure incorrecto.
- Archivo con saltos de línea dentro de campos de texto.
- Encabezado leído como fila de datos.

### Solución

- Usar separador `,`.
- Usar enclosure `"`.
- Activar header con una línea.
- Previsualizar los datos en `Text File Input` antes de ejecutar.

---

## 22.3. Caracteres rotos

### Síntoma

Aparecen textos con caracteres extraños en nombres, cargos o instituciones.

### Solución

- Validar codificación con `file -bi`.
- Convertir a UTF-8 con `iconv`.
- Configurar `Encoding = UTF-8` en el step `Text File Input`.

---

## 22.4. Carga lenta

### Causas probables

- Commit size muy bajo.
- Inserción fila por fila.
- Índices creados antes de la carga.

### Recomendaciones

- Usar `Commit size = 10000` o superior.
- Activar batch update si está disponible.
- Evitar índices en `raw` antes de cargar.
- Para volúmenes mayores, evaluar `PostgreSQL Bulk Loader` o carga con `COPY`.

---

# 23. Tratamiento de problemas de datos: qué hacer y qué no hacer

## 23.1. Valores nulos

### Recomendado en EDA

- medirlos;
- localizar en qué columnas se concentran;
- evaluar si su ausencia impide el análisis.

### No recomendado todavía

- imputar automáticamente sin criterio de negocio.

---

## 23.2. Valores atípicos

### Recomendado en EDA

- detectarlos por percentiles o IQR;
- revisar casos extremos manualmente;
- diferenciarlos entre errores, pagos extraordinarios y casos válidos.

### No recomendado todavía

- eliminar outliers en masa solo porque distorsionan gráficos.

---

## 23.3. Distribuciones sesgadas

### Recomendado en EDA

- comparar media y mediana;
- revisar concentración por percentiles;
- analizar por segmentos.

### No recomendado todavía

- normalizar o transformar variables sin haber definido el objetivo analítico.

---

## 23.4. Inconsistencias textuales

### Recomendado en EDA

- aplicar `TRIM`;
- usar `UPPER` o `LOWER` para comparar;
- revisar dominios con `GROUP BY`.

### No recomendado todavía

- reemplazar categorías manualmente sin registrar reglas de transformación.

---

## 23.5. Duplicados

### Recomendado en EDA

- distinguir duplicados exactos de duplicados de negocio;
- revisar multiplicidad por funcionario y período.

### No recomendado todavía

- usar `SELECT DISTINCT` como solución automática.

---

# 24. Preparación de conclusiones para modelado analítico

La parte más importante del EDA no es la consulta en sí, sino la capacidad de traducir hallazgos en decisiones de diseño.

## 24.1. Preguntas que deben responderse al cierre

1. ¿La tabla cruda representa personas o componentes remunerativos?
2. ¿Qué columnas parecen confiables para usar como dimensiones?
3. ¿Qué campos tienen demasiado ruido para el primer modelo?
4. ¿Qué métricas monetarias deben preservarse?
5. ¿Cuál debería ser el grano del hecho analítico?
6. ¿Qué reglas de limpieza serán obligatorias?
7. ¿Qué controles de ingesta deben incorporarse en el pipeline PDI?
8. ¿Qué transformaciones deben quedar en PDI y cuáles conviene dejar en SQL `staging`?

---

## 24.2. Reglas preliminares sugeridas

### Conservar como ejes analíticos principales

- tiempo: `anho`, `mes`;
- institución: `nivel`, `entidad`, `oee` y sus descripciones;
- identificación funcional: `documento`;
- segmentación laboral: `estado`, `sexo`, `anho_ingreso`;
- clasificación remunerativa: `fuente_financiamiento`, `objeto_gasto`, `concepto`, `categoria`;
- métricas: `presupuestado`, `devengado`, `descuento`.

### Tratar con cautela o diferir

- `cargo`;
- `funcion`;
- `carga_horaria`;
- `movimiento`;
- `lugar`;
- `correo`;
- `profesion`;
- `motivo_movimiento`;
- `uri`.

### Reglas mínimas de limpieza sugeridas

- convertir strings vacíos a `NULL`;
- parsear fechas con funciones defensivas;
- no convertir `documento` a entero;
- distinguir duplicado exacto de multiplicidad de negocio;
- revisar montos cero antes de excluirlos;
- documentar prefijos especiales del `documento`;
- preservar el archivo crudo original y el CSV UTF-8 staged;
- registrar metadatos de ingesta en `control.ingesta_archivos`.

---

## 24.3. Grano analítico preliminar sugerido

Para una futura consolidación general, un grano razonable a validar podría ser:

```text
anho + mes + nivel + entidad + oee + documento
```

Este grano permite construir una vista consolidada mensual por persona e institución. Sin embargo, esa consolidación no debe realizarse sin decidir antes cómo agregar los múltiples componentes remunerativos.

---

# 25. Actividades guiadas para estudiantes

## 25.1. Nivel básico

1. Descargar el dataset y validar el ZIP.
2. Verificar la codificación del archivo CSV.
3. Crear la base PostgreSQL y los esquemas de trabajo.
4. Crear la tabla `raw.funcionarios_2026_1`.
5. Configurar una conexión PostgreSQL en PDI.
6. Cargar el CSV con `Text File Input` y `Table Output`.
7. Contar filas y revisar columnas.

---

## 25.2. Nivel intermedio

1. Crear funciones seguras de conversión en PostgreSQL.
2. Construir la vista tipada `staging.v_funcionarios_2026_1_typed`.
3. Crear la vista enriquecida `analytics.v_funcionarios_2026_1_eda`.
4. Medir nulos en columnas críticas.
5. Identificar cuántos documentos aparecen más de una vez.
6. Calcular media, mediana y cuartiles de `devengado`.
7. Obtener el ranking de instituciones por masa salarial.

---

## 25.3. Nivel desafío

1. Proponer una clave de negocio tentativa para el grano crudo.
2. Diseñar una estrategia de consolidación mensual por funcionario.
3. Clasificar columnas en:
   - dimensión;
   - métrica;
   - trazabilidad;
   - descartable temporalmente.
4. Diseñar un flujo PDI parametrizable para otros meses.
5. Elaborar tres reglas de calidad obligatorias para una futura capa `staging`.
6. Redactar una conclusión técnica defendible sobre el grano real de la fuente.

---

## 25.4. Preguntas de reflexión

1. ¿Qué error analítico cometerías si contaras filas como si fueran personas?
2. ¿Por qué `documento` no debe convertirse automáticamente a entero?
3. ¿Qué diferencia conceptual hay entre `presupuestado` y `devengado`?
4. ¿Qué campos no usarías en un primer dashboard y por qué?
5. ¿Qué evidencia del EDA justifica el modelo analítico que propones?
6. ¿Qué ventajas y desventajas tiene cargar con PDI frente a cargar directamente con SQL?
7. ¿Qué parte del flujo pertenece a ingesta y qué parte pertenece a modelado analítico?

---

# 26. Conclusiones esperadas de la práctica

Al finalizar la práctica, el estudiante debería poder afirmar con fundamento que:

1. el dataset fue descargado, validado e ingestando correctamente en PostgreSQL;
2. la tabla `raw` preserva la fuente sin alteraciones destructivas;
3. PDI actúa como herramienta de ingesta y no como sustituto del razonamiento analítico;
4. la fuente no debe tratarse como una tabla consolidada por persona;
5. existen campos con buena utilidad analítica y otros con calidad débil;
6. los montos monetarios requieren interpretación en contexto;
7. el EDA produce reglas concretas para limpieza, consolidación y modelado;
8. el siguiente paso lógico no es visualizar directamente la tabla cruda, sino diseñar correctamente la capa analítica.

---

# 27. Recomendaciones docentes para implementar la clase

1. **No convertir la práctica en una clase de copiar y pegar pasos.**  
   Lo importante es que el estudiante justifique qué observa y qué decisión tomaría.

2. **Hacer explícita la diferencia entre ingesta y análisis.**  
   PDI resuelve la carga; PostgreSQL y SQL permiten razonar sobre calidad, grano y modelado.

3. **Comparar filas versus personas.**  
   Ese es el punto pedagógico más potente del laboratorio.

4. **Pedir evidencia reproducible.**  
   Toda conclusión debe apoyarse en una consulta SQL o en un control de ingesta verificable.

5. **Evitar resolver el modelo final demasiado pronto.**  
   Primero los estudiantes deben entender por qué la tabla cruda no sirve tal cual.

6. **Usar la práctica para introducir `raw`, `staging`, `analytics` y `control`.**  
   Esa separación conceptual es más importante que memorizar un step de PDI.

7. **Cerrar la clase con una discusión de diseño.**  
   La pregunta final no debería ser “¿cargó el CSV?”, sino:  
   **¿qué modelo analítico tendría sentido construir a partir de lo observado?**

---

# 28. Anexo A: script SQL consolidado

Este bloque puede guardarse como:

```text
/opt/repo/cit-bigdata-lab/sql/ddl/01_setup_postgresql_funcionarios.sql
```

```sql
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS control;

DROP TABLE IF EXISTS raw.funcionarios_2026_1;

CREATE TABLE raw.funcionarios_2026_1 (
    anho TEXT,
    mes TEXT,
    nivel TEXT,
    descripcion_nivel TEXT,
    entidad TEXT,
    descripcion_entidad TEXT,
    oee TEXT,
    descripcion_oee TEXT,
    documento TEXT,
    nombres TEXT,
    apellidos TEXT,
    funcion TEXT,
    estado TEXT,
    carga_horaria TEXT,
    anho_ingreso TEXT,
    sexo TEXT,
    discapacidad TEXT,
    tipo_discapacidad TEXT,
    fuente_financiamiento TEXT,
    objeto_gasto TEXT,
    concepto TEXT,
    linea TEXT,
    categoria TEXT,
    cargo TEXT,
    presupuestado TEXT,
    devengado TEXT,
    movimiento TEXT,
    lugar TEXT,
    fecha_nacimiento TEXT,
    fec_ult_modif TEXT,
    uri TEXT,
    fecha_acto TEXT,
    correo TEXT,
    profesion TEXT,
    motivo_movimiento TEXT
);

CREATE TABLE IF NOT EXISTS control.ingesta_archivos (
    id_ingesta BIGSERIAL PRIMARY KEY,
    fuente TEXT NOT NULL,
    periodo_anho INTEGER,
    periodo_mes INTEGER,
    archivo TEXT NOT NULL,
    ruta_archivo TEXT,
    herramienta TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    estado TEXT DEFAULT 'INICIADO',
    filas_leidas BIGINT,
    filas_insertadas BIGINT,
    observacion TEXT
);
```

---

# 29. Anexo B: script SQL consolidado para staging y analytics

Guardar como:

```text
/opt/repo/cit-bigdata-lab/sql/staging/02_staging_analytics_funcionarios.sql
```

```sql
CREATE OR REPLACE FUNCTION staging.try_int(p_text TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN v_text::INTEGER;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION staging.try_numeric(p_text TEXT)
RETURNS NUMERIC
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN v_text::NUMERIC;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION staging.try_date(p_text TEXT)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_text TEXT;
BEGIN
    v_text := NULLIF(BTRIM(p_text), '');
    IF v_text IS NULL THEN
        RETURN NULL;
    END IF;

    BEGIN
        RETURN v_text::DATE;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            RETURN TO_DATE(SUBSTRING(v_text FROM 1 FOR 10), 'YYYY/MM/DD');
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END;
END;
$$;

CREATE OR REPLACE FUNCTION staging.empty_to_null(p_text TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT NULLIF(BTRIM(p_text), '')
$$;

CREATE OR REPLACE VIEW staging.v_funcionarios_2026_1_typed AS
SELECT
    staging.try_int(anho) AS anho,
    staging.try_int(mes) AS mes,
    staging.try_int(nivel) AS nivel,
    staging.empty_to_null(descripcion_nivel) AS descripcion_nivel,
    staging.try_int(entidad) AS entidad,
    staging.empty_to_null(descripcion_entidad) AS descripcion_entidad,
    staging.try_int(oee) AS oee,
    staging.empty_to_null(descripcion_oee) AS descripcion_oee,
    staging.empty_to_null(documento) AS documento,
    staging.empty_to_null(nombres) AS nombres,
    staging.empty_to_null(apellidos) AS apellidos,
    staging.empty_to_null(funcion) AS funcion,
    UPPER(staging.empty_to_null(estado)) AS estado,
    staging.empty_to_null(carga_horaria) AS carga_horaria,
    staging.try_int(anho_ingreso) AS anho_ingreso,
    UPPER(staging.empty_to_null(sexo)) AS sexo,
    UPPER(staging.empty_to_null(discapacidad)) AS discapacidad,
    staging.empty_to_null(tipo_discapacidad) AS tipo_discapacidad,
    staging.try_int(fuente_financiamiento) AS fuente_financiamiento,
    staging.try_int(objeto_gasto) AS objeto_gasto,
    staging.empty_to_null(concepto) AS concepto,
    staging.empty_to_null(linea) AS linea,
    staging.empty_to_null(categoria) AS categoria,
    staging.empty_to_null(cargo) AS cargo,
    staging.try_numeric(presupuestado) AS presupuestado,
    staging.try_numeric(devengado) AS devengado,
    staging.empty_to_null(movimiento) AS movimiento,
    staging.empty_to_null(lugar) AS lugar,
    staging.empty_to_null(fecha_nacimiento) AS fecha_nacimiento_raw,
    staging.try_date(fecha_nacimiento) AS fecha_nacimiento,
    staging.empty_to_null(fec_ult_modif) AS fec_ult_modif_raw,
    staging.empty_to_null(uri) AS uri,
    staging.empty_to_null(fecha_acto) AS fecha_acto_raw,
    staging.try_date(fecha_acto) AS fecha_acto,
    staging.empty_to_null(correo) AS correo,
    staging.empty_to_null(profesion) AS profesion,
    staging.empty_to_null(motivo_movimiento) AS motivo_movimiento
FROM raw.funcionarios_2026_1;

CREATE OR REPLACE VIEW analytics.v_funcionarios_2026_1_eda AS
SELECT
    t.*,
    (t.presupuestado - t.devengado) AS descuento,
    CASE
        WHEN t.presupuestado IS NOT NULL
         AND t.presupuestado <> 0
         AND t.devengado IS NOT NULL
        THEN ROUND(((t.presupuestado - t.devengado) / t.presupuestado) * 100, 2)
        ELSE NULL
    END AS porcentaje_descuento,
    CASE
        WHEN t.fecha_nacimiento IS NOT NULL
        THEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, t.fecha_nacimiento))::INTEGER
        ELSE NULL
    END AS edad,
    CASE
        WHEN t.anho IS NOT NULL
         AND t.anho_ingreso IS NOT NULL
         AND t.anho_ingreso BETWEEN 1900 AND t.anho
        THEN t.anho - t.anho_ingreso
        ELSE NULL
    END AS antiguedad,
    UPPER(LEFT(t.documento, 1)) AS tipo_identificador,
    CASE
        WHEN UPPER(LEFT(t.documento, 1)) BETWEEN '1' AND '9'
            THEN 'DOCUMENTO NACIONAL'
        WHEN UPPER(LEFT(t.documento, 1)) = 'E'
            THEN 'DOCUMENTO EXTRANJERO'
        WHEN UPPER(LEFT(t.documento, 1)) = 'V'
            THEN 'VACANCIA INSTITUCIONAL'
        WHEN UPPER(LEFT(t.documento, 1)) = 'A'
            THEN 'ANONIMATO ADMINISTRATIVO'
        ELSE 'NO CLASIFICADO'
    END AS clasificacion_documento
FROM staging.v_funcionarios_2026_1_typed t;
```

---

# 30. Cierre técnico

Esta práctica no termina cuando PDI muestra una ejecución exitosa. Termina cuando el estudiante puede defender, con evidencia SQL, tres ideas:

1. **qué representa realmente una fila de la fuente**;
2. **qué problemas de calidad existen**;
3. **qué decisiones de modelado analítico se justifican a partir del EDA**.

Ese es el resultado que realmente importa.
