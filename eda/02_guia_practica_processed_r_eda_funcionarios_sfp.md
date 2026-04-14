<div align="center">
  <img src="../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
  <h1>FPUNA · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Guía práctica paso a paso: preparación de dataset `processed` y EDA científico en R

### Práctica de continuación sobre la fuente `https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip`

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción 

---

## Fecha y versión

- **Fecha:** 26/03/2026
- **Versión:** 1.0

---

## 1. Propósito de esta segunda guía

Esta guía continúa la práctica anterior de **EDA con SQL sobre DuckDB** y da el siguiente paso lógico del ciclo de trabajo:

1. tomar la capa `raw` ya explorada;
2. aplicar **limpiezas básicas y controladas**;
3. construir un dataset en la capa `processed`;
4. exportarlo a **CSV reproducible**;
5. importarlo en **R** con librerías adecuadas para análisis intensivo;
6. ejecutar un **EDA más profundo**, con enfoque de ciencia de datos;
7. y detectar **valores atípicos** con criterios más sólidos que un simple vistazo descriptivo.

Esta práctica no pretende “maquillar” la fuente. El criterio correcto es otro: **estandarizar, tipar, derivar y marcar problemas sin destruir evidencia útil**.

---

## 2. Relación con la guía anterior

Esta guía asume que ya se completó la práctica previa y que existe al menos lo siguiente dentro de `eda.duckdb`:

- esquema `raw`;
- tabla `raw.funcionarios_2026_1`;
- vista tipada `raw.v_funcionarios_2026_1_typed`.

Si esa vista no existe, no avances. Primero corrige la práctica anterior. Saltarte ese paso es un error metodológico porque te obliga a limpiar sobre una tabla todavía no validada.

---

## 3. Resultado esperado

Al finalizar la práctica deberías tener estos artefactos:

```text
/opt/repo/fpun-bigdata-lab/
├── data/
│   ├── raw/
│   ├── processed/
│   │   ├── funcionarios_2026_1_detalle_clean.csv
│   │   └── funcionarios_2026_1_persona_mes.csv
│   └── eda.duckdb
├── scripts/
│   ├── sql/
│   │   └── 02_prepare_processed_funcionarios_2026_1.sql
│   └── r/
│       └── 03_eda_funcionarios_2026_1.R
└── outputs/
    └── r_eda_funcionarios_2026_1/
        ├── tablas/
        ├── reportes/
        └── graficos/
```

---

## 4. Decisión metodológica clave: no analizar outliers salariales sobre el grano crudo

Este punto es importante.

La tabla cruda se aproxima a:

**una fila por componente remunerativo de un funcionario en un período y contexto institucional**.

Por tanto, hacer detección de outliers monetarios directamente sobre el grano crudo puede inducir errores, porque mezcla:

- componentes remunerativos pequeños;
- salarios consolidados;
- bonificaciones puntuales;
- líneas presupuestarias;
- y registros múltiples del mismo funcionario en el mismo mes.

La alternativa mejor es esta:

- **conservar** un dataset `detalle_clean` para trazabilidad y análisis fino;
- y además construir un dataset **consolidado persona-mes** para el EDA científico en R.

Ese será el dataset principal para estudiar:

- distribución salarial;
- concentración de remuneraciones;
- relación entre institución y devengado;
- antigüedad versus remuneración;
- y detección de outliers globales y por grupo.

---

## 5. Requisitos previos

## 5.1. Requisitos técnicos

- Ubuntu sobre WSL2 operativo.
- `duckdb` disponible en consola.
- `R` y `Rscript` disponibles, o posibilidad de instalarlos.
- Repositorio local del laboratorio accesible.

## 5.2. Base existente

Se espera que exista:

```text
/opt/repo/fpun-bigdata-lab/data/eda.duckdb
```

**Advertencia:** si tu repositorio real se llama `cit-bigdata-lab`, corrige todos los paths de esta guía. No copies comandos ciegamente.

---

## 6. Estructura inicial recomendada

Ejecuta:

```bash
mkdir -p /opt/repo/fpun-bigdata-lab/data/processed
mkdir -p /opt/repo/fpun-bigdata-lab/scripts/sql
mkdir -p /opt/repo/fpun-bigdata-lab/scripts/r
mkdir -p /opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/{tablas,reportes,graficos}
```

Verifica:

```bash
tree -L 3 /opt/repo/fpun-bigdata-lab
```

---

## 7. Paso a paso de la preparación de datos en DuckDB

## Paso 1. Abrir la base analítica

```bash
cd /opt/repo/fpun-bigdata-lab/data
duckdb eda.duckdb
```

---

## Paso 2. Verificar que la práctica anterior quedó bien

Ejecuta estas validaciones mínimas:

```sql
SHOW SCHEMAS;

SHOW TABLES FROM raw;

DESCRIBE raw.v_funcionarios_2026_1_typed;

SELECT COUNT(*) AS total_filas
FROM raw.v_funcionarios_2026_1_typed;

SELECT *
FROM raw.v_funcionarios_2026_1_typed
LIMIT 5;
```

Si esta vista falla, el problema no está en `processed`: está en tu capa anterior.

---

## Paso 3. Crear el esquema `processed`

```sql
CREATE SCHEMA IF NOT EXISTS processed;
```

