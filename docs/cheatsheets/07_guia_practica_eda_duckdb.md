<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# 📎 Cheat Sheet: Preparación inicial del entorno para EDA con DuckDB
**Guía rápida para dejar listo el laboratorio previo a `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md`**

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

- **Fecha:** 15/04/2026
- **Versión:** 1.0

---

## Propósito

Este documento resume de forma operativa los pasos, comandos, rutas y verificaciones mínimas para **dejar preparado el entorno de trabajo** antes de ejecutar el taller práctico de la guía `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md`.

El criterio de esta guía es simple: **primero dejar estable el entorno, después ingerir correctamente la fuente y recién luego pasar a EDA y a la construcción de `processed`**.  
No es un tutorial largo. Es una referencia rápida para no perder tiempo con configuraciones básicas durante el laboratorio.

---

## Alcance

**Herramienta / Tecnología:** DuckDB local, MotherDuck opcional, Pentaho Data Integration (PDI/Kettle) 11, DBeaver Community y WSL2/Ubuntu  
**Versión de referencia:** PDI 11, JDK 17, DuckDB CLI, JDBC Driver DuckDB 1.4, Python 3.12, Git  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu + DuckDB + DBeaver Community + Pentaho Data Integration  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- WSL2/Ubuntu operativo y acceso a terminal.
- `duckdb`, `curl`, `unzip`, `iconv`, `git` y `file` disponibles en consola.
- JDK 17 instalado para ejecutar Pentaho Data Integration 11.
- Pentaho Data Integration 11 descomprimido y DBeaver Community instalado.
- Repositorio local del laboratorio accesible en `/opt/repo/cit-bigdata-lab`.
- Para ejecutar sin fricción la guía `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md`, conviene trabajar con una base local `eda.duckdb`.
- MotherDuck puede usarse como alternativa de almacenamiento, pero introduce ajustes extra de conexión. Para un taller inicial, eso rara vez ayuda.

---

## Convenciones usadas en este documento

- `comando` → instrucción para ejecutar en terminal o consola.
- `ruta/archivo` → rutas o nombres de archivos.
- `SQL` → bloque para ejecutar en DuckDB o DBeaver.
- `# comentario` → explicación breve dentro del ejemplo.
- `REPO_ROOT` → raíz operativa del repositorio del curso.
- `raw` → capa de carga inicial sin transformación analítica fuerte.
- `processed` → capa posterior para limpieza, consolidación y exportación.

---

## Decisión operativa clave

En este laboratorio:

- **Pentaho Data Integration 11** se usa como herramienta de ingesta para leer el CSV fuente y volcarlo a **DuckDB local** o **MotherDuck**, según la preferencia del alumno.
- **DBeaver Community** se usa como cliente SQL para inspección, validación, EDA y análisis interpretativo.
- La guía `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md` parte de que la capa `raw` ya existe y que la práctica previa quedó correctamente resuelta.
---

## Comandos esenciales

| Acción | Comando / Sintaxis | Descripción breve |
|---|---|---|
| Verificar Java para Pentaho | `java -version` | Debe responder con JDK/JRE 17. |
| Confirmar variable para PDI | `echo $PENTAHO_JAVA_HOME` | Verifica la ruta de Java usada por Pentaho. |
| Verificar DuckDB | `duckdb --version` | Confirma que el CLI está disponible. |
| Definir raíz del repositorio | `export REPO_ROOT=/opt/repo/cit-bigdata-lab` | Estándar recomendado del curso. |
| Crear carpetas base | `mkdir -p "${REPO_ROOT}/data/"{raw,staged,duckdb,processed}` | Prepara estructura mínima. |
| Descargar fuente | `curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"` | Descarga el dataset fuente. |
| Convertir a UTF-8 | `iconv -f ISO-8859-1 -t UTF-8 ...` | Evita problemas de acentos y caracteres. |
| Abrir base analítica | `duckdb "${REPO_ROOT}/data/duckdb/eda.duckdb"` | Crea o abre la base local. |
| Revisar Git | `git --version` | Útil para control del repositorio del laboratorio. |

---

## Flujo rápido de uso

```bash
# 1) Definir raíz y crear estructura mínima
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged
export DB_DIR=${REPO_ROOT}/data/duckdb

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${DB_DIR}"
cd "${RAW_DIR}/sfp_funcionarios/2026_01"

# 2) Descargar, descomprimir y convertir la fuente
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"
unzip -o "funcionarios_2026_1.csv.zip"
file -bi "funcionarios_2026_1.csv"
iconv -f ISO-8859-1 -t UTF-8 "funcionarios_2026_1.csv" \
  -o "${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv"

# 3) Abrir DuckDB local y dejar lista la base
duckdb "${DB_DIR}/eda.duckdb"
```

