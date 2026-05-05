<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Planificación integral del proyecto de ingeniería de datos

**Proyecto:** `gasto-salarios-unpy`  
**Dominio analítico:** remuneraciones de funcionarios públicos de universidades nacionales de Paraguay  
**Periodo de análisis:** 2025  
**Stack principal:** DuckDB, SQL, Pentaho Data Integration v11, Apache Airflow 3.1.8, Git/GitHub, Power BI/Metabase/Tableau  
**Arquitectura de datos:** RAW → STAGING → CORE → DATAMART → QUALITY  
**Modelo analítico objetivo:** OBT — One Big Table  
**Autor:** Prof. Ing. Richard D. Jiménez-R.  
**Versión:** 1.0  
**Fecha:** 2026-05-04

---

## 1. Propósito del documento

Este documento define la planificación integral del proyecto `gasto-salarios-unpy` desde la perspectiva del ciclo de vida de un proyecto de ingeniería de datos. Su objetivo es establecer una guía formal para organizar, ejecutar, validar, documentar y entregar una solución analítica reproducible sobre remuneraciones de funcionarios públicos de universidades nacionales de Paraguay.

La planificación no se limita a una lista de tareas. Funciona como contrato técnico y metodológico del proyecto: define alcance, fases, entregables, criterios de éxito, riesgos, controles de calidad, responsabilidades, estándares de desarrollo y buenas prácticas necesarias para evitar errores frecuentes en proyectos de datos.

Este documento debe leerse junto con las carpetas previas:

```text
./docs/
├── 00_contexto_fuente/
├── 01_diseno_proyecto/
└── 02_planificacion_proyecto/
```

---

## 2. Resumen ejecutivo del proyecto

El proyecto busca construir una base analítica confiable para estudiar la distribución de remuneraciones de funcionarios públicos de universidades nacionales de Paraguay durante el periodo 2025.

La solución toma como fuente principal el archivo depurado de funcionarios y lo enriquece con clasificadores externos de gastos, instituciones/OEE, cotización USD mensual y régimen salarial. El resultado final será una tabla OBT orientada a explotación analítica en herramientas de BI.

La solución se organiza en capas:

| Capa | Propósito | Resultado principal |
|---|---|---|
| RAW | Preservar la fuente original o semioriginal sin transformaciones fuertes | Tablas fuente en DuckDB |
| STAGING | Normalizar, limpiar, tipar y enriquecer campos descriptivos básicos | `staging.funcionarios_modelo_ext` |
| CORE | Construir entidades analíticas consistentes y métricas derivadas | Hechos y dimensiones analíticas |
| DATAMART | Exponer la OBT y vistas agregadas para BI | `datamart.obt_remuneraciones_funcionarios_publicos` |
| QUALITY | Auditar calidad, consistencia y completitud | `dq.resultados_checks` y vistas de control |

---

## 3. Alcance del proyecto

### 3.1 Alcance incluido

El proyecto incluye:

1. Ingesta controlada de archivos CSV a DuckDB.
2. Normalización de nombres de columnas y tipos de datos.
3. Enriquecimiento desde fuentes externas:
   - clasificador de gastos;
   - clasificador OEE;
   - cotización USD mensual;
   - régimen salarial paraguayo.
4. Construcción de una capa CORE con granularidad analítica clara.
5. Construcción de una tabla OBT para consumo en BI.
6. Construcción de vistas agregadas para exploración inicial.
7. Implementación de controles de calidad de datos.
8. Documentación técnica del contexto, diseño, planificación y ejecución.
9. Organización de scripts SQL por capas.
10. Preparación conceptual del flujo ETL con Pentaho Data Integration y orquestación futura con Airflow.

### 3.2 Alcance excluido en esta fase

Quedan fuera del alcance inicial:

1. Construcción de dashboards finales en Power BI, Metabase o Tableau.
2. Implementación completa de DAGs de Airflow en producción.
3. Automatización de descarga desde portales públicos si no existe fuente estable.
4. Corrección manual de datos fuente inconsistentes.
5. Clasificación laboral definitiva docente/administrativo si no existe una columna fuente confiable.
6. Análisis legal o jurídico sobre remuneraciones públicas.
7. Predicción salarial o modelos de machine learning.
8. Anonimización irreversible, salvo que se defina como requisito explícito en una fase posterior.

---

## 4. Premisas técnicas del proyecto

### 4.1 Premisas sobre la fuente principal

La fuente principal del modelo no contiene las columnas:

- `cargo`
- `funcion`
- `concepto`
- `linea`
- `categoria`

Por tanto, estas columnas no deben ser asumidas como disponibles en `raw.funcionarios_modelo_src` ni en las capas posteriores.