Verifica:

```sql
SHOW TABLES FROM processed;
```

---

## Paso 4. Criterio de limpieza que sí usaremos

En esta práctica se aplicarán limpiezas **básicas, explícitas y defendibles**:

1. `TRIM()` de cadenas.
2. conversión de blancos vacíos a `NULL`.
3. tipado seguro ya heredado desde `raw.v_funcionarios_2026_1_typed`.
4. normalización mínima de `documento`.
5. derivación de indicadores útiles para análisis:
   - `edad_aprox`;
   - `antiguedad_aprox`;
   - `tramo_devengado`;
   - banderas de anomalías.
6. detección de **duplicado exacto técnico** mediante hash de fila.

## Lo que no haremos

- No eliminaremos registros por “parecer raros”.
- No anularemos montos altos solo porque son extremos.
- No deduplicaremos por `documento` solamente.
- No forzaremos un modelo dimensional todavía.

Eso sería precipitado y técnicamente flojo.

---

## Paso 5. Crear el script SQL de preparación de la capa `processed`

Guarda el siguiente contenido en:

```text
/opt/repo/fpun-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql
```

### Opción rápida desde terminal

```bash
cat > /opt/repo/fpun-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql <<'SQL'
CREATE SCHEMA IF NOT EXISTS processed;

-- =========================================================
-- 1) Dataset detalle_clean: conserva el grano del registro
--    remunerativo, aplica limpieza básica y genera banderas.
-- =========================================================
CREATE OR REPLACE TABLE processed.funcionarios_2026_1_detalle_clean AS
WITH base AS (
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
        CASE
            WHEN documento IS NULL THEN NULL
            WHEN UPPER(TRIM(documento)) LIKE 'ANON%' THEN UPPER(TRIM(documento))
            ELSE regexp_replace(TRIM(documento), '[^0-9]', '', 'g')
        END AS documento_limpio,
        CASE
            WHEN documento IS NOT NULL AND UPPER(TRIM(documento)) LIKE 'ANON%' THEN TRUE
            ELSE FALSE
        END AS fl_documento_anonimizado,
        nombres,
        apellidos,
        funcion,
        estado,
        carga_horaria,
        anho_ingreso,
        sexo,
        discapacidad,
        tipo_discapacidad,
        fuente_financiamiento,
        objeto_gasto,
        concepto,
        linea,
        categoria,
        cargo,
        ROUND(presupuestado, 2) AS presupuestado,
        ROUND(devengado, 2) AS devengado,
        movimiento,
        lugar,
        fecha_nacimiento,
        fec_ult_modif_ts,
        uri,
        fecha_acto,
        correo,
        profesion,
        motivo_movimiento,
        make_date(anho, mes, 1) AS periodo_ref,
        CASE
            WHEN fecha_nacimiento IS NOT NULL
                 AND make_date(anho, mes, 1) >= fecha_nacimiento
            THEN date_diff('year', fecha_nacimiento, make_date(anho, mes, 1))
            ELSE NULL
        END AS edad_aprox,
        CASE
            WHEN anho_ingreso BETWEEN 1950 AND anho
            THEN anho - anho_ingreso
            ELSE NULL
        END AS antiguedad_aprox,
        CASE
            WHEN presupuestado IS NOT NULL AND presupuestado < 0 THEN TRUE
            WHEN devengado IS NOT NULL AND devengado < 0 THEN TRUE
            ELSE FALSE
        END AS fl_monto_negativo,
        CASE
            WHEN presupuestado IS NOT NULL AND devengado IS NOT NULL AND devengado > presupuestado THEN TRUE
            ELSE FALSE
        END AS fl_devengado_mayor_presupuestado,
        CASE
            WHEN fecha_nacimiento IS NULL THEN TRUE
            ELSE FALSE
        END AS fl_fecha_nacimiento_null,
        CASE
            WHEN fecha_nacimiento IS NOT NULL AND fecha_nacimiento > make_date(anho, mes, 1) THEN TRUE
            ELSE FALSE
        END AS fl_fecha_nacimiento_futura,
        md5(
            concat_ws(
                '||',
                coalesce(CAST(anho AS VARCHAR), ''),
                coalesce(CAST(mes AS VARCHAR), ''),
                coalesce(CAST(nivel AS VARCHAR), ''),
                coalesce(descripcion_nivel, ''),
                coalesce(CAST(entidad AS VARCHAR), ''),
                coalesce(descripcion_entidad, ''),
                coalesce(CAST(oee AS VARCHAR), ''),
                coalesce(descripcion_oee, ''),
                coalesce(documento, ''),
                coalesce(nombres, ''),
                coalesce(apellidos, ''),
                coalesce(funcion, ''),
                coalesce(estado, ''),
                coalesce(carga_horaria, ''),
                coalesce(CAST(anho_ingreso AS VARCHAR), ''),
                coalesce(sexo, ''),
                coalesce(discapacidad, ''),
                coalesce(tipo_discapacidad, ''),
                coalesce(CAST(fuente_financiamiento AS VARCHAR), ''),
                coalesce(CAST(objeto_gasto AS VARCHAR), ''),
                coalesce(concepto, ''),
                coalesce(linea, ''),
                coalesce(categoria, ''),
                coalesce(cargo, ''),
                coalesce(CAST(presupuestado AS VARCHAR), ''),
                coalesce(CAST(devengado AS VARCHAR), ''),
                coalesce(movimiento, ''),
                coalesce(lugar, ''),
                coalesce(CAST(fecha_nacimiento AS VARCHAR), ''),
                coalesce(CAST(fec_ult_modif_ts AS VARCHAR), ''),
                coalesce(uri, ''),
                coalesce(CAST(fecha_acto AS VARCHAR), ''),
                coalesce(correo, ''),
                coalesce(profesion, ''),
                coalesce(motivo_movimiento, '')
            )
        ) AS hash_fila_origen
    FROM raw.v_funcionarios_2026_1_typed
), enrich AS (
    SELECT
        *,
        CASE
            WHEN edad_aprox IS NULL THEN NULL
            WHEN edad_aprox < 15 OR edad_aprox > 90 THEN TRUE
            ELSE FALSE
        END AS fl_edad_fuera_rango,
        CASE
            WHEN antiguedad_aprox IS NULL THEN NULL
            WHEN antiguedad_aprox < 0 OR antiguedad_aprox > 70 THEN TRUE
            ELSE FALSE
        END AS fl_antiguedad_fuera_rango,
        CASE
            WHEN devengado IS NULL THEN 'SIN_DATO'
            WHEN devengado = 0 THEN '0'
            WHEN devengado < 1000000 THEN '<1M'
            WHEN devengado < 3000000 THEN '1M-3M'
            WHEN devengado < 6000000 THEN '3M-6M'
            WHEN devengado < 10000000 THEN '6M-10M'
            ELSE '>=10M'
        END AS tramo_devengado,
        ROW_NUMBER() OVER (PARTITION BY hash_fila_origen ORDER BY hash_fila_origen) AS rn_duplicado_exacto,
        COUNT(*) OVER (PARTITION BY hash_fila_origen) AS n_duplicado_exacto
    FROM base
)
SELECT *
FROM enrich;

-- =========================================================
-- 2) Dataset persona_mes: consolidación analítica para EDA
--    salarial y detección de outliers.
-- =========================================================
CREATE OR REPLACE TABLE processed.funcionarios_2026_1_persona_mes AS
SELECT
    anho,
    mes,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    coalesce(documento_limpio, hash_fila_origen) AS persona_clave_eda,
    any_value(documento_limpio) AS documento_limpio,
    max(fl_documento_anonimizado) AS fl_documento_anonimizado,
    any_value(documento) AS documento_origen,
    any_value(nombres) AS nombres,
    any_value(apellidos) AS apellidos,
    any_value(sexo) AS sexo,
    any_value(estado) AS estado,
    max(anho_ingreso) AS anho_ingreso,
    max(edad_aprox) AS edad_aprox,
    max(antiguedad_aprox) AS antiguedad_aprox,
    count(*) AS cantidad_componentes,
    count(DISTINCT objeto_gasto) AS cantidad_objetos_gasto,
    sum(coalesce(presupuestado, 0)) AS presupuesto_total_mes,
    sum(coalesce(devengado, 0)) AS devengado_total_mes,
    min(devengado) AS minimo_devengado_componente,
    max(devengado) AS maximo_devengado_componente,
    avg(devengado) AS promedio_devengado_componente,
    max(fl_monto_negativo) AS fl_existe_monto_negativo,
    max(fl_devengado_mayor_presupuestado) AS fl_existe_devengado_mayor_presupuestado,
    max(fl_fecha_nacimiento_null) AS fl_fecha_nacimiento_null,
    max(fl_fecha_nacimiento_futura) AS fl_fecha_nacimiento_futura,
    max(fl_edad_fuera_rango) AS fl_edad_fuera_rango,
    max(fl_antiguedad_fuera_rango) AS fl_antiguedad_fuera_rango,
    CASE
        WHEN sum(coalesce(devengado, 0)) = 0 THEN '0'
        WHEN sum(coalesce(devengado, 0)) < 1000000 THEN '<1M'
        WHEN sum(coalesce(devengado, 0)) < 3000000 THEN '1M-3M'
        WHEN sum(coalesce(devengado, 0)) < 6000000 THEN '3M-6M'
        WHEN sum(coalesce(devengado, 0)) < 10000000 THEN '6M-10M'
        ELSE '>=10M'
    END AS tramo_devengado_total_mes
FROM processed.funcionarios_2026_1_detalle_clean
WHERE rn_duplicado_exacto = 1
GROUP BY
    anho,
    mes,
    nivel,
    descripcion_nivel,
    entidad,
    descripcion_entidad,
    oee,
    descripcion_oee,
    coalesce(documento_limpio, hash_fila_origen);

-- =========================================================
-- 3) Exportación a CSV para trabajo en R
-- =========================================================
COPY (
    SELECT *
    FROM processed.funcionarios_2026_1_detalle_clean
    WHERE rn_duplicado_exacto = 1
)
TO '/opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_detalle_clean.csv'
WITH (HEADER, DELIMITER ',', QUOTE '"');

COPY (
    SELECT *
    FROM processed.funcionarios_2026_1_persona_mes
)
TO '/opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_persona_mes.csv'
WITH (HEADER, DELIMITER ',', QUOTE '"');
SQL
```

