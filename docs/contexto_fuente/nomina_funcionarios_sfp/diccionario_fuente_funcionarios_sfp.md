<div align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
  <h1>CIT · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Diccionario de Datos de la Fuente: Nómina de Funcionarios Públicos

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

Este documento describe la estructura funcional y técnica de la fuente de datos de **remuneraciones de funcionarios públicos** publicada en el ecosistema histórico `datos.sfp.gov.py`, actualmente vinculado al **Viceministerio de Capital Humano y Gestión Organizacional (VCHGO)** del **Ministerio de Economía y Finanzas (MEF)**.

Su objetivo es servir como referencia base para:

- comprender la semántica de las columnas de la fuente;
- facilitar la carga y tipado del archivo en motores analíticos como DuckDB;
- anticipar problemas de calidad de datos y ambigüedades de interpretación;
- apoyar procesos de EDA, `staging`, limpieza y modelado analítico;
- documentar el grano real de la fuente y sus limitaciones.

---

## 2. Identificación de la fuente

| Atributo | Valor |
|---|---|
| Nombre funcional | Nómina de Funcionarios Públicos |
| Institución publicadora | Viceministerio de Capital Humano y Gestión Organizacional (ex SFP) / MEF |
| Dominio principal | `datos.sfp.gov.py` |
| Patrón de descarga | `https://datos.sfp.gov.py/data/funcionarios_{ANHO}_{ID_MES}.csv.zip` |
| Formato de entrega | `CSV` comprimido en `ZIP` |
| Cobertura esperada | Registros de remuneraciones presupuestadas y devengadas por entidad y período |
| Temporalidad | Corte mensual |
| Tipo de actualización esperada | Publicación periódica por año y mes |
| Acceso | Público |
| API oficial | No disponible |

### Parámetros de la URL

| Parámetro | Descripción | Ejemplo |
|---|---|---|
| `{ANHO}` | Año del período | `2025` |
| `{ID_MES}` | Identificador del mes | `3` |

### Ejemplo de construcción

```text
https://datos.sfp.gov.py/data/funcionarios_2026_1.csv.zip
```

---

## 3. Alcance y advertencias metodológicas

Este diccionario combina tres niveles de lectura:

1. la definición funcional oficial de la nómina pública;
2. la interpretación técnica necesaria para ingeniería de datos;
3. recomendaciones de tipado y uso analítico en un entorno reproducible.

### Advertencias importantes

- La fuente **no debe asumirse como una tabla lista para BI**.
- La granularidad observada en crudo **no equivale necesariamente a una fila por funcionario**.
- Un mismo funcionario puede aparecer varias veces dentro del mismo período por componentes remunerativos distintos.
- Los nombres mostrados en este documento responden a la **semántica oficial** y a una **propuesta de nombre técnico normalizado** para trabajo en SQL.
- Algunos campos presentan variabilidad de calidad, dominios poco normalizados o semántica operativa más que analítica.

---

## 4. Grano observado de la fuente

La interpretación más prudente de la fuente cruda es:

**una fila por componente remunerativo de un funcionario en un período y contexto institucional determinado**

Por tanto, antes de construir métricas o dashboards se recomienda distinguir claramente entre:

- **registro administrativo crudo**;
- **persona**;
- **período mensual**;
- **detalle remunerativo**;
- **agregado analítico consolidado**.

### Clave de negocio preliminar sugerida para revisión

No debe asumirse como clave primaria perfecta, pero es una combinación razonable para análisis exploratorio inicial:

```text
anho + mes + nivel + entidad + oee + documento + objeto_gasto + linea + categoria
```

### Grano analítico recomendado para consolidación mensual

Para un modelo analítico de consumo general, suele ser más defendible consolidar a:

```text
anho + mes + nivel + entidad + oee + documento
```

---

## 5. Convención de nombres técnicos recomendada

Para trabajar con SQL, DuckDB, PostgreSQL u otras herramientas analíticas, se recomienda normalizar los encabezados a `snake_case`, sin acentos ni espacios.

