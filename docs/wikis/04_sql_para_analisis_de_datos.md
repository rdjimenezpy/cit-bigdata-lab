<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# SQL para Análisis de Datos  
## Técnicas avanzadas para transformar datos en información accionable

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

## Resumen
Con la explosión de los datos, la potencia de cómputo y los almacenes de datos en la nube (cloud data warehouses), SQL se ha convertido en una herramienta aún más indispensable para el analista o científico de datos moderno. Este libro práctico revela formas nuevas y ocultas de mejorar tus habilidades en SQL, resolver problemas y aprovechar al máximo SQL como parte de tu flujo de trabajo. Aprenderás a utilizar funciones tanto comunes como exóticas —como joins, funciones de ventana (window functions), subconsultas y expresiones regulares— de maneras innovadoras, así como a combinar técnicas de SQL para alcanzar tus objetivos más rápido con un código comprensible.

### Puntos Clave de Aprendizaje:
* **Preparación de Datos para el Análisis:** Pasos fundamentales para la limpieza y estructuración de datos crudos.
* **Análisis de Series Temporales:** Uso de manipulaciones de fecha y hora de SQL.
* **Análisis de Cohortes:** Investigación de cómo cambian los grupos de usuarios a lo largo del tiempo.
* **Análisis de Texto:** Uso de funciones y operadores potentes para datos no estructurados.
* **Detección de Anomalías:** Identificación de valores atípicos y su sustitución por valores alternativos.
* **Análisis de Experimentos:** Establecimiento de causalidad mediante el análisis de pruebas A/B.

---

## 1. Introducción

En el contexto actual, dominado por la toma de decisiones basada en datos, organizaciones de sectores como finanzas, salud, ingeniería, marketing, logística, comercio electrónico y gobierno dependen cada vez más de datos estructurados para analizar operaciones, detectar tendencias y formular estrategias.

SQL, sigla de *Structured Query Language*, constituye uno de los lenguajes fundamentales para trabajar con bases de datos relacionales. Aunque muchas personas comienzan aprendiendo instrucciones básicas como `SELECT`, `WHERE` y `JOIN`, el verdadero valor analítico de SQL aparece cuando se aplican técnicas avanzadas para transformar datos crudos en información útil y accionable.

El enfoque del material se centra en:

- Transformaciones avanzadas con SQL.
- Optimización de consultas.
- Funciones analíticas.
- Aplicaciones en proyectos reales.
- Errores frecuentes y buenas prácticas profesionales.

Este tipo de conocimiento resulta útil tanto para estudiantes que se inician en el campo de los datos como para ingenieros, analistas y arquitectos que buscan fortalecer sus capacidades analíticas.

---

## 2. Fundamentos teóricos

### 2.1. ¿Qué es SQL?

SQL es un lenguaje estandarizado utilizado para interactuar con bases de datos relacionales. Permite realizar operaciones como:

- Consultar datos.
- Insertar registros.
- Actualizar información.
- Eliminar datos.
- Administrar estructuras de bases de datos.

SQL es compatible, con diferencias dialectales, con motores ampliamente utilizados como:

- MySQL.
- PostgreSQL.
- SQL Server.
- Oracle Database.

---

### 2.2. Fundamentos de las bases de datos relacionales

Las bases de datos relacionales almacenan información en tablas estructuradas compuestas por:

- Filas o registros.
- Columnas o campos.
- Claves primarias.
- Claves foráneas.

El modelo relacional se basa en conceptos matemáticos como:

- Teoría de conjuntos.
- Lógica de predicados.
- Relaciones matemáticas.

Comprender nociones de álgebra relacional, como proyección, selección, unión y join, ayuda a interpretar mejor el comportamiento interno de SQL, especialmente cuando se trabaja con consultas complejas.

---

## 3. Definición técnica: SQL para análisis de datos

SQL para análisis de datos consiste en el uso de consultas avanzadas, funciones analíticas y lógica de transformación dentro de bases de datos relacionales para:

- Extraer patrones.
- Identificar tendencias.
- Realizar agregaciones.
- Limpiar y transformar conjuntos de datos.
- Preparar información para visualización, reportes o modelos analíticos.

Entre las técnicas principales se incluyen:

- Funciones de ventana.
- Expresiones comunes de tabla, conocidas como CTE (*Common Table Expression*).
- Subconsultas.
- Lógica condicional.
- Agregación condicional.
- Transformaciones tipo *pivot* y *unpivot*.
- Optimización de rendimiento.

---

## 4. Técnicas avanzadas de SQL

### 4.1. Filtrado avanzado y lógica condicional

Una técnica fundamental en análisis de datos es la clasificación de registros mediante expresiones condicionales. Para ello se utiliza `CASE`, que permite crear nuevas categorías o variables derivadas según reglas de negocio.

