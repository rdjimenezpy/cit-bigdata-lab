
# Prompt optimizado y estructurado con técnicas de Ingeniería de Prompts para EDA

---

## Prompt 1: Creación de notebook para EDA en Python (Google Colab)

---

Actúa como un experto Científico de Datos Senior con amplia experiencia realizando Análisis de Datos Exploratorio (EDA) utilizando Python en Google Colab, aplicando las mejores prácticas tanto en el ámbito académico como profesional.

**Contexto del Proyecto:**

Me encuentro desarrollando un proyecto final integrador para el curso "Introducción a Big Data, Nivel Básico". El proyecto consiste en el análisis de gastos de remuneraciones a funcionarios públicos del Estado Paraguayo. El objetivo actual es realizar un EDA profundo y metodológico sobre el dataset crudo para entender los datos, identificar problemas de calidad y extraer insights valiosos. Este paso es fundamental antes de aplicar un modelado de datos analítico (como un esquema en estrella o un modelo moderno OBT).


**Recursos y Documentación Base (Archivos adjuntos en este chat):**

Antes de generar cualquier código, debes leer, analizar y construir una base de conocimiento sólida a partir de los siguientes archivos que te he proporcionado:

1. `00_informe_tecnico_fuente_funcionarios_sfp.md` (Contexto general e ideas del proyecto).

2. `00_diccionario_fuente_funcionarios_sfp.md` y `01_resumen_fuente_funcionarios_sfp.md` (Documentación técnica y reglas del dataset).

3. `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md` (Guía de la primera práctica general de EDA para alinear el enfoque).

4. `funcionarios_2026_1_sample100k.csv` (Muestra de 100k registros para que comprendas la estructura real de los datos).


**Tu Misión:**

Una vez asimilado el contexto, genera el código y las explicaciones necesarias para estructurar una Jupyter Notebook (.ipynb) lista para ejecutarse en Google Colab utilizando el archivo origen completo: `funcionarios_2026_1.csv`.

**Requerimientos técnicos y fases del EDA:**

El código debe estar dividido lógicamente simulando celdas de Colab (Markdown para explicaciones, Python para código) e incluir las siguientes etapas:

1. **Importación y Configuración:** Carga de las librerías necesarias (pandas, numpy, matplotlib, seaborn, etc.) y lectura del dataset crudo. Configuración de la estética de los gráficos. El archivo origen 'funcionarios_2026_1.csv' debe ser importado desde la ruta de Google Drive base: `/Labs/Dataset/raw/`

2. **Inspección, Selección y Tipado:** - Filtrado de las columnas relevantes para el análisis.

   - Conversión de tipos de datos correctos (casting de fechas, numéricos, categóricos).

3. **Limpieza de Datos:** Tratamiento de valores nulos, duplicados y estandarización de strings.

4. **Ingeniería de Características (Feature Engineering):**

   - Calcular una nueva columna `descuento` obtenida de la resta: `valor presupuestado` - `devengado`.

   - Calcular la `edad` actual de los funcionarios a partir de su fecha de nacimiento.

   - Calcular la `antiguedad` (en años) a partir de la fecha de ingreso.

5. **Exploración y Análisis Estadístico:**

   - Aplicar técnicas de estadística descriptiva.

   - Identificación y cuantificación de valores atípicos (outliers) utilizando métodos robustos (ej. IQR).

6. **Visualización de Datos (Data Storytelling):** Generar gráficos con calidad profesional (títulos, etiquetas, paletas de colores adecuadas). Incluir obligatoriamente:

   - Histogramas para analizar distribuciones (ej. edades, salarios).

   - Boxplots (Cajas) para la identificación visual de outliers cruzando variables categóricas (ej. salarios por ministerio o cargo).

   - Otros gráficos que consideres pertinentes según la naturaleza del dataset.

7. **Interpretación y Conclusiones:** Como Científico de Datos Senior, en las celdas Markdown debes interpretar qué nos dice cada gráfico o tabla estadística y qué consideraciones o advertencias debemos tener en cuenta para la siguiente fase de modelado analítico.

**Formato de Salida:**

Estructura tu respuesta separando claramente las `[CELDAS MARKDOWN]` de las `[CELDAS DE CÓDIGO]` en Python. El código debe ser limpio, modular, estar comentado y seguir el estándar PEP-8.

---

### Uso:

1. Abre un nuevo chat en Gemini (o en tu modelo de preferencia).

2. **Sube primero todos los archivos mencionados** (`.md` y `.csv`).

3. Pega el prompt exactamente como está arriba.

4. El modelo asimilará los documentos y te devolverá una estructura de código altamente profesional, pensada exactamente para las reglas de negocio de tu fuente del Estado Paraguayo. Puedes copiar y pegar fácilmente cada bloque en tu entorno de Colab.

---

## Prompt 2: Creación de notebook para EDA en R (Google Colab)

---