| Nombre funcional                 | Nombre técnico recomendado |
|----------------------------------|---|
| Año                              | `anho` |
| Mes                              | `mes` |
| Código de Nivel                  | `nivel` |
| Descripción de Nivel             | `descripcion_nivel` |
| Código de Entidad                | `entidad` |
| Descripción de Entidad           | `descripcion_entidad` |
| Código de OEE                    | `oee` |
| Descripción de OEE               | `descripcion_oee` |
| Cédula                           | `documento` |
| Nombres                          | `nombres` |
| Apellidos                        | `apellidos` |
| Sexo                             | `sexo` |
| Objeto de Gasto                  | `objeto_gasto` |
| Concepto                         | `concepto` |
| Fuente de Financiamiento         | `fuente_financiamiento` |
| Línea                            | `linea` |
| Categoría                        | `categoria` |
| Cargo                            | `cargo` |
| Función Real que cumple          | `funcion` |
| Carga Horaria                    | `carga_horaria` |
| Estado                           | `estado` |
| Año Ingreso                      | `anho_ingreso` |
| Discapacidad                     | `discapacidad` |
| Tipo                             | `tipo_discapacidad` |
| Movimiento                       | `movimiento` |
| Lugar                            | `lugar` |
| Fecha de Nacimiento              | `fecha_nacimiento` |
| Fecha de Última Actualización    | `fecha_ult_actualizacion` |
| Monto Presupuestado              | `presupuestado` |
| Monto Devengado                  | `devengado` |
| Remuneración Total Presupuestado | `remuneracion_total_presupuestado` |
| Remuneración Total Devengado     | `remuneracion_total_devengado` |
| Profesión                        | `profesion` |
| Correo                           | `correo` |
| Motivo Movimiento                | `motivo_movimiento` |
| Fecha de Acto Administrativo     | `fecha_acto` |
| Oficina                          | `oficina` |
| Uri                              | `uri` |

---

## 6. Diccionario de datos por grupos funcionales

## 6.1. Variables temporales

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Año | `anho` | Año en que se realizó la asignación monetaria | `INTEGER` | Clave temporal | Campo base para partición y filtrado |
| Mes | `mes` | Mes del período de asignación monetaria | `INTEGER` o `VARCHAR` normalizado | Clave temporal | Puede llegar como texto; conviene mapearlo a `1-12` |

## 6.2. Variables de jerarquía institucional

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Código de Nivel | `nivel` | Clasificación superior de la estructura del Estado | `INTEGER` | Agrupación institucional | Puede variar según el año fiscal |
| Descripción de Nivel | `descripcion_nivel` | Descripción del nivel institucional | `VARCHAR` | Etiquetado | Depende del PGN del año correspondiente |
| Código de Entidad | `entidad` | Código de la entidad u organismo | `INTEGER` | Agrupación institucional | Puede combinar codificación PGN y codificación interna |
| Descripción de Entidad | `descripcion_entidad` | Descripción de la entidad | `VARCHAR` | Etiquetado | Útil para navegación y agrupación |
| Código de OEE | `oee` | Código del Organismo o Entidad del Estado | `INTEGER` | Join y agrupación | En universidades puede desagregar facultades o dependencias |
| Descripción de OEE | `descripcion_oee` | Nombre del OEE o dependencia | `VARCHAR` | Etiquetado | Muy útil para análisis por institución |

## 6.3. Variables de identificación personal

| Nombre funcional    | Nombre técnico | Descripción resumida                     | Tipo sugerido | Uso analítico principal | Observaciones                                                   |
|---------------------|---|------------------------------------------|---------------|-------------------------|-----------------------------------------------------------------|
| Cédula              | `documento` | Identificador documental del funcionario | `VARCHAR`     | Clave de persona        | No debe tiparse como entero; puede contener prefijos especiales |
| Nombres             | `nombres` | Nombre(s) del funcionario                | `VARCHAR`     | Etiquetado              | Requiere `TRIM()` y normalización básica                        |
| Apellidos           | `apellidos` | Apellido(s) del funcionario              | `VARCHAR`     | Etiquetado              | Puede presentar inconsistencias de formato                      |
| Sexo                | `sexo` | Sexo del funcionario                     | `VARCHAR`     | Segmentación            | Conviene estandarizar dominio                                   |
| Fecha de Nacimiento | `fecha_nacimiento` | Natalicio del funcionario                | `DATE`        | Rango etario            | Estandarizar formato AAAA-MM-DD                                 |

## 6.4. Variables remunerativas y presupuestarias

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Objeto de Gasto | `objeto_gasto` | Código del objeto de gasto presupuestario | `INTEGER` | Clasificación del gasto | Requiere interpretación con contexto PGN |
| Concepto | `concepto` | Descripción del objeto de gasto | `VARCHAR` | Clasificación analítica | Permite agrupar componentes de remuneración |
| Fuente de Financiamiento | `fuente_financiamiento` | Origen de los recursos monetarios | `INTEGER` o `VARCHAR` | Segmentación presupuestaria | La fuente oficial menciona FF 10, 20 y 30 como ejemplos |
| Línea | `linea` | Código presupuestario asignado a una categoría | `VARCHAR` | Soporte de granularidad | En ciertos casos puede valer `0` |
| Categoría | `categoria` | Clasificación del puesto según criterios funcionales | `VARCHAR` | Segmentación | Útil para cortes salariales |
| Monto Presupuestado | `presupuestado` | Monto bruto asignado al objeto del gasto | `DECIMAL(18,2)` | Métrica | Conviene validar ceros, nulos y valores improbables |
| Monto Devengado | `devengado` | Monto neto percibido tras descuentos legales | `DECIMAL(18,2)` | Métrica principal | No debe interpretarse sin contexto normativo |
| Remuneración Total Presupuestado | `remuneracion_total_presupuestado` | Suma mensual de montos presupuestados del funcionario | `DECIMAL(18,2)` | Métrica agregada | Puede coexistir con líneas de detalle |
| Remuneración Total Devengado | `remuneracion_total_devengado` | Suma mensual de montos devengados del funcionario | `DECIMAL(18,2)` | Métrica agregada | Requiere validación frente a la suma de componentes |

