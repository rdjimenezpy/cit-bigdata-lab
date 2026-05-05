<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Decisiones de modelado

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

Este documento registra decisiones técnicas y analíticas adoptadas para modelar las remuneraciones públicas universitarias. Su función es evitar que las reglas importantes queden escondidas en SQL.

---

## 2. Decisión 1 — Usar OBT como consumo principal

La salida principal será:

```sql
datamart.obt_remuneraciones_funcionarios_publicos
```

Justificación: facilita el consumo BI y reduce joins para estudiantes y usuarios finales.

---

## 3. Decisión 2 — Grano funcionario/registro + mes + institución

La OBT se consolida por:

```text
anho + mes + nivel + entidad + oee + documento
```

Esto evita sobreconteo cuando un documento aparece en varios objetos de gasto.

---

## 4. Decisión 3 — Mantener detalle por objeto de gasto

Además de la OBT, se recomienda:

```sql
core.fact_remuneraciones_componentes
```

Grano:

```text
anho + mes + nivel + entidad + oee + documento + objeto_gasto
```

Esta tabla permite analizar componentes sin romper el grano consolidado.

---

## 5. Decisión 4 — No usar `cargo` ni `funcion` en la versión base

`cargo` y `funcion` no están presentes en la fuente principal de modelado. No deben usarse para clasificar funcionarios como docentes o administrativos salvo que se incorpore una fuente adicional válida.

---

## 6. Decisión 5 — Derivar `concepto_remunerativo` desde clasificador de gastos

El campo semántico de concepto remunerativo se obtiene desde:

```text
clasificador_gastos_utf8.csv.objeto_gasto_descripcion
```

Clave:

```text
objeto_gasto = objeto_gasto_codigo
```

Alias recomendado:

```sql
g.objeto_gasto_descripcion AS concepto_remunerativo
```

No debe referenciarse `funcionarios.concepto` como campo fuente.

---

## 7. Decisión 6 — No usar `linea` ni `categoria`

`linea` y `categoria` no están disponibles en la fuente principal. La tabla de detalle llega hasta `objeto_gasto`.

---

## 8. Decisión 7 — Clasificar tipo de registro desde `documento`

| Patrón | Clasificación |
|---|---|
| Primer carácter numérico | `FUNCIONARIO_NACIONAL` |
| Primer carácter `E` | `FUNCIONARIO_EXTRANJERO` |
| Primer carácter `V` | `VACANCIA` |
| Primer carácter `A` | `ANONIMO_NO_CONVENCIONAL` |
| Otro caso | `NO_CLASIFICADO` |

Esta decisión evita mezclar vacancias con personas activas.

---

## 9. Decisión 8 — Usar `devengado` como métrica salarial principal

`presupuestado` y `devengado` deben mantenerse separados. Para rankings, percentiles, outliers y brechas se recomienda usar `total_devengado_gs`.

---

## 10. Decisión 9 — Conversión USD referencial

Los campos USD se calculan con cotización mensual. Deben documentarse como conversión referencial, no como valor exacto transaccional.

---

## 11. Decisión 10 — Antigüedad aproximada

La antigüedad se calcula desde `anho_ingreso`, validando valores `0`, nulos o futuros. `fecha_acto` no debe confundirse con fecha de ingreso original.

---

## 12. Decisión 11 — Clasificación inicial de componentes

| Componente | Objetos/referencia inicial |
|---|---|
| `SALARIO_BASICO` | 111, 112, 141, 142, 144, 145, 148 |
| `AGUINALDO` | 114 |
| `GASTOS_REPRESENTACION` | 113 |
| `BONIFICACIONES` | 123, 125, 132, 133 |
| `BENEFICIOS` | 131, 191 |
| `VIATICOS` | 232 |
| `TRANSFERENCIAS_BECAS` | 841 |
| `OTROS_COMPONENTES` | 199 u otros válidos no clasificados |
| `SIN_CLASIFICAR` | 0 o sin match |

Advertencia: el objeto 148 puede señalar contratación docente/instructores, pero no habilita clasificar automáticamente a toda la persona como docente.

---

## 13. Decisión 12 — Separar becas del salario principal

El objeto 841 (`BECAS`) pertenece a transferencias y no debe mezclarse automáticamente con salario básico. Debe marcarse como `TRANSFERENCIAS_BECAS` o analizarse por separado.

---

## 14. Decisión 13 — Claridad antes que optimización

El SQL debe ser legible, comentado y mantenible. Para este laboratorio, la claridad pedagógica es más importante que una optimización prematura.
