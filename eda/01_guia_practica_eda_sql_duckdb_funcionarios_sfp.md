<div align="center">
  <img src="../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
  <h1>FPUNA · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Guía práctica paso a paso: Análisis Exploratorio de Datos (EDA) con SQL sobre DuckDB

### Práctica de laboratorio sobre la fuente `https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip`

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente de la asignatura *Electiva - Big Data*  
Facultad Politécnica - Universidad Nacional de Asunción  

---

## Fecha y versión

- **Fecha:** 26/03/2026
- **Versión:** 1.0

---

## 1. Propósito de la práctica

Esta guía orienta paso a paso el desarrollo de una clase práctica de **Análisis Exploratorio de Datos (EDA)** con **SQL sobre DuckDB** a partir de la fuente pública de **remuneraciones de funcionarios públicos** publicada en el portal histórico `datos.sfp.gov.py`.

La práctica tiene cuatro metas concretas:

1. preparar el dataset en un entorno reproducible de laboratorio;
2. cargar la fuente en una base analítica local `eda.duckdb`;
3. explorar la estructura, la calidad y la semántica operativa de los datos;
4. extraer conclusiones útiles para el diseño de un **modelado analítico** posterior.

---

## 2. Introducción breve: qué es un EDA y por qué importa

Un **EDA** es una etapa de reconocimiento y diagnóstico de datos. No busca todavía construir dashboards ni modelos finales, sino responder preguntas fundamentales como:

- qué contiene realmente la fuente;
- cuál es su granularidad;
- qué columnas son confiables;
- dónde hay nulos, atípicos, duplicados o inconsistencias;
- y qué reglas deberán aplicarse más adelante en limpieza y modelado.

En ingeniería de datos, el EDA cumple una función crítica: **evita modelar a ciegas**.  
Si el equipo asume mal el grano de la fuente, interpreta mal una métrica o no detecta duplicidades de negocio, todo el modelo analítico queda contaminado desde el inicio.

El uso de **SQL sobre DuckDB** es especialmente adecuado para esta práctica porque:

- permite trabajar localmente sin montar infraestructura pesada;
- facilita exploración rápida sobre archivos tabulares;
- soporta creación de tablas persistentes y vistas analíticas;
- y ofrece una sintaxis clara para estudiantes que están comenzando.

---

## 3. Objetivos

### 3.1. Objetivo general

Realizar un análisis exploratorio de datos del archivo `funcionarios_2026_1.csv.zip` con SQL sobre DuckDB, identificando estructura, calidad, patrones y hallazgos clave que sirvan de base para un futuro modelado analítico.

### 3.2. Objetivos específicos

1. Descargar y validar técnicamente el archivo fuente en el repositorio local del laboratorio.
2. Verificar integridad básica del archivo ZIP y la codificación del CSV antes de su carga.
3. Crear la base analítica `eda.duckdb` y el esquema `raw`.
4. Volcar la fuente en bruto sin alterar su estructura original.
5. Construir una vista tipada de apoyo para facilitar el EDA.
6. Detectar nulos, duplicados, formatos defectuosos y valores improbables.
7. Explorar distribuciones y relaciones entre variables clave del dataset.
8. Formular reglas preliminares para consolidación y modelado analítico posterior.

---

## 4. Base de conocimiento previa a la práctica

## 4.1. Contexto institucional de la fuente

La fuente pertenece al ecosistema histórico de datos abiertos de la función pública paraguaya y se distribuye en archivos CSV comprimidos por año y mes.  
Para esta práctica se utilizará el período **marzo de 2026**, representado por el recurso:

```text
https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip
```

## 4.2. Naturaleza del dataset

La fuente contiene información de remuneraciones, contexto institucional y algunos atributos laborales y personales de funcionarios públicos.  
Desde el punto de vista analítico, no debe asumirse como una tabla lista para BI.

La lectura más prudente del grano es:

**una fila por componente remunerativo de un funcionario en un período y contexto institucional determinado**

Eso implica que:

- una persona puede aparecer varias veces en el mismo mes;
- las métricas monetarias deben interpretarse con cuidado;
- y la tabla cruda no debe consumirse directamente como si fuera “una fila = una persona”.

## 4.3. Columnas observadas en la fuente

A partir de la muestra revisada, la fuente contiene **35 columnas**:

```text
anho, mes, nivel, descripcion_nivel, entidad, descripcion_entidad, oee, descripcion_oee,
documento, nombres, apellidos, funcion, estado, carga_horaria, anho_ingreso, sexo,
discapacidad, tipo_discapacidad, fuente_financiamiento, objeto_gasto, concepto, linea,
categoria, cargo, presupuestado, devengado, movimiento, lugar, fecha_nacimiento,
fec_ult_modif, uri, fecha_acto, correo, profesion, motivo_movimiento
```

## 4.4. Variables críticas para el EDA

Las columnas de mayor interés para esta práctica son:

- **Temporales:** `anho`, `mes`
- **Institucionales:** `nivel`, `descripcion_nivel`, `entidad`, `descripcion_entidad`, `oee`, `descripcion_oee`
- **Identificación:** `documento`, `nombres`, `apellidos`
- **Laborales:** `estado`, `cargo`, `funcion`, `anho_ingreso`
- **Segmentación básica:** `sexo`, `discapacidad`, `tipo_discapacidad`
- **Remunerativas:** `fuente_financiamiento`, `objeto_gasto`, `concepto`, `linea`, `categoria`, `presupuestado`, `devengado`
- **Fechas y trazabilidad:** `fecha_nacimiento`, `fec_ult_modif`, `fecha_acto`, `uri`

## 4.5. Riesgos y advertencias metodológicas

Antes de ejecutar una sola consulta, estas advertencias deben quedar claras:

1. **El campo `documento` no necesariamente representa solo cédulas convencionales.**
2. **La tabla cruda no debe usarse para contar personas sin control de duplicidad.**
3. **`presupuestado` y `devengado` no son equivalentes.**
4. **Hay campos descriptivos con calidad heterogénea** como `cargo`, `funcion`, `profesion`, `movimiento`, `lugar`, `motivo_movimiento`.
5. **Las fechas deben parsearse de forma defensiva.**
6. **Los montos cero o valores extremos no deben descartarse sin análisis.**
7. **La fuente es operativa**, no un modelo dimensional.

## 4.6. Hipótesis iniciales de exploración

Durante la práctica se buscará validar o refutar estas hipótesis:

- H1. La fuente contiene más filas que personas por la existencia de múltiples componentes remunerativos.
- H2. Existen columnas con alta proporción de nulos o baja utilidad analítica inicial.
- H3. Los montos `devengado` presentan asimetría y valores extremos.
- H4. La distribución de remuneraciones cambia según institución, tipo de vínculo y objeto de gasto.
- H5. Algunas columnas de contexto administrativo pueden quedar fuera del primer modelo analítico.
- H6. El grano apropiado para una consolidación mensual general será distinto del grano crudo.

---

## 5. Supuestos y limitaciones de esta guía

1. Se asume un entorno **Ubuntu sobre WSL2** con acceso a terminal.
2. Se asume que **DuckDB CLI** ya está instalado y disponible en el PATH.
3. Se asume conectividad para descargar el archivo fuente desde internet.
4. Esta guía usará como ruta base el repositorio:

