<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# Python Crash Course for Data Analysis  
## Curso acelerado de Python para análisis de datos

---

## Datos institucionales

**Institución:** Universidad Nacional de Asunción  
**Unidad Académica:** Facultad Politécnica  
**Dependencia:** Centro de Innovación TIC (PK)  
**Área:** Big Data   **Nivel:** Básico  
**Curso:** Introducción a Big Data   **Enfoque:** Fundamentos y Pipelines de Datos con Python  
**Docente:** Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción 

---

## Fecha y versión

- **Fecha:** 27/04/2026
- **Versión:** 1.0

---

# 1. Introducción

Los datos se han convertido en uno de los recursos fundamentales de la ingeniería, la ciencia, los negocios y la tecnología moderna. Desde la predicción del comportamiento de clientes en comercio electrónico hasta el análisis de datos provenientes de sensores en estructuras civiles o máquinas industriales, la capacidad de procesar e interpretar datos es hoy una competencia central para estudiantes, ingenieros, analistas y profesionales técnicos.

Dentro del ecosistema de lenguajes de programación, Python se ha consolidado como una de las herramientas más utilizadas para análisis de datos. Su sintaxis simple, su curva de aprendizaje relativamente accesible y su amplio conjunto de bibliotecas especializadas lo convierten en una opción adecuada para quienes se inician en programación aplicada al análisis de información.

El enfoque del recurso **Python Crash Course for Data Analysis** es introductorio y práctico. Está orientado a personas que desean comenzar desde cero y avanzar hacia una mentalidad analítica básica utilizando Python.

Los temas principales tratados en la página son:

- Fundamentos de Python para análisis de datos.
- Uso de NumPy para computación numérica.
- Uso de Pandas para manipulación de datos.
- Visualización de datos con bibliotecas gráficas.
- Aplicaciones reales en ingeniería.
- Casos de estudio y ejemplos prácticos.

La idea central es mostrar cómo un profesional puede transformar datos crudos en información significativa mediante herramientas de programación.

---

# 2. Fundamentos teóricos

## 2.1. ¿Por qué Python para análisis de datos?

Python es ampliamente utilizado en análisis de datos, ingeniería y computación científica por varias razones.

### 2.1.1. Simplicidad

Python tiene una sintaxis clara y legible. Esto facilita el aprendizaje para principiantes y permite concentrarse en la lógica del análisis más que en detalles complejos del lenguaje.

Ejemplo básico:

```python
x = 10
nombre = "Datos de ingeniería"

print(x)
print(nombre)
```

---

### 2.1.2. Bibliotecas poderosas

Python cuenta con un ecosistema amplio de bibliotecas especializadas:

| Biblioteca | Uso principal |
|---|---|
| `NumPy` | Computación numérica con arreglos y matrices. |
| `Pandas` | Manipulación y análisis de datos tabulares. |
| `Matplotlib` | Visualización de gráficos básicos y personalizados. |
| `Seaborn` | Visualización estadística de alto nivel. |
| `SciPy` | Computación científica y métodos matemáticos avanzados. |

Estas bibliotecas permiten realizar tareas que antes requerían herramientas más especializadas o procesos manuales.

---

### 2.1.3. Adopción en la industria

Python se utiliza en empresas tecnológicas, instituciones académicas, laboratorios de investigación, organizaciones científicas y sectores industriales.

Su popularidad se debe a que puede aplicarse en múltiples dominios:

- Ciencia de datos.
- Ingeniería de datos.
- Machine learning.
- Automatización.
- Análisis estadístico.
- Simulación.
- Procesamiento de señales.
- Visualización.
- Desarrollo de prototipos.

---

# 3. ¿Qué es el análisis de datos?

El análisis de datos es el proceso de examinar, limpiar, transformar, visualizar e interpretar datos con el objetivo de apoyar la toma de decisiones.

Un flujo general de análisis de datos incluye:

1. Recolección de datos.
2. Limpieza de datos.
3. Procesamiento.
4. Análisis.
5. Visualización.
6. Interpretación.
7. Toma de decisiones.

