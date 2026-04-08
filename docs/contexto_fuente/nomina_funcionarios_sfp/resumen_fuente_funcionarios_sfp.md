<div align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
  <h1>FPUNA · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Resumen del Contexto de la Fuente: Nómina de Funcionarios Públicos

### Fuente: `https://datos.sfp.gov.py/data/funcionarios_{ANHO}_{ID_MES}.csv.zip`

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente de la asignatura *Electiva - Big Data*  
Facultad Politécnica - Universidad Nacional de Asunción  

---

## Fecha y versión

- **Fecha:** 26/03/2026
- **Versión:** 1.0

---

## 1. Propósito del documento

Este documento resume el contexto institucional, técnico y analítico de la fuente principal de datos utilizada para las clases de laboratorio de la asignatura **Electiva - Big Data**, orientado al análisis de remuneraciones de funcionarios públicos que prestan servicios en las **Universidades Nacionales del Paraguay**.

Su finalidad es dejar explícito:

* de dónde provienen los datos;
* bajo qué marco institucional se publican;
* cuál es su naturaleza y granularidad;
* qué limitaciones presentan;
* y por qué requieren un proceso de ingeniería de datos antes de ser utilizados con fines analíticos.

---

## 2. Contexto institucional de la fuente

La fuente principal del proyecto proviene del portal de datos abiertos originalmente asociado a la **Secretaría de la Función Pública (SFP)**, actualmente bajo el ámbito del **Viceministerio de Capital Humano y Gestión Organizacional (VCHGO)** del **Ministerio de Economía y Finanzas (MEF)**. La propia página institucional del MEF indica que este viceministerio opera conforme a la **Ley 7158/2023**, absorbiendo atribuciones vinculadas a la función pública, y además enlaza directamente el portal histórico `datos.sfp.gov.py`. ([Ministerio de Educación y Ciencias][1])

En el portal nacional `datos.gov.py`, este sitio aparece catalogado como **Portal de Datos Abiertos del Viceministerio de Capital Humano (ex SFP)**, con información relacionada a la **nómina de funcionarios públicos** y otros datos de concursos. El mismo catálogo declara explícitamente que el portal **no dispone de API**. ([datos.gov.py][2])

---

## 3. Fuente principal utilizada en el proyecto

La fuente principal de este trabajo corresponde al conjunto de datos de **nómina de funcionarios públicos**, publicado en el ecosistema `datos.sfp.gov.py`, y utilizado en este proyecto en una versión acotada al subconjunto de registros correspondientes a las **Universidades Nacionales del Paraguay**.

Desde el punto de vista funcional, esta fuente permite analizar remuneraciones reportadas por organismos públicos por período, incluyendo variables institucionales, demográficas, laborales y presupuestarias. Su valor analítico es alto, pero no debe tratarse como un dataset “listo para BI” sin transformación previa.

---

## 4. Naturaleza de los datos

La fuente se presenta como un conjunto de datos tabular publicado en formato abierto y orientado a consulta ciudadana. Sin embargo, desde la perspectiva de ingeniería de datos, su estructura responde más a un **registro operativo de remuneraciones** que a un modelo analítico consolidado.

Esto implica que:

* la granularidad original no es necesariamente una fila por funcionario;
* un mismo funcionario puede aparecer múltiples veces en un mismo período;
* los registros incluyen componentes remunerativos diferenciados;
* existen atributos útiles para análisis y otros con baja calidad o escaso valor analítico inmediato;
* el dataset requiere limpieza, estandarización, deduplicación y agregación para su consumo en herramientas analíticas.

---

## 5. Granularidad observada de la fuente

A partir de la revisión de muestras del archivo principal y del análisis exploratorio realizado sobre subconjuntos de datos, se identificó que la granularidad real de la fuente en crudo se aproxima a:

**una fila por componente remunerativo de un funcionario en un período y contexto institucional determinado**

Esta observación es crítica porque evita un error común de modelado: asumir que cada fila representa directamente a un funcionario único por mes. En realidad, la fuente puede contener varias líneas asociadas a una misma persona en el mismo período, diferenciadas por concepto remunerativo, objeto de gasto, categoría u otros atributos asociados al registro salarial.

