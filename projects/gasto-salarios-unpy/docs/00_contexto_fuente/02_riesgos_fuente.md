<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 02 · Riesgos de la fuente

## Proyecto: gasto-salarios-unpy
### Evaluación inicial de riesgos de datos para el modelo analítico de remuneraciones públicas universitarias · Paraguay 2025

**Institución:** Facultad Politécnica · Universidad Nacional de Asunción  
**Dependencia:** Centro de Innovación TIC (PK)  
**Curso:** Introducción a Big Data · Nivel Básico  
**Autor:** Prof. Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py  
**Versión:** 0.1  
**Fecha:** 2026-05-04  
**Ruta sugerida:** `docs/00_contexto_fuente/riesgos_fuente.md`

---

## 1. Propósito

Este documento identifica los principales riesgos técnicos, metodológicos, éticos y analíticos asociados al uso de las fuentes del proyecto **gasto-salarios-unpy**. Su función es anticipar errores que pueden afectar la confiabilidad del pipeline ETL, la calidad del modelo OBT y la interpretación de resultados en herramientas de BI.

---

## 2. Escala de evaluación

| Nivel | Probabilidad | Impacto |
|---|---|---|
| Bajo | Puede ocurrir, pero no es frecuente o afecta pocos registros. | Afecta poco el análisis o es fácil de corregir. |
| Medio | Ocurre de forma visible o afecta una parte relevante de la fuente. | Puede distorsionar métricas o segmentaciones. |
| Alto | Es frecuente, estructural o difícil de detectar sin controles. | Puede invalidar conclusiones, publicar datos sensibles o generar doble conteo. |

---

## 3. Matriz de riesgos principales

| Riesgo | Probabilidad | Impacto | Evidencia observada | Mitigación recomendada |
|---|---|---|---|---|
| Doble conteo por grano incorrecto | Alto | Alto | La fuente contiene varias líneas por funcionario, período y objeto de gasto. | Documentar grano; agregar primero por componente y luego por funcionario-período-OEE. |
| Uso de `oee` sin clave compuesta | Alto | Alto | El clasificador OEE reutiliza códigos entre entidades. | Usar siempre `codigo_nivel + codigo_entidad + codigo_oee`. |
| Exposición de datos personales | Alto | Alto | La fuente contiene `documento`, `nombres`, `apellidos`, sexo, discapacidad y fecha de nacimiento. | Crear `funcionario_hash`; excluir identificadores directos de datasets publicados. |
| Clasificación docente/administrativo débil | Alto | Medio | La muestra no contiene `cargo`, `funcion` ni `concepto`. | Declarar inferencia como limitada; usar fuente completa con cargo/función cuando esté disponible. |
| Antigüedad mal calculada | Alto | Medio | 1.698 registros con `anho_ingreso = 0`. | Calcular antigüedad solo si el año está entre 1900 y el año analizado. |
| Fechas administrativas inválidas | Alto | Medio | `fecha_acto` contiene años inválidos o extremos como `0002` y `4752`. | Aplicar validación de rango y bandera `fecha_acto_valida`. |
| Fecha de nacimiento faltante | Medio | Medio | 138 registros sin `fecha_nacimiento`. | Calcular edad/generación solo si fecha válida; reportar cobertura. |
| Duplicados exactos | Medio | Medio | 17 duplicados exactos en la muestra. | Crear hash de registro y control de duplicados antes de agregación. |
| Objeto de gasto no clasificado | Bajo | Medio | `objeto_gasto = 0` aparece en la muestra y no está en el clasificador. | Marcar como `NO_CLASIFICADO`; revisar origen antes de excluir. |
| Conversión USD ambigua | Medio | Medio | La fuente de cotización contiene `cotizacion` genérica. | Documentar definición de cotización; mantener fecha de cierre y período. |
| Régimen salarial no mensual completo | Medio | Medio | Régimen salarial tiene cambios históricos, no una fila por cada mes. | Aplicar último régimen conocido vigente al período. |
| Interpretación de devengado cero | Medio | Bajo | 239 registros con `devengado = 0`. | No eliminar automáticamente; clasificar según regla de negocio. |
| Outliers salariales mal interpretados | Alto | Medio | Monto máximo devengado por línea observado: 28.428.343 Gs. | Analizar por total mensual y por componente; usar mediana, percentiles e IQR. |
| Nulidad en `tipo_discapacidad` mal interpretada | Alto | Medio | 9.968 nulos; esperado cuando `discapacidad = NO`. | Evaluar junto con `discapacidad`; no tratar todo nulo como error. |
| Versionado de CSV reales en GitHub | Medio | Alto | El proyecto académico usa datos públicos, pero con PII. | Mantener CSV en `.gitignore`; versionar scripts, docs y muestras anonimizadas. |

---

## 4. Riesgos técnicos por capa

### 4.1. Capa RAW