Ejemplo conceptual:

```sql
SELECT
    customer_id,
    CASE
        WHEN total_spent > 1000 THEN 'Premium'
        WHEN total_spent BETWEEN 500 AND 1000 THEN 'Standard'
        ELSE 'Basic'
    END AS customer_category
FROM customers;
```
Este patrón puede aplicarse en casos como:

- Segmentación de clientes.
- Clasificación de riesgo.
- Agrupación por niveles de desempeño.
- Creación de variables analíticas para reporting.

---

### 4.2. Técnicas avanzadas de JOIN

Los `JOIN` permiten combinar información de múltiples tablas. Son esenciales para análisis relacional, integración de datos y construcción de modelos analíticos.

Tipos principales:

| Tipo de JOIN      | Descripción                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------- |
| `INNER JOIN`      | Devuelve únicamente las filas coincidentes entre las tablas.                             |
| `LEFT JOIN`       | Mantiene todos los registros de la tabla izquierda y agrega coincidencias de la derecha. |
| `RIGHT JOIN`      | Mantiene todos los registros de la tabla derecha y agrega coincidencias de la izquierda. |
| `FULL OUTER JOIN` | Conserva todos los registros de ambas tablas, coincidan o no.                            |
| `SELF JOIN`       | Une una tabla consigo misma, útil para jerarquías o relaciones internas.                 |

Ejemplo conceptual de `SELF JOIN` para relacionar empleados con sus gerentes:

```sql
SELECT 
    e.employee_name,
    m.employee_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;
```

Este tipo de consulta es común en estructuras jerárquicas como:

* Organigramas.
* Relaciones jefe-subordinado.
* Categorías padre-hijo.
* Dependencias entre entidades.

---

### 4.3. Agregación y agrupamiento

Las funciones de agregación permiten resumir datos y obtener métricas relevantes.

Ejemplo de ventas totales por región:

```sql
SELECT 
    region,
    SUM(sales) AS total_sales
FROM orders
GROUP BY region;
```

Cuando se necesita filtrar resultados agregados, se utiliza `HAVING`:

```sql
SELECT 
    region,
    COUNT(*) AS total_orders
FROM orders
GROUP BY region
HAVING COUNT(*) > 100;
```

Diferencia clave:

* `WHERE` filtra filas antes de agrupar.
* `HAVING` filtra grupos después de la agregación.

---

### 4.4. Funciones de ventana

Las funciones de ventana permiten realizar cálculos sobre conjuntos de filas relacionadas sin colapsar el resultado final. A diferencia de `GROUP BY`, mantienen el nivel de detalle de cada fila.

Son especialmente útiles para:

* Rankings.
* Promedios móviles.
* Acumulados.
* Comparaciones contra valores anteriores.
* Análisis de series temporales.

Ejemplo de ranking por salario:

```sql
SELECT
    employee_id,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;
```

Ejemplo de promedio móvil semanal:

```sql
SELECT
    date,
    AVG(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS weekly_avg
FROM sales_data;
```

Aplicaciones comunes:

* Pronóstico financiero.
* Seguimiento de desempeño.
* Análisis temporal.
* Detección de cambios en tendencias.
* Comparación entre periodos.

---

### 4.5. Common Table Expressions — CTE

Las CTE permiten estructurar consultas complejas en bloques lógicos más legibles. Se definen mediante `WITH` y ayudan a mejorar la claridad, depuración y mantenimiento del código SQL.

Ejemplo conceptual:

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(amount) AS total
    FROM orders
    GROUP BY 1
)
SELECT *
FROM monthly_sales;
```

Ventajas principales:

* Mejoran la legibilidad.
* Permiten dividir problemas complejos en pasos.
* Facilitan la depuración.
* Evitan repetir lógica.
* Ayudan a documentar la intención analítica de una consulta.

---

### 4.6. Subconsultas y consultas anidadas

Las subconsultas permiten utilizar el resultado de una consulta dentro de otra. Pueden ser simples, escalares o correlacionadas.

Ejemplo: empleados con salario superior al promedio general.

```sql
SELECT 
    employee_name
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

Una subconsulta correlacionada depende de la fila procesada por la consulta externa. Su potencia es alta, pero debe usarse con cuidado porque puede afectar el rendimiento si el motor ejecuta la subconsulta repetidamente.

---

### 4.7. Pivot y transformación de datos

Las operaciones tipo `PIVOT` permiten transformar filas en columnas. Son útiles para crear reportes tabulares, matrices de análisis y salidas orientadas a visualización.

Ejemplo conceptual:

Tabla original:

| Mes     | Ventas |
| ------- | -----: |
| Enero   |   1000 |
| Febrero |   1200 |

Tabla transformada:

| Enero | Febrero |
| ----: | ------: |
|  1000 |    1200 |