```bash
cd /opt/repo/cit-bigdata-lab
```

5. La práctica prioriza una carga **reproducible y conservadora**: primero se preserva el dato bruto y luego se construye una vista tipada de apoyo.
6. La guía no resuelve todavía el modelado final; prepara el terreno para hacerlo correctamente.

---

## 6. Requisitos del entorno

Verifica estos puntos antes de iniciar:

### 6.1. Verificar sistema y DuckDB

```bash
uname -a
pwd
duckdb --version
```

### 6.2. Estructura mínima recomendada del repositorio

```text
/opt/repo/cit-bigdata-lab/
├── data/
│   ├── raw/
│   ├── staged/
│   ├── processed/
│   ├── exported/
│   └── duckdb/
│       └── eda.duckdb
└── docs/
```

### 6.3. Herramientas de shell utilizadas en esta práctica

- `mkdir`
- `cd`
- `curl`
- `unzip`
- `file`
- `iconv`
- `head`
- `ls`
- `duckdb`

Si alguna no está instalada, resuélvelo antes de iniciar la práctica.

---

## 7. Paso a paso de la práctica

## Paso 1. Crear el directorio de trabajo para la fuente

En esta guía se recomienda guardar la descarga en una carpeta específica para no mezclar archivos crudos con otros insumos.

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
export RAW_DIR=${REPO_ROOT}/data/raw
export STG_DIR=${REPO_ROOT}/data/staged

mkdir -p "${RAW_DIR}/sfp_funcionarios/2026_01"
mkdir -p "${STG_DIR}/sfp_funcionarios/2026_01"
cd "${SRC_DIR}"
pwd
```

### Qué se espera observar

La ruta actual debería quedar posicionada dentro de:

```text
/opt/repo/cit-bigdata-lab/data/raw/sfp_funcionarios/2026_01
```

---

## Paso 2. Descargar el archivo fuente

Descarga el recurso oficial en formato ZIP y en modo seguro.

```bash
# 1. Actualizar certificados en tu sistema
sudo apt-get update
sudo apt-get install --reinstall ca-certificates
sudo update-ca-certificates

# 2. Verificar el certificado del servidor sea GlobalSignRSAOVSSLCA2018.pem
openssl s_client -connect datos.sfp.gov.py:443

# 3. Descargar el certificado GlobalSignRSAOVSSLCA2018
wget https://secure.globalsign.com/cacert/gsrsaovsslca2018.crt -O gsrsaovsslca2018.crt

# 4. Convierte a PEM si está en DER
openssl x509 -inform DER -in gsrsaovsslca2018.crt -out GlobalSignRSAOVSSLCA2018.pem

# 5. Verificar que sea legible
openssl x509 -in GlobalSignRSAOVSSLCA2018.pem -text -noout

# 6. Usar el certificado en curl
curl --cacert GlobalSignRSAOVSSLCA2018.pem \
     -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" \
     -o "funcionarios_2026_1.csv.zip"
```

Descargar con verificación deshabilitada (solo para pruebas rápida de laboratorio)

```bash
# No recomendado en producción, porque omite la validación de seguridad
curl -k -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip" -o "funcionarios_2026_1.csv.zip"
```

### Verificación inmediata

```bash
ls -lh
```

### Qué se espera observar

Debe existir el archivo:

```text
funcionarios_2026_1.csv.zip
```

Si la descarga falla, **no sigas**.  
Primero confirma conectividad, URL y permisos de escritura.

---

## Paso 3. Verificar integridad básica del ZIP

Antes de descomprimir, valida que el contenedor ZIP no esté corrupto.

```bash
sudo apt install unzip
unzip -l "funcionarios_2026_1.csv.zip"
unzip -t "funcionarios_2026_1.csv.zip"
```

### Interpretación

- `unzip -l` lista el contenido interno.
- `unzip -t` valida integridad del ZIP.

Si `unzip -t` reporta errores, la descarga no es confiable y debe repetirse.

### El archivo `funcionarios_2026_1.csv.zip.md5` es un *checksum* de comprobación

Contiene el valor hash MD5 del archivo original. Sirve para que verifiques que el archivo que descargaste no se corrompió ni fue alterado en tránsito.

```bash
# 1. Descarga el archivo .md5 junto con el .zip
curl --cacert GlobalSignRSAOVSSLCA2018.pem \
     -fL "https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip.md5" \
     -o "funcionarios_2026_1.csv.zip.md5"

# 2. Visualiza el valor esperado 
cat funcionarios_2026_1.csv.zip.md5

# 3. Calcula el hash MD5 de tu archivo descargado
md5sum funcionarios_2026_1.csv.zip
```

---

## Paso 4. Descomprimir el archivo CSV

```bash
unzip -o "funcionarios_2026_1.csv.zip"
ls -lh
```

### Qué se espera observar

Además del ZIP, debe aparecer un archivo CSV con un nombre similar a:

```text
funcionarios_2026_1.csv
```

---

## Paso 5. Validar codificación y legibilidad del CSV

Este paso es clave. No conviene cargar a DuckDB un archivo con codificación defectuosa.

### 5.1. Inspección rápida del tipo de archivo

```bash
file -bi "funcionarios_2026_1.csv"
```
> **Nota:** Ese resultado significa que tu archivo funcionarios_2026_1.csv fue identificado como un archivo de texto en formato CSV y que su codificación de caracteres es ISO-8859-1 (también conocido como Latin-1).

**¿Cómo convertir a UTF-8?**

```bash
iconv -f ISO-8859-1 -t UTF-8 funcionarios_2026_1.csv -o ${STG_DIR}/sfp_funcionarios/2026_01/funcionarios_2026_1_utf8.csv
cd ${STG_DIR}/sfp_funcionarios/2026_01
file -bi "funcionarios_2026_1_utf8.csv"
```

### 5.2. Validación estricta de UTF-8

```bash
iconv -f UTF-8 -t UTF-8 "funcionarios_2026_1_utf8.csv" > /dev/null && \
echo "Validación UTF-8: OK"
```

### 5.3. Revisar primeras líneas

```bash
head -n 2 "funcionarios_2026_1_utf8.csv"
```

### Criterio de decisión

- Si el archivo se valida como UTF-8 y el encabezado se ve legible, continúa.
- Si aparecen caracteres rotos o `iconv` falla, **detén la práctica** y revisa la codificación antes de cargar.
- No recodifiques “a ciegas”. Primero confirma qué codificación tiene realmente el archivo.

---

## Paso 6. Crear la base de datos analítica `eda.duckdb`

Ubica la base en el directorio `data/duckdb/` del repositorio.

```bash
duckdb "${REPO_ROOT}/data/duckdb/eda.duckdb"
```

A partir de este punto, las sentencias se ejecutan dentro del cliente SQL de DuckDB.

---

## Paso 7. Crear el esquema `raw`

```sql
CREATE SCHEMA IF NOT EXISTS raw;
```

### Propósito

El esquema `raw` se reserva para conservar los datos **tal como llegan**, sin limpieza destructiva.

---

## Paso 8. Volcar la fuente en bruto al esquema `raw`

La recomendación pedagógica aquí es clara: **preservar primero y tipar después**.

```sql
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