| Riesgo | Descripción | Control sugerido |
|---|---|---|
| Cambio de delimitador | Los archivos no usan todos el mismo delimitador: funcionarios, OEE, régimen y cotización usan coma; gastos usa punto y coma. | Declarar delimitador por archivo en scripts de ingesta. |
| Cambio de esquema | Nuevas columnas o cambios de nombre pueden romper SQL aguas abajo. | Ejecutar `DESCRIBE`, comparar columnas esperadas y registrar diferencias. |
| Codificación inconsistente | Los archivos revisados son UTF-8/ASCII, pero la descarga mensual puede variar. | Validar codificación y convertir a UTF-8 antes de mover a `raw`. |
| Archivos incompletos | Descargas interrumpidas o HTML en lugar de CSV. | Validar MIME, tamaño mínimo, cabecera y cantidad de columnas. |

### 4.2. Capa STAGING

| Riesgo | Descripción | Control sugerido |
|---|---|---|
| Tipado incorrecto de documento | Convertir `documento` a entero puede perder ceros o formato. | Mantener como `VARCHAR`. |
| Fechas no parseables | `fecha_acto` contiene años inválidos o fuera de rango. | Usar `TRY_STRPTIME` y bandera de calidad. |
| Montos con formato variable | Separadores de miles o símbolos pueden afectar conversión. | Usar macro defensiva de conversión monetaria. |
| Normalización excesiva | Remover tildes en textos de presentación puede degradar nombres institucionales. | Separar columna normalizada para join y columna original para presentación. |

### 4.3. Capa CORE

| Riesgo | Descripción | Control sugerido |
|---|---|---|
| Join institucional incorrecto | Unir solo por OEE genera asignaciones erróneas. | Unir por `nivel`, `entidad` y `oee`. |
| Join de objeto de gasto incompleto | Códigos sin clasificador quedan sin descripción. | Crear categoría `NO_CLASIFICADO` y reporte de códigos faltantes. |
| Régimen salarial mal aplicado | Tomar solo el régimen 2025 puede distorsionar meses previos a julio. | Usar último régimen con `fecha_regimen <= fecha_periodo`. |
| Conversión USD sin cotización | Meses sin cotización dejan montos nulos en USD. | Validar cobertura mensual antes de construir datamart. |

### 4.4. Capa DATAMART

| Riesgo | Descripción | Control sugerido |
|---|---|---|
| OBT demasiado ancha sin documentación | Muchas columnas calculadas pueden ser mal usadas por estudiantes o BI. | Documentar campos derivados y reglas de cálculo. |
| Publicación de PII | La OBT puede contener nombres y documentos. | Crear versión pública anonimizada. |
| Métricas no aditivas mal agregadas | Percentiles, rankings y ratios no deben sumarse. | Marcar métricas como aditivas, semi-aditivas o no aditivas. |
| Categoría salarial arbitraria | Alta/media/baja puede ser subjetiva. | Definir umbrales por percentil o salario mínimo y documentarlos. |

---

## 5. Riesgos metodológicos críticos

### 5.1. Confundir línea remunerativa con funcionario

El principal riesgo analítico es asumir que cada fila representa un funcionario. No es así. La fuente contiene líneas por componente presupuestario. Si se cuentan filas como personas, los resultados de cantidad de funcionarios, ranking y distribución salarial serán incorrectos.

**Regla recomendada:** contar funcionarios con `COUNT(DISTINCT documento)` y remuneraciones con agregaciones por período e institución.

### 5.2. Confundir sueldo base con remuneración total

`objeto_gasto = 111` representa sueldos, pero la remuneración total puede incluir aguinaldo, bonificaciones, beneficios, subsidios, viáticos y contrataciones. El análisis debe separar:

- sueldo base;
- remuneraciones complementarias;
- bonificaciones;
- beneficios;
- viáticos;
- otros conceptos.

### 5.3. Tratar inferencias como datos oficiales

La clasificación `docente`, `administrativo` u `otro` puede inferirse parcialmente con objetos de gasto como `132` o `148`, pero eso no equivale a una clasificación oficial del funcionario. Si se dispone de fuente completa con `cargo` o `funcion`, debe usarse para mejorar la regla.

### 5.4. Publicar información sensible sin anonimización

Aunque la fuente sea pública, el proyecto académico no debe reproducir innecesariamente identificadores personales. El cruce con edad, sexo, discapacidad, institución y remuneración aumenta el riesgo de identificación y exposición.

---

## 6. Validaciones SQL recomendadas

Estas consultas deben incorporarse o reflejarse en `sql/05_quality/06_data_quality_checks.sql`.

### 6.1. Duplicados exactos o por clave funcional

```sql
SELECT
    anho,
    mes,
    codigo_nivel,
    codigo_entidad,
    codigo_oee,
    cedula_identidad,
    objeto_gasto,
    fuente_financiamiento,
    presupuestado_gs,
    devengado_gs,
    COUNT(*) AS registros
FROM staging.funcionarios_modelo
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY registros DESC;
```

### 6.2. Fechas de nacimiento inválidas

