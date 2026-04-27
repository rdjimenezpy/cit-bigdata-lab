<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# Estadística 12.ª Edición  
## Fundamentos, aplicaciones y dominio técnico para ingeniería, ciencia de datos y toma de decisiones

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

La estadística es una de las disciplinas fundamentales para la ingeniería, la ciencia de datos, la investigación científica, la gestión empresarial y la toma de decisiones basada en evidencia.

En un entorno donde las organizaciones generan y consumen grandes volúmenes de datos, la estadística permite convertir observaciones aisladas en información útil, conocimiento estructurado y decisiones justificadas.

La obra **Estadística 12.ª Edición**, asociada al autor Mario F. Triola, se presenta como un recurso orientado al aprendizaje de conceptos estadísticos esenciales, combinando teoría, ejemplos, aplicaciones prácticas y herramientas para interpretar datos en contextos reales.

La estadística resulta indispensable para:

- Describir conjuntos de datos.
- Analizar variabilidad.
- Medir incertidumbre.
- Realizar inferencias sobre poblaciones.
- Evaluar hipótesis.
- Modelar relaciones entre variables.
- Tomar decisiones basadas en datos.
- Diseñar experimentos.
- Controlar procesos.
- Apoyar análisis predictivo.

En áreas como Big Data, inteligencia artificial, ingeniería de datos y ciencia de datos, la estadística no es un complemento opcional. Es una base metodológica necesaria para interpretar correctamente los resultados.

---

# 2. Fundamentos teóricos

## 2.1. ¿Qué es la estadística?

La estadística es una rama de las matemáticas aplicada al trabajo con datos. Su objetivo es recolectar, organizar, analizar, interpretar y presentar información de manera sistemática.

Desde una perspectiva práctica, la estadística permite responder preguntas como:

- ¿Qué comportamiento tienen los datos?
- ¿Cuál es el valor promedio de una variable?
- ¿Qué tan dispersos están los datos?
- ¿Existen patrones o tendencias?
- ¿Una muestra representa adecuadamente a una población?
- ¿Una diferencia observada es estadísticamente significativa?
- ¿Es posible predecir una variable a partir de otra?

La estadística ayuda a reducir la incertidumbre, pero no la elimina por completo. Su valor está en proporcionar criterios racionales para decidir en contextos donde no se dispone de información perfecta.

---

## 2.2. Estadística descriptiva

La estadística descriptiva se ocupa de resumir, organizar y presentar datos.

Incluye técnicas como:

- Tablas de frecuencia.
- Gráficos.
- Medidas de tendencia central.
- Medidas de dispersión.
- Medidas de posición.
- Descripción de distribuciones.

Medidas frecuentes:

| Medida | Descripción |
|---|---|
| Media | Promedio aritmético de los valores. |
| Mediana | Valor central cuando los datos están ordenados. |
| Moda | Valor que aparece con mayor frecuencia. |
| Rango | Diferencia entre el valor máximo y el mínimo. |
| Varianza | Medida de dispersión respecto a la media. |
| Desviación estándar | Raíz cuadrada de la varianza; mide dispersión en la escala original. |

La estadística descriptiva no busca generalizar a una población mayor. Su propósito principal es describir los datos disponibles.

---

## 2.3. Estadística inferencial

La estadística inferencial permite obtener conclusiones sobre una población a partir de una muestra.

Incluye técnicas como:

- Estimación de parámetros.
- Intervalos de confianza.
- Pruebas de hipótesis.
- Regresión.
- Correlación.
- Análisis de varianza.
- Pruebas no paramétricas.

Ejemplo conceptual:

Si se toma una muestra de 500 estudiantes de una universidad, la estadística inferencial permite estimar características de todos los estudiantes de esa universidad, siempre que la muestra sea adecuada.

La inferencia estadística depende de conceptos clave como:

- Aleatoriedad.
- Tamaño de muestra.
- Nivel de confianza.
- Error muestral.
- Distribución de probabilidad.
- Supuestos del modelo.

---

# 3. Conceptos fundamentales

## 3.1. Población y muestra

| Concepto | Definición |
|---|---|
| Población | Conjunto total de elementos que se desea estudiar. |
| Muestra | Subconjunto de la población utilizado para realizar análisis. |

Ejemplo:

- Población: todos los funcionarios públicos de un país.
- Muestra: 10.000 registros seleccionados para análisis.