Actúa como un experto Científico de Datos Senior con amplia experiencia realizando Análisis de Datos Exploratorio (EDA) utilizando el lenguaje R en Google Colab, aplicando las mejores prácticas metodológicas en el ámbito académico y profesional.

**Contexto del Proyecto:**
Me encuentro desarrollando un proyecto final integrador para el curso "Introducción a Big Data, Nivel Básico". El proyecto consiste en el análisis de gastos de remuneraciones a funcionarios públicos del Estado Paraguayo. El objetivo actual es realizar un EDA profundo sobre el dataset crudo para entender los datos, identificar problemas de calidad y extraer insights valiosos. Este paso es fundamental antes de aplicar un modelado de datos analítico (como un esquema en estrella o un modelo moderno OBT).

**Recursos y Documentación Base (Archivos adjuntos en este chat):**
Antes de generar cualquier código, debes leer, analizar y construir una base de conocimiento sólida a partir de los siguientes archivos que te he proporcionado:
1. `00_informe_tecnico_fuente_funcionarios_sfp.md` (Contexto general e ideas del proyecto).
2. `00_diccionario_fuente_funcionarios_sfp.md` y `01_resumen_fuente_funcionarios_sfp.md` (Documentación técnica y reglas del dataset).
3. `02_guia_practica_eda_sql_duckdb_funcionarios_sfp.md` (Guía de la primera práctica general de EDA para alinear el enfoque).
4. `funcionarios_2026_1_sample100k.csv` (Muestra de 100k registros para comprender la estructura real).

**Tu Misión:**
Una vez asimilado el contexto, genera el código en R y las explicaciones necesarias para estructurar una Jupyter Notebook (.ipynb) lista para ejecutarse en Google Colab (utilizando un kernel de R). El análisis final se ejecutará sobre el archivo origen completo: `funcionarios_2026_1.csv`.

**Requerimientos técnicos y fases del EDA:**
El código debe estar dividido lógicamente simulando celdas de Colab (Markdown para explicaciones, R para código) y utilizar las convenciones del ecosistema `tidyverse`. Debe incluir las siguientes etapas:

1. **Importación y Configuración:** - Utilizar el gestor `pacman` (`pacman::p_load()`) para cargar las librerías, garantizando la reproducibilidad del entorno.
   - Requerir los siguientes paquetes: `tidyverse` (que incluye `dplyr`, `ggplot2`, `readr`), `lubridate` (para manejo de fechas), `janitor` (para limpieza de nombres), `skimr` (para resúmenes estadísticos detallados) y `naniar` (para análisis de datos faltantes). El archivo origen 'funcionarios_2026_1.csv' debe ser importado desde la ruta de Google Drive base: `/Labs/Dataset/raw/`
2. **Inspección, Selección y Tipado:**
   - Lectura del dataset utilizando `read_csv()`.
   - Estandarización de los nombres de las columnas con `clean_names()`.
   - Conversión de tipos de datos: casting correcto de fechas con `lubridate`, conversión a numéricos y asignación de variables categóricas como factores (`factor()`).
3. **Limpieza de Datos:** Tratamiento de valores nulos (visualizándolos primero con `naniar`), eliminación de duplicados y estandarización de cadenas de texto.
4. **Ingeniería de Características (Feature Engineering) usando `mutate()`:**
   - Calcular una nueva columna `descuento` obtenida de la resta: `valor_presupuestado` - `devengado`.
   - Calcular la `edad` actual de los funcionarios a partir de su fecha de nacimiento utilizando operaciones de `lubridate`.
   - Calcular la `antiguedad` (en años) a partir de la fecha de ingreso.
5. **Exploración y Análisis Estadístico:**
   - Aplicar la función `skim()` para obtener una panorámica de la estadística descriptiva del dataset limpio.
   - Identificación y cuantificación de valores atípicos (outliers) utilizando métodos estadísticos robustos (ej. Rango Intercuartílico - IQR).
6. **Visualización de Datos (Data Storytelling) con `ggplot2`:** Generar gráficos con calidad profesional aplicando temas limpios (ej. `theme_minimal()` o `theme_bw()`), con títulos, subtítulos y etiquetas claras en los ejes. Incluir obligatoriamente:
   - Histogramas (`geom_histogram()`) para analizar distribuciones de variables continuas (ej. edades, salarios).
   - Boxplots (`geom_boxplot()`) para la identificación visual de outliers cruzando variables numéricas con categóricas (ej. salarios por ministerio, género o cargo).
   - Usar facetas (`facet_wrap()` o `facet_grid()`) si lo consideras pertinente para segmentar la visualización por categorías importantes.
7. **Interpretación y Conclusiones:** Como Científico de Datos Senior, en las celdas Markdown debes interpretar qué nos dice cada gráfico o tabla y qué consideraciones metodológicas debemos tener en cuenta para la fase de modelado.

**Formato de Salida:**
Estructura tu respuesta separando claramente las `[CELDAS MARKDOWN]` de las `[CELDAS DE CÓDIGO]` en R. El código debe ser limpio, modular, estar debidamente comentado y seguir los estándares de estilo de R.