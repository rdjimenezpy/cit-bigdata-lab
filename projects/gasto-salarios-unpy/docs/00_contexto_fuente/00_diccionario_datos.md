<p align="center">
	<img src="../../../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 00 · Diccionario de datos

## Proyecto: gasto-salarios-unpy
### Modelo analítico OBT para remuneraciones de funcionarios públicos de universidades nacionales del Paraguay · Periodo 2025

**Institución:** Facultad Politécnica · Universidad Nacional de Asunción  
**Dependencia:** Centro de Innovación TIC (PK)  
**Curso:** Introducción a Big Data · Nivel Básico  
**Autor:** Prof. Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py  
**Versión:** 0.1  
**Fecha:** 2026-05-04

---

## 1. Propósito

Este documento define el diccionario funcional inicial de las fuentes que alimentan el proyecto **gasto-salarios-unpy**. Su objetivo es servir como referencia para las capas `raw`, `staging`, `core` y `datamart` del pipeline ETL/ELT en DuckDB, Pentaho Data Integration y Apache Airflow.

El diccionario no reproduce un catálogo institucional oficial completo. Está ajustado al alcance del proyecto académico: construir una tabla analítica tipo **OBT — One Big Table** para estudiar remuneraciones públicas de universidades nacionales del Paraguay durante 2025.

---

## 2. Fuentes revisadas

| Archivo                         | Rol                                               | Delimitador   |   Filas observadas |   Columnas | Codificación   | Uso analítico                                                                |
|:--------------------------------|:--------------------------------------------------|:--------------|-------------------:|-----------:|:---------------|:-----------------------------------------------------------------------------|
| sample_funcionarios_modelo.csv  | Fuente principal depurada para modelado           | ,             |              10000 |         19 | UTF-8          | Base del OBT; contiene variables seleccionadas y montos por objeto de gasto. |
| clasificador_gastos_utf8.csv    | Clasificador presupuestario de objetos de gasto   | ;             |                368 |          9 | UTF-8          | Enriquece el objeto de gasto con grupo, subgrupo y control financiero.       |
| clasificador_oee_utf8.csv       | Clasificador de Organismos y Entidades del Estado | ,             |                434 |         11 | UTF-8          | Permite etiquetar nivel, entidad y OEE; filtra universidades nacionales.     |
| cotizacion_usd_mensual_utf8.csv | Cotización mensual USD/PYG                        | ,             |                303 |          6 | UTF-8/ASCII    | Permite expresar métricas monetarias en USD por período.                     |
| regimen_salarial_py_utf8.csv    | Régimen salarial paraguayo                        | ,             |                 20 |         16 | UTF-8/ASCII    | Permite comparar remuneraciones con salario mínimo, jornal y aportes.        |

### Nota crítica sobre la muestra principal

El archivo `sample_funcionarios_modelo.csv` contiene **10.000 registros** y **19 columnas**. Esta muestra es suficiente para documentar el modelo base, pero **no contiene** campos como `cargo`, `funcion`, `concepto`, `linea` o `categoria`. Por tanto, cualquier clasificación de funcionario como docente/administrativo debe tratarse como **inferida y limitada** si se usa únicamente esta muestra.

En el ZIP del proyecto `gasto-salarios-unpy.zip`, los scripts SQL contemplan una fuente principal completa `funcionarios_2025_*_utf8.csv` y una fuente modelo. El diseño documental debe preservar esa distinción: la muestra sirve para entender la estructura seleccionada del modelo, pero no reemplaza el dataset completo cuando se requieran atributos textuales más ricos.

---

## 3. Grano analítico de referencia

La fuente principal seleccionada no representa una única fila por funcionario. El grano más seguro para la capa inicial es:

```text
funcionario + periodo mensual + nivel + entidad + oee + objeto_gasto + fuente_financiamiento + monto
```

A partir de este grano se puede construir una OBT mensual agregada por funcionario, institución y período. La agregación debe realizarse cuidadosamente para evitar doble conteo de componentes salariales.

---

## 4. Diccionario funcional: fuente principal `sample_funcionarios_modelo.csv`