Una muestra debe ser representativa. Si la muestra está sesgada, las conclusiones también lo estarán.

---

## 3.2. Variables

Una variable es una característica que puede tomar distintos valores.

Las variables se clasifican principalmente en:

| Tipo de variable | Descripción | Ejemplo |
|---|---|---|
| Cualitativa nominal | Categorías sin orden natural. | Sexo, ciudad, tipo de contrato. |
| Cualitativa ordinal | Categorías con orden. | Nivel educativo, nivel de satisfacción. |
| Cuantitativa discreta | Valores numéricos contables. | Número de hijos, cantidad de errores. |
| Cuantitativa continua | Valores numéricos medibles. | Peso, salario, temperatura. |

Identificar correctamente el tipo de variable es importante porque determina qué técnicas estadísticas pueden aplicarse.

---

## 3.3. Distribuciones

Una distribución describe cómo se comportan los valores de una variable.

Distribuciones frecuentes:

| Distribución | Uso típico |
|---|---|
| Normal | Variables continuas con comportamiento simétrico. |
| Binomial | Conteo de éxitos en un número fijo de ensayos. |
| Poisson | Conteo de eventos en un intervalo de tiempo o espacio. |

Comprender las distribuciones es clave para aplicar pruebas estadísticas, estimar probabilidades y construir modelos.

---

# 4. Definición técnica de la estadística aplicada

La estadística aplicada puede definirse como el conjunto de métodos matemáticos, computacionales y analíticos utilizados para transformar datos en información confiable.

Integra:

- Métodos descriptivos.
- Probabilidad.
- Inferencia estadística.
- Modelado.
- Visualización.
- Técnicas computacionales.
- Interpretación orientada a decisiones.

Sus objetivos principales son:

1. Tomar decisiones basadas en datos.
2. Reducir incertidumbre.
3. Modelar fenómenos reales.
4. Validar hipótesis.
5. Identificar patrones.
6. Medir variabilidad.
7. Evaluar riesgos.
8. Comunicar resultados con rigor.

---

# 5. Proceso estadístico paso a paso

## 5.1. Paso 1: Recolección de datos

La recolección de datos es la etapa inicial del análisis estadístico.

Fuentes comunes:

- Encuestas.
- Sensores.
- Bases de datos.
- Experimentos.
- Registros administrativos.
- Sistemas transaccionales.
- Archivos abiertos.
- Observaciones de campo.

Una mala recolección de datos compromete todo el análisis posterior. Por eso deben definirse con claridad:

- Qué datos se necesitan.
- Cómo se medirán.
- Con qué frecuencia se recolectarán.
- Qué población será analizada.
- Qué criterios de calidad se aplicarán.

---

## 5.2. Paso 2: Limpieza de datos

Los datos reales suelen contener problemas.

Problemas frecuentes:

- Valores faltantes.
- Registros duplicados.
- Errores de captura.
- Valores atípicos.
- Inconsistencias de formato.
- Variables mal codificadas.
- Datos fuera de rango.

Acciones comunes:

- Eliminar duplicados.
- Corregir formatos.
- Tratar valores faltantes.
- Revisar outliers.
- Validar rangos.
- Estandarizar categorías.
- Documentar reglas de limpieza.

La limpieza no debe hacerse de forma mecánica. Cada decisión debe estar justificada por el contexto del problema.

---

## 5.3. Paso 3: Análisis descriptivo

El análisis descriptivo permite obtener una primera comprensión del conjunto de datos.

Técnicas frecuentes:

- Media.
- Mediana.
- Moda.
- Varianza.
- Desviación estándar.
- Histogramas.
- Diagramas de caja.
- Tablas de frecuencia.
- Gráficos de barras.
- Gráficos de dispersión.

Ejemplo:

```text
Datos: 10, 20, 30

Media = (10 + 20 + 30) / 3 = 20
```

---

## 5.4. Paso 4: Modelado

El modelado busca representar relaciones entre variables o describir el comportamiento de un fenómeno.

Modelos frecuentes:

- Regresión lineal.
- Regresión múltiple.
- Modelos probabilísticos.
- Modelos de clasificación.
- Modelos de series temporales.
- Modelos de control estadístico de procesos.

Ejemplo conceptual:

```text
Horas de estudio  →  Calificación obtenida
```

