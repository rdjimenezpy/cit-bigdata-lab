<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Matriz de fuentes, campos y derivados

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

Este documento mapea las fuentes disponibles contra los campos esperados del modelo analítico. Distingue columnas directas, enriquecimientos externos y campos calculados.

---

## 2. Fuentes disponibles

| Fuente | Rol | Filas observadas | Columnas observadas |
|---|---|---:|---:|
| `sample_funcionarios_modelo.csv` | Fuente principal | 10.000 | 19 |
| `clasificador_gastos_utf8.csv` | Enriquecimiento de `objeto_gasto` | 368 | 9 |
| `clasificador_oee_utf8.csv` | Enriquecimiento institucional | 434 | 11 |
| `regimen_salarial_py_utf8.csv` | Referencia salarial | 20 | 16 |
| `cotizacion_usd_mensual_utf8.csv` | Conversión PYG/USD | 303 | 6 |

---

## 3. Campos directos de la fuente principal

| Campo | Uso recomendado | Observación |
|---|---|---|
| `anho` | periodo | Convertir a integer. |
| `mes` | periodo | Convertir a integer. |
| `nivel` | institución | Clave para OEE. |
| `entidad` | institución | Clave para OEE. |
| `oee` | institución | Clave para OEE. |
| `documento` | identificador operativo | Clasificar tipo de registro; considerar hash. |
| `nombres` | descriptivo sensible | No publicar innecesariamente. |
| `apellidos` | descriptivo sensible | No publicar innecesariamente. |
| `estado` | segmentación | Normalizar texto. |
| `anho_ingreso` | antigüedad | Validar `0` e inconsistencias. |
| `sexo` | segmentación | Normalizar texto. |
| `discapacidad` | segmentación sensible | Usar con cuidado. |
| `tipo_discapacidad` | segmentación sensible | Alta proporción de nulos. |
| `fuente_financiamiento` | presupuesto | Mantener como código. |
| `objeto_gasto` | componente presupuestario | Clave para clasificador de gastos. |
| `presupuestado` | métrica monetaria | Convertir a decimal. |
| `devengado` | métrica monetaria | Convertir a decimal. |
| `fecha_nacimiento` | edad/generación | Convertir a date. |
| `fecha_acto` | fecha administrativa | No confundir con fecha de ingreso. |

---

## 4. Campos no disponibles

| Campo | Estado | Tratamiento correcto |
|---|---|---|
| `cargo` | No disponible | Excluir de OBT base. |
| `funcion` | No disponible | No inferir docente/administrativo desde aquí. |
| `concepto` | No disponible como columna fuente | Derivar desde `clasificador_gastos.objeto_gasto_descripcion`. |
| `linea` | No disponible | Excluir de grano y joins. |
| `categoria` | No disponible | Excluir de grano y joins. |

---

## 5. Enriquecimiento con clasificador de gastos

Clave:

```sql
funcionarios.objeto_gasto = clasificador_gastos.objeto_gasto_codigo
```

| Campo externo | Campo recomendado | Uso |
|---|---|---|
| `grupo_codigo` | `grupo_gasto_codigo` | Clasificación superior. |
| `grupo_descripcion` | `grupo_gasto_descripcion` | Descripción del grupo. |
| `subgrupo_codigo` | `subgrupo_gasto_codigo` | Clasificación intermedia. |
| `subgrupo_descripcion` | `subgrupo_gasto_descripcion` | Descripción del subgrupo. |
| `objeto_gasto_codigo` | `objeto_gasto` | Clave. |
| `objeto_gasto_descripcion` | `concepto_remunerativo` | Concepto presupuestario derivado. |
| `control_financiero_codigo` | `control_financiero_codigo` | Clasificación financiera. |
| `control_financiero_descripcion` | `control_financiero_descripcion` | Descripción financiera. |
| `clasificacion_gasto_descripcion` | `clasificacion_gasto_descripcion` | Clasificación del gasto. |