Estas transformaciones son comunes en:

* Reportes financieros.
* Tableros ejecutivos.
* Comparaciones mensuales.
* Análisis de categorías.
* Preparación de datos para herramientas BI.

---

## 5. Flujo lógico de ejecución de una consulta SQL

Aunque una consulta se escribe empezando por `SELECT`, el motor de base de datos la procesa en otro orden lógico.

Orden conceptual:

| Paso | Operación  |
| ---: | ---------- |
|    1 | `FROM`     |
|    2 | `JOIN`     |
|    3 | `WHERE`    |
|    4 | `GROUP BY` |
|    5 | `HAVING`   |
|    6 | `SELECT`   |
|    7 | `ORDER BY` |

Comprender este orden ayuda a evitar errores comunes, especialmente cuando se utilizan alias, agregaciones y filtros sobre resultados agrupados.

---

## 6. Comparación de tipos de JOIN

| Tipo de JOIN | Devuelve coincidencias | Devuelve no coincidentes |
| ------------ | ---------------------- | ------------------------ |
| `INNER JOIN` | Sí                     | No                       |
| `LEFT JOIN`  | Sí                     | De la tabla izquierda    |
| `RIGHT JOIN` | Sí                     | De la tabla derecha      |
| `FULL JOIN`  | Sí                     | De ambas tablas          |

La elección del tipo de `JOIN` debe responder a una pregunta analítica concreta. Usar un `JOIN` incorrecto puede duplicar registros, excluir datos importantes o generar métricas distorsionadas.

---

## 7. Ejemplos analíticos

### 7.1. Análisis de tendencia de ventas

Objetivo: calcular ingresos móviles de tres meses.

```sql
SELECT
    month,
    SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3_month_revenue
FROM monthly_revenue;
```

Este patrón permite suavizar variaciones puntuales y observar tendencias más estables.

---

### 7.2. Detección de patrones de fraude

Objetivo: identificar transacciones superiores al promedio histórico del mismo usuario.

```sql
SELECT
    user_id,
    transaction_amount
FROM transactions t
WHERE transaction_amount > (
    SELECT AVG(transaction_amount)
    FROM transactions
    WHERE user_id = t.user_id
);
```

Este tipo de análisis puede utilizarse como base para reglas simples de detección de anomalías.

---

## 8. Aplicaciones reales

### 8.1. Sistemas bancarios

SQL avanzado puede aplicarse en:

* Evaluación de riesgo crediticio.
* Detección de anomalías transaccionales.
* Análisis de desempeño de préstamos.
* Seguimiento de comportamiento financiero.

---

### 8.2. Analítica en salud

Casos de uso:

* Análisis de readmisión de pacientes.
* Asignación de recursos hospitalarios.
* Modelado predictivo de resultados clínicos.
* Seguimiento operativo de servicios médicos.

---

### 8.3. Comercio electrónico

Aplicaciones frecuentes:

* Segmentación de clientes.
* Optimización de inventario.
* Seguimiento de embudos de conversión.
* Análisis de recurrencia de compra.
* Identificación de clientes de alto valor.

---

### 8.4. Ingeniería y construcción

Aplicaciones posibles:

* Análisis de variación de costos.
* Seguimiento del rendimiento de equipos.
* Pronóstico de mantenimiento.
* Control de avance de obras.
* Evaluación de eficiencia operativa.

---

## 9. Comparación entre SQL básico y SQL avanzado

| Aspecto               | SQL básico             | SQL avanzado                                         |
| --------------------- | ---------------------- | ---------------------------------------------------- |
| Filtrado              | `WHERE`                | `CASE`, filtros complejos y funciones analíticas     |
| Agregación            | `SUM`, `COUNT`, `AVG`  | Promedios móviles, acumulados y métricas por ventana |
| Preparación de datos  | Joins simples          | CTE, subconsultas, múltiples capas de transformación |
| Profundidad analítica | Consultas descriptivas | Identificación de patrones y tendencias              |
| Rendimiento           | Consultas directas     | Optimización, índices y análisis de planes           |
| Uso profesional       | Reportes simples       | Pipelines analíticos y modelos de datos complejos    |

---

## 10. Errores comunes

Errores frecuentes al trabajar con SQL para análisis de datos:

1. Usar `SELECT *` en ambientes productivos.
2. Ignorar índices y estrategias de optimización.
3. Definir condiciones incorrectas en los `JOIN`.
4. No tratar adecuadamente los valores `NULL`.
5. Abusar de subconsultas anidadas cuando una CTE sería más clara.
6. No validar duplicados después de combinar tablas.
7. Mezclar lógica de negocio y lógica técnica sin documentación.
8. No revisar el plan de ejecución.
9. No limitar columnas o rangos temporales en consultas exploratorias.
10. Asumir que todos los motores SQL se comportan igual.