---

## Sintaxis frecuente

### 1. Validaciones mínimas del entorno antes de abrir el laboratorio

```bash
java -version
echo $PENTAHO_JAVA_HOME
duckdb --version
python3 --version
Rscript --version
git --version
```

### 2. Preparación de fuente y staging en WSL2/Ubuntu

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged
export DB_DIR=${REPO_ROOT}/data/duckdb

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${DB_DIR}"

cd "${RAW_DIR}/sfp_funcionarios/2026_01"
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"
unzip -o "funcionarios_2026_1.csv.zip"
file -bi "funcionarios_2026_1.csv"

iconv -f ISO-8859-1 -t UTF-8 "funcionarios_2026_1.csv" \
  -o "${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv"

cd "${STG_DIR}/sfp_funcionarios/2026_01"
file -bi "funcionarios_2026_1_utf8.csv"
head -n 2 "funcionarios_2026_1_utf8.csv"
```

### 3. Carga mínima en DuckDB para dejar lista la capa `raw`

```sql
-- Abrir desde terminal:
-- duckdb "/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb"

CREATE SCHEMA IF NOT EXISTS raw;

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

SELECT COUNT(*) AS total_filas
FROM raw.funcionarios_2026_1;

SELECT *
FROM raw.funcionarios_2026_1
LIMIT 5;
```

### 4. Secuencia mínima recomendada de ingesta con Pentaho Data Integration 11

```text
CSV file input
  -> leer funcionarios_2026_1_utf8.csv
  -> validar separador, encabezado y codificación

Select Values / Metadata (opcional)
  -> revisar nombres, longitudes y tipos si aplica

Table Output
  -> destino recomendado: raw.funcionarios_2026_1
  -> base: eda.duckdb (local) o conexión equivalente definida por el alumno
```

### 5. Validación mínima en DBeaver antes de pasar a la guía 02

```sql
SHOW SCHEMAS;

SHOW TABLES FROM raw;

SELECT COUNT(*) AS total_raw
FROM raw.funcionarios_2026_1;

SELECT *
FROM raw.funcionarios_2026_1
LIMIT 10;

-- Requisito importante para la guía 02:
DESCRIBE raw.v_funcionarios_2026_1_typed;
```

---

## Ejemplos rápidos

### Ejemplo 1 — Preparar carpetas y normalizar la fuente

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
mkdir -p "${REPO_ROOT}/data/raw/sfp_funcionarios/2026_01"
mkdir -p "${REPO_ROOT}/data/staged/sfp_funcionarios/2026_01"

cd "${REPO_ROOT}/data/raw/sfp_funcionarios/2026_01"
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"
unzip -o "funcionarios_2026_1.csv.zip"

iconv -f ISO-8859-1 -t UTF-8 "funcionarios_2026_1.csv" \
  -o "${REPO_ROOT}/data/staged/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv"
```

### Ejemplo 2 — Crear y validar la base local `eda.duckdb`

```bash
mkdir -p /opt/repo/cit-bigdata-lab/data/duckdb
duckdb /opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb
```

```sql
CREATE SCHEMA IF NOT EXISTS raw;

SELECT current_database();

SHOW SCHEMAS;
SHOW TABLES FROM raw;
```

### Ejemplo 3 — Checklist mínimo para dejar listo el taller siguiente