En ingeniería, el análisis de datos puede aplicarse a problemas como:

- Monitoreo de desempeño de máquinas.
- Análisis de sensores.
- Detección temprana de fallas.
- Optimización del consumo energético.
- Evaluación de estructuras.
- Análisis de procesos industriales.
- Seguimiento de indicadores operativos.

---

# 4. Definición técnica: análisis de datos con Python

El análisis de datos con Python consiste en utilizar el lenguaje Python y sus bibliotecas para:

- Cargar conjuntos de datos.
- Manipular información estructurada.
- Limpiar datos incompletos o inconsistentes.
- Ejecutar operaciones matemáticas y estadísticas.
- Transformar variables.
- Generar visualizaciones.
- Detectar patrones.
- Apoyar procesos de decisión.

Python no reemplaza el razonamiento analítico. Es una herramienta. El valor real aparece cuando se combina programación, estadística básica, conocimiento del dominio y pensamiento crítico.

---

# 5. Bibliotecas principales

## 5.1. NumPy

NumPy, abreviatura de *Numerical Python*, es una biblioteca fundamental para computación numérica.

Permite trabajar con:

- Arreglos.
- Matrices.
- Operaciones vectorizadas.
- Funciones matemáticas.
- Estadística básica.
- Cálculo eficiente sobre grandes volúmenes de datos numéricos.

Ejemplo:

```python
import numpy as np

temperaturas = np.array([20, 25, 30, 35])
promedio = np.mean(temperaturas)

print(promedio)
```

Una ventaja clave de NumPy es que utiliza operaciones optimizadas, muchas de ellas implementadas en C, lo que mejora el rendimiento frente a bucles tradicionales de Python.

---

## 5.2. Pandas

Pandas es una biblioteca diseñada para trabajar con datos tabulares.

Su estructura principal es el `DataFrame`, similar conceptualmente a una hoja de cálculo o una tabla de base de datos.

Pandas permite:

- Leer archivos CSV.
- Filtrar filas.
- Seleccionar columnas.
- Agrupar datos.
- Crear nuevas variables.
- Limpiar valores faltantes.
- Calcular estadísticas descriptivas.
- Unir conjuntos de datos.
- Transformar información.

Ejemplo:

```python
import pandas as pd

datos = {
    "Nombre": ["Ahmed", "John", "Sara"],
    "Puntaje": [90, 85, 88]
}

df = pd.DataFrame(datos)

print(df)
```

---

## 5.3. Matplotlib

Matplotlib permite crear gráficos y visualizaciones.

Ejemplo básico:

```python
import matplotlib.pyplot as plt

plt.plot([1, 2, 3], [4, 5, 6])
plt.show()
```

También permite crear:

- Gráficos de líneas.
- Gráficos de barras.
- Histogramas.
- Diagramas de dispersión.
- Gráficos personalizados.

---

## 5.4. Seaborn

Seaborn es una biblioteca de visualización estadística construida sobre Matplotlib.

Es útil para crear gráficos más expresivos con menos código, especialmente en análisis exploratorio de datos.

Ejemplos de gráficos frecuentes:

- Histogramas.
- Boxplots.
- Heatmaps.
- Pairplots.
- Gráficos de dispersión con categorías.
- Gráficos de distribución.

---

# 6. Instalación del entorno básico

Para comenzar, se pueden instalar las bibliotecas principales mediante `pip`.

```bash
pip install numpy
pip install pandas
pip install matplotlib
pip install seaborn
```

También se puede instalar todo en una sola línea:

```bash
pip install numpy pandas matplotlib seaborn
```

En ambientes académicos, una opción práctica es utilizar Google Colab, porque ya incluye muchas bibliotecas preinstaladas y evita problemas iniciales de configuración local.

---

# 7. Fundamentos de Python para análisis de datos

## 7.1. Variables

Las variables permiten almacenar valores.

```python
x = 10
nombre = "Engineering Data"

print(x)
print(nombre)
```

---

## 7.2. Listas

Las listas almacenan colecciones ordenadas de elementos.

