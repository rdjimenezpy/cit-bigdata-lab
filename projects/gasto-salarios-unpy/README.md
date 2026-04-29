# Remuneraciones Públicas Universitarias — Portal de Datos Abiertos PY
### Análisis de gastos por remuneraciones de funcionarios de universidades nacionales (Paraguay) 2025

Repositorio académico para construir un proceso ETL básico orientado al análisis de remuneraciones de funcionarios públicos de universidades nacionales de Paraguay.

El proyecto está diseñado como línea base práctica para el curso básico de **Introducción a Big Data** del Centro de Innovación IT (PK) de la Facultad Politécnica de la Universidad Nacional de Asunción. Su propósito es que el estudiante aplique conceptos de ingeniería de datos, ingesta de archivos CSV, limpieza, transformación SQL, control de calidad y construcción de una tabla analítica tipo **OBT — One Big Table** usando **DuckDB**, **Pentaho Data Integration** y **Apache Airflow**. Con este proyecto se busca ofrecer un **explorador de sueldos y beneficios en universidades nacionales de Paraguay para el periodo 2025**

---

## 1. Objetivo del proyecto

Construir un pipeline ETL reproducible que transforme fuentes públicas y clasificadores auxiliares en una base analítica consolidada para responder preguntas como:

- ¿Cómo se distribuye la remuneración total por universidad o facultad (OEE)?
- ¿Cuál es la composición salarial entre salario básico, bonificaciones, viáticos y otros beneficios?
- ¿Qué diferencias existen entre funcionarios docentes, administrativos y otros perfiles?
- ¿Cómo varía la remuneración por cargo, edad, generación, antigüedad y régimen salarial?
- ¿Dónde aparecen posibles concentraciones salariales, brechas institucionales u *outliers*?

---

## 2. Arquitectura lógica

El flujo se organiza por capas:

```text
CSV fuente
   ↓
raw
   ↓
staging
   ↓
core
   ↓
datamart
   ↓
BI / EDA / exportación
```

### Capas del modelo

| Capa | Propósito |
|---|---|
| `raw` | Preservar la lectura original de los CSV con transformaciones mínimas. |
| `staging` | Limpiar, tipar, normalizar textos, fechas e importes. |
| `core` | Integrar funcionarios con clasificadores externos y calcular métricas derivadas. |
| `datamart` | Publicar la OBT final y vistas agregadas para BI. |
| `dq` / `tests` | Ejecutar validaciones de calidad de datos. |

---

## 3. Estructura de directorios

```text
gasto-salarios-unpy/
├── README.md
├── Makefile
├── .gitignore
├── assets/
│   └── img/
├── data/
│   ├── README.md
│   ├── temp/
│   ├── raw/
│   │   ├── funcionarios/
│   │   │   └── funcionarios_AAAA_MM.csv
│   │   ├── clasificadores/
│   │   │   ├── clasificador_gastos.csv
│   │   │   ├── clasificador_oee.csv
│   │   │   └── regimen_salarial_py.csv
│   │   └── cotizacion/
│   │       └── cotizacion_usd_mensual.csv
│   ├── staging/
│   ├── processed/
│   └── exports/
│       ├── csv/
│       └── parquet/
├── database/
│   └── unpy.duckdb
├── docs/
│   ├── diccionario_datos/
│   ├── guias/
│   └── informes/
├── notebooks/
│   └── eda/
├── pentaho/
│   ├── jobs/
│   └── transformations/
│       ├── 00_ingesta/
│       ├── 01_validacion/
│       ├── 02_sql_duckdb/
│       └── 03_exportacion/
├── scripts/
│   ├── bash/
│   │   └── run_pipeline_duckdb.sh
│   └── python/
├── sql/
│   ├── 00_setup/
│   │   └── 00_create_schemas.sql
│   ├── 01_raw/
│   │   └── 01_raw_ingesta.sql
│   ├── 02_staging/
│   │   └── 02_staging_limpieza.sql
│   ├── 03_core/
│   │   └── 03_core_modelo.sql
│   ├── 04_datamart/
│   │   ├── 04_datamart_obt.sql
│   │   └── 05_datamart_agregados.sql
│   └── 05_quality/
│       └── 06_data_quality_checks.sql
├── tests/
│   └── data_quality/
└── logs/
```