---

## Paso 6. Ejecutar el script SQL

Si sigues dentro de DuckDB:

```sql
.read /opt/repo/fpun-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql
```

Si prefieres ejecutarlo desde shell:

```bash
duckdb /opt/repo/fpun-bigdata-lab/data/eda.duckdb \
  -c ".read /opt/repo/fpun-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql"
```

---

## Paso 7. Validar la capa `processed`

Ejecuta estas consultas de control:

```sql
SHOW TABLES FROM processed;

SELECT COUNT(*) AS total_detalle_clean
FROM processed.funcionarios_2026_1_detalle_clean;

SELECT COUNT(*) AS total_detalle_exportable
FROM processed.funcionarios_2026_1_detalle_clean
WHERE rn_duplicado_exacto = 1;

SELECT COUNT(*) AS total_persona_mes
FROM processed.funcionarios_2026_1_persona_mes;

SELECT *
FROM processed.funcionarios_2026_1_detalle_clean
LIMIT 5;

SELECT *
FROM processed.funcionarios_2026_1_persona_mes
LIMIT 5;
```

### Controles útiles de calidad

```sql
SELECT
    SUM(CASE WHEN fl_documento_anonimizado THEN 1 ELSE 0 END) AS filas_documento_anonimizado,
    SUM(CASE WHEN fl_devengado_mayor_presupuestado THEN 1 ELSE 0 END) AS filas_devengado_mayor_presupuestado,
    SUM(CASE WHEN fl_monto_negativo THEN 1 ELSE 0 END) AS filas_monto_negativo,
    SUM(CASE WHEN fl_fecha_nacimiento_futura THEN 1 ELSE 0 END) AS filas_fecha_nacimiento_futura,
    SUM(CASE WHEN fl_edad_fuera_rango THEN 1 ELSE 0 END) AS filas_edad_fuera_rango,
    SUM(CASE WHEN n_duplicado_exacto > 1 THEN 1 ELSE 0 END) AS filas_con_duplicado_exacto
FROM processed.funcionarios_2026_1_detalle_clean;
```