### Por qué se usa `all_varchar = true`

Porque en la capa `raw` interesa:

- evitar conversiones agresivas durante la ingesta;
- preservar el contenido original;
- y diferir el tipado a una vista o capa de apoyo para EDA.

### Verificación de la carga

```sql
SELECT COUNT(*) AS total_filas
FROM raw.funcionarios_2026_1;

DESCRIBE raw.funcionarios_2026_1;

SELECT *
FROM raw.funcionarios_2026_1
LIMIT 10;
```

### Qué se espera observar

- una tabla persistente en `raw`;
- las 35 columnas cargadas;
- todos los campos como `VARCHAR`;
- y filas visibles sin errores de parseo estructural.

---

## Paso 9. Crear una vista tipada de apoyo para el EDA

En un proyecto real esta lógica debería vivir en una capa `staging` o `silver`.  

```sql
CREATE SCHEMA IF NOT EXISTS staging;
```

En esta práctica se crea una **vista de apoyo** para facilitar el análisis sin modificar la tabla cruda.

```sql
CREATE OR REPLACE VIEW staging.v_funcionarios_2026_1_typed AS
SELECT
    TRY_CAST(anho AS INTEGER) AS anho,
    TRY_CAST(mes AS INTEGER) AS mes,
    TRY_CAST(nivel AS INTEGER) AS nivel,
    NULLIF(TRIM(descripcion_nivel), '') AS descripcion_nivel,
    TRY_CAST(entidad AS INTEGER) AS entidad,
    NULLIF(TRIM(descripcion_entidad), '') AS descripcion_entidad,
    TRY_CAST(oee AS INTEGER) AS oee,
    NULLIF(TRIM(descripcion_oee), '') AS descripcion_oee,
    NULLIF(TRIM(documento), '') AS documento,
    NULLIF(TRIM(nombres), '') AS nombres,
    NULLIF(TRIM(apellidos), '') AS apellidos,
    NULLIF(TRIM(funcion), '') AS funcion,
    UPPER(NULLIF(TRIM(estado), '')) AS estado,
    NULLIF(TRIM(carga_horaria), '') AS carga_horaria,
    TRY_CAST(anho_ingreso AS INTEGER) AS anho_ingreso,
    UPPER(NULLIF(TRIM(sexo), '')) AS sexo,
    UPPER(NULLIF(TRIM(discapacidad), '')) AS discapacidad,
    NULLIF(TRIM(tipo_discapacidad), '') AS tipo_discapacidad,
    TRY_CAST(fuente_financiamiento AS INTEGER) AS fuente_financiamiento,
    TRY_CAST(objeto_gasto AS INTEGER) AS objeto_gasto,
    NULLIF(TRIM(concepto), '') AS concepto,
    NULLIF(TRIM(linea), '') AS linea,
    NULLIF(TRIM(categoria), '') AS categoria,
    NULLIF(TRIM(cargo), '') AS cargo,
    TRY_CAST(presupuestado AS DOUBLE) AS presupuestado,
    TRY_CAST(devengado AS DOUBLE) AS devengado,
    NULLIF(TRIM(movimiento), '') AS movimiento,
    NULLIF(TRIM(lugar), '') AS lugar,
    NULLIF(TRIM(fecha_nacimiento), '') AS fecha_nacimiento_raw,
    TRY_CAST(
        try_strptime(
            NULLIF(TRIM(fecha_nacimiento), ''),
            ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
        ) AS DATE
    ) AS fecha_nacimiento,
    NULLIF(TRIM(fec_ult_modif), '') AS fec_ult_modif_raw,
    try_strptime(
        NULLIF(TRIM(fec_ult_modif), ''),
        ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
    ) AS fec_ult_modif_ts,
    NULLIF(TRIM(uri), '') AS uri,
    NULLIF(TRIM(fecha_acto), '') AS fecha_acto_raw,
    TRY_CAST(
        try_strptime(
            NULLIF(TRIM(fecha_acto), ''),
            ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
        ) AS DATE
    ) AS fecha_acto,
    NULLIF(TRIM(correo), '') AS correo,
    NULLIF(TRIM(profesion), '') AS profesion,
    NULLIF(TRIM(motivo_movimiento), '') AS motivo_movimiento
FROM raw.funcionarios_2026_1;
```

### Validación rápida

```sql
DESCRIBE staging.v_funcionarios_2026_1_typed;

SELECT *
FROM staging.v_funcionarios_2026_1_typed
LIMIT 10;
```

---

## Paso 10. Exploración estructural inicial

El objetivo aquí es entender **qué fue cargado realmente**.

### 10.1. Conteo general

```sql
SELECT COUNT(*) AS total_filas
FROM staging.v_funcionarios_2026_1_typed;
```

### 10.2. Revisión rápida del esquema

```sql
DESCRIBE staging.v_funcionarios_2026_1_typed;
```

### 10.3. Resumen estadístico general

```sql
SUMMARIZE staging.v_funcionarios_2026_1_typed;
```

### 10.4 Resumen estadístico de variables cuantitativas y de tiempo

```sql
SELECT * 
FROM (SUMMARIZE staging.v_funcionarios_2026_1_typed) 
WHERE column_type <> 'VARCHAR';
```

### 10.5 Revisión de clave compuesta

```sql
SELECT * 
FROM (SUMMARIZE staging.v_funcionarios_2026_1_typed) 
WHERE column_name in('documento', 'nivel', 'entidad', 'oee', 'objeto_gasto');
```

### Qué analizar en este bloque

- cantidad total de filas;
- tipos inferidos en la vista;
- columnas con muchos `NULL`;
- rangos sospechosos;
- y primeras señales de campos problemáticos.

---

## Paso 11. Detectar la granularidad real de observación

Aquí está una de las preguntas más importantes de la práctica.

### 11.1. Filas versus documentos únicos

```sql
SELECT
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS documentos_unicos,
    COUNT(*) - COUNT(DISTINCT documento) AS diferencia,
    ROUND(documentos_unicos / filas, 2) * 100 AS porcentaje_documentos_unicos,
    ROUND(diferencia / filas, 2) * 100 AS porcentaje_diferencias
FROM staging.v_funcionarios_2026_1_typed;
```

### Interpretación esperada

Si `filas` es mayor que `documentos_unicos`, entonces la tabla no está consolidada a nivel persona.

### 11.2. Funcionarios con múltiples filas en el mismo período

```sql
SELECT
    documento,
    anho,
    mes,
    COUNT(*) AS filas_por_documento_mes
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1
ORDER BY filas_por_documento_mes DESC, documento
LIMIT 50;
```

Análisis exploratorio de los componentes remunerativos de un funcionario específico.

```sql
-- Query 1
SELECT * FROM staging.v_funcionarios_2026_1_typed WHERE documento = '{documento}';

-- Query 2
SELECT
    SUM(presupuestado) AS monto_bruto,
    SUM(devengado ) AS monto_neto, 
    monto_bruto - monto_neto AS descuento_total,
    ROUND(descuento_total / monto_bruto, 2) * 100 AS porcentaje_descuento
FROM staging.v_funcionarios_2026_1_typed WHERE documento = '{documento}';
```

