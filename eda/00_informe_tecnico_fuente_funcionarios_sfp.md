<div align="center">
  <img src="../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
  <h1>FPUNA · BIG DATA · LAB</h1>
  <h3>Repositorio académico y técnico para laboratorios de Big Data e Ingeniería de Datos</h3>
</div>

---

# Informe Técnico: Caracterización de Datos de Remuneraciones del Sector Público (Paraguay)

### Portal de datos abiertos de remuneraciones de funcionarios públicos: `https://datos.sfp.gov.py/data/funcionarios`

Los datos publicados en este portal son obtenidos del *SICCA* actualizados mensualmente. La veracidad o contenido de los datos son responsabilidad exclusiva del OEE.

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción 

---

## Fecha y versión

- **Fecha:** 26/03/2026
- **Versión:** 1.0

---

### Resumen
El **proyecto de ley de equidad de remuneración en Paraguay**, impulsado hacia 2025-2026, busca principalmente establecer salarios justos en el sector público, limitando los ingresos superiores al del Presidente de la República, racionalizando el gasto y garantizando *"igual salario por igual trabajo"*. 
Se enfoca en eliminar privilegios, transparentar la escala salarial y regular descuentos/embargos a funcionarios.

El Estado paraguayo busca establecer un **tope salarial** vinculado a la remuneración del Presidente de la República y racionalizar beneficios adicionales (seguros, combustibles, bonificaciones). 
Para un **Ingeniero de Datos**, esto implica preparar los datos para que puedan ser analizados por un **Científico de Datos**. En la práctica, significa transformar una base de datos administrativa en un tablero de control orientado a la equidad y la transparencia.

---
## 1. Identificación y Contexto del Proyecto

### 1.1 Marco Institucional y Propósito
El presente informe se enmarca en el análisis técnico de la implementación del **"Régimen de Equidad en las Remuneraciones del Sector Público"** en Paraguay. El objetivo primordial de esta iniciativa legislativa es la racionalización del gasto estatal mediante la imposición de un límite máximo a la remuneración total percibida por cualquier actor del sector público, tomando como umbral de referencia la asignación vigente del **Presidente de la República**.

Desde la perspectiva de la Ingeniería de Datos, este proyecto trasciende la simple auditoría contable para convertirse en un desafío de **Integración de Datos Masivos**, orientado a garantizar la transparencia y la equidad distributiva de los recursos del Tesoro Nacional.

### 1.2 Alcance y Universo de Análisis (Data Universe)
Para que el análisis sea exhaustivo y cumpla con el espíritu de la ley, el universo de datos no se limita a la administración central, sino que abarca la totalidad de los **Organismos y Entidades del Estado (OEE)**, desglosados en:

* **Administración Central:** Ministerios, Secretarías y entes dependientes del Presupuesto General de la Nación (PGN).
* **Entidades Descentralizadas:** Empresas Públicas, Entes Autónomos y Gobiernos Departamentales/Municipales.
* **Entidades Binacionales (Itaipú y Yacyretá):** Este segmento constituye el punto crítico de análisis debido a sus regímenes salariales diferenciados y la complejidad de acceso a sus estructuras de beneficios adicionales (Seguros VIP, bonificaciones por desarraigo, etc.).
* **Poderes Legislativo y Judicial:** Sujetos a la normativa de tope salarial para garantizar la equidad inter-poderes.

### 1.3 Origen de la Información y Flujo de Datos
Si bien la interfaz pública de consulta es el **Portal de Datos Abiertos de la ex Secretaría de la Función Pública (SFP)**, actualmente como **Viceministerio de Capital Humano y Gestión Organizacional (VCHGO)** del **Ministerio de Economía y Finanzas (MEF)**. El ecosistema de datos de esta revisión identifica tres fuentes primarias para asegurar la veracidad del análisis:

1.  **SICCA (Sistema de Información de Capital Humano - SFP):** Fuente de datos administrativos sobre cargos, categorías y movimientos de personal.
2.  **SNT (Sistema Nacional de Tesorería - Ministerio de Economía y Finanzas):** Fuente de la verdad financiera donde se registran los desembolsos reales bajo el **Grupo de Objeto de Gasto 100 (Servicios Personales)**.
3.  **Fuentes Externas (Binacionales):** Datos reportados bajo convenios de transparencia específicos que deben ser normalizados e integrados al modelo de datos centralizado.