| Columna origen        | Columna sugerida staging   | Tipo sugerido   | Descripción funcional                               | Regla de calidad / normalización                                                          | Uso analítico                                                       |
|:----------------------|:---------------------------|:----------------|:----------------------------------------------------|:------------------------------------------------------------------------------------------|:--------------------------------------------------------------------|
| anho                  | anho                       | INTEGER         | Año fiscal del registro remunerativo.               | Obligatorio; valor esperado 2025 en este proyecto.                                        | Temporal / partición / join con cotización y régimen.               |
| mes                   | mes                        | INTEGER         | Mes del período remunerativo.                       | Debe normalizarse a 1-12.                                                                 | Temporal / filtros / construcción de periodo_id.                    |
| nivel                 | codigo_nivel               | INTEGER         | Código de nivel institucional del Estado paraguayo. | Para universidades nacionales se espera nivel 28.                                         | Clave institucional.                                                |
| entidad               | codigo_entidad             | INTEGER         | Código de entidad dentro del nivel institucional.   | Se integra con clasificador OEE.                                                          | Agrupación universidad/entidad.                                     |
| oee                   | codigo_oee                 | INTEGER         | Código del Organismo o Entidad del Estado.          | Clave compuesta con nivel y entidad.                                                      | Identificación de facultad, rectorado o universidad.                |
| documento             | cedula_identidad           | VARCHAR         | Identificador documental del funcionario.           | No tipar como entero; puede requerir anonimización.                                       | Clave de persona y análisis longitudinal.                           |
| nombres               | nombres                    | VARCHAR         | Nombres del funcionario.                            | Normalizar espacios y mayúsculas; posible dato personal.                                  | Etiquetado; no recomendable para publicación abierta.               |
| apellidos             | apellidos                  | VARCHAR         | Apellidos del funcionario.                          | Normalizar espacios y mayúsculas; posible dato personal.                                  | Etiquetado; no recomendable para publicación abierta.               |
| estado                | estado                     | VARCHAR         | Situación administrativa del funcionario.           | Dominio observado: PERMANENTE, CONTRATADO, COMISIONADO.                                   | Segmentación laboral.                                               |
| anho_ingreso          | anho_ingreso               | INTEGER         | Año de ingreso reportado.                           | Cero significa no informado o dato no confiable; no calcular antigüedad directa con cero. | Antigüedad y cohortes de ingreso.                                   |
| sexo                  | sexo                       | VARCHAR         | Sexo reportado.                                     | Dominio observado: FEMENINO, MASCULINO.                                                   | Segmentación y brechas.                                             |
| discapacidad          | discapacidad               | VARCHAR         | Indicador de discapacidad.                          | Dominio observado: SI/NO.                                                                 | Segmentación sensible; requiere cuidado ético.                      |
| tipo_discapacidad     | tipo_discapacidad          | VARCHAR         | Tipo de discapacidad declarado cuando aplica.       | Alta nulidad esperada si discapacidad=NO.                                                 | Segmentación sensible; no exponer de forma identificable.           |
| fuente_financiamiento | fuente_financiamiento      | INTEGER         | Código de fuente presupuestaria.                    | Dominio observado: 0, 10, 30.                                                             | Segmentación financiera.                                            |
| objeto_gasto          | objeto_gasto_codigo        | INTEGER         | Código presupuestario del objeto de gasto.          | Join con clasificador_gastos; código 0 debe tratarse como anomalía o no clasificado.      | Clasificación de componente remunerativo.                           |
| presupuestado         | presupuestado_gs           | DECIMAL(18,2)   | Monto presupuestado en guaraníes.                   | Convertir desde texto/entero a decimal; validar negativos y ceros.                        | Métrica monetaria.                                                  |
| devengado             | devengado_gs               | DECIMAL(18,2)   | Monto devengado en guaraníes.                       | Métrica principal; puede ser cero.                                                        | Métrica monetaria principal.                                        |
| fecha_nacimiento      | fecha_nacimiento           | DATE            | Fecha de nacimiento del funcionario.                | Formato observado YYYY/MM/DD HH:MM:SS.fff; puede venir nula.                              | Edad, rango etario y generación.                                    |
| fecha_acto            | fecha_acto                 | DATE            | Fecha del acto administrativo asociado al registro. | Contiene valores anómalos como año 0002 y 4752; validar rango.                            | Contexto administrativo, no sustituye automáticamente anho_ingreso. |

### Observaciones de calidad de la fuente principal