La fuente principal sí contiene `objeto_gasto`, que permite enriquecer el registro con la descripción del concepto remunerativo desde `raw.clasificador_gastos_src`.

### 4.2 Premisas sobre enriquecimiento

El campo equivalente a concepto remunerativo se obtiene mediante:

```text
raw.funcionarios_modelo_src.objeto_gasto
        → raw.clasificador_gastos_src.objeto_gasto
        → raw.clasificador_gastos_src.objeto_gasto_descripcion
```

Las descripciones de nivel, entidad y OEE se obtienen desde:

```text
raw.funcionarios_modelo_src.nivel
raw.funcionarios_modelo_src.entidad
raw.funcionarios_modelo_src.oee
        → raw.clasificador_oee_src
```

### 4.3 Premisas sobre clasificación laboral

La clasificación `docente`, `administrativo` u `otro` no puede considerarse definitiva si se deriva únicamente de `objeto_gasto` o de la descripción del gasto. Puede utilizarse como indicador inferido, pero debe quedar documentado como inferencia débil.

Una clasificación laboral robusta requeriría una fuente adicional con cargo, función, escalafón, categoría ocupacional o estructura de puestos.

---

## 5. Ciclo de vida propuesto del proyecto de ingeniería de datos

El proyecto se organiza siguiendo un ciclo de vida de ingeniería de datos orientado a producción analítica.

```text
1. Comprensión del problema
2. Comprensión de fuentes
3. Diseño de arquitectura y modelo analítico
4. Preparación del entorno
5. Ingesta RAW
6. Limpieza y normalización STAGING
7. Modelado CORE
8. Construcción DATAMART
9. Calidad, auditoría y reconciliación
10. Explotación analítica y BI
11. Orquestación y automatización
12. Documentación, entrega y mejora continua
```

---

## 6. Fase 0 — Comprensión del problema

### 6.1 Objetivo

Definir el problema analítico, las preguntas de negocio/dominio y las métricas necesarias para responderlas.

### 6.2 Preguntas analíticas principales

1. ¿Cómo se distribuyen las remuneraciones por universidad/OEE?
2. ¿Qué instituciones concentran mayor masa salarial?
3. ¿Cuáles son los principales componentes remunerativos?
4. ¿Qué proporción corresponde a salario básico, bonificaciones, viáticos y otros componentes?
5. ¿Existen brechas relevantes por sexo, edad, antigüedad o régimen salarial?
6. ¿Qué objetos de gasto concentran mayor presupuesto remunerativo?
7. ¿Qué funcionarios o grupos aparecen en percentiles salariales superiores?
8. ¿Cómo varía la remuneración total en PYG y USD?
9. ¿Qué registros presentan posibles anomalías, duplicidades o importes extremos?

### 6.3 Entregables

| Entregable | Ubicación |
|---|---|
| Definición del problema | `docs/01_diseno_proyecto/01_fase_0_definicion_problema.md` |
| Alcance, supuestos y restricciones | `docs/01_diseno_proyecto/02_alcance_supuestos_restricciones.md` |
| Riesgos de fuente | `docs/00_contexto_fuente/riesgos_fuente.md` |

### 6.4 Criterios de éxito

- Las preguntas analíticas están explícitas.
- Las métricas necesarias están identificadas.
- Las restricciones de la fuente están documentadas.
- No se prometen segmentaciones que no son soportadas por los datos.

---

## 7. Fase 1 — Comprensión y perfilamiento de fuentes

### 7.1 Objetivo

Conocer estructura, granularidad, tipos de datos, campos críticos, problemas de calidad y reglas de unión entre fuentes.

### 7.2 Fuentes consideradas

| Fuente | Uso en el proyecto | Criticidad |
|---|---|---|
| `sample_funcionarios_modelo.csv` | Fuente principal depurada para modelado | Alta |
| `clasificador_gastos_utf8.csv` | Descripción de objeto de gasto/concepto remunerativo | Alta |
| `clasificador_oee_utf8.csv` | Descripciones de nivel, entidad y OEE | Alta |
| `cotizacion_usd_mensual_utf8.csv` | Conversión mensual PYG → USD | Media |
| `regimen_salarial_py_utf8.csv` | Enriquecimiento de régimen salarial | Media |

### 7.3 Actividades técnicas

1. Verificar encoding UTF-8.
2. Validar separadores y cabeceras.
3. Describir columnas con DuckDB.
4. Calcular conteos de registros.
5. Identificar claves candidatas.
6. Detectar campos obligatorios.
7. Evaluar duplicados.
8. Evaluar valores nulos.
9. Identificar rangos válidos de fechas e importes.
10. Documentar restricciones.