> **Nota:** El portal de la SFP suele presentar datos **"pre-procesados"** por cada OEE. En ingeniería de datos, esto es un riesgo de Veracidad.

### 1.4 Aspectos Clave del Proyecto de Equidad (Sector Público - 2026)
- **Techo Salarial:** Ningún funcionario público podrá ganar más que el Presidente de la República.
- **Principio de Equidad:** Se busca asegurar un salario igual para trabajos, cargos y jornadas idénticas, eliminando disparidades entre instituciones.
- **Salario Global:** La remuneración se estructurará como un salario global, buscando eliminar bonificaciones desproporcionadas y establecer una escala salarial transparente.
Profesionalización: El objetivo es atraer y retener personal idóneo bajo principios de competencia.

### 1.5. Contexto y Normativas Relacionadas
- **Ley N° 7445/2025 de la Función Pública y del Servicio Civil:** Esta normativa (aprobada recientemente) es el marco que busca la profesionalización y mayor eficiencia del personal público.
- **Ley N° 7564/2025 de Descuentos/Embargos:** Establece procedimientos y límites a descuentos sobre salarios públicos para proteger la capacidad económica del trabajador.
- **Equidad de Género:** Existen iniciativas anteriores (presentadas por legisladores como Salyn Buzarquis en 2022) que buscaban la igualdad salarial entre hombres y mujeres en ambos sectores. 

> **Nota:** El debate sobre la **equidad salarial en Paraguay** incluye la necesidad de "regularizar" situaciones del personal de blanco y la sostenibilidad financiera de la Caja Fiscal.

### 1.6 Objetivos Técnicos del Informe
* **Diagnóstico de Calidad:** Evaluar la integridad de los datos de remuneraciones (presencia de valores nulos o inconsistencias en los campos de "Beneficios").
* **Arquitectura de Integración:** Definir los requisitos para un pipeline de Big Data capaz de consolidar múltiples fuentes bajo una **Identidad Única de Funcionario** (Entity Resolution).
* **Monitoreo de Anomalías:** Establecer las bases para la detección automatizada de remuneraciones que excedan el tope presidencial en la sumatoria de todos sus conceptos.

---
## 2. Estructura Técnica del Dato Administrativo y Naturaleza de la Fuente (datos.sfp.gov.py)
El portal histórico de la SFP provee datos estructurados (generalmente en formatos `.csv` o vía API) que detallan la nómina estatal. Al realizar el EDA, se identificarán las siguientes dimensiones clave:

### A. Identificación y Jerarquía
* **OEE (Organismo o Entidad del Estado):** Variable categórica que permite segmentar por Ministerios, Entidades Binacionales, Gobiernos Departamentales o Municipalidades.
* **Línea Presupuestaria:** Código que vincula el cargo con el Presupuesto General de la Nación (PGN).

### B. Composición de la Remuneración (El foco del Proyecto de Ley)
Los datos no presentan un único campo de "sueldo", sino una suma de conceptos que el EDA debe desglosar:
1.  **Sueldo Base (Objeto de Gasto 111):** La asignación fija según el cargo.
2.  **Bonificaciones y Gratificaciones (Objeto de Gasto 133):** Aquí suelen esconderse los "privilegios indebidos" (antigüedad, responsabilidad en el cargo, grado académico, etc.).
3.  **Gastos de Representación:** Asignación fija para cargos jerárquicos.
4.  **Otros Beneficios:** Subsidios para salud, bonos por alimentación y premios por productividad.

Aquí tienes el contenido desarrollado para el **Bloque 2**, diseñado con un enfoque de ingeniería de datos para asegurar que la fase de Análisis Exploratorio de Datos (EDA) tenga una base sólida de granularidad y normalización.

### 2.1 Definición de la Unidad Mínima de Análisis (UMA)
Para la ejecución de un proyecto de Big Data orientado a la equidad salarial, es imperativo trascender la vista superficial del "registro por fila" y definir una **Unidad Mínima de Análisis** compuesta. En este ecosistema, la UMA se define como el conjunto atómico de datos que permite identificar de forma inequívoca el flujo financiero desde el Tesoro hacia el funcionario.

La clave primaria lógica (o *composite key*) para este modelo se constituye por el triplete:
**`Número de Cédula` + `Código de OEE` + `Objeto de Gasto`**

### 2.2 Desglose de Componentes de la UMA