| Aspecto | Observación |
|---|---|
| Cobertura temporal observada | Año 2025 con meses 1 a 12 presentes en la muestra. |
| Identificadores | 7.618 documentos únicos observados en 10.000 registros. |
| Duplicados exactos | 17 filas duplicadas exactas observadas en la muestra. |
| Monto devengado total observado | 17.933.191.409 Gs. |
| Monto presupuestado total observado | 20.469.121.148 Gs. |
| Devengados en cero | 239 registros con `devengado = 0`. |
| Año de ingreso cero | 1698 registros con `anho_ingreso = 0`; no deben usarse para antigüedad sin regla de imputación. |
| Fecha de nacimiento nula | 138 registros sin `fecha_nacimiento`. |
| Fecha de acto problemática | 79 nulos crudos y 453 valores no parseables o inválidos al aplicar parseo estricto. |

---

## 5. Diccionario funcional: `clasificador_gastos_utf8.csv`

| Columna                         | Tipo sugerido   | Descripción funcional                    | Regla de calidad / normalización             | Uso analítico                           |
|:--------------------------------|:----------------|:-----------------------------------------|:---------------------------------------------|:----------------------------------------|
| grupo_codigo                    | INTEGER         | Código de grupo presupuestario.          | Normalizar a entero.                         | Jerarquía de gasto.                     |
| grupo_descripcion               | VARCHAR         | Descripción del grupo presupuestario.    | Normalizar texto.                            | Etiqueta analítica.                     |
| subgrupo_codigo                 | INTEGER         | Código de subgrupo presupuestario.       | Normalizar a entero.                         | Jerarquía de gasto.                     |
| subgrupo_descripcion            | VARCHAR         | Descripción del subgrupo presupuestario. | Normalizar texto.                            | Etiqueta analítica.                     |
| objeto_gasto_codigo             | INTEGER         | Código del objeto de gasto.              | Clave de join con funcionarios.objeto_gasto. | Clasificación remunerativa.             |
| objeto_gasto_descripcion        | VARCHAR         | Descripción del objeto de gasto.         | Normalizar texto.                            | Interpretación del componente salarial. |
| control_financiero_codigo       | INTEGER         | Código de control financiero.            | Normalizar a entero.                         | Agrupación financiera.                  |
| control_financiero_descripcion  | VARCHAR         | Descripción de control financiero.       | Normalizar texto.                            | Agrupación para BI.                     |
| clasificacion_gasto_descripcion | VARCHAR         | Clasificación corriente/capital.         | Normalizar texto.                            | Segmentación presupuestaria.            |

### Objetos de gasto observados en la muestra principal

|   objeto_gasto_codigo | objeto_gasto_descripcion                                                                                            | control_financiero_descripcion                 | subgrupo_descripcion            |
|----------------------:|:--------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------|:--------------------------------|
|                     0 | SIN CLASIFICAR / VALOR CERO EN MUESTRA                                                                              | NO APLICA                                      | NO APLICA                       |
|                   111 | SUELDOS                                                                                                             | REMUNERACIONES BÁSICAS                         | REMUNERACIONES BÁSICAS          |
|                   112 | DIETAS                                                                                                              | REMUNERACIONES BÁSICAS                         | REMUNERACIONES BÁSICAS          |
|                   113 | GASTOS DE REPRESENTACIÓN                                                                                            | REMUNERACIONES BÁSICAS                         | REMUNERACIONES BÁSICAS          |
|                   114 | AGUINALDO                                                                                                           | REMUNERACIONES BÁSICAS                         | REMUNERACIONES BÁSICAS          |
|                   123 | REMUNERACIONES EXTRAORDINARIAS                                                                                      | REMUNERACIONES VARIAS                          | REMUNERACIONES TEMPORALES       |
|                   125 | REMUNERACIÓN ADICIONAL                                                                                              | REMUNERACIONES VARIAS                          | REMUNERACIONES TEMPORALES       |
|                   131 | SUBSIDIO FAMILIAR                                                                                                   | OTROS GASTOS DEL PERSONAL                      | ASIGNACIONES COMPLEMENTARIAS    |
|                   132 | ESCALAFÓN DOCENTE                                                                                                   | OTROS GASTOS DEL PERSONAL                      | ASIGNACIONES COMPLEMENTARIAS    |
|                   133 | BONIFICACIONES Y GRATIFICACIONES                                                                                    | OTROS GASTOS DEL PERSONAL                      | ASIGNACIONES COMPLEMENTARIAS    |
|                   141 | CONTRATACIÓN DE PERSONAL TÉCNICO                                                                                    | REMUNERACIONES VARIAS                          | PERSONAL CONTRATADO             |
|                   142 | CONTRATACIÓN DE PERSONAL DE SALUD                                                                                   | REMUNERACIONES VARIAS                          | PERSONAL CONTRATADO             |
|                   144 | JORNALES                                                                                                            | REMUNERACIONES VARIAS                          | PERSONAL CONTRATADO             |
|                   145 | HONORARIOS PROFESIONALES                                                                                            | REMUNERACIONES VARIAS                          | PERSONAL CONTRATADO             |
|                   148 | CONTRATACIÓN DE PERSONAL DOCENTE E INSTRUCTORES PARA CURSOS ESPECIALIZADOS, POR UNIDAD DE TIEMPO Y POR HORA CÁTEDRA | REMUNERACIONES VARIAS                          | PERSONAL CONTRATADO             |
|                   191 | SUBSIDIO PARA LA SALUD                                                                                              | OTROS GASTOS DEL PERSONAL                      | OTROS GASTOS DEL PERSONAL       |
|                   199 | OTROS GASTOS DE PERSONAL                                                                                            | OTROS GASTOS DEL PERSONAL                      | OTROS GASTOS DEL PERSONAL       |
|                   232 | VIÁTICOS Y MOVILIDAD                                                                                                | OTROS GASTOS                                   | PASAJES Y VIÁTICOS              |
|                   841 | BECAS                                                                                                               | TRANSF. CONSOLID. CORRIENTES AL SECTOR PÚBLICO | TRANSF. CORR. AL SECTOR PRIVADO |

