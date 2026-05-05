<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 01 · Resumen de la fuente

## Proyecto: gasto-salarios-unpy
### Contexto inicial de fuentes para el modelo analítico de remuneraciones públicas universitarias · Paraguay 2025

**Institución:** Facultad Politécnica · Universidad Nacional de Asunción  
**Dependencia:** Centro de Innovación TIC (PK)  
**Curso:** Introducción a Big Data · Nivel Básico  
**Autor:** Prof. Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py  
**Versión:** 0.1  
**Fecha:** 2026-05-04

---

## 1. Resumen ejecutivo

El proyecto **gasto-salarios-unpy** utiliza fuentes públicas de remuneraciones de funcionarios de universidades nacionales del Paraguay y clasificadores auxiliares para construir una base analítica orientada a BI. La meta técnica es transformar archivos CSV en una tabla OBT capaz de responder preguntas sobre distribución salarial, composición de la remuneración, brechas institucionales, antigüedad, edad, generación, régimen salarial y conversión a USD.

La fuente principal revisada para esta etapa es `sample_funcionarios_modelo.csv`, una muestra depurada con **10.000 registros** y **19 columnas**. La muestra contiene datos temporales, institucionales, personales, de perfil básico y montos presupuestados/devengados. No contiene campos descriptivos de cargo o función; por eso, la inferencia de tipo de funcionario debe tratarse con prudencia.

---

## 2. Inventario de fuentes

| Archivo                         | Rol                                               | Delimitador   |   Filas observadas |   Columnas | Codificación   | Uso analítico                                                                |
|:--------------------------------|:--------------------------------------------------|:--------------|-------------------:|-----------:|:---------------|:-----------------------------------------------------------------------------|
| sample_funcionarios_modelo.csv  | Fuente principal depurada para modelado           | ,             |              10000 |         19 | UTF-8          | Base del OBT; contiene variables seleccionadas y montos por objeto de gasto. |
| clasificador_gastos_utf8.csv    | Clasificador presupuestario de objetos de gasto   | ;             |                368 |          9 | UTF-8          | Enriquece el objeto de gasto con grupo, subgrupo y control financiero.       |
| clasificador_oee_utf8.csv       | Clasificador de Organismos y Entidades del Estado | ,             |                434 |         11 | UTF-8          | Permite etiquetar nivel, entidad y OEE; filtra universidades nacionales.     |
| cotizacion_usd_mensual_utf8.csv | Cotización mensual USD/PYG                        | ,             |                303 |          6 | UTF-8/ASCII    | Permite expresar métricas monetarias en USD por período.                     |
| regimen_salarial_py_utf8.csv    | Régimen salarial paraguayo                        | ,             |                 20 |         16 | UTF-8/ASCII    | Permite comparar remuneraciones con salario mínimo, jornal y aportes.        |

---

## 3. Objetivo analítico de las fuentes

Las fuentes permiten construir un modelo para analizar:

- remuneración presupuestada y devengada por funcionario, mes, universidad y OEE;
- composición de la remuneración por objeto de gasto;
- comparación de remuneración en guaraníes y dólares estadounidenses;
- segmentación por sexo, estado administrativo, discapacidad, rango etario y generación;
- comparación contra régimen salarial paraguayo;
- rankings, percentiles y posibles concentraciones salariales;
- brechas contra promedio y mediana institucional.

El valor del dataset está en combinar tres dimensiones: **persona**, **institución** y **componente presupuestario de gasto**.

---

## 4. Cobertura observada en la muestra principal

| Indicador | Valor observado |
|---|---:|
| Registros | 10.000 |
| Columnas | 19 |
| Año observado | 2025 |
| Meses observados | 1 a 12 |
| Documentos únicos | 7.618 |
| Combinaciones documento-año-mes únicas | 9.782 |
| Duplicados exactos | 17 |
| Devengado total observado | 17.933.191.409 Gs. |
| Presupuestado total observado | 20.469.121.148 Gs. |
| Registros con devengado cero | 239 |
| Registros con presupuestado cero | 57 |
| Registros con `anho_ingreso = 0` | 1.698 |
| Registros sin fecha de nacimiento | 138 |
| Registros sin fecha de acto cruda | 79 |
| Fechas de acto no parseables o inválidas en parseo estricto | 453 |

---

## 5. Lectura funcional de la fuente principal

La fuente principal combina columnas de cinco bloques:

| Bloque | Columnas principales | Interpretación |
|---|---|---|
| Temporal | `anho`, `mes` | Ubican la remuneración en un período fiscal mensual. |
| Institucional | `nivel`, `entidad`, `oee` | Permiten identificar universidad, facultad, rectorado u organismo. |
| Persona | `documento`, `nombres`, `apellidos` | Identifican al funcionario; deben manejarse como datos personales. |
| Perfil | `estado`, `anho_ingreso`, `sexo`, `discapacidad`, `tipo_discapacidad`, `fecha_nacimiento`, `fecha_acto` | Permiten segmentación laboral y demográfica, con cautela ética. |
| Remuneración | `fuente_financiamiento`, `objeto_gasto`, `presupuestado`, `devengado` | Permiten construir métricas monetarias y composición salarial. |

---

## 6. Grano y comportamiento de los registros

La fuente no debe interpretarse como una tabla única de funcionarios. Una misma persona puede aparecer varias veces por mes, institución u objeto de gasto. La unidad de análisis inicial es una **línea de remuneración por componente presupuestario**.

Grano recomendado para `staging`:

```text
anho + mes + nivel + entidad + oee + documento + objeto_gasto + fuente_financiamiento + monto
```

Grano recomendado para la OBT final:

```text
funcionario + periodo mensual + institución/OEE
```

La OBT debe agregar los componentes salariales y conservar columnas de composición para no perder trazabilidad.

---

## 7. Instituciones cubiertas

El clasificador OEE contiene **26 registros** asociados al nivel `28 — UNIVERSIDADES NACIONALES`. Estos incluyen la Universidad Nacional de Asunción y sus unidades académicas, además de universidades nacionales del Este, Pilar, Itapúa, Concepción, Villarrica del Espíritu Santo, Caaguazú, Canindeyú, Misiones y la Universidad Politécnica Taiwán-Paraguay.

La clave institucional correcta es:

```text
codigo_nivel + codigo_entidad + codigo_oee
```

No debe usarse solo `oee`, porque los códigos de OEE se repiten entre entidades.

---

## 8. Componentes remunerativos observados

Distribución de objetos de gasto por monto devengado en la muestra:

|   objeto_gasto |   registros | devengado_gs   | presupuestado_gs   |
|---------------:|------------:|:---------------|:-------------------|
|            111 |        5699 | 13.720.840.255 | 15.870.172.765     |
|            133 |        1865 | 1.405.834.063  | 1.553.382.896      |
|            114 |         458 | 1.036.285.273  | 1.159.786.601      |
|            144 |         164 | 378.234.206    | 390.735.053        |
|            191 |        1055 | 317.508.178    | 317.508.178        |
|            142 |          74 | 273.244.115    | 297.196.618        |
|            148 |         122 | 249.476.270    | 250.498.405        |
|            145 |          50 | 144.478.706    | 186.275.208        |
|            113 |          55 | 120.751.801    | 144.697.024        |
|            131 |         184 | 71.020.113     | 71.020.113         |
|            112 |          75 | 57.849.622     | 61.487.705         |
|            123 |          73 | 46.134.072     | 52.257.966         |
|            232 |          42 | 34.451.020     | 34.451.020         |
|            199 |           5 | 33.223.669     | 34.535.550         |
|            132 |          47 | 16.177.332     | 17.433.332         |
|            841 |           6 | 15.031.494     | 15.031.494         |
|            125 |          24 | 11.251.220     | 11.251.220         |
|            141 |           1 | 1.400.000      | 1.400.000          |
|              0 |           1 | 0              | 0                  |

La mayor parte del monto devengado observado se concentra en `111 — SUELDOS`, seguido por `133 — BONIFICACIONES Y GRATIFICACIONES`, `114 — AGUINALDO`, `144 — JORNALES`, `191 — SUBSIDIO PARA LA SALUD`, `142 — CONTRATACIÓN DE PERSONAL DE SALUD` y `148 — CONTRATACIÓN DE PERSONAL DOCENTE E INSTRUCTORES...`.

Esto confirma que el clasificador de gastos es indispensable para distinguir salario base, bonificaciones, beneficios, viáticos, contrataciones, aguinaldo y otros componentes.

---

## 9. Uso de fuentes externas

### 9.1. Clasificador de gastos