1.  **Número de Cédula (Identificador Único de Sujeto):**
    * **Función:** Actúa como el eje de vinculación (Join Key) entre diferentes instituciones.
    * **Relevancia Técnica:** Permite detectar la **multivinculación**. Sin este campo normalizado, sería imposible determinar si un funcionario percibe ingresos de dos o más OEE de forma simultánea, un factor crítico para el cumplimiento del tope presidencial.

2.  **Código de OEE (Organismo o Entidad del Estado):**
    * **Función:** Identifica la fuente administrativa del recurso.
    * **Relevancia Técnica:** Clasifica el origen del gasto (Administración Central vs. Entidades Binacionales). Este código permite segmentar el análisis por jerarquías institucionales y aplicar las reglas de negocio específicas de la Ley de Equidad según la naturaleza de la entidad.

3.  **Objeto de Gasto (Clasificador Presupuestario):**
    * **Función:** Define la naturaleza económica del pago.
    * **Relevancia Técnica:** Es el componente que permite identificar los **"privilegios indebidos"**. En lugar de analizar un monto global, el Big Data Pipeline debe desagregar los códigos del Presupuesto General de la Nación (PGN), tales como:
        * **111:** Sueldo Base.
        * **113:** Gastos de Representación.
        * **133:** Bonificaciones y Gratificaciones (Foco de racionalización).
        * **191:** Subsidio para la Salud.

### 2.3 Atributos Complementarios y Metadatos
Para enriquecer la UMA, cada registro debe acompañarse de los siguientes metadatos técnicos que facilitarán el análisis de derivas (*drifts*):

* **Periodo (Mes/Año):** Variable temporal para análisis de series de tiempo y detección de pagos extraordinarios (ej. aguinaldos o premios anuales).
* **Modalidad de Vinculación:** Variable categórica (Permanente, Contratado, Comisionado) para evaluar la estabilidad y legalidad del gasto.
* **Monto Nominal vs. Monto Percibido:** Diferenciación técnica necesaria para el análisis de descuentos y embargos mencionados en el proyecto de ley.

### 2.4 Relevancia para el Proceso de Ingesta (ETL)
La adopción de esta estructura técnica garantiza que, durante la fase de transformación (T), los datos puedan ser agregados (pivoteados) por `Número de Cédula` para obtener la **Remuneración Real Mensual**. 

Este enfoque permite que el científico de datos no solo visualice promedios, sino que identifique con precisión quirúrgica qué objeto de gasto específico es el que dispara el salario de un funcionario por encima del umbral permitido, permitiendo una toma de decisiones legislativa basada en evidencia granular.

---
## 3. Identificación de "Privilegios Indebidos" mediante EDA
Para que el análisis sea efectivo en función del proyecto de ley, se deben rastrear las siguientes anomalías:

* **Remuneración Total Excedente:** Cálculo de la sumatoria de todos los conceptos por número de cédula (identificador único) para comparar contra el umbral del salario presidencial.
* **Multivinculación:** Identificación de funcionarios que perciben remuneraciones de dos o más OEE simultáneamente.
* **Anomalías en Beneficios No Salariales:** Análisis de la dispersión en los gastos de "Combustible" o "Seguros Médicos VIP", donde la varianza entre instituciones puede indicar falta de equidad.

---
## 4. Desafíos Técnicos para el Ingeniero de Datos (Data Drift)
Desde la perspectiva de la **Ingeniería de Datos**, el reto no es solo analizar la información, sino construir la "tubería" (pipeline) robusta, escalable y confiable que permita que el análisis de remuneraciones sea posible. En el contexto de los datos de la SFP de Paraguay y el nuevo proyecto de ley, los desafíos técnicos se vuelven críticos debido a la sensibilidad de la información.

Aquí te presento los principales desafíos técnicos para el Ingeniero de Datos en este proyecto:

### 4.1. Ingesta y Orquestación de Fuentes Fragmentadas
El portal de la SFP consolida datos de cientos de Organismos y Entidades del Estado (OEE). El desafío técnico radica en:
* **Diversidad de Formatos:** Algunos entes suben archivos `.csv` limpios, mientras que otros pueden reportar mediante formatos menos estructurados o APIs con diferentes versiones.
* **Frecuencia de Actualización:** El sistema debe ser capaz de realizar ingestas mensuales automáticas sin romper los datos históricos, gestionando lo que llamamos *Data Drift* (cuando la estructura de los datos cambia de un mes a otro sin previo aviso).