### Mapeo inicial de componentes salariales

| Tipo componente sugerido               | Objeto(s) de gasto      | Criterio                                                                                                                 |
|:---------------------------------------|:------------------------|:-------------------------------------------------------------------------------------------------------------------------|
| SALARIO_BASICO                         | 111                     | Sueldos. En análisis estricto, usar 111 como sueldo base de personal permanente.                                         |
| REMUNERACIONES_BASICAS_COMPLEMENTARIAS | 112, 113, 114           | Dietas, gastos de representación y aguinaldo; no mezclar automáticamente con sueldo base.                                |
| CONTRATACIONES / JORNALES / HONORARIOS | 141, 142, 144, 145, 148 | Componentes de personal contratado, salud, jornales, honorarios y hora cátedra/docente.                                  |
| BONIFICACIONES                         | 123, 125, 132, 133, 199 | Remuneraciones extraordinarias, adicional, escalafón docente, bonificaciones/gratificaciones y otros gastos de personal. |
| BENEFICIOS                             | 131, 191                | Subsidio familiar y subsidio para la salud.                                                                              |
| VIATICOS                               | 232                     | Viáticos y movilidad.                                                                                                    |
| TRANSFERENCIAS / OTROS                 | 841                     | Becas u otros conceptos que requieren revisión de inclusión en remuneración total.                                       |
| NO CLASIFICADO                         | 0                       | Debe investigarse; no pertenece al clasificador observado.                                                               |

#### Advertencia metodológica

El campo `objeto_gasto` permite clasificar componentes remunerativos con bastante solidez presupuestaria, pero no resuelve por sí solo si un funcionario es docente o administrativo. Por ejemplo, `148` sugiere contratación docente por hora cátedra o cursos especializados, y `132` sugiere escalafón docente; aun así, la clasificación de persona debe validarse con `cargo`, `funcion` o reglas institucionales adicionales cuando estén disponibles.

---

## 6. Diccionario funcional: `clasificador_oee_utf8.csv`

| Columna             | Tipo sugerido   | Descripción funcional                | Regla de calidad / normalización                      | Uso analítico                             |
|:--------------------|:----------------|:-------------------------------------|:------------------------------------------------------|:------------------------------------------|
| codigo_nivel        | INTEGER         | Código del nivel institucional.      | Clave compuesta con entidad y OEE.                    | Join institucional.                       |
| descripcion_nivel   | VARCHAR         | Descripción del nivel institucional. | Normalizar texto.                                     | Filtro de universidades nacionales.       |
| codigo_entidad      | INTEGER         | Código de entidad.                   | Clave compuesta con nivel y OEE.                      | Identificación de universidad.            |
| descripcion_entidad | VARCHAR         | Descripción de entidad.              | Normalizar texto.                                     | Nombre de universidad.                    |
| codigo_oee          | INTEGER         | Código de OEE.                       | Clave compuesta con nivel y entidad.                  | Identificación de facultad/rectorado/OEE. |
| descripcion_oee     | VARCHAR         | Descripción del OEE.                 | Normalizar texto.                                     | Nombre descriptivo para BI.               |
| descripcion_corta   | VARCHAR         | Sigla o nombre corto.                | Normalizar texto; puede tener siglas institucionales. | Etiqueta compacta.                        |
| direccion           | VARCHAR         | Dirección física del OEE.            | Alta nulidad observada; no crítico para OBT salarial. | Contexto institucional opcional.          |
| telefono            | VARCHAR         | Teléfono del OEE.                    | Alta nulidad observada; preservar como texto.         | Contexto opcional.                        |
| pagina_web          | VARCHAR         | Página web institucional.            | Validar URL si se usa.                                | Contexto opcional.                        |
| uri                 | VARCHAR         | URI institucional en datos abiertos. | Debe preservarse como identificador externo.          | Trazabilidad.                             |