### 11.3. Ver componentes remunerativos de casos repetidos

```sql
SELECT
    documento,
    nombres,
    apellidos,
    objeto_gasto,
    concepto,
    categoria,
    presupuestado,
    devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IN (
    SELECT documento
    FROM staging.v_funcionarios_2026_1_typed
    WHERE documento IS NOT NULL
    GROUP BY documento, anho, mes
    HAVING COUNT(*) > 1
)
ORDER BY documento, objeto_gasto, concepto
LIMIT 100;
```

### 11.4 Clasificación semántica del campo `documento` mediante el primer carácter

La exploración del primer carácter del documento revela un atributo categórico derivado, útil para la clasificación de registros y la evaluación de consistencia en modelos de datos.

```sql
-- Query 1: Extarer primer caracter
SELECT DISTINCT substr(documento, 1, 1) AS tipo_identificador
FROM staging.v_funcionarios_2026_1_typed
ORDER BY primer_caracter;

-- Query 2: Explorar registros con tipo de identificador 'A', 'E' y 'V'
SELECT *, substr(documento, 1, 1) AS tipo_identificador
FROM staging.v_funcionarios_2026_1_typed
WHERE tipo_identificador = 'A'
LIMIT 50;

-- Query 3: Contar filas por tipo de identificador y clasificación de documento
SELECT
	DISTINCT substr(documento, 1, 1) AS tipo_identificador,
	CASE
		WHEN tipo_identificador BETWEEN '1' AND '9' THEN 'DOCUMENTO NACIONAL'
		WHEN tipo_identificador == 'E' THEN 'DOCUMENTO EXTRANJERO'
		WHEN tipo_identificador == 'V' THEN 'VACANCIA INSTITUCIONAL'
		WHEN tipo_identificador == 'A' THEN 'ANONIMATO ADMINISTRATIVO'
		ELSE 'NO CLASIFICADO'
	END AS clasificacion_documento,
	COUNT(*) AS cantidad_filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY tipo_identificador
ORDER BY tipo_identificador;

-- Query 4: Cuantificar el nivel de ruido o basura en la fuente de datos
SELECT
	DISTINCT substr(documento, 1, 1) AS tipo_identificador,
	CASE
		WHEN tipo_identificador BETWEEN '1' AND '9' THEN 'DOCUMENTO NACIONAL'
		WHEN tipo_identificador == 'E' THEN 'DOCUMENTO EXTRANJERO'
		WHEN tipo_identificador == 'V' THEN 'VACANCIA INSTITUCIONAL'
		WHEN tipo_identificador == 'A' THEN 'ANONIMATO ADMINISTRATIVO'
		ELSE 'NO CLASIFICADO'
	END AS clasificacion_documento,
	COUNT(*) AS cantidad_filas
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado = 0 and devengado = 0
GROUP BY tipo_identificador
ORDER BY tipo_identificador;

-- Query 5: Obtener métrica objetiva de limpieza de datos, útil para reportes de calidad y para documentar decisiones de depuración en tu pipeline
WITH total AS (
    SELECT COUNT(*) AS total_filas
    FROM staging.v_funcionarios_2026_1_typed
),
basura AS (
    SELECT COUNT(*) AS filas_basura
    FROM staging.v_funcionarios_2026_1_typed
    WHERE presupuestado = 0 AND devengado = 0
)
SELECT
    t.total_filas,
    b.filas_basura,
    ROUND(100.0 * b.filas_basura / t.total_filas, 2) AS porcentaje_basura
FROM total t, basura b;
```

El análisis exploratorio del primer carácter del campo `documento` permite establecer una **codificación implícita de la identidad y condición del funcionario** dentro del sistema de información. En términos de ingeniería de datos:

- Los valores **numéricos (1–9)** corresponden a documentos de identidad nacionales, asociados a funcionarios con **cédula paraguaya**.  
- El valor **`E`** indica registros vinculados a **documentos extranjeros**, representando funcionarios de **nacionalidad no paraguaya**.  
- El valor **`V`** señala registros de **vacancia institucional**, es decir, cargos presupuestados sin un titular asignado.  
- El valor **`A`** corresponde a casos de **anonimato administrativo**, donde el cargo está ocupado pero la identidad del funcionario no se encuentra registrada.

Desde la perspectiva de **gobernanza de datos**, esta codificación constituye un **atributo semántico clave** para la clasificación de registros, ya que permite distinguir entre **identidades válidas, registros administrativos especiales y excepciones**. En un pipeline de calidad de datos, este campo puede ser utilizado como **variable de control** para auditorías, segmentación de población y validación de consistencia en los procesos de ETL/ELT.  

> En otras palabras, el primer carácter del documento no es solo un valor textual, sino un **metadato embebido** que aporta información sobre la **naturaleza del registro** y debe ser tratado como un **atributo categórico de referencia** en los modelos de análisis.  

### Conclusión metodológica esperada


La práctica debería llevar al estudiante a concluir que la fuente cruda se parece más a un **detalle remunerativo** que a un padrón consolidado mensual por persona.

Además, como resultado de la exploración inicial se arma una **tabla de mapeo técnico** para documentar el significado de cada valor en la columna `tipo_identificador`. Esto te sirve como referencia formal para el flujo de datos y en auditorías de calidad.

#### Tabla de mapeo de `tipo_identificador`

| Valor | Significado técnico | Interpretación en datos | Uso en auditoría / ETL |
|-------|---------------------|-------------------------|-------------------------|
| `1–9` | Documento nacional | Cédula paraguaya → funcionario con nacionalidad paraguaya | Clasificación de identidad válida; segmentación de población nacional |
| `E`   | Documento extranjero | Funcionario con nacionalidad extranjera | Control de diversidad; validación de registros internacionales |
| `V`   | Vacancia institucional | Cargo presupuestado sin titular | Detección de puestos vacantes; análisis de estructura organizacional |
| `A`   | Anonimato administrativo | Cargo ocupado sin identidad registrada | Señal de inconsistencia o reserva de identidad; requiere revisión de calidad |

En términos de **ingeniería de datos**, este atributo debe ser tratado como un **metadato de clasificación** dentro del modelo de calidad y gobernanza, ya que:
- Facilita la **segmentación de la población** en procesos analíticos.  
- Permite la **detección temprana de inconsistencias** (ej. anonimato).  
- Sirve como **variable de control** en auditorías de ETL/ELT, asegurando que los registros se interpreten correctamente según su naturaleza administrativa.  

En resumen, `tipo_identificador` no es solo un carácter inicial, sino un **código semántico clave** para la trazabilidad y validación de los datos de funcionarios.

---

## Paso 12. Calidad de datos: nulos, vacíos e inconsistencias

## 12.1. Nulos en columnas críticas