Por esta razón, el proyecto **no expondrá directamente la tabla cruda en Metabase**, sino que construirá un modelo analítico consolidado.

---

## 6. Variables relevantes para el análisis

De acuerdo con la revisión de la fuente principal y del diccionario de datos, los campos de mayor valor analítico para este proyecto se organizan en los siguientes grupos:

### 6.1. Identificación temporal

* año
* mes

### 6.2. Identificación institucional

* nivel
* entidad
* OEE
* descripciones institucionales asociadas

### 6.3. Identificación del funcionario

* documento
* nombres
* apellidos

### 6.4. Perfil básico del funcionario

* sexo
* año de ingreso
* estado
* discapacidad
* tipo de discapacidad
* fecha de nacimiento
* fecha del acto administrativo

### 6.4.1. Diferencia entre `anho_ingreso` y `fecha_acto`

En la fuente de remuneraciones, los campos `anho_ingreso` y `fecha_acto` no deben interpretarse como equivalentes.

- **`anho_ingreso`** representa la referencia principal de antigüedad del funcionario, es decir, el año de ingreso a la función pública o a la institución según el criterio con que haya sido registrado.
- **`fecha_acto`** representa la fecha del acto administrativo que respalda la situación vigente observada en la nómina, como un nombramiento, ascenso, traslado, renovación contractual u otro movimiento formal.

En algunos casos ambos campos pueden coincidir, pero lo más frecuente es que no coincidan, porque `fecha_acto` suele reflejar el último movimiento administrativo, mientras que `anho_ingreso` permanece como referencia de trayectoria.

Esta diferencia es clave para el proyecto porque:

- `anho_ingreso` se utilizará como base principal para análisis de antigüedad;
- `fecha_acto` se interpretará como referencia del acto legal vigente;
- y no debe derivarse automáticamente la antigüedad a partir de `fecha_acto`.

### 6.5. Información remunerativa y presupuestaria

* objeto de gasto
* concepto
* línea
* categoría
* fuente de financiamiento
* monto presupuestado
* monto devengado
* remuneración total presupuestada
* remuneración total devengada

Estos campos hacen posible construir un modelo analítico útil para responder preguntas sobre gasto, distribución salarial, comportamiento institucional y comparaciones relativas.

---

## 7. Delimitación analítica del proyecto

Aunque la fuente institucional tiene una cobertura más amplia sobre la administración pública, este proyecto restringe deliberadamente el análisis a las **Universidades Nacionales del Paraguay**.

La decisión responde a criterios de:

* viabilidad técnica;
* límites de almacenamiento y procesamiento en el entorno de laboratorio;
* control de complejidad del modelado;
* foco temático más claro para el trabajo académico;
* y construcción de un caso analítico manejable, riguroso y defendible.

Esta delimitación no reduce el valor del proyecto. Al contrario, mejora su consistencia metodológica y permite profundizar el análisis sobre un subconjunto relevante y bien definido.

---

## 8. Limitaciones estructurales de la fuente

La fuente presenta varias limitaciones que deben quedar registradas desde el inicio del proyecto.

### 8.1. No es una fuente analítica nativa

El dataset no fue diseñado como modelo dimensional ni como tabla lista para visualización. Requiere transformación.

### 8.2. Posibles duplicados y multiplicidad por funcionario

La presencia de múltiples filas por funcionario y período obliga a definir cuidadosamente el grano de los modelos analíticos.

### 8.3. Calidad heterogénea en ciertos campos

Algunos atributos presentan baja consistencia o escaso valor analítico directo, por lo que se excluyen del modelo principal en esta etapa.

### 8.4. Dependencia de la calidad del reporte institucional

El valor del dato publicado depende del proceso de carga y actualización realizado por las instituciones que reportan.

### 8.5. Publicación sin API

El hecho de que el portal no disponga de API obliga a diseñar la estrategia de ingesta a partir de archivos y procesos controlados por lotes. ([datos.gov.py][2])

---

## 9. Campos excluidos del modelado principal

Como decisión de alcance y calidad analítica, en esta etapa del proyecto se excluyen del modelo principal los siguientes campos:

* `funcion`
* `carga_horaria`
* `cargo`
* `movimiento`
* `lugar`
* `fec_ult_modif`
* `uri`
* `correo`
* `profesion`
* `motivo_movimiento`