### 4.2. Construcción de una "Verdad Única" (Entity Resolution)
Este es quizás el mayor reto en el sector público paraguayo. Un funcionario puede aparecer en la planilla del Ministerio de Salud y también en la de una Universidad Nacional. 
* **El desafío:** Implementar procesos de **Deduplicación y Vinculación de Entidades**. Si un nombre está mal escrito en una base pero el número de cédula es el mismo, el ingeniero debe asegurar que el sistema los reconozca como la misma persona para calcular la "Remuneración Total" de forma precisa. Sin esto, el "Tope Salarial Presidencial" no se podría calcular correctamente.

### 4.3. Implementación de Reglas de Negocio Complejas (ETL/ELT)
El proyecto de ley menciona "Beneficios: seguro médico, vehículos, combustible". Estos no siempre vienen en una sola columna.
* **Normalización de Objetos de Gasto:** El ingeniero debe mapear los códigos presupuestarios (ej. Gasto 113, 133, 191) a categorías lógicas que el Científico de Datos pueda usar. 
* **Cálculos Agregados en Tiempo Real:** Diseñar transformaciones que sumen sueldos, bonificaciones, gastos de representación y subsidios para cada individuo, aplicando filtros de exclusión (como el aguinaldo, que generalmente está exento de topes) de manera programática y eficiente.

### 4.4. Calidad y Gobernanza de Datos (Data Quality)
En un proyecto de ley de "Racionalización", un error en los datos puede tener consecuencias legales o políticas graves. 
* **Validaciones Automatizadas:** Implementar *Great Expectations* o validaciones similares en el pipeline para detectar si un sueldo viene con un cero de más o si hay campos obligatorios vacíos antes de que lleguen al reporte final.
* **Linaje de Datos (Data Lineage):** El ingeniero debe poder demostrar de dónde salió cada número. Si se afirma que un funcionario gana más que el Presidente, el sistema debe permitir rastrear el dato exacto hasta el archivo original de la SFP.

### 4.5. Seguridad y Privacidad (PII - Personally Identifiable Information)
Trabajar con remuneraciones implica manejar nombres y números de cédula. 
* **Anonimización vs. Transparencia:** El desafío técnico es equilibrar la Ley de Transparencia con la seguridad informática. El ingeniero debe decidir qué datos se almacenan en texto claro y cuáles deben ser hasheados o encriptados en las capas intermedias de procesamiento para evitar filtraciones masivas de datos sensibles de los funcionarios.

### 4.6. Escalabilidad del Histórico
El portal de la SFP es "histórico". Analizar la evolución de los gastos públicos de los últimos 10 años requiere:
* **Optimización de Almacenamiento:** Decidir entre un Data Lake (para los archivos crudos) y un Data Warehouse (para los datos transformados y listos para consulta).
* **Particionamiento:** Organizar los datos por año y mes para que las consultas de los analistas no tarden horas en ejecutarse sobre millones de registros.

> **¿Qué es el Data Drift?**
> - **Definición:** Es la variación en la distribución de los datos de entrada respecto a la distribución original usada para entrenar un modelo.
> - **Ejemplo práctico:** Un modelo de predicción de fraude entrenado con datos de transacciones de 2024 puede fallar en 2026 si cambian los patrones de consumo o los métodos de pago.
> - **Impacto:** Reduce la precisión, aumenta los falsos positivos/negativos y puede invalidar decisiones críticas.

---
## 5. Desafíos Técnicos para el Científico de Datos (Data Profiling)
Antes de procesar, se deben considerar estos aspectos críticos del portal de la SFP:

1.  **Calidad de los Datos (Data Cleansing):** Es común encontrar variaciones en los nombres de los cargos (ej. "Director" vs "Dir.") que requieren normalización con `stringr` o técnicas de *fuzzy matching*.
2.  **Datos Faltantes (NAs):** El portal histórico puede tener lagunas en meses específicos o en ciertas municipalidades que no reportan a tiempo. Es vital usar herramientas como `naniar` para visualizar estos vacíos.
3.  **Valores Atípicos (Outliers):** Un funcionario con una bonificación extraordinariamente alta en un mes puntual podría deberse a un pago de aguinaldo o liquidación, no necesariamente a un privilegio permanente. El EDA debe distinguir entre *pagos únicos* y *gastos recurrentes*.