```sql
-- Query 1
SELECT 'documento' AS columna, COUNT(*) AS nulos
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NULL

UNION ALL
SELECT 'nombres', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE nombres IS NULL

UNION ALL
SELECT 'apellidos', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE apellidos IS NULL

UNION ALL
SELECT 'estado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE estado IS NULL

UNION ALL
SELECT 'sexo', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE sexo IS NULL

UNION ALL
SELECT 'objeto_gasto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE objeto_gasto IS NULL

UNION ALL
SELECT 'concepto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE concepto IS NULL

UNION ALL
SELECT 'presupuestado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NULL

UNION ALL
SELECT 'devengado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NULL

UNION ALL
SELECT 'fecha_acto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE fecha_acto IS NULL

-- Query 2
-- Lista de columnas a verificar
WITH columnas AS (
    SELECT * FROM (VALUES
        ('documento'),
        ('nombres'),
        ('apellidos'),
        ('estado'),
        ('sexo'),
        ('objeto_gasto'),
        ('concepto'),
        ('presupuestado'),
        ('devengado'),
        ('fecha_acto')
    ) AS t(columna)
)
SELECT columna,
       COUNT(*) AS nulos
FROM columnas
JOIN staging.v_funcionarios_2026_1_typed AS f
ON CASE columna
       WHEN 'documento'     THEN f.documento IS NULL
       WHEN 'nombres'       THEN f.nombres IS NULL
       WHEN 'apellidos'     THEN f.apellidos IS NULL
       WHEN 'estado'        THEN f.estado IS NULL
       WHEN 'sexo'          THEN f.sexo IS NULL
       WHEN 'objeto_gasto'  THEN f.objeto_gasto IS NULL
       WHEN 'concepto'      THEN f.concepto IS NULL
       WHEN 'presupuestado' THEN f.presupuestado IS NULL
       WHEN 'devengado'     THEN f.devengado IS NULL
       WHEN 'fecha_acto'    THEN f.fecha_acto IS NULL
   END
GROUP BY columna
ORDER BY nulos DESC, columna;
```

## 12.2. Valores vacíos o textos “rotos”

```sql
SELECT
    SUM(CASE WHEN TRIM(COALESCE(cargo, '')) = '' THEN 1 ELSE 0 END) AS cargo_vacio,
    SUM(CASE WHEN TRIM(COALESCE(funcion, '')) = '' THEN 1 ELSE 0 END) AS funcion_vacia,
    SUM(CASE WHEN TRIM(COALESCE(profesion, '')) = '' THEN 1 ELSE 0 END) AS profesion_vacia,
    SUM(CASE WHEN TRIM(COALESCE(correo, '')) = '' THEN 1 ELSE 0 END) AS correo_vacio,
    SUM(CASE WHEN TRIM(COALESCE(carga_horaria, '')) = '' THEN 1 ELSE 0 END) AS carga_horaria,
    SUM(CASE WHEN TRIM(COALESCE(tipo_discapacidad , '')) = '' THEN 1 ELSE 0 END) AS tipo_discapacidad
FROM staging.v_funcionarios_2026_1_typed;
```

## 12.3. Fechas no parseadas correctamente

```sql
SELECT
    SUM(CASE WHEN fecha_nacimiento_raw IS NOT NULL AND fecha_nacimiento IS NULL THEN 1 ELSE 0 END) AS fecha_nacimiento_invalida,
    SUM(CASE WHEN fec_ult_modif_raw IS NOT NULL AND fec_ult_modif_ts IS NULL THEN 1 ELSE 0 END) AS fec_ult_modif_invalida,
    SUM(CASE WHEN fecha_acto_raw IS NOT NULL AND fecha_acto IS NULL THEN 1 ELSE 0 END) AS fecha_acto_invalida
FROM staging.v_funcionarios_2026_1_typed;
```

## 12.4. Duplicados exactos

```sql
WITH total AS (
    SELECT COUNT(*) AS total_filas
    FROM raw.funcionarios_2026_1
),
distinto AS (
    SELECT COUNT(*) AS total_distintas
    FROM (
        SELECT DISTINCT *
        FROM raw.funcionarios_2026_1
    ) t
)
SELECT
    total_filas,
    total_distintas,
    total_filas - total_distintas AS filas_duplicadas_exactas
FROM total, distinto;
```

Ver duplicados exactos:

```sql
SELECT 
    *, 
    COUNT(*) AS cantidad
FROM raw.funcionarios_2026_1
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;
```

## 12.5. Posibles duplicados de negocio

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
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC, documento
LIMIT 50;
```

### Qué debe concluir el estudiante

- No todo duplicado es error.
- Debe distinguirse entre **duplicado exacto** y **multiplicidad legítima del negocio**.
- La definición de clave depende del grano que se quiera modelar.

---

## Paso 13. Exploración univariada de métricas monetarias

## 13.1. Estadísticos descriptivos de `devengado`

```sql
SELECT
    COUNT(devengado) AS filas_con_devengado,
    MIN(devengado) AS min_devengado,
    quantile_cont(devengado, 0.25) AS q1_devengado,
    MEDIAN(devengado) AS mediana_devengado,
    AVG(devengado) AS promedio_devengado,
    quantile_cont(devengado, 0.75) AS q3_devengado,
    MAX(devengado) AS max_devengado,
    STDDEV_SAMP(devengado) AS desvio_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL;
```

## 13.2. Estadísticos descriptivos de `presupuestado`

```sql
SELECT
    COUNT(presupuestado) AS filas_con_presupuestado,
    MIN(presupuestado) AS min_presupuestado,
    quantile_cont(presupuestado, 0.25) AS q1_presupuestado,
    MEDIAN(presupuestado) AS mediana_presupuestado,
    AVG(presupuestado) AS promedio_presupuestado,
    quantile_cont(presupuestado, 0.75) AS q3_presupuestado,
    MAX(presupuestado) AS max_presupuestado,
    STDDEV_SAMP(presupuestado) AS desvio_presupuestado
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL;
```

## 13.3. Frecuencias de variables categóricas relevantes

### Estado

```sql
SELECT
    estado,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC;
```

### Sexo

```sql
SELECT
    sexo,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC;
```

### Objeto de gasto

```sql
SELECT
    objeto_gasto,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC
LIMIT 20;
```

### Concepto

```sql
SELECT
    concepto,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC
LIMIT 20;
```

### Interpretación esperada

El estudiante debe detectar qué variables son dominantes, cuáles están más dispersas y cuáles presentan una cola larga de categorías.

---

## Paso 14. Exploración bivariada y multivariada

## 14.1. Remuneración por institución

```sql
SELECT
    descripcion_oee,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1
ORDER BY total_devengado DESC
LIMIT 20;
```

## 14.2. Remuneración por estado laboral

```sql
SELECT
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1
ORDER BY total_devengado DESC;
```

## 14.3. Remuneración por sexo y estado

```sql
SELECT
    sexo,
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1, 2
ORDER BY sexo, estado;
```

## 14.4. Comparación entre `presupuestado` y `devengado`

```sql
SELECT
    SUM(presupuestado) AS total_presupuestado,
    SUM(devengado) AS total_devengado,
    SUM(presupuestado - devengado) AS diferencia_total
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL
  AND devengado IS NOT NULL;
```

## 14.5. Comportamiento por objeto de gasto

```sql
SELECT
    objeto_gasto,
    concepto,
    COUNT(*) AS filas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1, 2