```sql
SELECT *
FROM staging.funcionarios_modelo
WHERE fecha_nacimiento IS NULL
   OR fecha_nacimiento < DATE '1900-01-01'
   OR fecha_nacimiento > fecha_periodo;
```

### 6.3. Fechas de acto inválidas

```sql
SELECT *
FROM staging.funcionarios_modelo
WHERE fecha_acto IS NULL
   OR fecha_acto < DATE '1900-01-01'
   OR fecha_acto > DATE '2026-12-31';
```

### 6.4. Antigüedad no calculable

```sql
SELECT *
FROM staging.funcionarios_modelo
WHERE anho_ingreso IS NULL
   OR anho_ingreso = 0
   OR anho_ingreso < 1900
   OR anho_ingreso > anho;
```

### 6.5. Objetos de gasto sin clasificador

```sql
SELECT
    f.objeto_gasto,
    COUNT(*) AS registros,
    SUM(f.devengado_gs) AS devengado_gs
FROM staging.funcionarios_modelo f
LEFT JOIN staging.clasificador_gastos g
       ON f.objeto_gasto = g.objeto_gasto_codigo
WHERE g.objeto_gasto_codigo IS NULL
GROUP BY f.objeto_gasto
ORDER BY registros DESC;
```

### 6.6. Instituciones sin clasificador OEE

```sql
SELECT
    f.codigo_nivel,
    f.codigo_entidad,
    f.codigo_oee,
    COUNT(*) AS registros
FROM staging.funcionarios_modelo f
LEFT JOIN staging.clasificador_oee o
       ON f.codigo_nivel = o.codigo_nivel
      AND f.codigo_entidad = o.codigo_entidad
      AND f.codigo_oee = o.codigo_oee
WHERE o.codigo_oee IS NULL
GROUP BY ALL
ORDER BY registros DESC;
```

### 6.7. Cotización USD faltante

```sql
SELECT
    f.anho,
    f.mes,
    COUNT(*) AS registros
FROM staging.funcionarios_modelo f
LEFT JOIN staging.cotizacion_usd_mensual c
       ON f.anho = c.anho
      AND f.mes = c.mes
WHERE c.cotizacion_usd_promedio IS NULL
GROUP BY f.anho, f.mes
ORDER BY f.anho, f.mes;
```

### 6.8. Outliers por monto devengado

```sql
WITH base AS (
    SELECT
        devengado_gs,
        quantile_cont(devengado_gs, 0.25) OVER () AS q1,
        quantile_cont(devengado_gs, 0.75) OVER () AS q3
    FROM staging.funcionarios_modelo
    WHERE devengado_gs IS NOT NULL
), limites AS (
    SELECT DISTINCT
        q1,
        q3,
        q3 - q1 AS iqr,
        q3 + 1.5 * (q3 - q1) AS limite_superior
    FROM base
)
SELECT f.*
FROM staging.funcionarios_modelo f
CROSS JOIN limites l
WHERE f.devengado_gs > l.limite_superior
ORDER BY f.devengado_gs DESC;
```

---

## 7. Recomendaciones de mitigación para el pipeline

1. **Crear tabla de auditoría de ejecución** con fecha, script, capa, estado y cantidad de registros.
2. **Generar hash de registro** en staging para identificar duplicados y trazabilidad.
3. **Separar OBT interna y OBT publicable**; la versión publicable debe anonimizar persona.
4. **Registrar cobertura mensual** de funcionarios, cotización y régimen salarial antes del datamart.
5. **Mantener una tabla de reglas de componentes salariales** para no codificar la lógica únicamente dentro del SQL.
6. **Crear vistas de calidad** que el estudiante pueda consultar desde DBeaver, DuckDB o Metabase.
7. **No eliminar anomalías automáticamente**; primero marcarlas con banderas de calidad.
8. **Documentar supuestos** directamente en los scripts SQL y en el README.

---

## 8. Riesgos éticos y de comunicación

El proyecto analiza remuneraciones de personas reales. Aunque se trabaje con fuentes públicas, hay riesgo de producir interpretaciones injustas o exposiciones innecesarias. En docencia, debe enfatizarse que el objetivo no es señalar personas, sino estudiar estructuras de gasto, distribución salarial, calidad de datos y diseño de pipelines.

Buenas prácticas mínimas:

- publicar agregados institucionales antes que listados nominales;
- evitar rankings nominales en entregables públicos;
- usar hashes y no cédulas visibles;
- contextualizar outliers antes de calificarlos como irregularidades;
- diferenciar hallazgo exploratorio de conclusión administrativa o legal.

---

## 9. Conclusión

La fuente es útil y suficientemente rica para un proyecto académico de ingeniería de datos, pero no es una fuente trivial. Sus principales riesgos son el grano, la privacidad, la clasificación incompleta de tipo de funcionario y la calidad de fechas/antigüedad. Si se implementan controles de calidad desde `staging`, la OBT puede ser confiable para análisis institucional y salarial. Si se omiten esos controles, el proyecto puede producir métricas erróneas con apariencia de precisión.