```text
[OK] Java 17 operativo
[OK] Pentaho 11 abre correctamente
[OK] DBeaver Community instalado
[OK] CSV descargado y convertido a UTF-8
[OK] eda.duckdb creado
[OK] tabla raw.funcionarios_2026_1 cargada
[OK] vista raw.v_funcionarios_2026_1_typed disponible
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Repositorio base | `/opt/repo/cit-bigdata-lab` | Raíz recomendada para el laboratorio. |
| Archivo ZIP fuente | `/opt/repo/cit-bigdata-lab/data/raw/sfp_funcionarios/2026_01/funcionarios_2026_1.csv.zip` | Descarga original del portal de datos. |
| CSV normalizado | `/opt/repo/cit-bigdata-lab/data/staged/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv` | Archivo listo para ingesta estable. |
| Base local DuckDB | `/opt/repo/cit-bigdata-lab/data/duckdb/eda.duckdb` | Base recomendada para el taller. |
| Script SQL posterior | `/opt/repo/cit-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql` | Se usa en la guía 02. |
| Script R posterior | `/opt/repo/cit-bigdata-lab/scripts/r/03_eda_funcionarios_2026_1.R` | Se usa para EDA científico. |
| Pentaho local | `C:\Pentaho\data-integration` | Ruta corta sugerida en Windows. |
| `kettle.properties` | `C:\Users\<usuario>\.kettle\kettle.properties` | Variables globales para PDI. |
| Driver JDBC DuckDB | `duckdb_jdbc-1.4.x.jar` | Requerido para conexión desde herramientas cliente según configuración del alumno. |

---

## Errores frecuentes y solución rápida

| Error / Situación | Diagnóstico probable | Solución rápida |
|---|---|---|
| `duckdb: command not found` | DuckDB CLI no está instalado o no está en `PATH`. | Instalar DuckDB y validar con `duckdb --version`. |
| `spoon.bat` no inicia | Java incorrecto o variable mal configurada. | Confirmar JDK 17 y revisar `PENTAHO_JAVA_HOME`. |
| Acentos o caracteres rotos en nombres | CSV cargado sin normalizar encoding. | Convertir primero con `iconv` a UTF-8. |
| `raw.v_funcionarios_2026_1_typed` no existe | La práctica previa no fue completada. | No avances a la guía 02. Primero construye y valida la vista tipada. |
| DBeaver no encuentra la base | Ruta incorrecta o archivo no creado aún. | Verificar que existe `eda.duckdb` y abrir exactamente ese archivo. |
| Conteos inesperados en `raw` | Ingesta incompleta o tabla sobrescrita mal. | Repetir la carga y volver a validar `COUNT(*)` y `LIMIT 10`. |
| Pentaho conecta pero no escribe | Driver/conexión JDBC incompleta o tabla destino mal definida. | Revisar conexión, esquema destino y permisos del archivo/base. |

---

## Buenas prácticas

- Define una sola raíz operativa del repositorio y úsala en todos los comandos del laboratorio.
- Convierte el CSV a UTF-8 antes de cualquier carga. Saltarte eso es comprar problemas innecesarios.
- Mantén la capa `raw` lo más cercana posible a la fuente; no la “limpies” de forma agresiva.
- Usa Pentaho para ingesta y DBeaver para validación; no mezcles ambos propósitos sin criterio.
- Valida primero la existencia de `raw.funcionarios_2026_1` y `raw.v_funcionarios_2026_1_typed` antes de ejecutar la guía 02.
- Si eliges MotherDuck, documenta claramente qué cambiaste respecto al camino local estándar.
- No hagas EDA serio sobre una tabla que ni siquiera pasó controles mínimos de estructura, codificación y conteo.

---

## Atajos o recordatorios clave

**Nota rápida 1:** Para el taller siguiente, el punto de entrada operativo más estable sigue siendo `eda.duckdb` local.  
**Nota rápida 2:** Pentaho se usa para cargar datos; DBeaver se usa para consultar, inspeccionar y analizar.  
**Nota rápida 3:** La guía `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md` no reemplaza la preparación inicial; depende de ella.  

---

## Checklist de salida del entorno listo

```text
[ ] WSL2/Ubuntu operativo
[ ] Java 17 validado
[ ] Pentaho Data Integration 11 operativo
[ ] DBeaver Community operativo
[ ] DuckDB CLI operativo
[ ] Repositorio /opt/repo/cit-bigdata-lab preparado
[ ] CSV fuente descargado
[ ] CSV convertido a UTF-8
[ ] eda.duckdb creado
[ ] tabla raw.funcionarios_2026_1 disponible
[ ] vista raw.v_funcionarios_2026_1_typed validada
```

---

## Referencias

1. `cheatsheet.md` — plantilla institucional y de estilo para documentos rápidos del laboratorio.
2. `guia_inicial_practica_eda.md` — borrador base de preparación del entorno, ingesta inicial y contexto operativo de PDI, DuckDB y MotherDuck.
3. `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md` — guía de continuación para construir `processed` y ejecutar EDA científico en R.
4. Fuente de datos del laboratorio: `https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip`.

---

## Relación con otros documentos del repositorio

- **Tutorial relacionado:** `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md`
- **Documento complementario:** `guia_inicial_practica_eda.md`
- **Plantilla base utilizada:** `cheatsheet.md`

---

## Recomendación de uso

Este Cheat Sheet debe usarse **antes** del taller de `processed` y del EDA en R.  
Su función no es explicar toda la práctica, sino evitar fallos básicos de instalación, rutas, codificación, conexión e ingesta.

La secuencia correcta es esta:

1. preparar entorno;
2. descargar y normalizar fuente;
3. cargar `raw`;
4. validar en DBeaver;
5. confirmar vista tipada;
6. recién después pasar a `processed` y al EDA científico.

---

## Directorio sugerido

```text
/opt/repo/cit-bigdata-lab/docs/cheatsheets/
```

## Nombre del archivo

```text
docs/cheatsheet/guia_practica_eda_duckdb.md
```

> **Recordatorio:** este documento debe seguir siendo una guía rápida.  
> Si empieza a reemplazar el tutorial largo, perdió su propósito.