Una regresión puede ayudar a estimar cómo cambia la calificación esperada cuando aumentan las horas de estudio.

---

## 5.5. Paso 5: Inferencia

La inferencia permite generalizar resultados de una muestra hacia una población.

Herramientas frecuentes:

- Intervalos de confianza.
- Pruebas de hipótesis.
- Pruebas de significancia.
- Estimaciones puntuales.
- Comparación de medias.
- Comparación de proporciones.

Ejemplo de pregunta inferencial:

> ¿Existe evidencia suficiente para afirmar que el promedio salarial de dos grupos es diferente?

---

## 5.6. Paso 6: Interpretación

La interpretación convierte resultados numéricos en conclusiones útiles.

Una buena interpretación debe responder:

- ¿Qué indican los resultados?
- ¿Qué tan confiables son?
- ¿Qué limitaciones existen?
- ¿Qué supuestos se asumieron?
- ¿Qué decisión puede tomarse?
- ¿Qué riesgo existe si se interpreta incorrectamente?

La estadística no termina en el cálculo. Termina cuando el resultado se comunica correctamente y apoya una decisión razonada.

---

# 6. Comparación entre estadística clásica y estadística moderna

| Característica | Estadística clásica | Estadística moderna |
|---|---|---|
| Enfoque | Manual y matemático | Computacional y aplicado |
| Herramientas | Papel, calculadora, tablas | R, Python, Excel, Power BI, software estadístico |
| Volumen de datos | Pequeño o moderado | Grande o masivo |
| Aplicaciones | Estudios tradicionales | Big Data, IA, ciencia de datos, analítica predictiva |
| Velocidad | Baja a media | Alta |
| Reproducibilidad | Limitada si es manual | Alta si se usa código y documentación |
| Comunicación | Tablas y reportes estáticos | Dashboards, notebooks, visualizaciones interactivas |

La estadística moderna no reemplaza la teoría clásica. La extiende mediante herramientas computacionales.

---

# 7. Representación conceptual de la distribución normal

La distribución normal es una de las distribuciones más importantes de la estadística.

Tiene forma de campana y suele aparecer en fenómenos naturales, mediciones y errores aleatorios.

```text
                    *
                 *     *
              *           *
           *                 *
        *                       *
------------------------------------------------
              Media
```

Características principales:

- Es simétrica.
- La media, mediana y moda coinciden.
- La mayor parte de los valores se concentra cerca del centro.
- Los valores extremos son menos frecuentes.
- Es fundamental para inferencia estadística.

---

# 8. Tabla de ejemplo

| Observación | Valor |
|---:|---:|
| 1 | 10 |
| 2 | 15 |
| 3 | 20 |

A partir de esta tabla se pueden calcular medidas descriptivas como media, mediana, rango y desviación estándar.

---

# 9. Ejemplos básicos

## 9.1. Ejemplo de media

Datos:

```text
10, 20, 30
```

Cálculo:

```text
Media = (10 + 20 + 30) / 3 = 20
```

Interpretación:

El promedio de los tres valores es 20.

---

## 9.2. Ejemplo de probabilidad

Supóngase una urna con:

- 3 bolas rojas.
- 2 bolas azules.

Total de bolas:

```text
3 + 2 = 5
```

Probabilidad de extraer una bola roja:

```text
P(roja) = 3 / 5 = 0.6
```

Interpretación:

Existe una probabilidad de 60% de seleccionar una bola roja.

---

## 9.3. Ejemplo de regresión

Variables:

- Horas de estudio.
- Calificación obtenida.

Pregunta:

> ¿Existe relación entre la cantidad de horas de estudio y la calificación?

La regresión permite analizar si una variable ayuda a explicar o predecir otra.

---

# 10. Aplicaciones en el mundo real

## 10.1. Ingeniería industrial

Aplicaciones:

- Optimización de procesos.
- Control de calidad.
- Análisis de defectos.
- Reducción de variabilidad.
- Evaluación de productividad.
- Control estadístico de procesos.

---

## 10.2. Ciencia de datos

Aplicaciones:

- Machine learning.
- Análisis predictivo.
- Evaluación de modelos.
- Análisis exploratorio de datos.
- Segmentación.
- Validación estadística.

---

## 10.3. Medicina

Aplicaciones:

- Ensayos clínicos.
- Diagnóstico.
- Epidemiología.
- Evaluación de tratamientos.
- Análisis de supervivencia.
- Estudios observacionales.