### Objetos observados en la muestra

| Objeto | Concepto | Componente sugerido |
|---:|---|---|
| 111 | SUELDOS | `SALARIO_BASICO` |
| 112 | DIETAS | `SALARIO_BASICO` |
| 113 | GASTOS DE REPRESENTACIÓN | `GASTOS_REPRESENTACION` |
| 114 | AGUINALDO | `AGUINALDO` |
| 123 | REMUNERACIONES EXTRAORDINARIAS | `BONIFICACIONES` |
| 125 | REMUNERACIÓN ADICIONAL | `BONIFICACIONES` |
| 131 | SUBSIDIO FAMILIAR | `BENEFICIOS` |
| 132 | ESCALAFÓN DOCENTE | `BONIFICACIONES` |
| 133 | BONIFICACIONES Y GRATIFICACIONES | `BONIFICACIONES` |
| 141 | CONTRATACIÓN DE PERSONAL TÉCNICO | `SALARIO_BASICO` / `PERSONAL_CONTRATADO` |
| 142 | CONTRATACIÓN DE PERSONAL DE SALUD | `SALARIO_BASICO` / `PERSONAL_CONTRATADO` |
| 144 | JORNALES | `SALARIO_BASICO` |
| 145 | HONORARIOS PROFESIONALES | `HONORARIOS` |
| 148 | CONTRATACIÓN DE PERSONAL DOCENTE E INSTRUCTORES... | `SALARIO_BASICO`; posible indicador por objeto, no por persona. |
| 191 | SUBSIDIO PARA LA SALUD | `BENEFICIOS` |
| 199 | OTROS GASTOS DE PERSONAL | `OTROS_COMPONENTES` |
| 232 | VIÁTICOS Y MOVILIDAD | `VIATICOS` |
| 841 | BECAS | `TRANSFERENCIAS_BECAS` o excluir del análisis salarial. |
| 0 | Sin match | `SIN_CLASIFICAR` |

---

## 6. Enriquecimiento con OEE

Clave:

```sql
funcionarios.nivel = clasificador_oee.codigo_nivel
funcionarios.entidad = clasificador_oee.codigo_entidad
funcionarios.oee = clasificador_oee.codigo_oee
```

Campos aportados: `descripcion_nivel`, `descripcion_entidad`, `descripcion_oee`, `descripcion_corta`, `uri`.

---

## 7. Enriquecimiento con cotización USD

Clave:

```sql
funcionarios.anho = cotizacion_usd_mensual.anho
funcionarios.mes = cotizacion_usd_mensual.mes
```

Campos derivados: `total_devengado_usd`, `salario_basico_usd`, `bonificaciones_usd`, `beneficios_usd`, `viaticos_usd`.

---

## 8. Enriquecimiento con régimen salarial

Para cada periodo se recomienda tomar el régimen vigente o el último régimen con fecha menor o igual al periodo analizado. Permite derivar `salario_minimo_mensual_gs`, `multiplo_salario_minimo` y `tramo_salario_minimo`.

---

## 9. Campos derivados principales

| Campo | Base | Regla |
|---|---|---|
| `fecha_periodo` | `anho`, `mes` | Primer día del mes. |
| `periodo_yyyy_mm` | `anho`, `mes` | `YYYY-MM`. |
| `edad` | `fecha_nacimiento` | Diferencia contra fecha de referencia. |
| `rango_etario` | `edad` | Bandas etarias. |
| `generacion` | año nacimiento | Gen Z, Millennials, Gen X, Baby Boomers, etc. |
| `antiguedad_anhos` | `anho_ingreso` | `anho - anho_ingreso`, validando anomalías. |
| `tipo_registro_funcionario` | `documento` | Nacional, extranjero, vacancia, anónimo/no convencional. |
| `componente_remunerativo` | `objeto_gasto` | CASE basado en clasificador. |