### Universidades nacionales y OEE del nivel 28 observados en el clasificador

|   codigo_entidad | descripcion_entidad                                   |   codigo_oee | descripcion_oee                                               | descripcion_corta   |
|-----------------:|:------------------------------------------------------|-------------:|:--------------------------------------------------------------|:--------------------|
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            1 | UNA RECTORADO (RECTORADO UNA)                                 | UNA                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            2 | FACULTAD DE ENFERMERIA Y OBSTETRICIA                          | FENOB               |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            3 | COLEGIO EXPERIMENTAL PARAGUAY-BRASIL (CEPB)                   | CEPYBR              |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            4 | FACULTAD DE CIENCIAS AGRARIAS (FCA-UNA)                       | FCA                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            5 | UNA FACULTAD CIENCIAS EXACTAS Y NATURALES (FACEN)             | FACEN               |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            6 | UNA FACULTAD DE ARQUITECTURA, DISENO Y ARTE                   | FADA                |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            7 | FACULTAD DE CIENCIAS ECONOMICAS (FCE)                         | FCE                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            8 | FACULTAD DE CIENCIAS MEDICAS (FCM)                            | FCM                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |            9 | FACULTAD DE CIENCIAS QUIMICAS (FCQ)                           | FCQ                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           10 | FACULTAD DE DERECHO Y CIENCIAS SOCIALES (FDCS)                | FDCS                |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           11 | FACULTAD DE FILOSOFIA (FIL)                                   | FIL                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           12 | FACULTAD DE INGENIERIA (FIUNA)                                | FIUNA               |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           13 | FACULTAD DE ODONTOLOGIA (FO)                                  | FO                  |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           14 | FACULTAD DE POLITECNICA (FPUNA)                               | FPUNA               |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           15 | FACULTAD DE CIENCIAS VETERINARIAS (FCV)                       | FCV                 |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           16 | INSTITUTO DE INVESTIGACIONES EN CIENCIAS DE LA SALUD (IICS)   | IICS                |
|                1 | UNIVERSIDAD NACIONAL DE ASUNCIÓN                      |           17 | FACULTAD DE CIENCIAS SOCIALES                                 | FACSO               |
|                2 | UNIVERSIDAD NACIONAL DEL ESTE                         |            1 | UNIVERSIDAD NACIONAL DEL ESTE (UNE)                           | UNE                 |
|                3 | UNIVERSIDAD NACIONAL DE PILAR                         |            1 | UNIVERSIDAD NACIONAL DE PILAR (UNP)                           | UNP                 |
|                4 | UNIVERSIDAD NACIONAL DE ITAPÚA                        |            1 | UNIVERSIDAD NACIONAL DE ITAPUA (UNI)                          | UNI                 |
|                5 | UNIVERSIDAD NACIONAL DE CONCEPCIÓN                    |            1 | UNIVERSIDAD NACIONAL DE CONCEPCION (UNC)                      | UNCON               |
|                6 | UNIVERSIDAD NACIONAL DE VILLARRICA DEL ESPIRITU SANTO |            1 | UNIVERSIDAD NACIONAL DE VILLARRICA DEL ESPIRITU SANTO (UNVES) | UNVES               |
|                7 | UNIVERSIDAD NACIONAL DE CAAGUAZU                      |            1 | UNIVERSIDAD NACIONAL DE CAAGUAZU (UNCAA)                      | UNCA                |
|                8 | UNIVERSIDAD NACIONAL DE CANINDEYU                     |            1 | UNIVERSIDAD NACIONAL DE CANINDEYU (UNCAN)                     | UNICAN              |
|                9 | UNIVERSIDAD POLITECNICA TAIWAN-PARAGUAY               |            9 | UNIVERSIDAD POLITECNICA TAIWAN-PARAGUAY                       | UNIPOL              |
|               10 | UNIVERSIDAD NACIONAL DE MISIONES                      |            1 | UNIVERSIDAD NACIONAL DE  MISIONES                             | UNAMIS              |