---

## 4. Fuentes de datos esperadas

Colocar los archivos CSV en las rutas indicadas:

```text
data/raw/funcionarios/funcionarios_2025_1.csv
data/raw/funcionarios/funcionarios_2025_2.csv
data/raw/funcionarios/funcionarios_2025_3.csv
data/raw/funcionarios/funcionarios_2025_4.csv
data/raw/funcionarios/funcionarios_2025_5.csv
data/raw/funcionarios/funcionarios_2025_6.csv
data/raw/funcionarios/funcionarios_2025_7.csv
data/raw/funcionarios/funcionarios_2025_8.csv
data/raw/funcionarios/funcionarios_2025_9.csv
data/raw/funcionarios/funcionarios_2025_10.csv
data/raw/funcionarios/funcionarios_2025_11.csv
data/raw/funcionarios/funcionarios_2025_12.csv
data/raw/clasificadores/clasificador_gastos.csv
data/raw/clasificadores/clasificador_oee.csv
data/raw/clasificadores/regimen_salarial_py.csv
data/raw/cotizacion/cotizacion_usd_mensual.csv
```

### Nota sobre versionado de datos

Los CSV reales quedan excluidos por `.gitignore`. En GitHub se versiona la estructura, los scripts SQL, la documentación y plantillas mínimas. Esto evita subir datos pesados o potencialmente sensibles.

---

## 5. Requisitos técnicos

### Software mínimo

- DuckDB CLI.
- Pentaho Data Integration — Spoon / Kitchen / Pan.
- Git.
- Java compatible con la versión de Pentaho utilizada.
- Opcional: DBeaver Community para explorar la base DuckDB.
- Opcional: Python 3.12+ para validaciones auxiliares o notebooks.

### Validación rápida de DuckDB

```bash
duckdb --version
```

---

## 6. Ejecución del pipeline con DuckDB

Crear la base local y ejecutar los scripts por orden:

```bash
duckdb database/remuneraciones.duckdb < sql/00_setup/00_create_schemas.sql
duckdb database/remuneraciones.duckdb < sql/01_raw/01_raw_ingesta.sql
duckdb database/remuneraciones.duckdb < sql/02_staging/02_staging_limpieza.sql
duckdb database/remuneraciones.duckdb < sql/03_core/03_core_modelo.sql
duckdb database/remuneraciones.duckdb < sql/04_datamart/04_datamart_obt.sql
duckdb database/remuneraciones.duckdb < sql/04_datamart/05_datamart_agregados.sql
duckdb database/remuneraciones.duckdb < sql/05_quality/06_data_quality_checks.sql
```

O ejecutar todo con el script base:

```bash
chmod +x scripts/bash/run_pipeline_duckdb.sh
./scripts/bash/run_pipeline_duckdb.sh database/remuneraciones.duckdb
```

También se puede ejecutar con `make`:

```bash
make all
make export
```

---

## 7. Tabla analítica principal

La tabla final del modelo se publica como:

```sql
SELECT *
FROM datamart.obt_remuneraciones_funcionarios_publicos
LIMIT 10;
```

Vista enfocada en universidades nacionales:

```sql
SELECT *
FROM datamart.vw_obt_remuneraciones_universidades_nacionales
LIMIT 10;
```

---

## 8. Vistas agregadas esperadas

El datamart incluye vistas para análisis de:

- remuneración por universidad/OEE;
- remuneración por tipo de funcionario;
- remuneración por cargo;
- remuneración por generación;
- remuneración por rango etario;
- remuneración por régimen salarial;
- distribución de componentes salariales;
- top cargos con mayor remuneración;
- brecha salarial por institución.

---

## 9. Flujo recomendado en Pentaho Data Integration

La estructura sugerida para Pentaho es:

```text
pentaho/jobs/
└── jb_00_pipeline_remuneraciones.kjb

pentaho/transformations/
├── 00_ingesta/
│   ├── tr_00_validar_archivos_csv.ktr
│   └── tr_01_preparar_directorios.ktr
├── 01_validacion/
│   └── tr_02_validar_estructura_csv.ktr
├── 02_sql_duckdb/
│   ├── tr_03_ejecutar_sql_raw.ktr
│   ├── tr_04_ejecutar_sql_staging.ktr
│   ├── tr_05_ejecutar_sql_core.ktr
│   └── tr_06_ejecutar_sql_datamart.ktr
└── 03_exportacion/
    └── tr_07_exportar_obt.ktr
```

