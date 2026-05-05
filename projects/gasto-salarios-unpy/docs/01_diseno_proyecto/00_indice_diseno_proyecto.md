<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Índice de documentación — Diseño del Proyecto

**Proyecto:** `gasto-salarios-unpy`  
**Tema:** Modelo analítico OBT para remuneraciones de funcionarios públicos de universidades nacionales de Paraguay  
**Periodo de análisis:** 2025  
**Motor analítico:** DuckDB  
**ETL:** Pentaho Data Integration v11  
**Orquestación objetivo:** Apache Airflow 3.1.8  
**Autor académico:** Prof. Ing. Richard D. Jiménez-R.  
**Fecha:** 2026-05-04

---


## 1. Propósito de esta carpeta

La carpeta `docs/01_diseno_proyecto/` documenta el diseño técnico y metodológico del proyecto `gasto-salarios-unpy`. Su función es servir como contrato de arquitectura, modelado y ejecución antes de ajustar los scripts SQL, diseñar las transformaciones Pentaho y preparar la orquestación con Airflow.

Esta etapa no describe solamente la fuente; eso corresponde a `docs/00_contexto_fuente/`. Esta carpeta responde qué se va a construir, con qué alcance, bajo qué supuestos, con qué grano analítico, con qué reglas de enriquecimiento y con qué criterios de calidad.

---

## 2. Documentos incluidos

| Orden | Documento | Propósito |
|---:|---|---|
| 00 | `00_indice_diseno_proyecto.md` | Mapa de lectura de la carpeta de diseño. |
| 01 | `01_fase_0_definicion_problema.md` | Define problema, objetivos, preguntas guía y unidad de análisis. |
| 02 | `02_alcance_supuestos_restricciones.md` | Delimita alcance, supuestos y restricciones reales de fuente. |
| 03 | `03_arquitectura_datos_pipeline.md` | Describe arquitectura por capas y responsabilidad de DuckDB, Pentaho y Airflow. |
| 04 | `04_diseno_modelo_obt.md` | Define grano, familias de campos y estructura esperada de la OBT. |
| 05 | `05_matriz_fuentes_campos_derivados.md` | Mapea columnas directas, externas y derivadas. |
| 06 | `06_decisiones_modelado.md` | Registra decisiones críticas de modelado y exclusiones. |
| 07 | `07_plan_ejecucion_pipeline.md` | Orden recomendado de ejecución de scripts y flujo Pentaho/Airflow. |
| 08 | `08_convenciones_estandares.md` | Convenciones de nombres, SQL, calidad, privacidad y versionado. |
| 09 | `09_backlog_tecnico.md` | Tareas pendientes para alinear implementación con diseño. |

---

## 3. Principio rector

El diseño debe ser técnicamente honesto: no se debe inferir más de lo que las fuentes permiten. Las columnas `cargo`, `funcion`, `linea` y `categoria` no forman parte del CSV principal de modelado disponible. La columna `concepto` tampoco viene como campo fuente; debe derivarse desde `clasificador_gastos_utf8.csv`, usando `objeto_gasto` como clave de enriquecimiento.

---

## 4. Resultado esperado

Al cerrar esta etapa se debe contar con documentación suficiente para:

- corregir y completar SQL por capas;
- implementar Pentaho sin ambigüedad;
- construir `datamart.obt_remuneraciones_funcionarios_publicos`;
- ejecutar controles de calidad mínimos;
- y explicar el proyecto ante estudiantes, evaluadores o revisores técnicos.
