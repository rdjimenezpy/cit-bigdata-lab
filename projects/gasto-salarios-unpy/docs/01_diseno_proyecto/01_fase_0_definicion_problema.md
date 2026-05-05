<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Fase 0 — Definición formal del problema analítico

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

Este documento formaliza el problema analítico del proyecto. Antes de escribir SQL, construir transformaciones en Pentaho o crear dashboards, debe quedar claro qué se quiere analizar, cuál será la unidad de análisis, qué restricciones tiene la fuente y qué resultados se consideran válidos.

---

## 2. Contexto del problema

La nómina de funcionarios públicos del Estado paraguayo contiene información valiosa para estudiar la estructura del gasto en remuneraciones. En este proyecto se toma como foco el subconjunto asociado a universidades nacionales de Paraguay durante el periodo 2025.

El problema no consiste en consultar archivos CSV de forma aislada. La fuente principal requiere ingesta, normalización, tipado, enriquecimiento con clasificadores externos, consolidación de componentes salariales y controles de calidad. El objetivo es convertir una fuente operativa abierta en un activo analítico reproducible.

---

## 3. Formulación del problema

¿Cómo diseñar e implementar un pipeline ETL básico, reproducible y mantenible que transforme archivos CSV de remuneraciones públicas y fuentes externas de referencia en una tabla analítica tipo **OBT — One Big Table**, apta para analizar distribución salarial de funcionarios públicos de universidades nacionales de Paraguay en el periodo 2025?

---

## 4. Objetivo general

Construir una base analítica consolidada en DuckDB que permita analizar remuneraciones públicas universitarias del Paraguay, integrando la fuente principal de funcionarios con clasificadores externos y exponiendo una OBT final apta para consumo en herramientas BI como Power BI, Metabase o Tableau.

---

## 5. Objetivos específicos

1. Ingerir las fuentes CSV en una capa `raw`, preservando los datos originales.
2. Limpiar, tipar y normalizar la información en `staging`.
3. Enriquecer la fuente principal con clasificadores de OEE, gastos, régimen salarial y cotización USD.
4. Calcular métricas monetarias en guaraníes y dólares estadounidenses.
5. Derivar edad, rango etario, generación, antigüedad y rango de antigüedad.
6. Clasificar componentes remunerativos usando `objeto_gasto` y el clasificador de gastos.
7. Consolidar una OBT orientada a análisis salarial.
8. Publicar vistas agregadas para exploración institucional, demográfica y presupuestaria.
9. Incorporar controles de calidad para duplicados, nulos críticos, importes inconsistentes, objetos sin clasificar y outliers.
10. Diseñar una ruta de ejecución compatible con Pentaho Data Integration y Airflow.

---

## 6. Preguntas analíticas iniciales

El modelo final debe permitir responder, al menos:

1. ¿Cuál es la remuneración total devengada por universidad/OEE y por mes?
2. ¿Cómo se distribuye la remuneración por sexo, estado laboral y tipo de registro?
3. ¿Cuál es la composición entre salario básico, bonificaciones, beneficios, viáticos, aguinaldo y otros componentes?
4. ¿Qué objetos de gasto concentran la mayor parte del monto devengado?
5. ¿Qué proporción de la remuneración corresponde a salario básico frente al total?
6. ¿Cuál es la remuneración total expresada en USD según cotización mensual?
7. ¿Qué registros presentan valores extremos respecto a la distribución institucional?
8. ¿Cuál es la brecha contra el promedio y la mediana institucional?
9. ¿Cómo varía la remuneración por generación y rango etario?
10. ¿Cómo se comportan las remuneraciones respecto al salario mínimo mensual vigente?
11. ¿Cuántos registros corresponden a nacionales, extranjeros, vacancias o registros anónimos/no convencionales?
12. ¿Qué instituciones presentan mayor dispersión salarial?

---

## 7. Unidad de análisis principal

La unidad de análisis principal del modelo OBT será:

> **funcionario o registro identificable + periodo mensual + institución universitaria**

Grano técnico recomendado:

```text
anho + mes + nivel + entidad + oee + documento
```

Este grano permite consolidar múltiples componentes remunerativos asociados a un mismo registro en un mismo periodo e institución.

---

## 8. Granularidad complementaria

Debe mantenerse un activo de detalle por componente:

```text
anho + mes + nivel + entidad + oee + documento + objeto_gasto
```

Esta tabla de detalle permite analizar composición salarial sin romper la OBT consolidada ni provocar sobreconteos en BI.

---

## 9. Restricción crítica de la fuente principal

El CSV principal de modelado disponible contiene 10.000 registros y 19 columnas:

```text
anho, mes, nivel, entidad, oee, documento, nombres, apellidos, estado,
anho_ingreso, sexo, discapacidad, tipo_discapacidad, fuente_financiamiento,
objeto_gasto, presupuestado, devengado, fecha_nacimiento, fecha_acto
```

No incluye:

```text
cargo, funcion, concepto, linea, categoria
```

Por tanto, `cargo`, `funcion`, `linea` y `categoria` no deben formar parte del modelo base. El atributo `concepto` debe construirse como `concepto_remunerativo` desde `clasificador_gastos_utf8.csv`, usando `objeto_gasto` como clave.

---

## 10. Criterio de éxito

El resultado será aceptable si el pipeline carga las fuentes, limpia y tipa datos, enriquece con clasificadores, construye una OBT trazable, genera agregados útiles y ejecuta validaciones de calidad básicas. La calidad del proyecto no se mide solo por tener una tabla final, sino por evitar sobreconteos y sostener consistencia semántica.