ORDER BY total_devengado DESC
LIMIT 30;
```

### Qué debe observarse

- instituciones con mayor masa salarial;
- diferencias por tipo de vínculo;
- concentración del gasto en ciertos objetos;
- y señales de que el modelo analítico deberá separar hechos monetarios de atributos institucionales y laborales.

---

## Paso 15. Detección de anomalías y casos extremos

## 15.1. Montos negativos o iguales a cero

```sql
SELECT
    SUM(CASE WHEN presupuestado < 0 THEN 1 ELSE 0 END) AS presupuestado_negativo,
    SUM(CASE WHEN devengado < 0 THEN 1 ELSE 0 END) AS devengado_negativo,
    SUM(CASE WHEN presupuestado = 0 THEN 1 ELSE 0 END) AS presupuestado_cero,
    SUM(CASE WHEN devengado = 0 THEN 1 ELSE 0 END) AS devengado_cero
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL
   OR devengado IS NOT NULL;
```

## 15.2. Outliers por criterio IQR sobre `devengado`

```sql
WITH limites AS (
    SELECT
        quantile_cont(devengado, 0.25) AS q1,
        quantile_cont(devengado, 0.75) AS q3
    FROM staging.v_funcionarios_2026_1_typed
    WHERE devengado IS NOT NULL
)
SELECT
    t.documento,
    t.nombres,
    t.apellidos,
    t.descripcion_oee,
    t.estado,
    t.objeto_gasto,
    t.concepto,
    t.devengado
FROM staging.v_funcionarios_2026_1_typed t
CROSS JOIN limites l
WHERE t.devengado IS NOT NULL
  AND (
        t.devengado < (l.q1 - 1.5 * (l.q3 - l.q1))
        OR
        t.devengado > (l.q3 + 1.5 * (l.q3 - l.q1))
      )
ORDER BY t.devengado DESC
LIMIT 100;
```

## 15.3. Prefijos especiales del documento

```sql
SELECT
    UPPER(LEFT(documento, 1)) AS prefijo_documento,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1
ORDER BY filas DESC;
```

## 15.4. Consistencia entre discapacidad y tipo de discapacidad

```sql
SELECT
    discapacidad,
    tipo_discapacidad,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1, 2
ORDER BY filas DESC;
```

### Interpretación correcta

Un valor extremo no debe eliminarse automáticamente.  
Primero debe clasificarse como:

- error de carga;
- caso administrativo especial;
- o valor legítimo del fenómeno observado.

---

## Paso 16. Preparación de conclusiones para modelado analítico

La parte más importante del EDA no es la consulta en sí, sino la capacidad de traducir hallazgos en decisiones de diseño.

## 16.1. Preguntas que deben responderse al cierre

1. ¿La tabla cruda representa personas o componentes remunerativos?
2. ¿Qué columnas parecen confiables para usar como dimensiones?
3. ¿Qué campos tienen demasiado ruido para el primer modelo?
4. ¿Qué métricas monetarias deben preservarse?
5. ¿Cuál debería ser el grano del hecho analítico?
6. ¿Qué reglas de limpieza serán obligatorias?

## 16.2. Reglas preliminares sugeridas

A partir del EDA, una primera propuesta razonable es la siguiente:

### Conservar como ejes analíticos principales

- tiempo: `anho`, `mes`
- institución: `nivel`, `entidad`, `oee` y sus descripciones
- identificación funcional: `documento`
- segmentación laboral: `estado`, `sexo`, `anho_ingreso`
- clasificación remunerativa: `fuente_financiamiento`, `objeto_gasto`, `concepto`, `categoria`
- métricas: `presupuestado`, `devengado`

### Tratar con cautela o diferir

- `cargo`
- `funcion`
- `carga_horaria`
- `movimiento`
- `lugar`
- `correo`
- `profesion`
- `motivo_movimiento`
- `uri`

### Reglas mínimas de limpieza sugeridas

- convertir strings vacíos a `NULL`;
- parsear fechas con `try_strptime`;
- no convertir `documento` a entero;
- distinguir duplicado exacto de multiplicidad de negocio;
- revisar montos cero antes de excluirlos;
- documentar prefijos especiales del `documento`.

## 16.3. Grano analítico preliminar sugerido

Para una futura consolidación general, un grano razonable a validar podría ser:

```text
anho + mes + nivel + entidad + oee + documento
```

Eso permitiría construir una vista consolidada mensual por persona e institución.  
Pero esa consolidación no debe hacerse sin antes decidir cómo agregar los múltiples componentes remunerativos.

---

## 8. Tratamiento de problemas de datos: qué hacer y qué no hacer

## 8.1. Valores nulos

### Recomendado en EDA

- medirlos;
- localizar en qué columnas se concentran;
- evaluar si su ausencia impide el análisis.

### No recomendado todavía

- imputar automáticamente sin criterio de negocio.

## 8.2. Valores atípicos

### Recomendado en EDA

- detectarlos por percentiles o IQR;
- revisar casos extremos manualmente;
- diferenciarlos entre posibles errores y casos válidos.

### No recomendado todavía

- eliminar outliers en masa solo porque “molestan” en el análisis.

## 8.3. Distribuciones sesgadas

### Recomendado en EDA

- comparar media y mediana;
- revisar concentración por percentiles;
- analizar por segmentos.

### No recomendado todavía

- normalizar o transformar variables sin haber definido el objetivo analítico.

## 8.4. Inconsistencias textuales

### Recomendado en EDA

- aplicar `TRIM`;
- usar `UPPER` o `LOWER` para comparar;
- revisar dominios con `GROUP BY`.

### No recomendado todavía

- reemplazar categorías manualmente sin registrar reglas de transformación.

## 8.5. Duplicados

### Recomendado en EDA

- distinguir duplicados exactos de duplicados de negocio;
- revisar multiplicidad por funcionario y período.

### No recomendado todavía

- usar `SELECT DISTINCT` como “solución mágica”.

---

## 9. Actividades guiadas para los estudiantes

## 9.1. Nivel básico

1. Descargar el dataset y validar el ZIP.
2. Verificar la codificación del archivo CSV.
3. Crear la base `eda.duckdb` y los esquemas `raw` y `staging`.
4. Cargar la tabla cruda.
5. Contar filas totales y revisar el esquema.

## 9.2. Nivel intermedio

1. Construir la vista tipada.
2. Medir nulos en columnas críticas.
3. Identificar cuántos documentos aparecen más de una vez.
4. Calcular media, mediana y cuartiles de `devengado`.
5. Obtener el ranking de instituciones por masa salarial.

## 9.3. Nivel desafío

1. Proponer una clave de negocio tentativa para el grano crudo.
2. Diseñar una estrategia de consolidación mensual por funcionario.
3. Clasificar las columnas en:
   - dimensión;
   - métrica;
   - trazabilidad;
   - descartable temporalmente.
4. Elaborar tres reglas de calidad obligatorias para una futura capa `staging` para la arquitectura del modelo analítico final.
5. Redactar una conclusión técnica defendible sobre el grano real de la fuente.

## 9.4. Preguntas de reflexión

1. ¿Qué error analítico cometerías si contaras filas como si fueran personas?
2. ¿Por qué `documento` no debe convertirse automáticamente a entero?
3. ¿Qué diferencia conceptual hay entre `presupuestado` y `devengado`?
4. ¿Qué campos no usarías en un primer dashboard y por qué?
5. ¿Qué evidencia del EDA justifica el modelo analítico que propones?

---

## 10. Conclusiones esperadas de la práctica

Al finalizar la práctica, el estudiante debería poder afirmar con fundamento que:

1. el dataset fue cargado correctamente en DuckDB;
2. la tabla `raw` preserva la fuente sin alteraciones destructivas;
3. la fuente no debe tratarse como una tabla consolidada por persona;
4. existen campos con buena utilidad analítica y otros con calidad débil;
5. los montos monetarios requieren interpretación en su contexto;
6. el EDA produce reglas concretas para limpieza, consolidación y modelado;
7. y el siguiente paso lógico no es “visualizar”, sino **diseñar la capa analítica correctamente**.

---

## 11. Recomendaciones docentes para implementar la clase

1. **No conviertas esta práctica en una clase de copiar y pegar consultas.**  
   Lo importante es que el estudiante justifique lo que observa.

2. **Haz que comparen filas versus personas.**  
   Ese es el punto pedagógico más potente del laboratorio.

3. **Pide evidencias.**  
   Toda conclusión debe apoyarse en una consulta reproducible.

4. **Evita resolverles el modelado final demasiado pronto.**  
   Primero deben entender por qué la tabla cruda no sirve tal cual.

5. **Usa la práctica para introducir la diferencia entre `raw`, `staging` y analítica.**  
   Esa transición es más importante que memorizar funciones SQL.

6. **Cierra la clase con una discusión de diseño.**  
   La pregunta final no debería ser “qué consulta salió”, sino:
   **“qué modelo analítico tendría sentido construir a partir de lo observado”**.

---

## 12. Anexo: bloque consolidado de consultas SQL

```sql
-- =========================================================
-- 0) Crear esquema raw y staging
-- =========================================================
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;

