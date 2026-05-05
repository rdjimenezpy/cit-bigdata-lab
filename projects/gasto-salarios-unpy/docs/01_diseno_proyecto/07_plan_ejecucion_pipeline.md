<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Plan de ejecución del pipeline

**Proyecto:** `gasto-salarios-unpy`  
**Tema:** Modelo analítico OBT para remuneraciones de funcionarios públicos de universidades nacionales de Paraguay  
**Periodo de análisis:** 2025  
**Motor analítico:** DuckDB  
**ETL:** Pentaho Data Integration v11  
**Orquestación objetivo:** Apache Airflow 3.1.8  
**Autor académico:** Prof. Ing. Richard D. Jiménez-R.  
**Fecha:** 2026-05-04

---


## 1. Propósito

Este documento define el orden recomendado de ejecución del pipeline ETL, considerando scripts Bash, transformaciones Pentaho, SQL en DuckDB y orquestación objetivo con Airflow.

---

## 2. Flujo general

```text
1. Preparar carpetas y base DuckDB
2. Descargar o ubicar CSV en data/raw
3. Validar codificación UTF-8
4. Crear esquemas
5. Cargar RAW
6. Construir STAGING
7. Construir CORE
8. Construir DATAMART OBT
9. Construir vistas agregadas
10. Ejecutar validaciones de calidad
11. Exportar resultados opcionales
12. Registrar logs
```

---

## 3. Orden de scripts SQL

| Orden | Script | Propósito |
|---:|---|---|
| 00 | `sql/00_setup/00_create_schemas.sql` | Crear esquemas y funciones auxiliares. |
| 01 | `sql/01_raw/01_raw_ingesta.sql` | Leer CSV y crear tablas RAW. |
| 02 | `sql/02_staging/02_staging_limpieza.sql` | Tipar, limpiar y normalizar datos. |
| 03 | `sql/03_core/03_core_modelo.sql` | Integrar fuentes y calcular hechos/dimensiones core. |
| 04 | `sql/04_datamart/04_datamart_obt.sql` | Construir OBT final. |
| 05 | `sql/04_datamart/05_datamart_agregados.sql` | Crear vistas agregadas. |
| 06 | `sql/05_quality/06_data_quality_checks.sql` | Ejecutar controles de calidad. |

---

## 4. Ejecución manual DuckDB

```bash
export PROJECT_HOME=/opt/repo/cit-bigdata-lab/projects/gasto-salarios-unpy
export DUCKDB_PATH=$PROJECT_HOME/database/unpy.duckdb

mkdir -p $PROJECT_HOME/database

duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/00_setup/00_create_schemas.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/01_raw/01_raw_ingesta.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/02_staging/02_staging_limpieza.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/03_core/03_core_modelo.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/04_datamart/04_datamart_obt.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/04_datamart/05_datamart_agregados.sql
duckdb $DUCKDB_PATH < $PROJECT_HOME/sql/05_quality/06_data_quality_checks.sql
```

---

## 5. Flujo recomendado en Pentaho

Job principal sugerido:

```text
pentaho/jobs/jb_gasto_salarios_unpy_pipeline.kjb
```

Transformaciones sugeridas:

| Orden | Transformación | Propósito |
|---:|---|---|
| 01 | `tr_validar_archivos_entrada.ktr` | Verificar existencia y tamaño de CSV. |
| 02 | `tr_validar_codificacion_utf8.ktr` | Controlar codificación y separadores. |
| 03 | `tr_ejecutar_sql_setup.ktr` | Ejecutar creación de esquemas. |
| 04 | `tr_ejecutar_sql_raw.ktr` | Ejecutar ingesta RAW. |
| 05 | `tr_ejecutar_sql_staging.ktr` | Ejecutar limpieza STAGING. |
| 06 | `tr_ejecutar_sql_core.ktr` | Ejecutar integración CORE. |
| 07 | `tr_ejecutar_sql_datamart.ktr` | Ejecutar OBT y agregados. |
| 08 | `tr_ejecutar_sql_quality.ktr` | Ejecutar validaciones de calidad. |
| 09 | `tr_exportar_datamart.ktr` | Exportar OBT a CSV/Parquet. |

---

## 6. Control de errores

Cada bloque debe detener el job ante errores críticos, registrar script fallido, guardar logs en `logs/pentaho/` y no continuar a `datamart` si falla `staging` o `core`.

---

## 7. Exportaciones opcionales

```sql
COPY datamart.obt_remuneraciones_funcionarios_publicos
TO 'data/exports/parquet/obt_remuneraciones_funcionarios_publicos.parquet'
(FORMAT PARQUET);
```

```sql
COPY datamart.obt_remuneraciones_funcionarios_publicos
TO 'data/exports/csv/obt_remuneraciones_funcionarios_publicos.csv'
(HEADER, DELIMITER ',');
```

---

## 8. DAG objetivo Airflow

DAG sugerido:

```text
dag_gasto_salarios_unpy_etl
```

Tareas sugeridas:

```text
start
  ↓
validar_directorios
  ↓
descargar_csv_funcionarios
  ↓
descargar_csv_clasificadores
  ↓
descargar_csv_cotizacion
  ↓
validar_csv_utf8
  ↓
ejecutar_sql_setup
  ↓
ejecutar_sql_raw
  ↓
ejecutar_sql_staging
  ↓
ejecutar_sql_core
  ↓
ejecutar_sql_datamart_obt
  ↓
ejecutar_sql_datamart_agregados
  ↓
ejecutar_quality_checks
  ↓
exportar_resultados
  ↓
end
```

---

## 9. Validaciones mínimas antes de publicar

| Control | Condición esperada |
|---|---|
| Conteo RAW > 0 | Todas las fuentes críticas cargadas. |
| OBT > 0 | Tabla final con registros. |
| Sin periodo nulo | `anho`, `mes`, `fecha_periodo` completos. |
| Sin institución nula | `nivel`, `entidad`, `oee` completos. |
| Cotización disponible | Todo periodo 2025 tiene match. |
| Concepto disponible | Todo `objeto_gasto` válido tiene match, excepto anomalías como `0`. |
| Montos no negativos | No hay devengados negativos salvo regla documentada. |
| Sin duplicados OBT | Una fila por grano definido. |