```python
datos = [10, 20, 30, 40]

print(datos)
```

---

## 7.3. Bucles

Los bucles permiten recorrer colecciones de datos.

```python
datos = [10, 20, 30, 40]

for valor in datos:
    print(valor)
```

Aunque los bucles son útiles, en análisis de datos conviene usar operaciones vectorizadas con NumPy o Pandas cuando sea posible.

---

# 8. Fundamentos de NumPy

## 8.1. Crear arreglos

```python
import numpy as np

arr = np.array([1, 2, 3, 4])

print(arr)
```

---

## 8.2. Operaciones matemáticas

```python
arr = np.array([1, 2, 3, 4])

print(arr * 2)
print(arr + 10)
print(arr.mean())
```

Estas operaciones se aplican directamente sobre todo el arreglo, sin necesidad de escribir bucles explícitos.

---

## 8.3. Ventaja de la vectorización

La vectorización permite realizar operaciones sobre conjuntos completos de datos de forma eficiente.

Ejemplo:

```python
import numpy as np

valores = np.array([10, 20, 30, 40])
resultado = valores * 1.10

print(resultado)
```

Este patrón es más eficiente y claro que recorrer elemento por elemento con un bucle tradicional.

---

# 9. Fundamentos de Pandas

## 9.1. Crear un DataFrame

```python
import pandas as pd

datos = {
    "Nombre": ["Ahmed", "John", "Sara"],
    "Puntaje": [90, 85, 88]
}

df = pd.DataFrame(datos)

print(df)
```

---

## 9.2. Leer archivos CSV

```python
import pandas as pd

df = pd.read_csv("data.csv")

print(df.head())
```

El método `head()` permite observar las primeras filas del conjunto de datos.

---

## 9.3. Estadísticas descriptivas

```python
print(df.describe())
```

Este método genera un resumen estadístico de las columnas numéricas, incluyendo conteo, media, desviación estándar, mínimo, máximo y cuartiles.

---

## 9.4. Selección de columnas

```python
print(df["Nombre"])
```

También se pueden seleccionar varias columnas:

```python
print(df[["Nombre", "Puntaje"]])
```

---

## 9.5. Filtrado de filas

```python
aprobados = df[df["Puntaje"] >= 70]

print(aprobados)
```

---

# 10. Limpieza de datos

La limpieza de datos es una de las tareas más importantes del análisis.

Los datos reales pueden contener:

- Valores faltantes.
- Duplicados.
- Errores de formato.
- Columnas mal nombradas.
- Tipos de datos incorrectos.
- Valores extremos.
- Inconsistencias entre registros.

---

## 10.1. Manejo de valores faltantes

Eliminar filas con valores faltantes:

```python
df_limpio = df.dropna()
```

Rellenar valores faltantes con cero:

```python
df_rellenado = df.fillna(0)
```

Rellenar con la media de una columna:

```python
df["Puntaje"] = df["Puntaje"].fillna(df["Puntaje"].mean())
```

La elección entre eliminar o imputar valores depende del problema, del volumen de datos faltantes y del significado de la variable.

---

## 10.2. Renombrar columnas

```python
df.rename(columns={"Name": "Student_Name"}, inplace=True)
```

Un buen nombre de columna debe ser claro, consistente y fácil de interpretar.

---

## 10.3. Eliminar duplicados

```python
df = df.drop_duplicates()
```

Los duplicados pueden distorsionar conteos, promedios y métricas agregadas.

---

# 11. Visualización de datos

La visualización ayuda a interpretar patrones, tendencias y anomalías.

## 11.1. Gráfico de línea

```python
import matplotlib.pyplot as plt

plt.plot([1, 2, 3], [4, 5, 6])
plt.xlabel("Eje X")
plt.ylabel("Eje Y")
plt.title("Gráfico de línea básico")
plt.show()
```

---

## 11.2. Gráfico de barras

```python
plt.bar(df["Nombre"], df["Puntaje"])
plt.xlabel("Nombre")
plt.ylabel("Puntaje")
plt.title("Puntaje por estudiante")
plt.show()
```

