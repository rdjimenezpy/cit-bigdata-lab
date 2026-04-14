Para crear contenido académico de alta calidad, especialmente en un entorno como **NotebookLM** que se basa estrictamente en las fuentes que le proporcionas, la estructura del prompt es fundamental. Un buen prompt no es solo una instrucción, es un conjunto de coordenadas que guían a la IA para que no alucine y se mantenga fiel a tu material.

Aquí tienes la guía maestra para definir y estructurar prompts profesionales.

---

### 1. Anatomía de un Prompt Académico Profesional
Un prompt efectivo para la creación de materiales de curso debe tener estos 5 componentes:

1.  **Rol (Persona):** ¿Quién está hablando? (Ej: Un profesor experto en Big Data).
2.  **Contexto y Objetivo:** ¿Qué estamos haciendo y para quién? (Ej: Estudiantes principiantes).
3.  **Instrucción de Fuente (Crucial en NotebookLM):** Obligar a la IA a usar solo tus documentos cargados.
4.  **Tarea Específica:** Qué debe entregar (Resumen, guion, etc.).
5.  **Formato y Restricciones:** Estructura visual, tono (educativo, técnico pero accesible) y longitud.

---

### 2. Estructura Base (Template Universal)

Puedes copiar y adaptar esta estructura para cualquier necesidad:

> **"Actúa como un [ROL]. Basándote exclusivamente en las fuentes proporcionadas en este cuaderno, tu objetivo es [OBJETIVO]. Crea un [TIPO DE CONTENIDO] dirigido a [AUDIENCIA]. Asegúrate de incluir [CONCEPTOS CLAVE]. El tono debe ser [TONO] y el formato de salida debe ser [FORMATO]."**

---

### 3. Prompts Específicos por Tipo de Contenido

A continuación, te detallo los prompts diseñados para tu curso de **Introducción a Big Data**:

#### A. Para Resúmenes Ejecutivos
* **Propósito:** Condensar capítulos largos para lectura rápida.
* **Prompt:**
    > "Actúa como un tutor académico. Utilizando solo el material de las fuentes, crea un resumen ejecutivo del módulo de 'Fundamentos de Big Data'. Estructura el contenido con: 1) Una definición simplificada, 2) Explicación de las 5 V's y 3) Un glosario de los 5 términos más importantes. Usa un lenguaje claro para principiantes y evita tecnicismos innecesarios sin explicación."

#### B. Para Estructura de Presentaciones (Slides)
* **Propósito:** Crear el esqueleto de una clase magistral.
* **Prompt:**
    > "Actúa como un diseñador instruccional. Genera el esquema para una presentación de 10 diapositivas sobre 'Arquitectura de Datos'. Para cada diapositiva, indica: Título, Puntos clave extraídos de las fuentes y una sugerencia de imagen o gráfico que ayude a explicar el concepto. Asegúrate de que haya una progresión lógica desde la ingesta hasta el consumo de datos."

#### C. Para Guiones de Video (YouTube o Clases Grabadas)
* **Propósito:** Crear un guion dinámico y educativo.
* **Prompt:**
    > "Actúa como un comunicador científico. Crea un guion de video de 5 minutos para explicar '¿Qué es un Pipeline de Datos?'. Estructura el guion en: Gancho inicial (hook), Desarrollo (usando la analogía de una fábrica según las fuentes) y Conclusión con una pregunta de reflexión. Incluye notas de 'Corte a...' para indicar cambios visuales."

#### D. Para Informes Técnicos o Whitepapers
* **Propósito:** Documentar un tema con profundidad académica.
* **Prompt:**
    > "Actúa como un Analista de Datos Senior. Redacta un informe técnico sobre el 'Futuro del Big Data en Paraguay' basado en el ensayo y los documentos del programa. El informe debe tener: Introducción, Análisis de la situación actual, Retos tecnológicos mencionados en las fuentes y Recomendaciones finales. Usa un tono formal y profesional."

#### E. Para Diseño de Infografías (Estructura de Contenido)
* **Propósito:** Organizar la información visualmente.
* **Prompt:**
    > "Actúa como un experto en visualización de datos. Extrae la información más relevante sobre 'El Ecosistema de Hadoop vs. Herramientas Modernas' y organízala para una infografía. Divide el contenido en secciones: 'Capa de Almacenamiento', 'Capa de Procesamiento' y 'Capa de Análisis'. Para cada sección, escribe un texto de máximo 30 palabras basado en los libros de Joyanes."

#### F. Para Mapas Mentales (Jerarquía de Texto)
* **Propósito:** Organizar ideas jerárquicamente.
* **Prompt:**
    > "Actúa como un estratega de aprendizaje. Genera una estructura jerárquica para un mapa mental sobre el 'Ciclo de Vida de la Ciencia de Datos'. El nodo central es el Ciclo de Vida. Los nodos de primer nivel deben ser las fases principales. Los nodos de segundo nivel deben ser las herramientas y tareas específicas mencionadas en el libro de Joyanes Aguilar y el programa de estudios."

---

### Consejos de Experto para NotebookLM:

1.  **Iteración:** Si la respuesta es muy general, añade: *"Sé más específico usando los ejemplos de la página X del documento [Nombre del Archivo]"*.
2.  **Citas:** Puedes pedirle: *"Incluye citas textuales de los documentos para respaldar cada punto"*. Esto da mucha autoridad a tu contenido.
3.  **Control de Nivel:** Si sientes que es muy complejo, añade: *"Explica esto como si fuera para un estudiante de primer año que nunca ha programado"*.

¿Te gustaría que desarrollemos un prompt específico para alguna de las clases de tu cronograma (por ejemplo, la Clase 1 de la Semana 1)?