### Clave institucional recomendada

```text
codigo_nivel + codigo_entidad + codigo_oee
```

No se recomienda unir únicamente por `codigo_oee`, porque el mismo código puede repetirse entre entidades diferentes. Para universidades nacionales, el `codigo_nivel = 28` es el filtro institucional principal.

---

## 7. Diccionario funcional: `cotizacion_usd_mensual_utf8.csv`

| Columna      | Tipo sugerido   | Descripción funcional                     | Regla de calidad / normalización   | Uso analítico                                  |
|:-------------|:----------------|:------------------------------------------|:-----------------------------------|:-----------------------------------------------|
| fecha_cierre | DATE            | Fecha de cierre de la cotización mensual. | Parsear como fecha ISO.            | Trazabilidad temporal.                         |
| periodo      | VARCHAR         | Período en formato YYYY-MM.               | Validar coherencia con anho y mes. | Etiqueta temporal.                             |
| anho         | INTEGER         | Año de cotización.                        | Join con anho del hecho.           | Conversión monetaria.                          |
| mes          | INTEGER         | Mes de cotización.                        | Join con mes del hecho.            | Conversión monetaria.                          |
| cotizacion   | DECIMAL(18,4)   | Cotización PYG por 1 USD.                 | Debe ser positiva.                 | Cálculo de montos USD = monto_gs / cotizacion. |
| periodo_id   | INTEGER         | Identificador YYYYMM.                     | Validar con anho*100+mes.          | Clave técnica temporal.                        |

### Regla de conversión sugerida

```sql
monto_usd = monto_gs / cotizacion
```

La cotización debe unirse por `anho` y `mes`. Para análisis financiero formal, conviene documentar si se utiliza cotización de cierre, promedio mensual, compra, venta u otra referencia. En esta fuente, el campo disponible se denomina genéricamente `cotizacion`, por lo que se debe conservar la trazabilidad hacia `fecha_cierre` y `periodo`.

---

## 8. Diccionario funcional: `regimen_salarial_py_utf8.csv`

| Columna                      | Tipo sugerido   | Descripción funcional                 | Regla de calidad / normalización        | Uso analítico                                |
|:-----------------------------|:----------------|:--------------------------------------|:----------------------------------------|:---------------------------------------------|
| anho                         | INTEGER         | Año de vigencia del régimen salarial. | Construir fecha_regimen con anho y mes. | Join temporal por último régimen <= período. |
| mes                          | INTEGER         | Mes de vigencia.                      | Construir fecha_regimen.                | Join temporal.                               |
| mes_nombre                   | VARCHAR         | Nombre del mes de vigencia.           | Normalizar texto.                       | Etiqueta.                                    |
| salario_minimo_mensual       | DECIMAL(18,2)   | Salario mínimo mensual legal.         | Debe ser positivo.                      | Comparación contra remuneración.             |
| salario_por_dia              | DECIMAL(18,2)   | Salario diario.                       | Debe ser positivo.                      | Indicador laboral.                           |
| jornal_por_dia               | DECIMAL(18,2)   | Jornal diario.                        | Debe ser positivo.                      | Referencia de jornal.                        |
| salario_por_hora             | DECIMAL(18,2)   | Salario por hora.                     | Debe ser positivo.                      | Referencia horaria.                          |
| salario_nocturno_mensual     | DECIMAL(18,2)   | Salario nocturno mensual.             | Debe ser positivo.                      | Referencia laboral.                          |
| salario_nocturno_por_dia     | DECIMAL(18,2)   | Salario nocturno diario.              | Debe ser positivo.                      | Referencia laboral.                          |
| jornal_nocturno_por_dia      | DECIMAL(18,2)   | Jornal nocturno diario.               | Debe ser positivo.                      | Referencia laboral.                          |
| salario_nocturno_por_hora    | DECIMAL(18,2)   | Salario nocturno por hora.            | Debe ser positivo.                      | Referencia laboral.                          |
| asignacion_familiar_por_hijo | DECIMAL(18,2)   | Asignación familiar por hijo.         | Debe ser positivo.                      | Beneficios / comparación social.             |
| aporte_patronal              | DECIMAL(18,2)   | Aporte patronal estimado.             | Debe ser positivo.                      | Referencia laboral.                          |
| aporte_empleado              | DECIMAL(18,2)   | Aporte del empleado estimado.         | Debe ser positivo.                      | Referencia laboral.                          |
| salario_neto                 | DECIMAL(18,2)   | Salario neto referencial.             | Debe ser positivo.                      | Comparación.                                 |
| vigente                      | BOOLEAN         | Marca de régimen vigente.             | Convertir a booleano.                   | Selección de referencia vigente.             |