---

## 11.3. Histograma

```python
plt.hist(df["Puntaje"], bins=10)
plt.xlabel("Puntaje")
plt.ylabel("Frecuencia")
plt.title("Distribución de puntajes")
plt.show()
```

---

# 12. Comparación: Python vs Excel para análisis de datos

| Característica | Python | Excel |
|---|---|---|
| Tamaño de datos | Adecuado para conjuntos grandes | Más limitado |
| Automatización | Alta | Baja a media |
| Velocidad | Alta en procesos programados | Moderada |
| Flexibilidad | Muy alta | Media |
| Reproducibilidad | Alta si se documenta el código | Baja si el proceso es manual |
| Visualización | Avanzada y programable | Básica a intermedia |
| Escalabilidad | Alta | Limitada |

Excel sigue siendo útil para análisis pequeños, revisión manual y tareas administrativas. Sin embargo, Python es más adecuado para procesos repetibles, automatizables y escalables.

---

# 13. Comparación: NumPy vs Pandas

| Característica | NumPy | Pandas |
|---|---|---|
| Estructura principal | Arreglos y matrices | DataFrames y Series |
| Tipo de datos | Principalmente numéricos | Tabulares y mixtos |
| Rendimiento | Muy alto en operaciones numéricas | Alto, pero con mayor abstracción |
| Caso de uso | Cálculo matemático | Análisis de datos tabulares |
| Legibilidad | Técnica | Más cercana a tablas |

En la práctica, NumPy y Pandas se complementan. Pandas suele apoyarse internamente en NumPy para muchas operaciones numéricas.

---

# 14. Flujo de trabajo del análisis de datos

```text
Datos crudos
    ↓
Limpieza
    ↓
Procesamiento
    ↓
Análisis
    ↓
Visualización
    ↓
Toma de decisiones
```

Este flujo es iterativo. Un gráfico puede revelar un error en los datos, una limpieza puede obligar a recalcular métricas y un resultado analítico puede requerir nuevos datos.

---

# 15. Ejemplo de dataset

| ID | Temperatura | Presión | Resultado |
|---:|---:|---:|---|
| 1 | 25 °C | 1 atm | OK |
| 2 | 40 °C | 1.5 atm | Advertencia |
| 3 | 60 °C | 2 atm | Falla |

Este tipo de tabla puede representar lecturas de sensores industriales. A partir de estos datos podrían analizarse umbrales, tendencias, riesgos y estados operativos.

---

# 16. Ejemplos prácticos

## 16.1. Análisis de temperatura promedio

```python
import numpy as np

temperatura = np.array([20, 25, 30, 35])
temperatura_promedio = np.mean(temperatura)

print("Temperatura promedio:", temperatura_promedio)
```

Este ejemplo calcula la temperatura promedio a partir de un conjunto de lecturas.

---

## 16.2. Análisis de rendimiento estudiantil

```python
import pandas as pd

datos = {
    "Estudiante": ["A", "B", "C"],
    "Puntaje": [78, 85, 90]
}

df = pd.DataFrame(datos)

print(df.describe())
```

Este ejemplo permite generar estadísticas descriptivas sobre puntajes estudiantiles.

---

# 17. Aplicaciones reales

## 17.1. Ingeniería civil

Python puede utilizarse para:

- Análisis de carga en puentes.
- Monitoreo de salud estructural.
- Evaluación de deformaciones.
- Procesamiento de datos de sensores.
- Detección de anomalías en estructuras.

---

## 17.2. Ingeniería mecánica

Aplicaciones frecuentes:

- Seguimiento del rendimiento de máquinas.
- Mantenimiento predictivo.
- Análisis de vibraciones.
- Evaluación de temperatura y presión.
- Detección temprana de fallas.

---

## 17.3. Ingeniería eléctrica

Casos de uso:

- Análisis de consumo energético.
- Procesamiento de señales.
- Monitoreo de redes eléctricas.
- Análisis de series temporales.
- Identificación de patrones de carga.

---

## 17.4. Ingeniería de negocios

