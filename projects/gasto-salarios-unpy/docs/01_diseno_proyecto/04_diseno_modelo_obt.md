<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Diseño del modelo analítico OBT

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

Este documento define el diseño lógico de `datamart.obt_remuneraciones_funcionarios_publicos`. La OBT debe ser una tabla ancha, entendible y estable para análisis BI, evitando joins complejos por parte del usuario final.

---

## 2. Tabla final

```sql
datamart.obt_remuneraciones_funcionarios_publicos
```

---

## 3. Grano

Una fila por:

```text
anho + mes + nivel + entidad + oee + documento
```

Interpretación: remuneración mensual consolidada por funcionario o tipo de registro dentro de una institución/OEE.

---

## 4. Justificación

La fuente puede contener múltiples filas para el mismo documento en un mismo periodo debido a distintos objetos de gasto. El grano consolidado evita sobreconteo y permite calcular remuneración total, composición salarial, percentiles, rankings, brechas y conversiones a USD.

---

## 5. Familias de columnas

### Identificación técnica

| Campo | Tipo sugerido | Origen |
|---|---|---|
| `hash_obt` | varchar | derivado |
| `hash_registro_persona_mes` | varchar | derivado |
| `fecha_carga` | timestamp | derivado |
| `fuente_archivo` | varchar | raw/staging |

### Periodo

| Campo | Tipo | Origen |
|---|---:|---|
| `anho` | integer | fuente principal |
| `mes` | integer | fuente principal |
| `periodo_yyyy_mm` | varchar | derivado |
| `fecha_periodo` | date | derivado |
| `trimestre` | integer | derivado |
| `mes_nombre` | varchar | derivado |

### Institución

| Campo | Tipo | Origen |
|---|---:|---|
| `nivel` | integer | fuente principal |
| `entidad` | integer | fuente principal |
| `oee` | integer | fuente principal |
| `descripcion_nivel` | varchar | clasificador OEE |
| `descripcion_entidad` | varchar | clasificador OEE |
| `descripcion_oee` | varchar | clasificador OEE |
| `descripcion_corta_oee` | varchar | clasificador OEE |
| `es_universidad_nacional` | boolean | derivado |

### Persona o registro

| Campo | Tipo | Observación |
|---|---:|---|
| `documento` | varchar | Identificador operativo; evaluar exposición. |
| `documento_hash` | varchar | Recomendado para BI público/académico. |
| `nombres` | varchar | No recomendado en dashboards abiertos. |
| `apellidos` | varchar | No recomendado en dashboards abiertos. |
| `estado` | varchar | Normalizado. |
| `sexo` | varchar | Normalizado. |
| `discapacidad` | varchar | Uso agregado y responsable. |
| `tipo_discapacidad` | varchar | Alto nivel de nulos. |
| `tipo_registro_funcionario` | varchar | Nacional, extranjero, vacancia, anónimo/no convencional. |
| `es_vacancia` | boolean | Derivado desde documento. |
| `es_registro_anonimo` | boolean | Derivado desde documento. |

### Variables temporales personales

| Campo | Tipo | Origen |
|---|---:|---|
| `fecha_nacimiento` | date | fuente principal |
| `edad` | integer | derivado |
| `rango_etario` | varchar | derivado |
| `generacion` | varchar | derivado |
| `anho_ingreso` | integer | fuente principal |
| `antiguedad_anhos` | integer | derivado |
| `rango_antiguedad` | varchar | derivado |
| `fecha_acto` | date | fuente principal |

### Conceptos y componentes

La fuente principal no incluye `concepto`. La OBT debe derivar conceptos desde `clasificador_gastos_utf8.csv`.

| Campo | Tipo | Origen |
|---|---:|---|
| `objetos_gasto_lista` | varchar | agregado desde detalle |
| `conceptos_remunerativos_lista` | varchar | clasificador de gastos |
| `componentes_remunerativos_lista` | varchar | derivado |
| `cantidad_objetos_gasto` | integer | derivado |
| `tiene_objeto_gasto_sin_clasificar` | boolean | derivado |

### Métricas monetarias PYG

| Campo | Tipo | Descripción |
|---|---:|---|
| `total_presupuestado_gs` | decimal(18,2) | Suma mensual presupuestada. |
| `total_devengado_gs` | decimal(18,2) | Suma mensual devengada. |
| `diferencia_presupuestado_devengado_gs` | decimal(18,2) | Presupuestado menos devengado. |
| `salario_basico_gs` | decimal(18,2) | Componentes clasificados como salario básico. |
| `bonificaciones_gs` | decimal(18,2) | Bonificaciones y gratificaciones. |
| `beneficios_gs` | decimal(18,2) | Subsidios y beneficios. |
| `viaticos_gs` | decimal(18,2) | Viáticos y movilidad. |
| `aguinaldo_gs` | decimal(18,2) | Aguinaldo. |
| `otros_componentes_gs` | decimal(18,2) | Otros componentes válidos. |
| `sin_clasificar_gs` | decimal(18,2) | Montos sin clasificador. |

### Métricas USD

| Campo | Tipo | Descripción |
|---|---:|---|
| `cotizacion_usd_mensual` | decimal(18,6) | Cotización mensual referencial. |
| `total_devengado_usd` | decimal(18,2) | `total_devengado_gs / cotizacion`. |
| `salario_basico_usd` | decimal(18,2) | Salario básico convertido. |
| `bonificaciones_usd` | decimal(18,2) | Bonificaciones convertidas. |
| `beneficios_usd` | decimal(18,2) | Beneficios convertidos. |
| `viaticos_usd` | decimal(18,2) | Viáticos convertidos. |

### Ratios y distribución

| Campo | Fórmula o descripción |
|---|---|
| `pct_salario_basico` | `salario_basico_gs / total_devengado_gs`. |
| `pct_bonificaciones` | `bonificaciones_gs / total_devengado_gs`. |
| `pct_beneficios` | `beneficios_gs / total_devengado_gs`. |
| `pct_viaticos` | `viaticos_gs / total_devengado_gs`. |
| `percentil_salarial_global` | Percentil global del devengado. |
| `percentil_salarial_institucional` | Percentil dentro de institución/mes. |
| `ranking_salarial_institucional` | Ranking descendente por OEE/mes. |
| `brecha_vs_promedio_institucional_gs` | Diferencia contra promedio institucional. |
| `brecha_vs_mediana_institucional_gs` | Diferencia contra mediana institucional. |
| `es_outlier_salarial` | Indicador estadístico. |

---

## 6. Campos excluidos de la OBT base

| Campo | Motivo |
|---|---|
| `cargo` | No está en el CSV principal de modelado. |
| `funcion` | No está en el CSV principal de modelado. |
| `linea` | No está en el CSV principal de modelado. |
| `categoria` | No está en el CSV principal de modelado. |
| `concepto` como fuente | Debe derivarse como `concepto_remunerativo`. |

---

## 7. Tabla de detalle recomendada

Crear adicionalmente:

```sql
core.fact_remuneraciones_componentes
```

Grano:

```text
anho + mes + nivel + entidad + oee + documento + objeto_gasto
```

Esta tabla permite analizar composición salarial sin romper la OBT consolidada.