### Control de consolidación persona-mes

```sql
SELECT
    AVG(cantidad_componentes) AS promedio_componentes_por_persona_mes,
    MAX(cantidad_componentes) AS max_componentes_por_persona_mes,
    AVG(devengado_total_mes) AS promedio_devengado_total_mes,
    MAX(devengado_total_mes) AS max_devengado_total_mes
FROM processed.funcionarios_2026_1_persona_mes;
```

---

## Paso 8. Verificar que los CSV fueron exportados correctamente

```bash
ls -lh /opt/repo/fpun-bigdata-lab/data/processed/

file /opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_detalle_clean.csv
file /opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_persona_mes.csv

head -n 5 /opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_persona_mes.csv
```

**Recomendación:** para el EDA científico en R usa como dataset principal:

```text
/opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_persona_mes.csv
```

El detalle limpio sigue siendo útil, pero no es el mejor punto de partida para outliers salariales.

---

## 8. Preparación del entorno de R

## Paso 9. Verificar si R está instalado

```bash
R --version
Rscript --version
```

Si no está instalado en Ubuntu/WSL2:

```bash
sudo apt update
sudo apt install -y r-base
```

Verifica otra vez:

```bash
Rscript --version
```

---

## Paso 10. Instalar librerías recomendadas

Estas librerías son suficientes para un EDA serio, sin meter complejidad innecesaria:

- `data.table`: importación rápida y robusta de CSV.
- `dplyr`, `tidyr`, `tibble`: transformación y análisis.
- `ggplot2`, `scales`, `forcats`: visualización.
- `janitor`: nombres y tabulados prácticos.
- `skimr`: perfil rápido del dataset.
- `naniar`: análisis de faltantes.
- `stringr`: manipulación de texto.
- `readr`: exportación consistente de tablas derivadas.

Instálalas:

```bash
R
```

Luego dentro de la consola de R:

```r
install.packages(c(
  "data.table",
  "dplyr",
  "tidyr",
  "tibble",
  "ggplot2",
  "janitor",
  "skimr",
  "naniar",
  "stringr",
  "forcats",
  "scales",
  "readr"
))
```

Salir de R:

```r
q()
```

---

## 9. Script reproducible en R para el EDA científico

## Paso 11. Crear el script de análisis

Guárdalo en:

```text
/opt/repo/fpun-bigdata-lab/scripts/r/03_eda_funcionarios_2026_1.R
```

### Opción rápida desde terminal