### 7.4 Consultas recomendadas de exploración

```sql
DESCRIBE SELECT * FROM read_csv_auto('data/raw/sample_funcionarios_modelo.csv');

SELECT *
FROM read_csv_auto('data/raw/sample_funcionarios_modelo.csv')
LIMIT 10;

SUMMARIZE SELECT *
FROM read_csv_auto('data/raw/sample_funcionarios_modelo.csv');
```

### 7.5 Entregables

| Entregable | Ubicación |
|---|---|
| Diccionario de datos | `docs/00_contexto_fuente/00_diccionario_datos.md` |
| Resumen de fuente | `docs/00_contexto_fuente/01_resumen_fuente.md` |
| Riesgos de fuente | `docs/00_contexto_fuente/riesgos_fuente.md` |

### 7.6 Criterios de éxito

- Cada fuente tiene propósito documentado.
- Cada campo crítico tiene uso esperado.
- Las claves de unión están identificadas.
- Se conocen las limitaciones de clasificación.

---

## 8. Fase 2 — Diseño de arquitectura y modelo analítico

### 8.1 Objetivo

Diseñar una arquitectura mantenible por capas y un modelo analítico OBT alineado a las preguntas del proyecto.

### 8.2 Arquitectura lógica

```text
CSV UTF-8
   ↓
Pentaho Data Integration v11
   ↓
DuckDB RAW
   ↓
SQL STAGING
   ↓
SQL CORE
   ↓
SQL DATAMART
   ↓
BI / notebooks / análisis exploratorio
   ↓
Data Quality / auditoría / mejora continua
```

### 8.3 Principios de arquitectura

1. **Separación de responsabilidades:** cada capa tiene un propósito claro.
2. **Trazabilidad:** las transformaciones deben poder rastrearse desde DATAMART hasta RAW.
3. **Reproducibilidad:** el proyecto debe poder ejecutarse desde cero.
4. **SQL primero:** las reglas de negocio se implementan principalmente en SQL.
5. **Transformaciones declarativas:** evitar lógica oculta en herramientas visuales cuando pueda expresarse en SQL.
6. **Calidad incorporada:** los controles de calidad no son una etapa opcional.
7. **Documentación viva:** cada decisión técnica debe quedar registrada.

### 8.4 Modelo OBT

El modelo final se orienta a una tabla ancha para consumo analítico:

```text
datamart.obt_remuneraciones_funcionarios_publicos
```

La OBT debe contener:

- claves de periodo;
- atributos de institución/OEE;
- atributos demográficos;
- métricas salariales en PYG;
- métricas salariales en USD;
- ratios de composición salarial;
- percentiles y rankings;
- rangos de edad y antigüedad;
- indicadores de calidad o completitud cuando corresponda.

### 8.5 Entregables

| Entregable | Ubicación |
|---|---|
| Arquitectura de datos | `docs/01_diseno_proyecto/03_arquitectura_datos_pipeline.md` |
| Diseño OBT | `docs/01_diseno_proyecto/04_diseno_modelo_obt.md` |
| Matriz de fuentes y campos derivados | `docs/01_diseno_proyecto/05_matriz_fuentes_campos_derivados.md` |
| Decisiones de modelado | `docs/01_diseno_proyecto/06_decisiones_modelado.md` |

### 8.6 Criterios de éxito

- La arquitectura está documentada.
- El grano de las tablas CORE y DATAMART está definido.
- Las reglas de derivación están explícitas.
- Los campos no disponibles no se simulan como datos reales.

---

## 9. Fase 3 — Preparación del entorno

### 9.1 Objetivo

Preparar el entorno local de trabajo para ejecutar el pipeline de forma reproducible.

### 9.2 Componentes mínimos

| Componente | Uso |
|---|---|
| Git | Control de versiones |
| DuckDB CLI | Motor analítico local |
| DBeaver Community | Cliente SQL opcional |
| Pentaho Data Integration v11 | Ingesta visual/ETL |
| Python | Automatización auxiliar opcional |
| Apache Airflow 3.1.8 | Orquestación futura |
| VS Code / PyCharm | Edición de scripts |

### 9.3 Estructura recomendada del repositorio

```text
gasto-salarios-unpy/
├── data/
│   ├── raw/
│   ├── temp/
│   ├── processed/
│   └── exports/
├── docs/
│   ├── 00_contexto_fuente/
│   ├── 01_diseno_proyecto/
│   └── 02_planificacion_proyecto/
├── sql/
│   ├── 00_setup/
│   ├── 01_raw/
│   ├── 02_staging/
│   ├── 03_core/
│   ├── 04_datamart/
│   └── 05_quality/
├── etl/
│   └── pentaho/
├── orchestration/
│   └── airflow/
├── notebooks/
├── reports/
├── tests/
└── README.md
```