### Regla temporal sugerida

Cuando el régimen salarial no exista para todos los meses del año, se debe aplicar el último régimen conocido cuya fecha sea menor o igual al período analizado:

```sql
fecha_regimen <= fecha_periodo
```

Para 2025, la fuente contiene un registro vigente desde julio de 2025. Por tanto, los meses anteriores deben heredar el régimen anterior disponible si se requiere comparación temporal.

---

## 9. Campos derivados recomendados para la OBT

| Campo derivado            | Tipo sugerido   | Regla / definición                                                                                           | Uso analítico                                                        |
|:--------------------------|:----------------|:-------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------|
| periodo_id                | INTEGER         | anho * 100 + mes.                                                                                            | Clave temporal para joins y BI.                                      |
| periodo_yyyy_mm           | VARCHAR         | Formato YYYY-MM.                                                                                             | Filtro temporal legible.                                             |
| funcionario_hash          | VARCHAR         | Hash de documento y/o atributos mínimos.                                                                     | Anonimización y deduplicación analítica.                             |
| nombre_completo           | VARCHAR         | Concatenación normalizada de nombres y apellidos.                                                            | Solo para entorno académico controlado; no publicar si se anonimiza. |
| descripcion_entidad       | VARCHAR         | Nombre de universidad nacional.                                                                              | Dimensión institucional.                                             |
| descripcion_oee           | VARCHAR         | Nombre de OEE/facultad/rectorado.                                                                            | Dimensión institucional.                                             |
| objeto_gasto_descripcion  | VARCHAR         | Descripción del objeto de gasto.                                                                             | Interpretación salarial.                                             |
| tipo_componente_salarial  | VARCHAR         | Clasificación derivada: salario básico, bonificación, beneficio, viáticos, aguinaldo, representación, otros. | Composición de la remuneración.                                      |
| monto_devengado_gs        | DECIMAL(18,2)   | Monto devengado por línea/componente.                                                                        | Métrica base.                                                        |
| monto_devengado_usd       | DECIMAL(18,4)   | monto_devengado_gs / cotizacion_usd.                                                                         | Comparabilidad monetaria.                                            |
| remuneracion_total_gs     | DECIMAL(18,2)   | Suma de devengado por funcionario, período e institución.                                                    | Métrica principal agregada.                                          |
| remuneracion_total_usd    | DECIMAL(18,4)   | Remuneración total convertida a USD.                                                                         | Métrica principal en USD.                                            |
| pct_salario_basico        | DECIMAL(9,4)    | Salario básico / remuneración total.                                                                         | Composición salarial.                                                |
| pct_bonificaciones        | DECIMAL(9,4)    | Bonificaciones / remuneración total.                                                                         | Composición salarial.                                                |
| pct_viaticos              | DECIMAL(9,4)    | Viáticos / remuneración total.                                                                               | Composición salarial.                                                |
| edad                      | INTEGER         | Edad calculada desde fecha_nacimiento al período.                                                            | Segmentación demográfica.                                            |
| rango_etario              | VARCHAR         | Bandas sugeridas: <25, 25-34, 35-44, 45-54, 55-64, 65+.                                                      | Segmentación demográfica.                                            |
| generacion                | VARCHAR         | Gen Z, Millennials, Gen X, Baby Boomers u otra regla documentada.                                            | Segmentación generacional.                                           |
| antiguedad_anhos          | INTEGER         | anho - anho_ingreso, solo si anho_ingreso válido.                                                            | Trayectoria laboral.                                                 |
| rango_antiguedad          | VARCHAR         | Bandas sugeridas: 0-2, 3-5, 6-10, 11-20, 21+.                                                                | Segmentación laboral.                                                |
| tipo_funcionario_inferido | VARCHAR         | Docente, administrativo u otro; inferencia limitada por campos disponibles.                                  | No debe tratarse como dato oficial sin cargo/función.                |
| percentil_salarial_oee    | DECIMAL(9,4)    | Percentil dentro del OEE y período.                                                                          | Concentración y distribución.                                        |
| ranking_salarial_oee      | INTEGER         | Ranking dentro de OEE y período.                                                                             | Top remuneraciones.                                                  |
| brecha_promedio_oee_gs    | DECIMAL(18,2)   | Remuneración total - promedio OEE.                                                                           | Brecha institucional.                                                |
| brecha_mediana_oee_gs     | DECIMAL(18,2)   | Remuneración total - mediana OEE.                                                                            | Brecha institucional robusta.                                        |
| categoria_remuneracion    | VARCHAR         | Alta, media, baja con umbrales documentados.                                                                 | Segmentación de BI.                                                  |

