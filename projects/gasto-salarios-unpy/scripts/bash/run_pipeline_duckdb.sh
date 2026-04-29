#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${1:-remuneraciones.duckdb}"

duckdb "$DB_PATH" < sql/00_create_schemas.sql
duckdb "$DB_PATH" < sql/01_raw_ingesta.sql
duckdb "$DB_PATH" < sql/02_staging_limpieza.sql
duckdb "$DB_PATH" < sql/03_core_modelo.sql
duckdb "$DB_PATH" < sql/04_datamart_obt.sql
duckdb "$DB_PATH" < sql/05_datamart_agregados.sql
duckdb "$DB_PATH" < sql/06_data_quality_checks.sql

echo "Pipeline SQL completado sobre $DB_PATH"
