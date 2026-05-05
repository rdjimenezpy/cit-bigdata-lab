<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Alcance, supuestos y restricciones del proyecto

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

Este documento delimita lo que el proyecto incluye, lo que no incluye y los supuestos bajo los cuales se interpretarán los resultados. Su objetivo es evitar conclusiones falsas o diseños dependientes de columnas inexistentes.

---

## 2. Alcance funcional

### Incluye

- Carga de archivos CSV de funcionarios del periodo 2025.
- Uso de `sample_funcionarios_modelo.csv` como muestra base para diseño.
- Integración con `clasificador_gastos_utf8.csv`, `clasificador_oee_utf8.csv`, `cotizacion_usd_mensual_utf8.csv` y `regimen_salarial_py_utf8.csv`.
- Capas `raw`, `staging`, `core`, `datamart` y `dq`.
- Construcción de una OBT final para BI.
- Vistas agregadas por institución, periodo, sexo, estado, rango etario, generación, régimen salarial y componente remunerativo.
- Controles de calidad de datos.
- Diseño de flujo compatible con Pentaho Data Integration v11 y Airflow 3.1.8.

### No incluye

- Clasificación definitiva docente/administrativo sin una fuente confiable de cargo o función.
- Análisis jurídico-laboral de cada concepto remunerativo.
- Cálculo de salario neto real con todos los descuentos personales o legales.
- Análisis de desempeño académico, productividad docente o carga horaria.
- Publicación de datos personales sensibles en dashboards abiertos.
- Auditoría oficial del gasto público.

---

## 3. Supuestos técnicos

| Supuesto | Justificación | Riesgo |
|---|---|---|
| `anho` y `mes` definen el periodo. | Están en la fuente. | Rectificaciones futuras requerirían versionado. |
| `nivel`, `entidad`, `oee` identifican institución. | Permiten unir con clasificador OEE. | Puede haber OEE sin match. |
| `documento` es identificador operativo. | Permite consolidar registros. | Puede representar vacancias, extranjeros o anónimos. |
| `objeto_gasto` clasifica componentes. | Es clave contra clasificador de gastos. | Código `0` queda sin clasificar. |
| `presupuestado` y `devengado` son métricas base. | Son los importes disponibles. | No explican por sí solos causas de diferencias. |
| `fecha_nacimiento` permite edad. | Está en la muestra. | Nulos o fechas inválidas afectan rangos. |
| `anho_ingreso` permite antigüedad aproximada. | Es el campo disponible. | Valor `0` no debe interpretarse literalmente. |
| `fecha_acto` representa acto administrativo observado. | Está en la fuente. | No equivale necesariamente al ingreso original. |
| Cotización USD mensual permite conversión referencial. | La fuente externa tiene periodo y cotización. | No es cotización exacta del día de pago. |

---

## 4. Restricciones de fuente

El CSV principal no contiene `cargo`, `funcion`, `concepto`, `linea` ni `categoria`. Cualquier diseño que dependa de esas columnas debe considerarse fuera de alcance en la versión base.

El tratamiento correcto de `concepto` es derivarlo desde:

```text
clasificador_gastos_utf8.csv.objeto_gasto_descripcion
```

Clave de unión:

```text
sample_funcionarios_modelo.objeto_gasto = clasificador_gastos_utf8.objeto_gasto_codigo
```

Nombre recomendado:

```text
concepto_remunerativo
```

---

## 5. Supuestos analíticos

La clasificación de componentes debe realizarse por `objeto_gasto` y por la descripción del clasificador de gastos.

| Componente | Regla inicial |
|---|---|
| `salario_basico` | Sueldos, dietas, jornales, contratación docente o personal contratado. |
| `bonificaciones` | Bonificaciones, gratificaciones, remuneraciones extraordinarias o adicionales. |
| `beneficios` | Subsidios, asignaciones familiares, subsidio para salud. |
| `viaticos` | Pasajes, viáticos y movilidad. |
| `aguinaldo` | Objeto de gasto asociado a aguinaldo. |
| `otros_componentes` | Código válido no incluido en grupos anteriores. |
| `sin_clasificar` | Objeto sin match, por ejemplo código `0`. |

No se recomienda inferir `tipo_funcionario` como docente/administrativo sin `cargo`, `funcion` o fuente externa adicional. En la versión base conviene usar `tipo_registro_funcionario`: nacional, extranjero, vacancia, anónimo/no convencional o no clasificado.

---

## 6. Restricciones de privacidad y ética

Aunque la fuente sea pública, el proyecto debe aplicar minimización de datos:

- evitar exponer nombres, apellidos y documentos completos en dashboards abiertos;
- usar `documento_hash` para consumo académico cuando sea posible;
- analizar discapacidad solo en forma agregada y responsable;
- separar análisis de distribución salarial de identificación individual;
- evitar conclusiones personales no respaldadas.

---

## 7. Riesgos de alcance

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Prometer análisis por cargo o función. | Alto | Declarar que no están disponibles. |
| Inferir docente/administrativo sin base suficiente. | Alto | Usar `NO_DETERMINADO` salvo fuente adicional. |
| Usar cada fila como funcionario único. | Alto | Consolidar por grano OBT. |
| Mezclar vacancias con personas activas. | Alto | Crear `tipo_registro_funcionario`. |
| Interpretar USD como valor exacto de pago. | Medio | Documentar conversión referencial. |
| Publicar datos personales completos. | Alto | Seudonimizar y agregar. |