```bash
cat > /opt/repo/fpun-bigdata-lab/scripts/r/03_eda_funcionarios_2026_1.R <<'RSCRIPT'
# ==========================================================
# EDA científico sobre funcionarios_2026_1_persona_mes.csv
# Proyecto: FPUNA BIG DATA LAB
# Autor: Richard D. Jiménez-R.
# ==========================================================

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(ggplot2)
  library(janitor)
  library(skimr)
  library(naniar)
  library(stringr)
  library(forcats)
  library(scales)
  library(readr)
})

# ----------------------------------------------------------
# 1) Parámetros
# ----------------------------------------------------------
path_csv <- "/opt/repo/fpun-bigdata-lab/data/processed/funcionarios_2026_1_persona_mes.csv"
out_base <- "/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1"
out_tablas <- file.path(out_base, "tablas")
out_reportes <- file.path(out_base, "reportes")
out_graficos <- file.path(out_base, "graficos")

for (p in c(out_base, out_tablas, out_reportes, out_graficos)) {
  dir.create(p, recursive = TRUE, showWarnings = FALSE)
}

# ----------------------------------------------------------
# 2) Funciones auxiliares
# ----------------------------------------------------------
modified_z_score <- function(x) {
  med <- median(x, na.rm = TRUE)
  mad_raw <- mad(x, center = med, constant = 1, na.rm = TRUE)
  if (is.na(mad_raw) || mad_raw == 0) {
    return(rep(NA_real_, length(x)))
  }
  0.6745 * (x - med) / mad_raw
}

safe_iqr_bounds <- function(x, k = 1.5) {
  x <- x[!is.na(x)]
  if (length(x) < 4) {
    return(list(lower = NA_real_, upper = NA_real_))
  }
  q1 <- quantile(x, 0.25, na.rm = TRUE, names = FALSE)
  q3 <- quantile(x, 0.75, na.rm = TRUE, names = FALSE)
  iqr_val <- q3 - q1
  list(
    lower = q1 - k * iqr_val,
    upper = q3 + k * iqr_val
  )
}

percent_missing <- function(x) {
  mean(is.na(x)) * 100
}

# ----------------------------------------------------------
# 3) Carga del dataset
# ----------------------------------------------------------
if (!file.exists(path_csv)) {
  stop("No existe el archivo CSV esperado: ", path_csv)
}

eda <- fread(
  path_csv,
  encoding = "UTF-8",
  na.strings = c("", "NA", "NULL")
) |>
  as_tibble() |>
  clean_names()

# ----------------------------------------------------------
# 4) Ajustes de tipos
# ----------------------------------------------------------
eda <- eda |>
  mutate(
    anho = as.integer(anho),
    mes = as.integer(mes),
    nivel = as.integer(nivel),
    entidad = as.integer(entidad),
    oee = as.integer(oee),
    anho_ingreso = as.integer(anho_ingreso),
    edad_aprox = as.integer(edad_aprox),
    antiguedad_aprox = as.integer(antiguedad_aprox),
    cantidad_componentes = as.integer(cantidad_componentes),
    cantidad_objetos_gasto = as.integer(cantidad_objetos_gasto),
    presupuesto_total_mes = as.numeric(presupuesto_total_mes),
    devengado_total_mes = as.numeric(devengado_total_mes),
    minimo_devengado_componente = as.numeric(minimo_devengado_componente),
    maximo_devengado_componente = as.numeric(maximo_devengado_componente),
    promedio_devengado_componente = as.numeric(promedio_devengado_componente),
    fl_documento_anonimizado = as.logical(fl_documento_anonimizado),
    fl_existe_monto_negativo = as.logical(fl_existe_monto_negativo),
    fl_existe_devengado_mayor_presupuestado = as.logical(fl_existe_devengado_mayor_presupuestado),
    fl_fecha_nacimiento_null = as.logical(fl_fecha_nacimiento_null),
    fl_fecha_nacimiento_futura = as.logical(fl_fecha_nacimiento_futura),
    fl_edad_fuera_rango = as.logical(fl_edad_fuera_rango),
    fl_antiguedad_fuera_rango = as.logical(fl_antiguedad_fuera_rango),
    sexo = str_trim(sexo),
    estado = str_trim(estado),
    descripcion_entidad = str_squish(descripcion_entidad),
    descripcion_oee = str_squish(descripcion_oee),
    tramo_devengado_total_mes = factor(
      tramo_devengado_total_mes,
      levels = c("0", "<1M", "1M-3M", "3M-6M", "6M-10M", ">=10M")
    )
  )

# ----------------------------------------------------------
# 5) Perfil general del dataset
# ----------------------------------------------------------
cat("\n=== DIMENSIONES DEL DATASET ===\n")
print(dim(eda))

cat("\n=== NOMBRES DE COLUMNAS ===\n")
print(names(eda))

cat("\n=== HEAD ===\n")
print(head(eda, 5))

sink(file.path(out_reportes, "01_skim_summary.txt"))
print(skimr::skim(eda))
sink()

missing_report <- tibble(
  variable = names(eda),
  pct_missing = sapply(eda, percent_missing)
) |>
  arrange(desc(pct_missing))

write_csv(missing_report, file.path(out_tablas, "01_missing_report.csv"))

# ----------------------------------------------------------
# 6) Reglas de control de calidad relevantes
# ----------------------------------------------------------
quality_flags <- eda |>
  summarise(
    total_registros = n(),
    total_documento_anonimizado = sum(fl_documento_anonimizado, na.rm = TRUE),
    total_monto_negativo = sum(fl_existe_monto_negativo, na.rm = TRUE),
    total_devengado_mayor_presupuestado = sum(fl_existe_devengado_mayor_presupuestado, na.rm = TRUE),
    total_fecha_nacimiento_null = sum(fl_fecha_nacimiento_null, na.rm = TRUE),
    total_fecha_nacimiento_futura = sum(fl_fecha_nacimiento_futura, na.rm = TRUE),
    total_edad_fuera_rango = sum(fl_edad_fuera_rango, na.rm = TRUE),
    total_antiguedad_fuera_rango = sum(fl_antiguedad_fuera_rango, na.rm = TRUE)
  )

write_csv(quality_flags, file.path(out_tablas, "02_quality_flags.csv"))

# ----------------------------------------------------------
# 7) Tablas de alto impacto analítico
# ----------------------------------------------------------
resumen_general <- eda |>
  summarise(
    total_registros = n(),
    total_entidades = n_distinct(descripcion_entidad, na.rm = TRUE),
    total_oee = n_distinct(descripcion_oee, na.rm = TRUE),
    total_personas = n_distinct(persona_clave_eda, na.rm = TRUE),
    devengado_total = sum(devengado_total_mes, na.rm = TRUE),
    presupuesto_total = sum(presupuesto_total_mes, na.rm = TRUE),
    promedio_devengado = mean(devengado_total_mes, na.rm = TRUE),
    mediana_devengado = median(devengado_total_mes, na.rm = TRUE),
    p95_devengado = quantile(devengado_total_mes, 0.95, na.rm = TRUE),
    max_devengado = max(devengado_total_mes, na.rm = TRUE)
  )

write_csv(resumen_general, file.path(out_tablas, "03_resumen_general.csv"))

por_estado <- eda |>
  count(estado, sort = TRUE) |>
  mutate(pct = n / sum(n))
write_csv(por_estado, file.path(out_tablas, "04_distribucion_estado.csv"))

por_sexo <- eda |>
  count(sexo, sort = TRUE) |>
  mutate(pct = n / sum(n))
write_csv(por_sexo, file.path(out_tablas, "05_distribucion_sexo.csv"))

entidades_top <- eda |>
  group_by(descripcion_entidad) |>
  summarise(
    registros = n(),
    devengado_total = sum(devengado_total_mes, na.rm = TRUE),
    promedio_devengado = mean(devengado_total_mes, na.rm = TRUE),
    mediana_devengado = median(devengado_total_mes, na.rm = TRUE)
  ) |>
  arrange(desc(devengado_total))
write_csv(entidades_top, file.path(out_tablas, "06_entidades_top_devengado.csv"))

oee_top <- eda |>
  group_by(descripcion_oee) |>
  summarise(
    registros = n(),
    devengado_total = sum(devengado_total_mes, na.rm = TRUE),
    promedio_devengado = mean(devengado_total_mes, na.rm = TRUE),
    mediana_devengado = median(devengado_total_mes, na.rm = TRUE)
  ) |>
  arrange(desc(devengado_total))
write_csv(oee_top, file.path(out_tablas, "07_oee_top_devengado.csv"))

bandas_devengado <- eda |>
  count(tramo_devengado_total_mes, sort = FALSE) |>
  mutate(pct = n / sum(n))
write_csv(bandas_devengado, file.path(out_tablas, "08_bandas_devengado.csv"))

# ----------------------------------------------------------
# 8) Concentración del gasto devengado
# ----------------------------------------------------------
concentracion <- eda |>
  filter(!is.na(devengado_total_mes)) |>
  arrange(desc(devengado_total_mes)) |>
  mutate(
    rank = row_number(),
    pct_rank = rank / n(),
    share = devengado_total_mes / sum(devengado_total_mes, na.rm = TRUE)
  )

share_top_1 <- concentracion |>
  filter(pct_rank <= 0.01) |>
  summarise(share_top_1 = sum(share, na.rm = TRUE))

share_top_5 <- concentracion |>
  filter(pct_rank <= 0.05) |>
  summarise(share_top_5 = sum(share, na.rm = TRUE))

write_csv(share_top_1, file.path(out_tablas, "09_share_top_1_pct.csv"))
write_csv(share_top_5, file.path(out_tablas, "10_share_top_5_pct.csv"))

# ----------------------------------------------------------
# 9) Outliers globales: IQR y Modified Z-Score (MAD)
# ----------------------------------------------------------
iqr_bounds_global <- safe_iqr_bounds(eda$devengado_total_mes, k = 1.5)

eda_out <- eda |>
  mutate(
    mz_devengado = modified_z_score(devengado_total_mes),
    fl_outlier_iqr_global = case_when(
      is.na(devengado_total_mes) ~ NA,
      devengado_total_mes < iqr_bounds_global$lower ~ TRUE,
      devengado_total_mes > iqr_bounds_global$upper ~ TRUE,
      TRUE ~ FALSE
    ),
    fl_outlier_mad_global = case_when(
      is.na(mz_devengado) ~ NA,
      abs(mz_devengado) > 3.5 ~ TRUE,
      TRUE ~ FALSE
    )
  )

outliers_iqr_global <- eda_out |>
  filter(fl_outlier_iqr_global %in% TRUE) |>
  arrange(desc(devengado_total_mes))
write_csv(outliers_iqr_global, file.path(out_tablas, "11_outliers_iqr_global.csv"))

outliers_mad_global <- eda_out |>
  filter(fl_outlier_mad_global %in% TRUE) |>
  arrange(desc(abs(mz_devengado)))
write_csv(outliers_mad_global, file.path(out_tablas, "12_outliers_mad_global.csv"))

# ----------------------------------------------------------
# 10) Outliers por entidad: comparación más justa
#     Solo se calculan en entidades con n >= 30.
# ----------------------------------------------------------
eda_out_entidad <- eda_out |>
  group_by(descripcion_entidad) |>
  mutate(
    n_entidad = n(),
    q1_entidad = ifelse(n() >= 30, quantile(devengado_total_mes, 0.25, na.rm = TRUE), NA_real_),
    q3_entidad = ifelse(n() >= 30, quantile(devengado_total_mes, 0.75, na.rm = TRUE), NA_real_),
    iqr_entidad = q3_entidad - q1_entidad,
    lower_entidad = q1_entidad - 1.5 * iqr_entidad,
    upper_entidad = q3_entidad + 1.5 * iqr_entidad,
    fl_outlier_iqr_entidad = case_when(
      n_entidad < 30 ~ NA,
      is.na(devengado_total_mes) ~ NA,
      devengado_total_mes < lower_entidad ~ TRUE,
      devengado_total_mes > upper_entidad ~ TRUE,
      TRUE ~ FALSE
    )
  ) |>
  ungroup()

outliers_iqr_entidad <- eda_out_entidad |>
  filter(fl_outlier_iqr_entidad %in% TRUE) |>
  arrange(desc(devengado_total_mes))
write_csv(outliers_iqr_entidad, file.path(out_tablas, "13_outliers_iqr_por_entidad.csv"))

# ----------------------------------------------------------
# 11) Visualizaciones principales
# ----------------------------------------------------------
p1 <- ggplot(eda_out, aes(x = devengado_total_mes)) +
  geom_histogram(bins = 60) +
  scale_x_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Distribución del devengado total mensual",
    x = "Devengado total mensual (Gs.)",
    y = "Frecuencia"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(out_graficos, "01_hist_devengado_total_mes.png"),
  plot = p1,
  width = 12,
  height = 7,
  dpi = 160
)

p2 <- ggplot(eda_out, aes(x = devengado_total_mes)) +
  geom_histogram(bins = 60) +
  scale_x_log10(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Distribución del devengado total mensual en escala log10",
    x = "Devengado total mensual (Gs., escala log10)",
    y = "Frecuencia"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(out_graficos, "02_hist_devengado_total_mes_log10.png"),
  plot = p2,
  width = 12,
  height = 7,
  dpi = 160
)

top_10_entidades <- entidades_top |>
  slice_head(n = 10) |>
  pull(descripcion_entidad)

p3 <- eda_out |>
  filter(descripcion_entidad %in% top_10_entidades) |>
  mutate(descripcion_entidad = fct_reorder(descripcion_entidad, devengado_total_mes, .fun = median, .desc = FALSE)) |>
  ggplot(aes(x = descripcion_entidad, y = devengado_total_mes)) +
  geom_boxplot(outlier.alpha = 0.3) +
  coord_flip() +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Boxplot del devengado total por entidad (Top 10 por masa salarial)",
    x = "Entidad",
    y = "Devengado total mensual (Gs.)"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(out_graficos, "03_boxplot_devengado_top_10_entidades.png"),
  plot = p3,
  width = 13,
  height = 8,
  dpi = 160
)

p4 <- eda_out |>
  filter(!is.na(edad_aprox), !is.na(devengado_total_mes)) |>
  ggplot(aes(x = edad_aprox, y = devengado_total_mes)) +
  geom_point(alpha = 0.25) +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Edad aproximada vs devengado total mensual",
    x = "Edad aproximada",
    y = "Devengado total mensual (Gs.)"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(out_graficos, "04_scatter_edad_vs_devengado.png"),
  plot = p4,
  width = 12,
  height = 7,
  dpi = 160
)

missing_plot_data <- missing_report |>
  slice_max(order_by = pct_missing, n = 15) |>
  mutate(variable = fct_reorder(variable, pct_missing))

p5 <- ggplot(missing_plot_data, aes(x = variable, y = pct_missing)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 15 variables con mayor porcentaje de faltantes",
    x = "Variable",
    y = "% faltante"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(out_graficos, "05_missing_top_15.png"),
  plot = p5,
  width = 12,
  height = 8,
  dpi = 160
)

# ----------------------------------------------------------
# 12) Reporte ejecutivo en texto
# ----------------------------------------------------------
sink(file.path(out_reportes, "02_resumen_ejecutivo_eda.txt"))
cat("EDA científico sobre funcionarios_2026_1_persona_mes\n")
cat("===============================================\n\n")
cat("Total de registros persona-mes: ", nrow(eda_out), "\n", sep = "")
cat("Total entidades: ", n_distinct(eda_out$descripcion_entidad, na.rm = TRUE), "\n", sep = "")
cat("Total OEE: ", n_distinct(eda_out$descripcion_oee, na.rm = TRUE), "\n", sep = "")
cat("Devengado total acumulado: ", format(sum(eda_out$devengado_total_mes, na.rm = TRUE), big.mark = ".", scientific = FALSE), "\n", sep = "")
cat("Mediana devengado total: ", format(median(eda_out$devengado_total_mes, na.rm = TRUE), big.mark = ".", scientific = FALSE), "\n", sep = "")
cat("P95 devengado total: ", format(quantile(eda_out$devengado_total_mes, 0.95, na.rm = TRUE), big.mark = ".", scientific = FALSE), "\n", sep = "")
cat("Máximo devengado total: ", format(max(eda_out$devengado_total_mes, na.rm = TRUE), big.mark = ".", scientific = FALSE), "\n", sep = "")
cat("Outliers IQR global: ", sum(eda_out$fl_outlier_iqr_global, na.rm = TRUE), "\n", sep = "")
cat("Outliers MAD global: ", sum(eda_out$fl_outlier_mad_global, na.rm = TRUE), "\n", sep = "")
cat("Outliers IQR por entidad: ", sum(eda_out_entidad$fl_outlier_iqr_entidad, na.rm = TRUE), "\n", sep = "")
cat("\nNotas:\n")
cat("- Los outliers globales muestran extremos absolutos.\n")
cat("- Los outliers por entidad son más útiles para detectar casos inusuales dentro de contextos comparables.\n")
cat("- Un valor atípico no es automáticamente un error; primero debe interpretarse con reglas de negocio.\n")
sink()

cat("\nProceso completado correctamente.\n")
cat("Resultados en: ", out_base, "\n", sep = "")
RSCRIPT
```