Aplicaciones posibles:

- Pronóstico de ventas.
- Análisis de tendencias de mercado.
- Segmentación de clientes.
- Evaluación de indicadores comerciales.
- Automatización de reportes.

---

# 18. Errores comunes

## 18.1. Ignorar la limpieza de datos

Los datos sucios producen conclusiones incorrectas. Antes de analizar, se debe revisar la calidad del conjunto de datos.

Problemas frecuentes:

- Valores faltantes.
- Duplicados.
- Tipos incorrectos.
- Errores de carga.
- Valores extremos no tratados.

---

## 18.2. Usar mal Pandas

Un error común es utilizar bucles innecesarios cuando Pandas permite operaciones vectorizadas.

Ejemplo poco recomendable:

```python
for i in range(len(df)):
    print(df.iloc[i]["Puntaje"])
```

Alternativa más limpia:

```python
print(df["Puntaje"])
```

---

## 18.3. No visualizar los datos

Omitir gráficos limita la interpretación. Muchas anomalías, tendencias o patrones se detectan mejor visualmente que leyendo tablas.

---

## 18.4. Complicar demasiado el código

Un código innecesariamente complejo es difícil de depurar, explicar y mantener. En análisis de datos, la claridad es una ventaja técnica.

---

# 19. Desafíos y soluciones

## 19.1. Rendimiento con datasets grandes

**Desafío:** los conjuntos de datos grandes pueden ralentizar el análisis.

**Soluciones:**

- Usar operaciones vectorizadas.
- Evitar bucles innecesarios.
- Cargar solo columnas necesarias.
- Procesar datos por partes.
- Usar formatos eficientes como Parquet.
- Considerar motores como DuckDB, Polars o Spark cuando el volumen excede a Pandas.

---

## 19.2. Datos faltantes

**Desafío:** los valores nulos pueden distorsionar cálculos y modelos.

**Soluciones:**

```python
df.fillna(0)
df.dropna()
```

También se puede imputar con media, mediana, moda o reglas de negocio.

---

## 19.3. Confusión en visualizaciones

**Desafío:** usar gráficos inadecuados puede llevar a malas interpretaciones.

**Soluciones:**

- Empezar con gráficos simples.
- Usar histogramas para distribuciones.
- Usar barras para categorías.
- Usar líneas para series temporales.
- Usar dispersión para relaciones entre variables.
- Etiquetar ejes y títulos correctamente.

---

# 20. Caso de estudio: monitoreo de máquinas industriales

## 20.1. Problema

Una fábrica desea reducir la tasa de fallas de sus máquinas y mejorar la planificación del mantenimiento.

---

## 20.2. Enfoque analítico

El proceso puede organizarse así:

1. Recolectar datos de sensores.
2. Cargar los datos con Python.
3. Limpiar registros incompletos o erróneos.
4. Usar Pandas para estructurar la información.
5. Usar NumPy para cálculos estadísticos.
6. Visualizar patrones con Matplotlib.
7. Detectar comportamientos anómalos.
8. Generar alertas tempranas.
9. Mejorar la planificación del mantenimiento.

---

## 20.3. Herramientas utilizadas

| Herramienta | Propósito |
|---|---|
| Python | Lenguaje principal de análisis |
| Pandas | Limpieza y manipulación de datos |
| NumPy | Cálculo numérico y estadístico |
| Matplotlib | Visualización de patrones |

---

## 20.4. Resultados esperados

Un sistema de monitoreo bien diseñado puede contribuir a:

- Reducir tiempos de inactividad.
- Detectar fallas tempranas.
- Mejorar la planificación de mantenimiento.
- Optimizar recursos operativos.
- Disminuir costos asociados a paradas no programadas.

---

# 21. Consejos para ingenieros y estudiantes

## 21.1. Practicar diariamente

Incluso sesiones cortas de práctica ayudan a consolidar habilidades. Es preferible practicar 30 minutos diarios que estudiar muchas horas de forma aislada y esporádica.

---

## 21.2. Trabajar con datos reales

