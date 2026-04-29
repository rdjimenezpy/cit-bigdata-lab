# Modelo analítico OBT de remuneraciones públicas en DuckDB

## Arquitectura propuesta

El flujo implementa un pipeline por capas:

1. **raw**: lectura directa de CSV, preservando los datos como `VARCHAR`.
2. **staging**: limpieza, tipado, normalización, fechas, montos y preparación de claves.
3. **core**: integración semántica con clasificadores, cálculo de componentes salariales, consolidación por funcionario/OEE/mes y métricas analíticas.
4. **datamart**: tabla OBT final y vistas agregadas para Power BI, Metabase o Tableau.
5. **dq**: validaciones de calidad, outliers y controles de integridad.

El diseño parte de una premisa crítica: la fuente cruda no debe tratarse como una fila por funcionario, sino como registros por componente remunerativo. Por eso se conserva el detalle en `core.fact_remuneraciones_componentes` y se consolida la OBT a nivel mensual en `datamart.obt_remuneraciones_funcionarios_publicos`.

## Archivos SQL

Ejecutar en este orden:

```bash
duckdb remuneraciones.duckdb < sql/00_create_schemas.sql
duckdb remuneraciones.duckdb < sql/01_raw_ingesta.sql
duckdb remuneraciones.duckdb < sql/02_staging_limpieza.sql
duckdb remuneraciones.duckdb < sql/03_core_modelo.sql
duckdb remuneraciones.duckdb < sql/04_datamart_obt.sql
duckdb remuneraciones.duckdb < sql/05_datamart_agregados.sql
duckdb remuneraciones.duckdb < sql/06_data_quality_checks.sql
```

## Estructura esperada

```text
proyecto/
├── data/
│   ├── funcionarios_2025_3_utf8_sample10k.csv
│   ├── funcionarios_2025_3_utf8_sample10k_modelo.csv
│   ├── clasificador_gastos_utf8.csv
│   ├── clasificador_oee_utf8.csv
│   ├── cotizacion_usd_mensual.csv
│   └── regimen_salarial_py.csv
├── sql/
│   ├── 00_create_schemas.sql
│   ├── 01_raw_ingesta.sql
│   ├── 02_staging_limpieza.sql
│   ├── 03_core_modelo.sql
│   ├── 04_datamart_obt.sql
│   ├── 05_datamart_agregados.sql
│   └── 06_data_quality_checks.sql
└── exports/
```

## Nota importante sobre `cotizacion_usd_mensual.csv`

En el entorno recibido no se encontró físicamente el archivo `cotizacion_usd_mensual.csv`. Los scripts asumen que existe con columnas:

```text
anho, mes, cotizacion_usd
```

Si el archivo tiene otros nombres, ajustar el bloque `staging.cotizacion_usd_mensual` en `02_staging_limpieza.sql`.

## Pipeline recomendado en Pentaho Data Integration

### Job principal

Nombre sugerido:

```text
job_remuneraciones_funcionarios_publicos.kjb
```

Orden:

1. **START**
2. **Validar existencia de archivos CSV**
3. **Crear carpetas de salida**
4. **Ejecutar SQL 00_create_schemas.sql**
5. **Ejecutar SQL 01_raw_ingesta.sql**
6. **Ejecutar SQL 02_staging_limpieza.sql**
7. **Ejecutar SQL 03_core_modelo.sql**
8. **Ejecutar SQL 04_datamart_obt.sql**
9. **Ejecutar SQL 05_datamart_agregados.sql**
10. **Ejecutar SQL 06_data_quality_checks.sql**
11. **Consultar `dq.vw_resumen_calidad`**
12. **Exportar OBT a Parquet/CSV si corresponde**
13. **SUCCESS / ERROR**

### Pasos Pentaho sugeridos

- **File Exists**: validar cada CSV requerido.
- **SQL Script / Execute SQL script**: ejecutar cada archivo `.sql`.
- **Transformation Executor**: si se separan validaciones en transformaciones.
- **Detect empty stream** o **Filter Rows**: controlar checks con severidad alta.
- **Write to log**: registrar resultados de `dq.resultados_checks`.
- **Abort**: detener si hay fallas críticas.
- **Copy Files / Shell**: exportación opcional a `exports/`.

### Driver DuckDB en PDI

En Pentaho, usar JDBC de DuckDB. La cadena típica es:

```text
jdbc:duckdb:/ruta/proyecto/remuneraciones.duckdb
```

El driver debe estar disponible en `data-integration/lib`.

## Objetos principales generados

- `core.fact_remuneraciones_componentes`
- `core.remuneraciones_funcionario_mes`
- `datamart.obt_remuneraciones_funcionarios_publicos`
- `datamart.vw_obt_remuneraciones_universidades_nacionales`
- `datamart.vw_remuneracion_por_universidad_oee`
- `datamart.vw_distribucion_componentes_salariales`
- `dq.vw_resumen_calidad`

## Plantilla incluida

Se incluye `data_templates/cotizacion_usd_mensual_template.csv` con el encabezado mínimo esperado para adaptar la fuente de cotización USD.