---

## 10. Reglas de normalización recomendadas

### 10.1. Nombres y texto

- Convertir a mayúsculas.
- Aplicar `TRIM`.
- Reemplazar múltiples espacios por uno solo.
- Remover caracteres invisibles como BOM (`CHR(65279)`).
- Evaluar remoción de tildes solo para claves de comparación; preservar texto original si se requiere presentación institucional.

### 10.2. Fechas

- Parsear `fecha_nacimiento` y `fecha_acto` con formatos `YYYY/MM/DD HH:MM:SS.fff` y `YYYY-MM-DD`.
- Validar `fecha_nacimiento` en un rango razonable, por ejemplo `1900-01-01` a fecha del período.
- Validar `fecha_acto` en un rango administrativo razonable; los valores con año `0002` o `4752` deben marcarse como inválidos.

### 10.3. Montos

- Convertir `presupuestado` y `devengado` a `DECIMAL(18,2)`.
- Rechazar o marcar importes negativos.
- Preservar importes cero, pero diferenciarlos entre: cero legítimo, no devengado, error de carga o registro administrativo.

### 10.4. Identificadores personales

- No tipar `documento` como entero.
- Generar `funcionario_hash` para publicación, tableros o datasets compartidos.
- Evitar publicar nombres, apellidos y documento juntos fuera de un entorno académico controlado.

---

## 11. Supuestos explícitos

1. La fuente principal corresponde al periodo fiscal 2025.
2. Los montos están expresados en guaraníes paraguayos.
3. `devengado` se considera la métrica monetaria principal para análisis de remuneración ejecutada.
4. `presupuestado` se conserva como métrica complementaria para comparar asignación versus ejecución.
5. El clasificador OEE es la referencia institucional preferente para etiquetas de universidad, facultad y rectorado.
6. El clasificador de gastos es la referencia semántica preferente para interpretar `objeto_gasto`.
7. La clasificación docente/administrativo no debe declararse como oficial si no se dispone de `cargo` o `funcion`.
8. `fecha_acto` describe el acto administrativo asociado, no necesariamente la fecha real de ingreso laboral.

---

## 12. Decisiones pendientes

| Decisión | Riesgo si no se resuelve | Recomendación |
|---|---|---|
| Publicación de datos personales | Exposición innecesaria de información identificable. | Usar hash y excluir nombres/documento en datasets públicos. |
| Definición de remuneración total | Doble conteo o inclusión de conceptos no salariales. | Documentar qué objetos de gasto integran la métrica oficial. |
| Clasificación docente/administrativo | Segmentación débil o sesgada. | Usar `cargo`, `funcion` o reglas validadas con dominio. |
| Tratamiento de `anho_ingreso = 0` | Antigüedad incorrecta. | Marcar como no informado; no imputar sin evidencia. |
| Tratamiento de fechas anómalas | Edades o vigencias absurdas. | Aplicar reglas de rango y columna de bandera de calidad. |
| Tipo de cotización USD | Conversión monetaria ambigua. | Documentar si es cierre, promedio, venta o compra. |

---

## 13. Conclusión técnica

El conjunto de fuentes es suficiente para construir una OBT analítica robusta de remuneraciones universitarias públicas si se respetan tres condiciones: preservar el grano por componente remunerativo, integrar institucionalmente con clave compuesta `nivel-entidad-oee`, y separar los datos personales de las métricas publicables. La debilidad principal no está en los montos, sino en la semántica laboral fina: sin `cargo`, `funcion` o `concepto`, la clasificación docente/administrativo debe considerarse una inferencia incompleta.