---

## 10.4. Finanzas

Aplicaciones:

- Evaluación de riesgos.
- Modelos económicos.
- Análisis de inversión.
- Detección de fraude.
- Predicción de pérdidas.
- Modelos de crédito.

---

# 11. Errores comunes en estadística

## 11.1. Confundir correlación con causalidad

Dos variables pueden estar relacionadas sin que una cause la otra.

Ejemplo:

```text
Mayor venta de helados ↔ Mayor cantidad de ahogamientos
```

Ambas variables pueden aumentar en verano, pero eso no significa que comprar helado cause ahogamientos.

---

## 11.2. Usar muestras pequeñas

Las muestras pequeñas pueden producir resultados poco confiables.

Problemas asociados:

- Alta variabilidad.
- Baja representatividad.
- Estimaciones inestables.
- Mayor riesgo de conclusiones erróneas.

---

## 11.3. Ignorar valores atípicos

Los outliers pueden distorsionar los resultados.

Ejemplo:

```text
Salarios: 2.000.000, 2.200.000, 2.100.000, 50.000.000
```

El valor extremo puede inflar fuertemente la media.

Alternativas:

- Analizar mediana.
- Usar boxplots.
- Revisar origen del outlier.
- Decidir si corresponde conservarlo, corregirlo o excluirlo.

---

## 11.4. Usar gráficos inadecuados

Un gráfico mal diseñado puede inducir interpretaciones incorrectas.

Errores frecuentes:

- Escalas manipuladas.
- Ejes sin etiquetas.
- Colores confusos.
- Gráficos 3D innecesarios.
- Comparaciones visuales engañosas.
- Falta de contexto.

---

# 12. Desafíos y soluciones

## 12.1. Datos incompletos

**Desafío:** presencia de valores faltantes.

**Soluciones posibles:**

- Imputación con media, mediana o moda.
- Imputación basada en modelos.
- Eliminación controlada de registros.
- Análisis del patrón de ausencia.
- Documentación de criterios aplicados.

---

## 12.2. Gran volumen de datos

**Desafío:** procesamiento de datasets grandes.

**Soluciones posibles:**

- Uso de herramientas Big Data.
- Procesamiento distribuido.
- Bases de datos analíticas.
- Muestreo estadístico.
- Optimización de consultas.
- Uso de formatos columnares.
- Automatización de pipelines.

Herramientas posibles:

- Python.
- R.
- SQL.
- Spark.
- DuckDB.
- PostgreSQL.
- Power BI.
- Plataformas cloud.

---

## 12.3. Interpretación compleja

**Desafío:** resultados difíciles de comunicar.

**Soluciones posibles:**

- Visualizaciones claras.
- Resúmenes ejecutivos.
- Explicación de supuestos.
- Separación entre hallazgos y opiniones.
- Uso de lenguaje técnico adecuado al público.
- Presentación de limitaciones.

---

# 13. Caso de estudio: optimización de producción

## 13.1. Contexto

Una fábrica detecta una cantidad elevada de fallas en sus productos.

El objetivo es identificar patrones asociados a los defectos y reducir la tasa de fallas.

---

## 13.2. Proceso estadístico

El proceso puede organizarse en tres pasos principales:

1. Recolección de datos.
2. Identificación de patrones.
3. Análisis estadístico.

Variables posibles:

- Línea de producción.
- Turno.
- Operario.
- Máquina.
- Tipo de defecto.
- Lote de materia prima.
- Temperatura.
- Humedad.
- Tiempo de operación.

---

## 13.3. Resultado esperado

Un análisis estadístico adecuado puede permitir:

- Reducir defectos.
- Identificar causas probables.
- Mejorar eficiencia.
- Establecer controles.
- Optimizar procesos.
- Tomar decisiones basadas en evidencia.

La ficha consultada menciona como resultado posible una reducción del 30% en defectos y aumento de eficiencia.

---

# 14. Consejos para ingenieros y profesionales

## 14.1. Aprender herramientas computacionales

La estadística moderna requiere herramientas que permitan procesar, analizar y visualizar datos.

Herramientas recomendadas:

- Python.
- R.
- Excel avanzado.
- Power BI.
- MATLAB.
- SQL.
- Software estadístico especializado.

---

## 14.2. Practicar con datasets reales