### 9.4 Buenas prácticas de entorno

1. Usar rutas relativas cuando sea posible.
2. No versionar archivos pesados innecesarios.
3. No subir datos sensibles si no corresponde.
4. Versionar scripts SQL y documentación.
5. Mantener convenciones de nombres estables.
6. Validar que los scripts puedan ejecutarse desde cero.

### 9.5 Criterios de éxito

- El proyecto puede clonarse y ejecutarse localmente.
- La estructura de carpetas es consistente.
- Los scripts están separados por capa.
- Las rutas de datos están documentadas.

---

## 10. Fase 4 — Ingesta RAW

### 10.1 Objetivo

Cargar las fuentes CSV en DuckDB preservando el contenido original tanto como sea razonable.

### 10.2 Scripts involucrados

```text
sql/00_setup/00_create_schemas.sql
sql/01_raw/01_raw_ingesta.sql
```

### 10.3 Tablas RAW esperadas

| Tabla | Propósito |
|---|---|
| `raw.funcionarios_modelo_src` | Fuente principal del modelo |
| `raw.clasificador_gastos_src` | Clasificador de gastos |
| `raw.clasificador_oee_src` | Clasificador institucional/OEE |
| `raw.cotizacion_usd_mensual_src` | Cotización mensual USD |
| `raw.regimen_salarial_py_src` | Régimen salarial |

### 10.4 Buenas prácticas RAW

1. Evitar transformaciones de negocio en RAW.
2. Conservar nombres y valores originales cuando sea útil para auditoría.
3. Agregar metadatos mínimos de carga si aplica.
4. Mantener conteos de registros por fuente.
5. Validar encoding, delimitador y cabecera.

### 10.5 Criterios de éxito

- Las tablas RAW existen.
- Los conteos coinciden con los archivos fuente.
- Las columnas críticas están presentes.
- La carga puede repetirse sin estados corruptos.

---

## 11. Fase 5 — Limpieza y normalización STAGING

### 11.1 Objetivo

Preparar fuentes limpias, tipadas y enriquecidas para el modelado analítico.

### 11.2 Script principal

```text
sql/02_staging/02_staging_limpieza.sql
```

### 11.3 Salida principal

```text
staging.funcionarios_modelo_ext
```

### 11.4 Transformaciones esperadas

1. Normalización de textos.
2. Conversión segura de importes.
3. Conversión de fechas.
4. Estandarización de campos categóricos.
5. Enriquecimiento con descripción de objeto de gasto.
6. Enriquecimiento con descripción de nivel, entidad y OEE.
7. Incorporación de cotización USD mensual.
8. Incorporación de régimen salarial mensual.
9. Generación de campos técnicos.
10. Identificación de registros potencialmente problemáticos.

### 11.5 Buenas prácticas STAGING

1. Usar `TRY_CAST` o mecanismos equivalentes para evitar fallas por datos sucios.
2. No descartar registros sin documentar la regla.
3. Mantener campos originales relevantes cuando ayuden a trazabilidad.
4. Separar limpieza técnica de reglas analíticas complejas.
5. Documentar nulos esperados versus nulos problemáticos.

### 11.6 Criterios de éxito

- Los campos numéricos son utilizables.
- Los campos de fecha son consistentes.
- Las uniones con clasificadores están evaluadas.
- Los campos derivados no introducen categorías falsas.

---

## 12. Fase 6 — Modelado CORE

### 12.1 Objetivo

Construir entidades analíticas limpias, consistentes y reutilizables para el datamart.

### 12.2 Script principal

```text
sql/03_core/03_core_modelo.sql
```

### 12.3 Tablas principales esperadas

| Tabla | Grano | Propósito |
|---|---|---|
| `core.fact_remuneraciones_componentes` | Funcionario/OEE/periodo/objeto_gasto | Detalle de componentes remunerativos |
| `core.fact_remuneraciones_funcionario_mes` | Funcionario/OEE/periodo | Consolidación mensual por funcionario |
| `core.dim_periodo_mensual` | Mes | Dimensión temporal |
| `core.dim_institucion_oee` | Nivel/entidad/OEE | Dimensión institucional |
| `core.dim_clasificador_gasto` | Objeto de gasto | Dimensión de concepto remunerativo |

### 12.4 Métricas derivadas esperadas