> **¿Qué implica el Data Profiling?**
> - **Definición:** Conjunto de técnicas para revisar y resumir datos, evaluando su estado y calidad.
> - **Objetivo principal:** Obtener un entendimiento claro de la estructura (tipos de datos, formatos), contenido (valores únicos, distribuciones) y relaciones entre variables.
> - **Resultado esperado:** Metadatos que describen los datos y permiten decidir si son confiables para análisis o integración

---
## 6. Propuesta de Indicadores Clave (KPIs) para el Análisis
Para sustentar el proyecto de ley, el EDA debería generar:
* **Índice de Brecha Presidencial:** Porcentaje de funcionarios que superan el sueldo del Ejecutivo.
* **Ratio de Beneficios/Sueldo:** Qué porcentaje de la remuneración total corresponde a beneficios adicionales vs. sueldo base.
* **Concentración del Gasto:** Identificación de las 5 instituciones que consumen mayor presupuesto en "Gastos Personales" (Grupo 100).

---
## 7. Análisis de Complejidad bajo el Modelo de las 5V del Big Data

Aunque el volumen total de registros (la nómina pública) puede no alcanzar los petabytes que manejan las Big Tech, este proyecto presenta una **complejidad estructural y de veracidad** que encaja perfectamente en el paradigma de las **5 V's del Big Data**.

A continuación, se justifica por qué este análisis de remuneraciones debe abordarse bajo esta metodología:

### 7.1. Volumen (Volume)
Aunque la nómina de Paraguay tiene aproximadamente 800.000 a 1.000.000 registros por mes, el desafío del **portal histórico** es el acumulado.
* **Por qué:** Para identificar "privilegios" o "gastos innecesarios", no basta con mirar el mes actual. Se requiere analizar series temporales de 5 a 10 años. Multiplicar 1.000k registros por 120 meses (10 años) genera millones de puntos de datos que superan la capacidad de herramientas de oficina tradicionales (como Excel) y requieren motores de procesamiento como Spark o bases de datos optimizadas.

### 7.2. Velocidad (Velocity)
En el contexto de una nueva ley de control, la velocidad no se refiere solo a la rapidez de la ingesta, sino a la **capacidad de respuesta**.
* **Por qué:** El sistema debe ser capaz de procesar las actualizaciones mensuales de todos los Organismos y Entidades del Estado (OEE) de manera ágil. Además, si el proyecto de ley busca auditorías en tiempo real, la infraestructura debe permitir consultas complejas (como detectar un doble cobro en el momento que ocurre) sin retrasos.

### 7.3. Variedad (Variety)
Este es uno de los puntos más fuertes en este proyecto. Los datos de remuneraciones no son uniformes.
* **Por qué:** Los datos provienen de fuentes heterogéneas. Las Binacionales (Itaipú/Yacyretá) tienen estructuras salariales distintas a los Ministerios, y estos a su vez difieren de las Municipalidades. Integrar archivos CSV, JSON de APIs, y posiblemente PDFs escaneados de resoluciones sobre "combustibles" o "vehículos" representa un reto de variedad técnica masivo.

### 7.4. Veracidad (Veracity)
Para un proyecto de ley que busca "garantizar la transparencia", la calidad del dato es sagrada.
* **Por qué:** Los datos públicos suelen tener "ruido": nombres mal escritos, números de cédula erróneos o campos vacíos. Como vimos en el error de `naniar`, los datos faltantes pueden sesgar el análisis. En Big Data, la veracidad implica limpiar y validar que la suma de "Bonificaciones + Sueldo + Seguro" sea realmente el ingreso percibido y no un error de carga del OEE. Sin veracidad, la ley se aplicaría sobre premisas falsas.

### 7.5. Valor (Value)
Esta es la V más importante para el legislador y el ciudadano.
* **Por qué:** El valor de este Big Data no es el dato en sí, sino el **conocimiento extraído**. El valor radica en transformar millones de filas en hallazgos accionables: "¿Cuánto dinero recuperaría el Estado si se eliminan los seguros VIP?", "¿Quiénes son los funcionarios que superan el tope presidencial?". El valor es la **racionalización del gasto** basada en evidencia.

---
## 8. Diagnóstico desde la Ingeniería de Datos
Desde el diseño de patrones ETL, este proyecto es un caso de estudio ideal porque:
1.  **Requiere integración de silos:** Cada ente público es un "silo" de datos.
2.  **Necesita Entity Resolution:** Determinar que "Juan Pérez" en el Ministerio A es el mismo "Juan Pérez" en la Entidad B.
3.  **Análisis de Outliers:** Identificar salarios que se escapan de la norma estadística (el "top 1%") para detectar privilegios indebidos.