---

## 11. Desafíos y soluciones

### 11.1. Problemas de rendimiento

Soluciones recomendadas:

* Crear índices adecuados.
* Revisar planes de ejecución con `EXPLAIN`.
* Evitar columnas innecesarias.
* Filtrar temprano cuando sea posible.
* Evitar funciones sobre columnas indexadas en condiciones críticas.
* Analizar cardinalidad y distribución de datos.

---

### 11.2. Grandes volúmenes de datos

Soluciones recomendadas:

* Particionar tablas.
* Usar vistas materializadas.
* Optimizar condiciones de `JOIN`.
* Procesar datos por ventanas temporales.
* Aplicar estrategias incrementales.
* Separar capas de datos crudos, transformados y analíticos.

---

## 12. Caso de estudio: transformación analítica en retail

### Problema

Una empresa minorista enfrenta una caída en sus ventas y necesita comprender las causas mediante análisis de datos.

### Análisis

Mediante SQL avanzado se podrían realizar tareas como:

* Identificar tendencias estacionales.
* Calcular promedios móviles.
* Segmentar clientes de alto valor.
* Comparar ventas por región, canal o categoría.
* Detectar productos con baja rotación.
* Analizar cambios en patrones de compra.

### Resultados esperados

Un análisis bien diseñado podría permitir:

* Mejorar la planificación de inventario.
* Aumentar la precisión de campañas comerciales.
* Identificar segmentos rentables.
* Reducir costos operativos.
* Tomar decisiones basadas en evidencia.

---

## 13. Recomendaciones para ingenieros y analistas

Buenas prácticas sugeridas:

* Analizar siempre el plan de ejecución.
* Usar CTE para mejorar legibilidad.
* Evitar cálculos repetidos.
* Aprender optimizaciones específicas del motor utilizado.
* Escribir consultas manualmente para comprender su lógica.
* Validar resultados intermedios.
* Documentar supuestos analíticos.
* Medir impacto de joins sobre cardinalidad.
* Diferenciar claramente consultas exploratorias, productivas y de reporting.
* Mantener criterios de calidad de datos.

---

## 14. Preguntas frecuentes

### 14.1. ¿SQL es suficiente para análisis de datos?

SQL es muy potente para trabajar con datos estructurados, especialmente dentro de bases de datos relacionales. Sin embargo, suele complementarse con Python, R o herramientas BI cuando se requieren visualizaciones avanzadas, modelado estadístico o aprendizaje automático.

---

### 14.2. ¿Cuál es una de las características más poderosas de SQL?

Las funciones de ventana son una de las herramientas más potentes para análisis avanzado, porque permiten calcular métricas complejas sin perder el detalle de las filas originales.

---

### 14.3. ¿Cómo se puede mejorar la velocidad de una consulta?

Algunas estrategias son:

* Crear índices apropiados.
* Optimizar condiciones de unión.
* Revisar el plan de consulta.
* Evitar traer columnas innecesarias.
* Reducir subconsultas costosas.
* Usar particiones o vistas materializadas cuando corresponde.

---

### 14.4. ¿Los ingenieros deberían aprender SQL avanzado?

Sí. SQL avanzado es fundamental para ingeniería de datos, backend, analítica, inteligencia de negocios y arquitectura de datos. Permite trabajar cerca del dato, reducir dependencias innecesarias y construir consultas más eficientes.

---

### 14.5. ¿SQL sigue siendo relevante?

Sí. SQL continúa siendo una tecnología central en sistemas empresariales, plataformas analíticas, data warehouses, lakehouses, herramientas BI y procesos de ingeniería de datos.

---

### 14.6. ¿Qué industrias dependen fuertemente de SQL?

Entre las industrias que utilizan SQL de forma intensiva se encuentran:

* Finanzas.
* Salud.
* Comercio electrónico.
* Ingeniería.
* Gobierno.
* Educación.
* Logística.
* Telecomunicaciones.
* Seguros.
* Tecnología.

---

## 15. Conclusión

SQL es mucho más que un lenguaje para consultar datos. En contextos analíticos, funciona como **una herramienta de transformación, exploración y generación de conocimiento** a partir de datos estructurados.

Dominar técnicas como funciones de ventana, CTE, agregaciones condicionales, subconsultas y optimización de consultas permite a analistas, ingenieros y arquitectos de datos construir soluciones más robustas, eficientes y orientadas a la toma de decisiones.

Para proyectos modernos de datos, SQL avanzado sigue siendo una competencia esencial. Su valor no está únicamente en obtener registros, sino en transformar datos dispersos en información confiable, interpretable y útil para la acción.

---

## 15. Referencia bibliográfica

Tanimura, C. (2021). *SQL for data analysis: Advanced techniques for transforming data into insights*. O’Reilly Media.