1. Remuneración total PYG.
2. Remuneración total USD.
3. Salario básico.
4. Bonificaciones.
5. Beneficios.
6. Viáticos.
7. Otros componentes.
8. Ratios de composición salarial.
9. Edad.
10. Rango etario.
11. Antigüedad.
12. Rango de antigüedad.
13. Generación.
14. Percentiles salariales.
15. Rankings por institución.
16. Brechas contra promedio y mediana institucional.

### 12.5 Buenas prácticas CORE

1. Declarar el grano de cada tabla.
2. Evitar mezclar detalle y agregado sin control.
3. Usar claves de negocio limpias.
4. No depender de orden físico de datos.
5. Documentar reglas de clasificación de componentes.
6. Validar que las sumas de componentes coincidan con totales consolidados.

### 12.6 Criterios de éxito

- Las tablas CORE son coherentes entre sí.
- La suma de componentes explica el total mensual.
- Las dimensiones enriquecen sin duplicar registros incorrectamente.
- Los campos inferidos están marcados como inferidos.

---

## 13. Fase 7 — Construcción DATAMART

### 13.1 Objetivo

Construir la capa de consumo analítico para BI y análisis exploratorio.

### 13.2 Scripts principales

```text
sql/04_datamart/04_datamart_obt.sql
sql/04_datamart/05_datamart_agregados.sql
```

### 13.3 Tablas y vistas principales

| Objeto | Propósito |
|---|---|
| `datamart.obt_remuneraciones_funcionarios_publicos` | Tabla principal de análisis BI |
| `datamart.det_remuneraciones_componentes_bi` | Detalle de componentes para análisis desagregado |
| Vistas agregadas por OEE | Análisis institucional |
| Vistas por sexo, edad, generación y antigüedad | Segmentación demográfica |
| Vistas por componente y objeto de gasto | Composición remunerativa |
| Vistas de brecha salarial | Comparación relativa |
| Vistas de control | Auditoría de consistencia |

### 13.4 Buenas prácticas DATAMART

1. Diseñar para lectura y consumo, no para captura transaccional.
2. Mantener nombres claros y orientados al analista.
3. Incluir métricas listas para dashboard.
4. Evitar columnas ambiguas.
5. Exponer campos de calidad cuando ayuden a interpretación.
6. No ocultar limitaciones metodológicas.

### 13.5 Criterios de éxito

- La OBT responde las preguntas analíticas principales.
- Las vistas agregadas evitan consultas repetitivas.
- Los dashboards pueden conectarse sin lógica excesiva adicional.
- Las métricas PYG y USD están disponibles.

---

## 14. Fase 8 — Calidad, auditoría y reconciliación

### 14.1 Objetivo

Garantizar que los datos transformados sean completos, consistentes, trazables y adecuados para análisis.

### 14.2 Script principal

```text
sql/05_quality/06_data_quality_checks.sql
```

### 14.3 Categorías de validación

| Categoría | Ejemplos de controles |
|---|---|
| Estructura | existencia de tablas, columnas esperadas |
| Volumen | conteos por capa |
| Completitud | nulos en campos críticos |
| Validez | fechas inválidas, importes negativos |
| Consistencia | total OBT vs suma de componentes |
| Enriquecimiento | faltantes en clasificadores |
| Duplicidad | duplicados por grano esperado |
| Outliers | remuneraciones extremas por IQR |
| Trazabilidad | fuente y fecha de carga |

### 14.4 Reglas críticas de calidad

1. `objeto_gasto` debe existir para derivar concepto remunerativo.
2. `nivel`, `entidad` y `oee` deben permitir descripción institucional.
3. Los importes salariales no deberían ser negativos salvo justificación.
4. La suma de componentes debe reconciliar contra el total consolidado.
5. Los registros sin cotización USD deben quedar marcados.
6. Los registros sin régimen salarial deben quedar marcados, no eliminados automáticamente.
7. Las columnas no disponibles por diseño no deben contarse como error.

### 14.5 Buenas prácticas QUALITY

1. Guardar resultados de checks en tablas auditables.
2. Clasificar severidad: crítica, alta, media, baja, informativa.
3. Diferenciar error técnico, riesgo metodológico y limitación de fuente.
4. Automatizar la ejecución de calidad después de cada corrida.
5. Fallar el pipeline si hay errores críticos.
6. Permitir advertencias si los hallazgos son explicables.

### 14.6 Criterios de éxito

- Existen resultados consolidados de calidad.
- Los errores críticos son visibles.
- La calidad puede medirse por corrida.
- Los checks se ejecutan de forma reproducible.

---

## 15. Fase 9 — Explotación analítica y BI

### 15.1 Objetivo

Permitir el consumo confiable de datos por analistas, docentes, estudiantes o usuarios de negocio.

### 15.2 Herramientas objetivo

