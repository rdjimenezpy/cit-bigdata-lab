<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Convenciones y estándares técnicos

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

Este documento define convenciones de nombres, SQL, capas, calidad, privacidad y versionado para que el proyecto sea mantenible y didáctico.

---

## 2. Convenciones de nombres

| Elemento | Convención | Ejemplo |
|---|---|---|
| Esquemas | minúsculas, snake_case | `raw`, `staging`, `core`, `datamart` |
| Tablas | minúsculas, snake_case | `funcionarios_modelo` |
| Vistas | prefijo `vw_` | `vw_remuneracion_por_oee` |
| Dimensiones | prefijo `dim_` | `dim_oee` |
| Hechos | prefijo `fact_` | `fact_remuneraciones_componentes` |
| Booleanos | prefijo `es_`, `tiene_` | `es_vacancia` |
| Guaraníes | sufijo `_gs` | `total_devengado_gs` |
| Dólares | sufijo `_usd` | `total_devengado_usd` |
| Porcentajes | prefijo `pct_` | `pct_salario_basico` |
| Ratios | prefijo `ratio_` | `ratio_viaticos_total` |
| Fechas | prefijo `fecha_` | `fecha_periodo` |
| Hashes | `hash` en el nombre | `documento_hash`, `hash_obt` |

---

## 3. Esquemas estándar

```sql
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS datamart;
CREATE SCHEMA IF NOT EXISTS dq;
```

Responsabilidades:

- `raw`: datos fuente sin transformaciones fuertes.
- `staging`: limpieza técnica.
- `core`: integración semántica y reglas de negocio.
- `datamart`: consumo analítico.
- `dq`: controles de calidad.

---

## 4. Estándares SQL

- Usar SQL compatible con DuckDB.
- Usar CTEs para separar pasos complejos.
- Comentar bloques principales.
- Evitar nombres ambiguos sin sufijo monetario o semántico.
- Usar `TRY_CAST` ante conversiones riesgosas.
- Evitar `SELECT *` en tablas finales.
- No usar columnas inexistentes: `cargo`, `funcion`, `concepto`, `linea`, `categoria`.

Ejemplo:

```sql
CREATE OR REPLACE TABLE staging.funcionarios_modelo AS
WITH fuente AS (
    SELECT *
    FROM raw.funcionarios_modelo_src
), tipado AS (
    SELECT
        TRY_CAST(anho AS INTEGER) AS anho,
        TRY_CAST(mes AS INTEGER) AS mes,
        TRIM(CAST(documento AS VARCHAR)) AS documento,
        TRY_CAST(devengado AS DECIMAL(18,2)) AS devengado_gs
    FROM fuente
)
SELECT *
FROM tipado;
```

---

## 5. Estándares monetarios

| Regla | Aplicación |
|---|---|
| Usar `DECIMAL(18,2)` para PYG y USD. | Evita problemas de precisión. |
| No mezclar monedas sin sufijo. | Siempre usar `_gs` o `_usd`. |
| Dividir por cotización solo si no es nula ni cero. | Evita errores. |
| Documentar USD como referencial. | La cotización es mensual. |

---

## 6. Campos sensibles

| Campo | Tratamiento |
|---|---|
| `documento` | Mantener en core; publicar hash cuando sea posible. |
| `nombres` | Evitar dashboards públicos. |
| `apellidos` | Evitar dashboards públicos. |
| `discapacidad` | Usar solo en agregados responsables. |
| `tipo_discapacidad` | No exponer individualmente. |

---

## 7. Campos derivados

### Edad

- Calcular solo con `fecha_nacimiento` válida.
- Marcar como nula si la edad es negativa o irrazonable.

### Antigüedad

- Calcular desde `anho_ingreso`.
- Tratar `0` como no informado/no válido.
- No confundir `fecha_acto` con fecha de ingreso.

### Generación

| Generación | Año nacimiento aproximado |
|---|---:|
| `GEN_Z` | 1997-2012 |
| `MILLENNIALS` | 1981-1996 |
| `GEN_X` | 1965-1980 |
| `BABY_BOOMERS` | 1946-1964 |
| `SILENT_GENERATION` | antes de 1946 |
| `NO_DETERMINADO` | fecha inválida o nula |

---

## 8. Calidad de datos

Cada corrida debe validar:

- conteo de registros por capa;
- duplicados en grano OBT;
- objetos de gasto sin clasificador;
- periodos sin cotización USD;
- instituciones sin clasificador OEE;
- montos negativos;
- fechas inválidas;
- registros monetariamente nulos;
- outliers salariales.

---

## 9. Versionado Git

Versionar SQL, documentación Markdown, scripts Bash, jobs/transformaciones Pentaho y notebooks sin datos sensibles. No versionar CSV completos, base DuckDB, exports grandes, logs extensos, temporales ni credenciales.

`.gitignore` mínimo:

```gitignore
data/temp/*
data/raw/**/*.csv
data/staging/*
data/processed/*
data/exports/*
database/*.duckdb
database/*.wal
logs/*
.env
__pycache__/
.ipynb_checkpoints/
```