> **Nota:** Abordar esto como un problema de Big Data permite que la solución sea **escalable**. Si hoy regulamos salarios, mañana la misma infraestructura de datos puede auditar licitaciones de vehículos o cupos de combustible utilizando las mismas 5 V's.

---
## 9. Conclusiones
La base de datos de la SFP es un **reflejo financiero de la estructura del Estado**. El éxito del EDA no radicará en contar filas, sino en la capacidad de **pivotar y agregar** los datos por individuo para revelar la "Remuneración Real Total", permitiendo que los legisladores tomen decisiones basadas en evidencia científica y no en percepciones.

Mientras el **Científico de Datos** busca el *insight* (¿quiénes ganan más?), el **Ingeniero de Datos** garantiza la *integridad del pipeline*. Sin una ingeniería sólida, el proyecto de ley correría el riesgo de basarse en datos duplicados, incompletos o mal calculados.

### 9.1 Metodología y Perfiles

- Se sugiere aplicar la metodología **CRISP-DM** adaptada a Ciencia de Datos.
  - Comprensión del Negocio (la Ley) → Comprensión de Datos → Preparación → Modelado → Evaluación.
- El perfil de **Ingeniero de Datos:** Responsable de la ingesta (ETL), limpieza y resolución de entidades (deduplicación de funcionarios).
- El perfil de **Científico de Datos:** Responsable del análisis de outliers salariales y visualización de brechas de equidad.

---
## 10. Referencias

- [Diputados - Noticias](https://www.diputados.gov.py/noticias/noticias/533)
- [Ñandutí - Proyecto de ley sobre equidad salarial](https://nanduti.com.py/plantean-proyecto-de-ley-para-buscar-la-equidad-en-el-salario-del-personal-de-blanco)
- [Congreso - Expediente 126328](https://ods.congreso.gov.py/expedientes/126328)
- [ADN Digital - Tope salarial en el Senado](https://www.adndigital.com.py/proponen-en-el-senado-tope-salarial-para-funcionarios-publicos/)
- [Hoy - Ley sobre salarios de funcionarios públicos](https://www.hoy.com.py/nacionales/2026/03/30/plantean-ley-para-que-ningun-funcionario-gane-mas-que-el-presidente-de-la-republica)

---

## ANEXO A - Mapa Conceptual: Calidad y Evolución de Datos en Big Data

### Data Profiling
- **Definición:** Análisis inicial de los datos para entender su estructura, contenido y calidad.
- **Objetivo:** Garantizar que los datos sean consistentes, completos y útiles.
- **Relación:** Es la primera línea de defensa antes de entrenar modelos o construir tableros.

### Data Drift
- **Definición:** Cambio en la distribución de los datos de entrada con el tiempo.
- **Ejemplo:** Variación en la edad promedio de clientes respecto al dataset original.
- **Impacto:** Los modelos pierden precisión porque los datos ya no se parecen a los de entrenamiento.
- **Relación:** Detectado gracias a monitoreo continuo y técnicas de *profiling*.

### Concept Drift
- **Definición:** Cambio en la relación entre variables de entrada y la variable objetivo.
- **Ejemplo:** Lo que antes indicaba “fraude” ya no lo hace debido a nuevas prácticas.
- **Impacto:** El modelo deja de capturar correctamente el fenómeno que predice.
- **Relación:** Puede ocurrir incluso si los datos no cambian en apariencia (no hay *data drift*).

### Model Drift
- **Definición:** Degradación del rendimiento del modelo en producción.
- **Causas:** Data Drift, Concept Drift, cambios operativos o tecnológicos.
- **Impacto:** Resultados poco confiables en decisiones críticas.
- **Relación:** Es la consecuencia observable de los otros tipos de drift.

### Conexiones Clave
- **Data Profiling → Prevención:** Detecta problemas antes de entrenar modelos.
- **Data Drift → Señal temprana:** Indica que los datos cambian con el tiempo.
- **Concept Drift → Cambio profundo:** Señala que la lógica entre variables y resultados ya no es válida.
- **Model Drift → Resultado final:** El modelo pierde precisión y requiere reentrenamiento.

---