- Power BI
- Metabase
- Tableau
- DBeaver
- DuckDB CLI
- Notebooks Python/R

### 15.3 Tablas recomendadas para BI

| Objeto | Uso recomendado |
|---|---|
| `datamart.obt_remuneraciones_funcionarios_publicos` | Dashboard principal |
| `datamart.det_remuneraciones_componentes_bi` | Drill-down por componente |
| Agregados institucionales | Vistas resumen |
| Agregados por componente | Composición salarial |
| Vistas de brecha | Análisis comparativo |

### 15.4 Buenas prácticas BI

1. No recalcular reglas complejas en el dashboard si ya existen en SQL.
2. Mantener medidas certificadas.
3. Documentar definiciones de métricas.
4. Mostrar advertencias metodológicas cuando aplique.
5. Evitar rankings sin contexto de tamaño institucional.
6. Diferenciar remuneración mensual, anualizada y acumulada si se incorporan más periodos.

### 15.5 Criterios de éxito

- Los usuarios pueden navegar por institución, sexo, edad, generación, antigüedad y componente.
- Las métricas son consistentes con SQL.
- Los dashboards no dependen de transformaciones ocultas.

---

## 16. Fase 10 — Orquestación y automatización

### 16.1 Objetivo

Preparar la automatización del flujo completo mediante Apache Airflow 3.1.8.

### 16.2 Flujo sugerido del DAG

```text
start
  ↓
validar_archivos_fuente
  ↓
ingestar_raw_con_pentaho_o_sql
  ↓
ejecutar_staging_limpieza
  ↓
ejecutar_core_modelo
  ↓
ejecutar_datamart_obt
  ↓
ejecutar_datamart_agregados
  ↓
ejecutar_quality_checks
  ↓
publicar_resultados
  ↓
end
```

### 16.3 Reglas de ejecución

1. Cada script debe ser idempotente o controlado.
2. La capa siguiente no debe ejecutarse si falla la anterior.
3. Los checks críticos deben detener la publicación.
4. La corrida debe registrar fecha, duración y estado.
5. Los logs deben conservar errores SQL completos.

### 16.4 Buenas prácticas Airflow

1. Separar configuración de lógica.
2. Usar conexiones y variables para rutas.
3. Evitar rutas absolutas rígidas en DAGs.
4. Registrar artefactos generados.
5. Definir reintentos razonables.
6. No ocultar errores con capturas genéricas.

### 16.5 Criterios de éxito

- El pipeline puede ejecutarse de punta a punta.
- Los errores quedan registrados.
- Las dependencias entre tareas están claras.
- La publicación depende de la calidad de datos.

---

## 17. Fase 11 — Documentación, entrega y mejora continua

### 17.1 Objetivo

Consolidar el conocimiento del proyecto para que pueda ser entendido, auditado, mantenido y extendido.

### 17.2 Documentación mínima requerida

| Documento | Ubicación |
|---|---|
| README principal | `README.md` |
| Contexto de fuente | `docs/00_contexto_fuente/` |
| Diseño del proyecto | `docs/01_diseno_proyecto/` |
| Planificación integral | `docs/02_planificacion_proyecto/` |
| Diccionario OBT | `docs/03_diccionario_modelo/` |
| Guía de ejecución | `docs/04_operacion_pipeline/` |
| Informe de calidad | `docs/05_calidad_datos/` |
| Guía BI | `docs/06_consumo_analitico/` |

### 17.3 Buenas prácticas de documentación

1. Documentar decisiones, no solo resultados.
2. Mantener trazabilidad entre SQL y documentación.
3. Usar ejemplos de consultas.
4. Registrar limitaciones conocidas.
5. Actualizar documentación al cambiar scripts.
6. Incluir fecha y versión en documentos clave.

### 17.4 Criterios de éxito

- Una persona externa puede entender el proyecto.
- Los supuestos son explícitos.
- Los scripts tienen documentación asociada.
- Las limitaciones no están ocultas.

---

## 18. Plan de trabajo sugerido

### 18.1 Plan por fases

| Fase | Nombre | Estado esperado | Entregable principal |
|---|---|---|---|
| 0 | Comprensión del problema | Completado | Definición analítica |
| 1 | Comprensión de fuentes | Completado | Diccionario y riesgos |
| 2 | Diseño del proyecto | Completado | Arquitectura y OBT |
| 3 | Setup/RAW | Completado | `00_create_schemas.sql`, `01_raw_ingesta.sql` |
| 4 | STAGING | Implementado | `02_staging_limpieza.sql` |
| 5 | CORE | Implementado | `03_core_modelo.sql` |
| 6 | DATAMART | Implementado | `04_datamart_obt.sql`, `05_datamart_agregados.sql` |
| 7 | QUALITY | Implementado | `06_data_quality_checks.sql` |
| 8 | Operación | Pendiente | guía de ejecución end-to-end |
| 9 | BI | Pendiente | modelo semántico/dashboard |
| 10 | Airflow | Pendiente | DAG de orquestación |
| 11 | Cierre | Pendiente | informe técnico final |