## 6.5. Variables laborales y de clasificación administrativa

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Cargo | `cargo` | Nivel jerárquico asignado al funcionario | `VARCHAR` | Segmentación | Suele requerir fuerte normalización |
| Función Real que cumple | `funcion` | Función efectiva desempeñada | `VARCHAR` | Análisis organizacional | Puede diferir de `cargo` |
| Carga Horaria | `carga_horaria` | Horario o carga horaria del funcionario | `VARCHAR` | Control complementario | Baja estandarización frecuente |
| Estado | `estado` | Tipo de vínculo con la institución | `VARCHAR` | Segmentación laboral | Valores esperables: permanente, contratado, comisionado |
| Movimiento | `movimiento` | Situación particular del funcionario en el período | `VARCHAR` | Contexto administrativo | Puede indicar altas, bajas, traslados y permisos |
| Lugar | `lugar` | Organismo de origen o destino en comisión de servicio | `VARCHAR` | Contexto | Solo relevante para ciertos movimientos |
| Motivo Movimiento | `motivo_movimiento` | Motivo del movimiento del funcionario | `VARCHAR` | Contexto | Útil pero poco estable para explotación directa |
| Oficina | `oficina` | Sede, filial, facultad u oficina | `VARCHAR` | Desagregación organizacional | Calidad variable según institución |

## 6.6. Variables de perfil personal y trayectoria

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Año Ingreso | `anho_ingreso` | Año de ingreso a la función pública | `INTEGER` | Antigüedad | Prioritario para análisis de trayectoria |
| Discapacidad | `discapacidad` | Indica si el funcionario posee discapacidad | `VARCHAR` | Segmentación | Dominio esperado: `S` / `N` |
| Tipo | `tipo_discapacidad` | Tipo de discapacidad | `VARCHAR` | Segmentación | Los códigos requieren diccionario adicional o mapeo explícito |
| Profesión | `profesion` | Profesión declarada del funcionario | `VARCHAR` | Perfil ocupacional | Campo útil, pero puede requerir taxonomía previa |
| Correo | `correo` | Correo institucional del funcionario | `VARCHAR` | Referencia administrativa | Generalmente no necesario para análisis remunerativo |

## 6.7. Variables de fecha, trazabilidad y referencia técnica

| Nombre funcional | Nombre técnico | Descripción resumida | Tipo sugerido | Uso analítico principal | Observaciones |
|---|---|---|---|---|---|
| Fecha de Última Actualización | `fecha_ult_actualizacion` | Fecha del último informe de nómina registrado | `DATE` o `VARCHAR` con parseo seguro | Trazabilidad | Puede venir con formato no limpio |
| Fecha de Acto Administrativo | `fecha_acto` | Fecha del acto administrativo de nombramiento o contratación | `DATE` | Contexto administrativo | No equivale automáticamente a antigüedad |
| Uri | `uri` | Identificador corto o referencia unívoca del recurso | `VARCHAR` | Trazabilidad técnica | Generalmente de baja utilidad analítica |

---

## 7. Reglas de tipado y normalización sugeridas

## 7.1. Reglas generales

- preservar identificadores como `VARCHAR` cuando exista riesgo de pérdida de formato;
- convertir montos a `DECIMAL(18,2)` o tipo monetario equivalente;
- normalizar fechas mediante parseo seguro;
- transformar cadenas vacías, espacios y valores de “sin dato” a `NULL`;
- documentar cualquier renombrado o recodificación.

## 7.2. Texto

- aplicar `TRIM()`;
- unificar espacios internos cuando sea necesario;
- estandarizar mayúsculas/minúsculas según el propósito analítico;
- revisar caracteres especiales y codificación UTF-8.

## 7.3. Fechas

- usar parseo seguro;
- convertir fechas inválidas a `NULL`;
- nunca derivar automáticamente `anho_ingreso` desde `fecha_acto` sin justificación explícita.