La exclusión no implica que carezcan totalmente de valor, sino que actualmente presentan al menos una de estas condiciones:

* baja calidad;
* escasa estandarización;
* poco aporte al análisis principal;
* o necesidad de tratamientos adicionales de limpieza y unificación que exceden el alcance actual.

Estos campos podrán abordarse como parte de trabajos futuros.

---

## 10. Fuentes secundarias para enriquecimiento

Además de la fuente principal de remuneraciones, el proyecto integra dos fuentes auxiliares para enriquecer el análisis:

### 10.1. Cotización mensual del dólar

Permite expresar remuneraciones y agregados en una unidad de referencia internacional, útil para comparaciones complementarias.

### 10.2. Régimen salarial en Paraguay

Permite contextualizar los montos devengados respecto al salario mínimo y otras referencias salariales vigentes por período.

### 10.3. Clasificador OEE

Permite enriquecer y normalizar la jerarquía institucional, facilitando agrupaciones y análisis por entidad u organismo.

Estas fuentes secundarias no reemplazan la fuente principal, pero amplían significativamente la capacidad interpretativa del modelo analítico final.

### 10.4. Clasificador de gastos públicos del Presupuesto General de la Nación

Se incorpora además un archivo complementario de **clasificación de gastos públicos del Presupuesto General de la Nación**, utilizado como fuente de referencia semántica para interpretar el campo `objeto_gasto` presente en la fuente principal de remuneraciones.

Su función dentro del proyecto no es actuar como fuente principal de hechos ni como tabla analítica autónoma, sino como apoyo para:

- comprender la naturaleza presupuestaria de determinados códigos de gasto;
- validar la interpretación funcional de componentes remunerativos;
- reforzar la separación analítica entre salario base y beneficios adicionales;
- y documentar con mayor precisión la lógica de agregación del modelo final.

Dado que su aporte es principalmente semántico y de contextualización presupuestaria, esta fuente se considera **complementaria de referencia**.

---

## 11. Implicancias para el diseño del proyecto

La revisión del contexto fuente conduce a varias decisiones metodológicas clave:

1. La tabla cruda no debe consumirse directamente en visualización.
2. El proyecto requiere una capa de **staging** para estandarización y tipado.
3. Se necesita una capa intermedia para deduplicación y agregación.
4. El modelo de salida para Metabase debe construirse como una **One Big Table (OBT)** consolidada.
5. El grano del OBT debe responder a una unidad analítica estable y comprensible para usuarios finales.
6. La documentación de supuestos y riesgos es obligatoria, no opcional.

---

## 12. Conclusión

La fuente principal del proyecto ofrece un insumo valioso para estudiar remuneraciones del sector público universitario, pero su aprovechamiento analítico exige un tratamiento técnico riguroso. No se trata de un dataset listo para usar, sino de una fuente operativa publicada en formato abierto que requiere ser comprendida, evaluada, limpiada, integrada y modelada.

Precisamente por eso, este proyecto de ingeniería de datos no se limita a visualizar datos existentes, sino que propone construir una base analítica reproducible, documentada y metodológicamente sólida para analizar las remuneraciones de funcionarios públicos de las **Universidades Nacionales del Paraguay**.

---

## 13. Referencias de contexto institucional

* Ministerio de Economía y Finanzas. Viceministerio de Capital Humano y Gestión Organizacional. ([Ministerio de Educación y Ciencias][1])
* Portal de Datos Abiertos del Viceministerio de Capital Humano (ex SFP) en datos.gov.py. ([datos.gov.py][2])

La parte crítica ya quedó bien asentada: fuente institucional vigente, portal heredado, ausencia de API y necesidad de modelado analítico previo. ([Ministerio de Educación y Ciencias][1])

[1]: https://www.mef.gov.py/es/dependencias/viceministerio-de-capital-humano-y-gestion-organizacional "Viceministerio de Capital Humano y Gestión Organizacional | Ministerio de Economía y Finanzas"
[2]: https://www.datos.gov.py/portal-de-datos-abiertos-del-viceministerio-de-capital-humano-ex-sfp "Portal de Datos Abiertos del Viceministerio de Capital Humano (ex SFP) | Datos.gov.py"