### 18.2 Secuencia de ejecución técnica

```bash
# Desde la raíz del repositorio

duckdb data/gasto_salarios_unpy.duckdb < sql/00_setup/00_create_schemas.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/01_raw/01_raw_ingesta.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/02_staging/02_staging_limpieza.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/03_core/03_core_modelo.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/04_datamart/04_datamart_obt.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/04_datamart/05_datamart_agregados.sql
duckdb data/gasto_salarios_unpy.duckdb < sql/05_quality/06_data_quality_checks.sql
```

---

## 19. Criterios de aceptación del proyecto

### 19.1 Criterios técnicos

El proyecto puede considerarse técnicamente aceptable si:

1. Todos los scripts SQL se ejecutan sin errores desde una base vacía.
2. Las tablas RAW, STAGING, CORE, DATAMART y DQ se crean correctamente.
3. La OBT contiene registros consistentes con CORE.
4. La suma de componentes reconcilia con el total consolidado.
5. No existen duplicados críticos por grano esperado.
6. Los enriquecimientos desde clasificadores están controlados.
7. Las vistas agregadas responden consultas analíticas relevantes.
8. Los checks de calidad generan resultados interpretables.

### 19.2 Criterios analíticos

El proyecto puede considerarse analíticamente aceptable si permite responder:

1. remuneración total por OEE;
2. masa salarial por universidad;
3. composición de remuneración por componente;
4. distribución por sexo, edad, generación y antigüedad;
5. ranking salarial institucional;
6. brecha contra promedio y mediana;
7. análisis en PYG y USD;
8. detección preliminar de outliers.

### 19.3 Criterios metodológicos

El proyecto puede considerarse metodológicamente aceptable si:

1. no inventa dimensiones no disponibles;
2. documenta inferencias débiles;
3. diferencia datos fuente, datos derivados y datos enriquecidos;
4. conserva trazabilidad entre capas;
5. deja explícitas las limitaciones de fuente.

---

## 20. Matriz de responsabilidades sugerida

| Rol | Responsabilidades |
|---|---|
| Data Engineer | Ingesta, SQL, modelado, optimización, calidad técnica |
| Data Architect | Arquitectura por capas, convenciones, decisiones de modelado |
| Data Analyst / BI | Validación de métricas, dashboards, interpretación |
| Domain Expert | Validación de reglas salariales y conceptos remunerativos |
| Data Steward | Definición de calidad, linaje y gobierno |
| Instructor / Docente | Adaptación pedagógica, evaluación y guía de estudiantes |
| Estudiante / Practicante | Ejecución del laboratorio, análisis y documentación de hallazgos |

---

## 21. Buenas prácticas críticas para garantizar el éxito

### 21.1 Buenas prácticas de modelado

1. Declarar el grano antes de crear una tabla.
2. No mezclar granularidades sin una regla explícita.
3. No crear dimensiones falsas para satisfacer un dashboard.
4. Mantener métricas aditivas separadas de ratios.
5. Documentar toda inferencia.
6. Evitar lógica duplicada entre SQL y BI.

### 21.2 Buenas prácticas de SQL

1. Usar nombres en minúsculas y `snake_case`.
2. Separar scripts por capa.
3. Usar comentarios en bloques complejos.
4. Preferir `CREATE OR REPLACE` en desarrollo.
5. Validar resultados intermedios.
6. Evitar `SELECT *` en modelos finales.
7. Usar `TRY_CAST` cuando la fuente no sea confiable.
8. Controlar nulos de forma explícita.

### 21.3 Buenas prácticas de calidad de datos

1. Ejecutar controles después de cada capa.
2. No eliminar registros problemáticos sin trazabilidad.
3. Clasificar severidad de hallazgos.
4. Registrar métricas de calidad por corrida.
5. Mantener checks automatizables.
6. Validar consistencia de agregaciones.

### 21.4 Buenas prácticas de ingeniería

1. Versionar scripts y documentación.
2. Mantener una rama estable.
3. Usar commits pequeños y descriptivos.
4. Evitar cambios manuales no reproducibles.
5. Crear una guía de ejecución desde cero.
6. Preparar pruebas antes de publicar resultados.

### 21.5 Buenas prácticas docentes