Los datos reales presentan problemas que no aparecen en ejercicios demasiado simplificados.

Problemas frecuentes:

- Nulos.
- Duplicados.
- Sesgos.
- Errores de captura.
- Categorías inconsistentes.
- Outliers.
- Cambios de formato.

Practicar con datos reales ayuda a desarrollar criterio técnico.

---

## 14.3. Entender la teoría

Usar software sin comprender la teoría es riesgoso.

Un profesional debe entender:

- Qué calcula una técnica.
- Qué supuestos requiere.
- Cuándo se puede aplicar.
- Cómo se interpreta.
- Qué limitaciones tiene.
- Qué errores pueden surgir.

La estadística no consiste en presionar botones; consiste en razonar con datos.

---

# 15. Preguntas frecuentes

## 15.1. ¿Qué es la estadística?

La estadística es la ciencia que permite analizar datos para describir fenómenos, medir incertidumbre y apoyar decisiones.

---

## 15.2. ¿Para qué sirve la estadística en ingeniería?

Sirve para optimizar procesos, mejorar resultados, controlar calidad, analizar fallas, evaluar rendimiento y tomar decisiones basadas en evidencia.

---

## 15.3. ¿Es difícil aprender estadística?

Puede ser exigente al inicio, especialmente por los conceptos de probabilidad e inferencia. Sin embargo, con práctica, ejemplos reales y herramientas computacionales, es perfectamente accesible.

---

## 15.4. ¿Qué software se puede usar?

Herramientas comunes:

- Python.
- R.
- Excel.
- Power BI.
- MATLAB.
- Minitab.
- SPSS.
- Statdisk.

---

## 15.5. ¿Qué es una muestra?

Una muestra es un subconjunto de una población. Se utiliza para estudiar la población cuando no es viable analizar todos sus elementos.

---

## 15.6. ¿Qué es la desviación estándar?

La desviación estándar mide qué tan dispersos están los datos respecto a la media.

Una desviación estándar baja indica que los datos están concentrados cerca del promedio. Una desviación estándar alta indica mayor variabilidad.

---

## 15.7. ¿Qué es una regresión?

La regresión es una técnica estadística que permite analizar la relación entre una variable dependiente y una o más variables independientes.

Se utiliza para explicación, predicción y modelado de relaciones.

---

# 16. Conclusión

La estadística es una herramienta fundamental para comprender el mundo moderno. Permite analizar datos, medir incertidumbre, evaluar hipótesis y tomar decisiones con base en evidencia.

La **Estadística 12.ª Edición** se presenta como un recurso orientado a desarrollar habilidades críticas para estudiantes y profesionales que necesitan interpretar datos correctamente.

Dominar estadística implica mucho más que memorizar fórmulas. Requiere comprender conceptos, cuestionar resultados, validar supuestos, interpretar correctamente los análisis y comunicar hallazgos con claridad.

En ingeniería, ciencia de datos, Big Data, salud, finanzas y gestión organizacional, la estadística actúa como puente entre los datos crudos y la toma de decisiones racional.

En síntesis, la estadística permite:

1. Describir datos.
2. Detectar patrones.
3. Medir variabilidad.
4. Evaluar incertidumbre.
5. Modelar fenómenos.
6. Validar hipótesis.
7. Optimizar procesos.
8. Comunicar evidencia.
9. Apoyar decisiones.
10. Reducir errores de interpretación.

---

# 17. Síntesis académica para estudio

Para estudiantes de Big Data, ingeniería de datos, ciencia de datos o análisis de datos, los puntos clave son:

1. La estadística es la base metodológica del análisis de datos.
2. La estadística descriptiva resume datos.
3. La estadística inferencial permite generalizar desde muestras hacia poblaciones.
4. Las variables deben clasificarse correctamente antes de analizarlas.
5. Las distribuciones son esenciales para comprender probabilidad e inferencia.
6. Los outliers pueden distorsionar métricas.
7. La correlación no implica causalidad.
8. Las muestras pequeñas o sesgadas producen conclusiones débiles.
9. La visualización mejora la interpretación, pero puede engañar si se usa mal.
10. La estadística moderna se apoya en herramientas computacionales como Python, R, SQL y Power BI.

---

# 18. Referencia bibliográfica

Triola, M. F. (2018). *Estadística* (12.ª ed.). Pearson Educación.