-- =========================================================
-- 1) Cargar CSV en bruto como VARCHAR
-- =========================================================
CREATE OR REPLACE TABLE raw.funcionarios_2026_1 AS
SELECT *
FROM read_csv(
    '/opt/repo/cit-bigdata-lab/data/raw/sfp_funcionarios/2026_01/funcionarios_2026_1.csv',
    header = true,
    all_varchar = true,
    sample_size = -1,
    normalize_names = false,
    encoding = 'utf-8'
);

-- =========================================================
-- 2) Validaciones básicas
-- =========================================================
SELECT COUNT(*) AS total_filas
FROM raw.funcionarios_2026_1;

DESCRIBE raw.funcionarios_2026_1;

SELECT *
FROM raw.funcionarios_2026_1
LIMIT 10;

-- =========================================================
-- 3) Vista tipada de apoyo para EDA
-- =========================================================
CREATE OR REPLACE VIEW staging.v_funcionarios_2026_1_typed AS
SELECT
    TRY_CAST(anho AS INTEGER) AS anho,
    TRY_CAST(mes AS INTEGER) AS mes,
    TRY_CAST(nivel AS INTEGER) AS nivel,
    NULLIF(TRIM(descripcion_nivel), '') AS descripcion_nivel,
    TRY_CAST(entidad AS INTEGER) AS entidad,
    NULLIF(TRIM(descripcion_entidad), '') AS descripcion_entidad,
    TRY_CAST(oee AS INTEGER) AS oee,
    NULLIF(TRIM(descripcion_oee), '') AS descripcion_oee,
    NULLIF(TRIM(documento), '') AS documento,
    NULLIF(TRIM(nombres), '') AS nombres,
    NULLIF(TRIM(apellidos), '') AS apellidos,
    NULLIF(TRIM(funcion), '') AS funcion,
    UPPER(NULLIF(TRIM(estado), '')) AS estado,
    NULLIF(TRIM(carga_horaria), '') AS carga_horaria,
    TRY_CAST(anho_ingreso AS INTEGER) AS anho_ingreso,
    UPPER(NULLIF(TRIM(sexo), '')) AS sexo,
    UPPER(NULLIF(TRIM(discapacidad), '')) AS discapacidad,
    NULLIF(TRIM(tipo_discapacidad), '') AS tipo_discapacidad,
    TRY_CAST(fuente_financiamiento AS INTEGER) AS fuente_financiamiento,
    TRY_CAST(objeto_gasto AS INTEGER) AS objeto_gasto,
    NULLIF(TRIM(concepto), '') AS concepto,
    NULLIF(TRIM(linea), '') AS linea,
    NULLIF(TRIM(categoria), '') AS categoria,
    NULLIF(TRIM(cargo), '') AS cargo,
    TRY_CAST(presupuestado AS DOUBLE) AS presupuestado,
    TRY_CAST(devengado AS DOUBLE) AS devengado,
    NULLIF(TRIM(movimiento), '') AS movimiento,
    NULLIF(TRIM(lugar), '') AS lugar,
    NULLIF(TRIM(fecha_nacimiento), '') AS fecha_nacimiento_raw,
    TRY_CAST(
        try_strptime(
            NULLIF(TRIM(fecha_nacimiento), ''),
            ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
        ) AS DATE
    ) AS fecha_nacimiento,
    NULLIF(TRIM(fec_ult_modif), '') AS fec_ult_modif_raw,
    try_strptime(
        NULLIF(TRIM(fec_ult_modif), ''),
        ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
    ) AS fec_ult_modif_ts,
    NULLIF(TRIM(uri), '') AS uri,
    NULLIF(TRIM(fecha_acto), '') AS fecha_acto_raw,
    TRY_CAST(
        try_strptime(
            NULLIF(TRIM(fecha_acto), ''),
            ['%Y/%m/%d %H:%M:%S.%f', '%Y/%m/%d %H:%M:%S']
        ) AS DATE
    ) AS fecha_acto,
    NULLIF(TRIM(correo), '') AS correo,
    NULLIF(TRIM(profesion), '') AS profesion,
    NULLIF(TRIM(motivo_movimiento), '') AS motivo_movimiento
FROM raw.funcionarios_2026_1;

DESCRIBE staging.v_funcionarios_2026_1_typed;

SELECT *
FROM staging.v_funcionarios_2026_1_typed
LIMIT 10;

SUMMARIZE staging.v_funcionarios_2026_1_typed;

-- =========================================================
-- 4) Granularidad
-- =========================================================
SELECT
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS documentos_unicos,
    COUNT(*) - COUNT(DISTINCT documento) AS diferencia
FROM staging.v_funcionarios_2026_1_typed;

SELECT
    documento,
    anho,
    mes,
    COUNT(*) AS filas_por_documento_mes
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1
ORDER BY filas_por_documento_mes DESC, documento
LIMIT 50;

SELECT
    documento,
    nombres,
    apellidos,
    objeto_gasto,
    concepto,
    categoria,
    presupuestado,
    devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IN (
    SELECT documento
    FROM staging.v_funcionarios_2026_1_typed
    WHERE documento IS NOT NULL
    GROUP BY documento, anho, mes
    HAVING COUNT(*) > 1
)
ORDER BY documento, objeto_gasto, concepto
LIMIT 100;