### Orden operativo del job Pentaho

1. Validar existencia de archivos CSV.
2. Validar nombres, separador, codificación y cantidad mínima de columnas.
3. Crear esquemas y base DuckDB.
4. Ejecutar ingesta `raw`.
5. Ejecutar limpieza `staging`.
6. Ejecutar integración `core`.
7. Generar OBT y vistas agregadas en `datamart`.
8. Ejecutar controles de calidad.
9. Exportar resultados a CSV o Parquet si corresponde.
10. Registrar logs de ejecución.

### Enfoque recomendado

Pentaho debe orquestar y controlar el flujo, pero el procesamiento principal debe quedar en SQL. Esto facilita trazabilidad, revisión académica, portabilidad y reutilización de los scripts fuera de Pentaho.

---

## 10. Controles de calidad sugeridos

Ejecutar controles para detectar:

- registros duplicados;
- importes negativos o nulos;
- fechas inválidas;
- funcionarios sin institución/OEE;
- funcionarios sin régimen salarial;
- registros sin cotización USD;
- diferencias entre total calculado y total informado;
- distribución de nulos por columna;
- outliers salariales.

Consulta de referencia:

```sql
SELECT *
FROM dq.resumen_validaciones;
```

---

## 11. Exportación para BI

Exportar la OBT a Parquet:

```sql
COPY datamart.obt_remuneraciones_funcionarios_publicos
TO 'data/exports/parquet/obt_remuneraciones_funcionarios_publicos.parquet'
(FORMAT PARQUET);
```

Exportar la OBT a CSV:

```sql
COPY datamart.obt_remuneraciones_funcionarios_publicos
TO 'data/exports/csv/obt_remuneraciones_funcionarios_publicos.csv'
(HEADER, DELIMITER ',');
```

---

## 12. Convenciones del proyecto

### Nombres

- Carpetas en minúsculas.
- SQL en minúsculas con `snake_case`.
- Tablas por capa: `raw`, `staging`, `core`, `datamart`, `dq`.
- Scripts numerados por orden de ejecución.

### Estilo SQL

- CTEs para transformaciones complejas.
- Comentarios por bloque funcional.
- Evitar lógica oculta en Pentaho cuando puede expresarse en SQL.
- Mantener reproducibilidad: cada script debe poder ejecutarse desde cero.

---

## 13. Limitaciones metodológicas

Este proyecto es una base de laboratorio. Antes de usarlo para decisiones oficiales deben revisarse:

- calidad y completitud de la fuente original;
- reglas de consolidación de persona, cargo y remuneración;
- tratamiento de documentos duplicados o inconsistentes;
- definición normativa de salario, beneficio, bonificación y viático;
- límites legales y éticos de publicación de datos personales;
- correspondencia exacta entre objeto de gasto, concepto presupuestario y componente salarial.

---

## 14. Roadmap académico sugerido

- [ ] Validar estructura de todos los CSV fuente.
- [ ] Ejecutar EDA inicial en DuckDB.
- [ ] Consolidar tabla `raw`.
- [ ] Crear tablas `staging` tipadas.
- [ ] Integrar clasificadores externos.
- [ ] Crear modelo OBT.
- [ ] Ejecutar validaciones de calidad.
- [ ] Exportar OBT a Parquet.
- [ ] Conectar Power BI, Metabase o Tableau.
- [ ] Documentar hallazgos salariales principales.

---

## 15. Autoría académica

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Facultad Politécnica · Universidad Nacional de Asunción  
Asignatura: Electiva - Big Data  
Correo institucional: `rjimenez@pol.una.py`

---

## 16. Licencia sugerida

Para uso académico, se recomienda publicar el código bajo licencia MIT o Apache 2.0. Los datos fuente deben mantenerse sujetos a los términos de publicación del portal original y a las consideraciones éticas de tratamiento de datos personales.