---

## Paso 12. Ejecutar el script en R

```bash
Rscript /opt/repo/fpun-bigdata-lab/scripts/r/03_eda_funcionarios_2026_1.R
```

Si todo salió bien deberías ver un mensaje final similar a este:

```text
Proceso completado correctamente.
Resultados en: /opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1
```

---

## 10. Cómo interpretar correctamente los métodos de outliers

## 10.1. Método IQR global

Sirve para identificar observaciones que se alejan fuertemente de la distribución total del dataset.

Es útil para detectar:

- remuneraciones excepcionalmente altas;
- errores de escala;
- registros que merecen revisión manual.

## Limitación

Si la población es muy heterogénea, este método mezcla grupos que no deberían compararse directamente.

---

## 10.2. Modified Z-Score con MAD

Es más robusto que el Z-score clásico porque usa:

- mediana;
- y desviación absoluta mediana.

Es mejor cuando la distribución es asimétrica o tiene colas pesadas, algo esperable en remuneraciones públicas.

---

## 10.3. IQR por entidad

Este método es, en general, **más útil analíticamente** que el IQR global para remuneraciones.

¿Por qué?

Porque compara cada registro contra un grupo institucional más homogéneo. Un salario alto en una entidad puede ser perfectamente normal en otra.

Esa es una diferencia importante entre hacer un EDA superficial y hacer un EDA serio.