-- =========================================================
-- 5) Nulos e inconsistencias
-- =========================================================
SELECT 'documento' AS columna, COUNT(*) AS nulos
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NULL
UNION ALL
SELECT 'nombres', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE nombres IS NULL
UNION ALL
SELECT 'apellidos', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE apellidos IS NULL
UNION ALL
SELECT 'estado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE estado IS NULL
UNION ALL
SELECT 'sexo', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE sexo IS NULL
UNION ALL
SELECT 'objeto_gasto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE objeto_gasto IS NULL
UNION ALL
SELECT 'concepto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE concepto IS NULL
UNION ALL
SELECT 'presupuestado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NULL
UNION ALL
SELECT 'devengado', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NULL
UNION ALL
SELECT 'fecha_acto', COUNT(*)
FROM staging.v_funcionarios_2026_1_typed
WHERE fecha_acto IS NULL
ORDER BY nulos DESC, columna;

SELECT
    SUM(CASE WHEN TRIM(COALESCE(cargo, '')) = '' THEN 1 ELSE 0 END) AS cargo_vacio,
    SUM(CASE WHEN TRIM(COALESCE(funcion, '')) = '' THEN 1 ELSE 0 END) AS funcion_vacia,
    SUM(CASE WHEN TRIM(COALESCE(profesion, '')) = '' THEN 1 ELSE 0 END) AS profesion_vacia,
    SUM(CASE WHEN TRIM(COALESCE(correo, '')) = '' THEN 1 ELSE 0 END) AS correo_vacio
FROM staging.v_funcionarios_2026_1_typed;

SELECT
    SUM(CASE WHEN fecha_nacimiento_raw IS NOT NULL AND fecha_nacimiento IS NULL THEN 1 ELSE 0 END) AS fecha_nacimiento_invalida,
    SUM(CASE WHEN fec_ult_modif_raw IS NOT NULL AND fec_ult_modif_ts IS NULL THEN 1 ELSE 0 END) AS fec_ult_modif_invalida,
    SUM(CASE WHEN fecha_acto_raw IS NOT NULL AND fecha_acto IS NULL THEN 1 ELSE 0 END) AS fecha_acto_invalida
FROM staging.v_funcionarios_2026_1_typed;

WITH total AS (
    SELECT COUNT(*) AS total_filas
    FROM raw.funcionarios_2026_1
),
distinto AS (
    SELECT COUNT(*) AS total_distintas
    FROM (
        SELECT DISTINCT *
        FROM raw.funcionarios_2026_1
    ) t
)
SELECT
    total_filas,
    total_distintas,
    total_filas - total_distintas AS filas_duplicadas_exactas
FROM total, distinto;

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
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC, documento
LIMIT 50;

-- =========================================================
-- 6) Estadística descriptiva
-- =========================================================
SELECT
    COUNT(devengado) AS filas_con_devengado,
    MIN(devengado) AS min_devengado,
    quantile_cont(devengado, 0.25) AS q1_devengado,
    MEDIAN(devengado) AS mediana_devengado,
    AVG(devengado) AS promedio_devengado,
    quantile_cont(devengado, 0.75) AS q3_devengado,
    MAX(devengado) AS max_devengado,
    STDDEV_SAMP(devengado) AS desvio_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL;

SELECT
    COUNT(presupuestado) AS filas_con_presupuestado,
    MIN(presupuestado) AS min_presupuestado,
    quantile_cont(presupuestado, 0.25) AS q1_presupuestado,
    MEDIAN(presupuestado) AS mediana_presupuestado,
    AVG(presupuestado) AS promedio_presupuestado,
    quantile_cont(presupuestado, 0.75) AS q3_presupuestado,
    MAX(presupuestado) AS max_presupuestado,
    STDDEV_SAMP(presupuestado) AS desvio_presupuestado
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL;

SELECT
    estado,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC;

SELECT
    sexo,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC;

SELECT
    objeto_gasto,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC
LIMIT 20;

SELECT
    concepto,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1
ORDER BY filas DESC
LIMIT 20;

-- =========================================================
-- 7) Cruces analíticos
-- =========================================================
SELECT
    descripcion_oee,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1
ORDER BY total_devengado DESC
LIMIT 20;

SELECT
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1
ORDER BY total_devengado DESC;

SELECT
    sexo,
    estado,
    COUNT(*) AS filas,
    COUNT(DISTINCT documento) AS personas_distintas,
    AVG(devengado) AS promedio_devengado,
    MEDIAN(devengado) AS mediana_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1, 2
ORDER BY sexo, estado;

SELECT
    SUM(presupuestado) AS total_presupuestado,
    SUM(devengado) AS total_devengado,
    SUM(presupuestado - devengado) AS diferencia_total
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL
  AND devengado IS NOT NULL;

SELECT
    objeto_gasto,
    concepto,
    COUNT(*) AS filas,
    SUM(devengado) AS total_devengado,
    AVG(devengado) AS promedio_devengado
FROM staging.v_funcionarios_2026_1_typed
WHERE devengado IS NOT NULL
GROUP BY 1, 2
ORDER BY total_devengado DESC
LIMIT 30;

-- =========================================================
-- 8) Anomalías
-- =========================================================
SELECT
    SUM(CASE WHEN presupuestado < 0 THEN 1 ELSE 0 END) AS presupuestado_negativo,
    SUM(CASE WHEN devengado < 0 THEN 1 ELSE 0 END) AS devengado_negativo,
    SUM(CASE WHEN presupuestado = 0 THEN 1 ELSE 0 END) AS presupuestado_cero,
    SUM(CASE WHEN devengado = 0 THEN 1 ELSE 0 END) AS devengado_cero
FROM staging.v_funcionarios_2026_1_typed
WHERE presupuestado IS NOT NULL
   OR devengado IS NOT NULL;

WITH limites AS (
    SELECT
        quantile_cont(devengado, 0.25) AS q1,
        quantile_cont(devengado, 0.75) AS q3
    FROM staging.v_funcionarios_2026_1_typed
    WHERE devengado IS NOT NULL
)
SELECT
    t.documento,
    t.nombres,
    t.apellidos,
    t.descripcion_oee,
    t.estado,
    t.objeto_gasto,
    t.concepto,
    t.devengado
FROM staging.v_funcionarios_2026_1_typed t
CROSS JOIN limites l
WHERE t.devengado IS NOT NULL
  AND (
        t.devengado < (l.q1 - 1.5 * (l.q3 - l.q1))
        OR
        t.devengado > (l.q3 + 1.5 * (l.q3 - l.q1))
      )
ORDER BY t.devengado DESC
LIMIT 100;

SELECT
    UPPER(LEFT(documento, 1)) AS prefijo_documento,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
WHERE documento IS NOT NULL
GROUP BY 1
ORDER BY filas DESC;

SELECT
    discapacidad,
    tipo_discapacidad,
    COUNT(*) AS filas
FROM staging.v_funcionarios_2026_1_typed
GROUP BY 1, 2
ORDER BY filas DESC;
```

---

## 13. Cierre técnico

Esta práctica no termina cuando “ya cargó el CSV”.  
Termina cuando el estudiante puede defender, con evidencia SQL, tres ideas:

1. **qué representa realmente una fila de la fuente**;
2. **qué problemas de calidad existen**;
3. **qué decisiones de modelado analítico se justifican a partir del EDA**.

Ese es el resultado que realmente importa.