1. Explicar al estudiante por qué se separan capas.
2. Mostrar errores reales de datos, no solo casos limpios.
3. Usar la calidad de datos como parte del aprendizaje.
4. Pedir interpretación, no solo ejecución de SQL.
5. Evaluar reproducibilidad.
6. Exigir reflexión sobre limitaciones de la fuente.

---

## 22. Riesgos del proyecto y mitigaciones

| Riesgo | Impacto | Probabilidad | Mitigación |
|---|---:|---:|---|
| Ausencia de `cargo` y `funcion` | Alto | Alta | No prometer análisis laboral definitivo; documentar limitación |
| Concepto no presente en fuente principal | Medio | Alta | Derivar desde clasificador de gastos por `objeto_gasto` |
| Faltantes en clasificador OEE | Alto | Media | Crear checks de enriquecimiento faltante |
| Duplicados por grano esperado | Alto | Media | Validar duplicados en STAGING, CORE y DATAMART |
| Importes mal parseados | Alto | Media | Usar limpieza numérica y checks de negativos/cero |
| Cotización USD faltante | Medio | Media | Marcar registros y evitar conversión silenciosa |
| Clasificación docente/administrativo débil | Alto | Alta | Usar solo como indicador inferido, no como verdad laboral |
| Scripts no idempotentes | Medio | Media | Usar `CREATE OR REPLACE` y orden de ejecución documentado |
| Dashboard con lógica duplicada | Medio | Media | Centralizar reglas en SQL |
| Falta de documentación operativa | Alto | Media | Crear guía de ejecución end-to-end |

---

## 23. Indicadores de gestión del proyecto

### 23.1 Indicadores técnicos

| Indicador | Fórmula / medición |
|---|---|
| Tasa de carga exitosa | fuentes cargadas / fuentes esperadas |
| Cobertura de enriquecimiento OEE | registros con descripción OEE / total registros |
| Cobertura de concepto remunerativo | registros con concepto derivado / total registros |
| Duplicados críticos | cantidad de duplicados por grano |
| Diferencia de reconciliación | total OBT - total CORE |
| Cobertura USD | registros con cotización / total registros |

### 23.2 Indicadores de calidad documental

| Indicador | Criterio |
|---|---|
| Documentación de fuentes | cada fuente tiene descripción y uso |
| Documentación de reglas | cada campo derivado tiene regla |
| Documentación de riesgos | cada limitación crítica está registrada |
| Reproducibilidad | existe guía de ejecución completa |

---

## 24. Definición de terminado

Una fase se considera terminada cuando cumple las siguientes condiciones:

1. El script o documento existe en la ubicación definida.
2. El contenido está alineado con las convenciones del proyecto.
3. La ejecución fue validada o, si no fue posible, se documentó la razón.
4. Las dependencias están identificadas.
5. Los riesgos o supuestos están explícitos.
6. El entregable puede ser entendido por otra persona técnica.
7. La salida no contradice la estructura real de las fuentes.

---

## 25. Próximos documentos recomendados

Después de esta planificación, conviene avanzar con los siguientes documentos:

```text
docs/03_diccionario_modelo/
├── 00_diccionario_obt_remuneraciones.md
├── 01_diccionario_core.md
└── 02_glosario_metricas.md

docs/04_operacion_pipeline/
├── 00_guia_ejecucion_end_to_end.md
├── 01_guia_pentaho_data_integration.md
├── 02_guia_airflow_orquestacion.md
└── 03_runbook_errores_frecuentes.md

docs/05_calidad_datos/
├── 00_plan_calidad_datos.md
├── 01_catalogo_checks_calidad.md
└── 02_informe_resultados_calidad.md

docs/06_consumo_analitico/
├── 00_guia_consumo_bi.md
├── 01_metricas_dashboard.md
└── 02_preguntas_analiticas_sql.md
```

---

## 26. Conclusión

El proyecto `gasto-salarios-unpy` está correctamente orientado si mantiene una disciplina estricta de ingeniería de datos: separación por capas, reglas SQL reproducibles, documentación de supuestos, calidad automatizable y una OBT diseñada para consumo analítico.

El punto más importante para preservar la calidad metodológica es no forzar dimensiones inexistentes. En particular, `cargo`, `funcion`, `linea`, `categoria` y `concepto` no deben tratarse como columnas de la fuente principal. El concepto remunerativo se deriva desde el clasificador de gastos mediante `objeto_gasto`, mientras que las descripciones institucionales se derivan desde el clasificador OEE.

El éxito del proyecto dependerá menos de construir muchas tablas y más de garantizar que cada transformación sea trazable, justificable, validada y útil para responder preguntas analíticas reales.