Aporta semántica presupuestaria para `objeto_gasto`. Es la fuente clave para clasificar componentes salariales y evitar interpretaciones débiles basadas solo en códigos numéricos.

### 9.2. Clasificador OEE

Aporta nombres institucionales, siglas, descripción de nivel, entidad y OEE. Debe ser la fuente preferente para etiquetas institucionales en BI.

### 9.3. Cotización mensual USD

Permite convertir montos en guaraníes a USD por período. En 2025 se observan registros para los 12 meses, por lo que la conversión mensual del año objetivo es viable.

### 9.4. Régimen salarial paraguayo

Permite comparar remuneraciones con salario mínimo, jornal, salario neto referencial y aportes. La fuente es histórica y no mensual completa; por eso se debe aplicar una regla de último régimen vigente conocido al período analizado.

---

## 10. Perfil de calidad inicial

### Fortalezas

- Estructura tabular simple y adecuada para DuckDB.
- Presencia de claves temporales, institucionales y presupuestarias.
- Montos expresados de forma directamente convertible a numérico.
- Buena compatibilidad con arquitectura por capas `raw → staging → core → datamart`.
- Clasificadores externos suficientes para enriquecer el análisis.

### Debilidades

- Presencia de duplicados exactos.
- Campos personales identificables que requieren tratamiento de privacidad.
- `anho_ingreso = 0` en una proporción relevante de registros.
- `fecha_acto` contiene valores imposibles o anómalos como años `0002` y `4752`.
- La muestra no contiene `cargo`, `funcion`, `concepto`, `linea` ni `categoria`.
- El código `objeto_gasto = 0` aparece en la muestra, pero no está en el clasificador de gastos revisado.
- `tipo_discapacidad` tiene alta nulidad, esperable cuando `discapacidad = NO`, pero sensible para publicación.

---

## 11. Decisiones recomendadas para el proyecto

| Decisión | Recomendación |
|---|---|
| Métrica monetaria principal | Usar `devengado_gs` como remuneración ejecutada. |
| Métrica complementaria | Mantener `presupuestado_gs` para comparar presupuesto versus ejecución. |
| Conversión a USD | Dividir monto en Gs. por cotización mensual del mismo `anho` y `mes`. |
| Identificador de funcionario | Usar `documento` internamente y `funcionario_hash` para publicación. |
| Institución | Usar `nivel + entidad + oee`; enriquecer desde clasificador OEE. |
| Componente salarial | Clasificar desde `objeto_gasto` y clasificador de gastos. |
| Edad y generación | Calcular solo si `fecha_nacimiento` es válida. |
| Antigüedad | Calcular solo si `anho_ingreso` está entre un rango razonable y no es cero. |
| Docente/administrativo | Tratar como inferencia; mejorar con fuente completa que incluya `cargo` o `funcion`. |

---

## 12. Arquitectura de datos sugerida

```text
CSV públicos y clasificadores
        ↓
raw
  Preserva archivos como fueron leídos.
        ↓
staging
  Tipado, limpieza, normalización y banderas de calidad.
        ↓
core
  Integración con clasificadores, cotización y régimen salarial.
        ↓
datamart
  OBT final y vistas agregadas para BI.
        ↓
Power BI / Metabase / Tableau / SQL EDA
```

---

## 13. Preguntas analíticas habilitadas

1. ¿Cuál es la remuneración total mensual por universidad y OEE?
2. ¿Qué proporción de la remuneración corresponde a sueldo base, bonificaciones, beneficios, aguinaldo, viáticos y otros conceptos?
3. ¿Qué OEE concentran mayores montos devengados?
4. ¿Cuál es la distribución salarial por sexo, estado administrativo, edad y antigüedad?
5. ¿Qué funcionarios o cargos aparecen en percentiles salariales altos?
6. ¿Cómo se compara la remuneración contra el salario mínimo vigente?
7. ¿Qué brechas existen contra la media y la mediana institucional?
8. ¿Qué registros presentan montos extremos, fechas inválidas o falta de clasificador?

---

## 14. Recomendación final

La fuente es adecuada para un laboratorio académico de ingeniería de datos y analítica pública, pero exige una postura metodológica estricta. El error más grave sería construir dashboards atractivos sin explicar el grano, los campos ausentes y las limitaciones de clasificación. Para una OBT confiable, primero deben resolverse reglas de calidad, anonimización, clasificación de componentes salariales y validación institucional por clave compuesta.