---

## 10.4. Regla metodológica correcta

No tomes un outlier como error automáticamente.

Primero clasifícalo en una de estas categorías:

1. **error técnico**: carga defectuosa, fecha imposible, monto negativo, parseo incorrecto;
2. **caso legítimo extremo**: cargo de alta jerarquía, bonos acumulados, regularizaciones;
3. **caso raro pero plausible**: necesita validación adicional con negocio;
4. **señal de modelado**: indica que el grano elegido no era el adecuado.

---

## 11. Qué outputs deberías revisar al terminar

Revisa especialmente estos archivos:

### Tablas

```text
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/03_resumen_general.csv
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/06_entidades_top_devengado.csv
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/11_outliers_iqr_global.csv
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/12_outliers_mad_global.csv
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/13_outliers_iqr_por_entidad.csv
```

### Reportes

```text
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/reportes/01_skim_summary.txt
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/reportes/02_resumen_ejecutivo_eda.txt
```

### Gráficos

```text
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/01_hist_devengado_total_mes.png
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/02_hist_devengado_total_mes_log10.png
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/03_boxplot_devengado_top_10_entidades.png
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/04_scatter_edad_vs_devengado.png
/opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/05_missing_top_15.png
```

---

## 12. Conclusiones operativas de esta práctica

Al terminar esta guía ya no estarás trabajando con una fuente cruda improvisadamente. Tendrás:

- una capa `processed` reproducible;
- un dataset de detalle con banderas de calidad;
- un dataset consolidado persona-mes, mucho más adecuado para EDA salarial;
- un pipeline reproducible de exportación a CSV;
- y un script en R que ejecuta un EDA serio, con trazabilidad y detección de outliers.

Eso es bastante mejor que abrir el CSV en Excel, mirar dos columnas y sacar conclusiones rápidas. Técnicamente no compiten.

---

## 13. Próximo paso recomendado

La continuación natural de esta práctica es construir una tercera guía para:

- segmentación analítica por universidades nacionales;
- consolidación de hechos y dimensiones;
- modelado estrella para consumo en BI;
- y comparación con salario mínimo, cotización del dólar u otras fuentes externas.

---

## 14. Anexo rápido de comandos

### Ejecutar toda la preparación SQL

```bash
duckdb /opt/repo/fpun-bigdata-lab/data/eda.duckdb \
  -c ".read /opt/repo/fpun-bigdata-lab/scripts/sql/02_prepare_processed_funcionarios_2026_1.sql"
```

### Ejecutar el EDA en R

```bash
Rscript /opt/repo/fpun-bigdata-lab/scripts/r/03_eda_funcionarios_2026_1.R
```

### Ver los archivos exportados

```bash
ls -lh /opt/repo/fpun-bigdata-lab/data/processed/
ls -lh /opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/tablas/
ls -lh /opt/repo/fpun-bigdata-lab/outputs/r_eda_funcionarios_2026_1/graficos/
```