## 7.4. Dominios

- mapear `mes` a un dominio estable `1-12`;
- normalizar `sexo`, `estado`, `discapacidad` y `movimiento`;
- controlar que `tipo_discapacidad` sea coherente con `discapacidad`.

## 7.5. Numéricos

- validar montos negativos, nulos y ceros;
- controlar consistencia entre montos de línea y montos totales;
- evitar convertir identificadores documentales a enteros.

---

## 8. Riesgos y limitaciones relevantes de la fuente

## 8.1. Semántica heterogénea del campo `documento`

El valor de `documento` no siempre representa únicamente una cédula paraguaya estándar. En exploraciones previas se identificaron prefijos especiales que pueden indicar casos como funcionario extranjero, vacancia u otras representaciones atípicas.

## 8.2. Grano no consolidado por persona

La tabla cruda no debe leerse como “una fila = una persona”. Esto puede inflar conteos de funcionarios y distorsionar agregaciones salariales.

## 8.3. Ambigüedad entre `presupuestado` y `devengado`

La diferencia entre ambos montos puede responder a descuentos legales, retenciones u otras reglas administrativas, no necesariamente a errores de carga.

## 8.4. Inconsistencias en fechas

Campos como `fecha_ult_actualizacion` o `fecha_acto` pueden requerir parseo defensivo. No es correcto asumir formato limpio en todos los períodos.

## 8.5. Calidad variable en variables descriptivas

Campos como `cargo`, `funcion`, `oficina`, `profesion` o `motivo_movimiento` pueden resultar útiles, pero suelen presentar alta dispersión textual y baja normalización.

## 8.6. Riesgo de interpretación analítica

Sin una consolidación previa es fácil:

- contar registros en lugar de personas;
- duplicar montos;
- mezclar detalle remunerativo con totales mensuales;
- usar variables administrativas como si fueran dimensiones limpias.

---

## 9. Recomendaciones mínimas para carga en DuckDB

## 9.1. Ingesta inicial

- conservar copia del `.zip` original descargado;
- registrar `ANHO` y `ID_MES` como metadatos de extracción;
- guardar el archivo en una carpeta de `raw/` sin alterar el contenido original.

## 9.2. Capa `staging`

Se recomienda construir una tabla `stg_funcionarios_raw` o equivalente, aplicando:

- renombrado técnico de columnas;
- tipado consistente;
- limpieza básica de texto;
- estandarización de nulos;
- parseo controlado de fechas;
- validación de montos.

## 9.3. Validaciones básicas recomendadas

- conteo de registros por período;
- distribución de `objeto_gasto` y `concepto`;
- nulos por columna;
- duplicados de negocio;
- consistencia entre `devengado` y `remuneracion_total_devengado`;
- revisión de dominios de `estado`, `movimiento`, `discapacidad` y `sexo`.

---

## 10. Columnas prioritarias para EDA inicial

Si se requiere una primera exploración rápida, estas columnas son las más críticas:

```text
anho
mes
nivel
descripcion_nivel
entidad
descripcion_entidad
oee
descripcion_oee
documento
sexo
estado
anho_ingreso
objeto_gasto
concepto
categoria
presupuestado
devengado
remuneracion_total_presupuestado
remuneracion_total_devengado
fecha_acto
```

---

## 11. Conclusión técnica

Esta fuente tiene **alto valor analítico**, pero también exige una lectura cuidadosa desde ingeniería de datos. Su principal dificultad no está en la cantidad de columnas, sino en la **semántica operativa del registro**, la **granularidad no consolidada** y la **necesidad de tipado y normalización previa**.

En consecuencia, este diccionario debe leerse como una guía para:

- interpretar correctamente la fuente;
- diseñar una capa `staging` sólida;
- evitar errores de conteo y agregación;
- y preparar un modelo analítico reproducible para consumo posterior.

---

## 12. Fuentes consultadas

### Fuentes oficiales

- Viceministerio de Capital Humano y Gestión Organizacional (MEF): `https://www.mef.gov.py/es/dependencias/viceministerio-de-capital-humano-y-gestion-organizacional`
- Definición del recurso: `https://datos.sfp.gov.py/def/funcionarios`
- Descarga del recurso: `https://datos.sfp.gov.py/data/funcionarios/download`
- Patrón de descarga mensual: `https://datos.sfp.gov.py/data/funcionarios_{ANHO}_{ID_MES}.csv.zip`
- Referencia del portal de datos abiertos del VCHGO (ex SFP): `https://www.datos.gov.py/portal-de-datos-abiertos-del-viceministerio-de-capital-humano-ex-sfp`

