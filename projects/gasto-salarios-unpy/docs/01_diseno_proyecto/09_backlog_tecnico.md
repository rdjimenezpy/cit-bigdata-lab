<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Backlog técnico de diseño e implementación

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

Este backlog registra tareas necesarias para alinear la implementación con el diseño documentado. Es relevante porque los scripts preliminares pueden contener referencias a columnas no disponibles en el CSV principal.

---

## 2. Prioridades

| Prioridad | Significado |
|---|---|
| Alta | Bloquea el modelo o puede generar resultados erróneos. |
| Media | Mejora calidad, trazabilidad o mantenibilidad. |
| Baja | Mejora deseable, no bloqueante. |

---

## 3. Backlog crítico

| ID | Tarea | Prioridad | Criterio de cierre |
|---|---|---|---|
| BT-001 | Revisar SQL que referencie `cargo`, `funcion`, `linea`, `categoria` o `concepto` como columnas fuente. | Alta | Ningún script base depende de columnas inexistentes. |
| BT-002 | Sustituir `concepto` por `concepto_remunerativo` derivado desde `clasificador_gastos.objeto_gasto_descripcion`. | Alta | La tabla core usa join por `objeto_gasto`. |
| BT-003 | Redefinir `core.fact_remuneraciones_componentes` hasta `objeto_gasto`, no hasta línea/categoría. | Alta | No existen joins ni hashes con columnas inexistentes. |
| BT-004 | Definir `tipo_funcionario` como `NO_DETERMINADO` o eliminarlo si no hay fuente adicional. | Alta | No se afirma docente/administrativo sin sustento. |
| BT-005 | Crear `tipo_registro_funcionario` desde patrón de `documento`. | Alta | Vacancias y registros anómalos son segmentables. |
| BT-006 | Incorporar control de objeto de gasto sin match, especialmente código `0`. | Alta | Existe reporte de registros/montos sin clasificar. |
| BT-007 | Separar becas/transferencias del salario principal. | Alta | Objeto 841 no contamina salario básico. |

---

## 4. Backlog de modelado

| ID | Tarea | Prioridad | Criterio de cierre |
|---|---|---|---|
| BM-001 | Crear `core.dim_clasificador_gastos`. | Alta | Contiene códigos y descripciones. |
| BM-002 | Crear `core.fact_remuneraciones_componentes`. | Alta | Una fila por funcionario/registro/mes/OEE/objeto_gasto. |
| BM-003 | Crear `core.remuneraciones_funcionario_mes`. | Alta | Una fila por grano OBT. |
| BM-004 | Calcular componentes por sumas condicionadas. | Alta | Columnas de salario, bonificaciones, beneficios y viáticos disponibles. |
| BM-005 | Calcular ratios de composición. | Media | Ratios controlan división por cero. |
| BM-006 | Calcular percentiles y rankings institucionales. | Media | Campos disponibles en OBT. |
| BM-007 | Calcular brechas contra promedio y mediana institucional. | Media | Campos disponibles en OBT. |

---

## 5. Backlog de calidad

| ID | Tarea | Prioridad | Criterio de cierre |
|---|---|---|---|
| BQ-001 | Validar duplicados por grano OBT. | Alta | Cero duplicados críticos. |
| BQ-002 | Validar nulos en periodo e institución. | Alta | Campos críticos completos. |
| BQ-003 | Validar objetos de gasto sin clasificador. | Alta | Casos identificados. |
| BQ-004 | Validar periodos sin cotización USD. | Alta | Todo periodo 2025 tiene match. |
| BQ-005 | Validar fechas de nacimiento inválidas. | Media | Edades fuera de rango se marcan nulas. |
| BQ-006 | Validar `anho_ingreso` igual a 0 o futuro. | Media | Antigüedad inválida se marca no determinada. |
| BQ-007 | Validar montos negativos y monetariamente nulos. | Alta | Reporte disponible. |
| BQ-008 | Detectar outliers por OEE y periodo. | Media | Vista o tabla de outliers generada. |

---

## 6. Backlog Pentaho y Airflow

| ID | Tarea | Prioridad | Criterio de cierre |
|---|---|---|---|
| BP-001 | Crear job principal `jb_gasto_salarios_unpy_pipeline.kjb`. | Media | Job ejecuta flujo completo. |
| BP-002 | Crear transformación de validación de archivos. | Media | Falla si falta CSV crítico. |
| BP-003 | Crear transformación para ejecutar SQL por capa. | Media | Cada script SQL se ejecuta desde Pentaho. |
| BP-004 | Centralizar rutas en variables. | Media | Sin rutas hardcodeadas innecesarias. |
| BA-001 | Crear DAG `dag_gasto_salarios_unpy_etl.py`. | Baja/Media | DAG define tareas por capa. |
| BA-002 | Agregar validaciones como tareas separadas. | Baja/Media | DAG falla ante controles críticos. |

---

## 7. Nota final

La prioridad inmediata es corregir cualquier script que todavía asuma la existencia de `cargo`, `funcion`, `concepto`, `linea` o `categoria` en el CSV principal. El diseño debe apoyarse en campos reales y enriquecimientos documentados.