Los datasets reales enseñan problemas que no aparecen en ejemplos artificiales:

- Datos incompletos.
- Nombres inconsistentes.
- Formatos mixtos.
- Errores de captura.
- Duplicados.
- Variables irrelevantes.
- Valores extremos.

---

## 21.3. Aprender visualización desde el inicio

Los gráficos permiten comprender mejor los datos y comunicar hallazgos con mayor claridad.

---

## 21.4. Automatizar tareas repetitivas

Python permite reemplazar tareas manuales repetitivas por scripts reproducibles.

Ejemplo:

```python
import pandas as pd

df = pd.read_csv("ventas.csv")
resumen = df.groupby("categoria")["monto"].sum()
resumen.to_csv("resumen_ventas.csv")
```

---

## 21.5. Pensar como ingeniero

La pregunta central no debe ser solo “¿qué código escribo?”, sino:

> ¿Qué problema resuelve este análisis?

El análisis de datos debe estar vinculado a una pregunta, una decisión o una mejora concreta.

---

# 22. Preguntas frecuentes

## 22.1. ¿Python es difícil para principiantes?

No. Python suele considerarse uno de los lenguajes más accesibles para comenzar, especialmente por su sintaxis clara.

---

## 22.2. ¿Se necesita matemática para análisis de datos?

Sí, al menos matemática básica y estadística descriptiva. Para análisis más avanzados se requieren conocimientos de probabilidad, inferencia, álgebra lineal y modelado.

---

## 22.3. ¿Un ingeniero puede usar Python sin experiencia previa en programación?

Sí. Es posible comenzar con fundamentos básicos y avanzar gradualmente hacia tareas de análisis, automatización y modelado.

---

## 22.4. ¿Qué es mejor: Excel o Python?

Depende del contexto. Excel es práctico para tareas pequeñas, análisis manuales y revisión rápida. Python es mejor para análisis reproducibles, automatización, grandes volúmenes de datos y procesos repetitivos.

---

## 22.5. ¿Cuánto tiempo toma aprender Python para análisis básico?

Una base inicial puede lograrse en dos o tres meses de práctica constante. El dominio profesional requiere más tiempo, proyectos reales y exposición a problemas diversos.

---

## 22.6. ¿Python se usa en trabajos de ingeniería?

Sí. Python se utiliza ampliamente en ingeniería civil, mecánica, eléctrica, industrial, informática, ciencia de datos, simulación, automatización y análisis técnico.

---

## 22.7. ¿Se necesita una computadora potente?

Para comenzar, no. Una laptop básica es suficiente para ejercicios introductorios. Para datasets grandes, modelos complejos o procesamiento intensivo, puede ser necesario usar mejores recursos o plataformas cloud.

---

# 23. Conclusión

Python ha cambiado la forma en que ingenieros, analistas y profesionales trabajan con datos. Gracias a bibliotecas como NumPy, Pandas y Matplotlib, es posible transformar conjuntos de datos crudos en información clara, visual y accionable.

Para estudiantes y profesionales, aprender Python para análisis de datos ofrece ventajas concretas:

- Mejora la capacidad de automatizar tareas.
- Permite trabajar con datos reales.
- Facilita la visualización de patrones.
- Aumenta la reproducibilidad del análisis.
- Sirve como base para ciencia de datos y machine learning.
- Complementa herramientas como SQL, Excel y plataformas BI.

El aprendizaje debe comenzar de forma simple: variables, listas, lectura de archivos, DataFrames, limpieza básica y visualizaciones iniciales. A partir de ahí, se puede avanzar hacia análisis exploratorio, modelado predictivo, automatización de pipelines y proyectos reales.

El punto crítico no es memorizar comandos, sino desarrollar una mentalidad analítica: entender el problema, revisar la calidad de los datos, aplicar herramientas adecuadas y comunicar resultados de forma clara.

---

# 24. Referencia bibliográfica

AI Publishing. (2019). *Python crash course for data analysis: A complete beginner guide for Python coding, NumPy, Pandas and data visualization*. AI Publishing LLC.
