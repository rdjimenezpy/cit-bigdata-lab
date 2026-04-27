<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# SQL for Data Analytics  
## Guía completa de SQL para analítica de datos rápida, escalable y eficiente

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

Los datos se han convertido en uno de los activos más valiosos para la ingeniería, los negocios, la ciencia y la tecnología moderna. Las organizaciones dependen cada vez más de la toma de decisiones basada en datos para mantenerse competitivas en una economía digital.

Instituciones financieras, empresas de comercio electrónico, sistemas de salud, organizaciones gubernamentales y plataformas tecnológicas utilizan datos para analizar operaciones, detectar tendencias, optimizar recursos y generar conocimiento accionable.

En este contexto, SQL, sigla de *Structured Query Language*, es una de las herramientas más importantes para la analítica de datos. SQL permite consultar, transformar, filtrar, agregar y analizar datos almacenados en bases de datos relacionales.

A diferencia de muchas herramientas de programación general, SQL está diseñado específicamente para trabajar con datos estructurados. Su potencia radica en permitir consultas eficientes sobre grandes volúmenes de información mediante una sintaxis declarativa.

Un analista de datos puede usar SQL para responder preguntas como:

- ¿Qué productos generaron mayores ingresos durante el último trimestre?
- ¿Qué segmentos de clientes tienen mayor valor de vida?
- ¿Qué regiones muestran disminución en su desempeño?
- ¿Qué tendencias existen en el tráfico de un sitio web?
- ¿Qué clientes compran con mayor frecuencia?
- ¿Qué procesos presentan anomalías operativas?

SQL permite obtener este tipo de respuestas de forma rápida, incluso cuando se trabaja con millones de registros.

Para ingenieros, analistas y científicos de datos, SQL cumple funciones críticas:

- Extracción de datos.
- Transformación de datos.
- Agregación de métricas.
- Integración de múltiples tablas.
- Reportes de inteligencia de negocios.
- Soporte a pipelines de datos.
- Preparación de datasets para machine learning.
- Construcción de vistas analíticas.
- Validación de calidad de datos.

Como SQL se utiliza en bases de datos empresariales, data warehouses, motores analíticos, plataformas cloud y ecosistemas Big Data, su aprendizaje sigue siendo una habilidad fundamental para cualquier profesional de datos.

---

# 2. Fundamentos teóricos

## 2.1. Modelo de base de datos relacional

Antes de comprender SQL aplicado a la analítica, es necesario entender el modelo relacional.

El modelo relacional fue introducido por Edgar F. Codd en 1970. Su idea central consiste en organizar los datos en tablas, también llamadas relaciones, compuestas por filas y columnas.

Cada tabla representa una entidad del dominio.

Ejemplos de entidades:

- Clientes.
- Pedidos.
- Productos.
- Transacciones.
- Empleados.
- Facturas.
- Pagos.
- Regiones.
- Categorías.

Ejemplo conceptual de una tabla `customers`:

| Customer_ID | Name  | Country | Join_Date  |
|------------:|-------|---------|------------|
| 101         | Alice | USA     | 2023-01-15 |
| 102         | James | UK      | 2022-10-02 |
| 103         | Maria | Canada  | 2024-03-01 |

Características principales de las bases de datos relacionales:

- Esquema estructurado.
- Organización en tablas.
- Relaciones entre tablas.
- Restricciones de integridad.
- Claves primarias y foráneas.
- Capacidad de consulta mediante SQL.
- Consistencia de datos.
- Soporte para transacciones.

En analítica de datos, el modelo relacional permite integrar información de distintas entidades para construir indicadores, reportes, modelos analíticos y datasets preparados para análisis avanzado.

---

## 2.2. Álgebra relacional

SQL está fuertemente inspirado en el álgebra relacional, que es un sistema matemático para manipular relaciones.

Las operaciones principales incluyen:

| Operación | Propósito |
|---|---|
| Selección | Filtrar filas según una condición. |
| Proyección | Seleccionar columnas específicas. |
| Join | Combinar tablas relacionadas. |
| Unión | Combinar conjuntos de datos compatibles. |
| Agregación | Calcular métricas resumidas. |

Estas operaciones forman la base conceptual de la mayoría de consultas SQL utilizadas en analítica.

Ejemplo:

```sql
SELECT country, SUM(revenue) AS total_revenue
FROM sales
GROUP BY country;
```

Esta consulta combina selección de columnas, agregación y agrupamiento.

---

## 2.3. Propiedades ACID

Los sistemas de bases de datos confiables se apoyan en las propiedades ACID.

| Propiedad | Descripción |
|---|---|
| Atomicidad | Una transacción se ejecuta completamente o no se ejecuta. |
| Consistencia | La base de datos mantiene reglas válidas después de cada transacción. |
| Aislamiento | Las transacciones concurrentes no interfieren incorrectamente entre sí. |
| Durabilidad | Los datos confirmados persisten incluso ante fallos del sistema. |

Aunque las cargas analíticas suelen priorizar rendimiento, escalabilidad y lectura masiva, la integridad de los datos sigue siendo esencial.

Una métrica calculada sobre datos inconsistentes produce resultados poco confiables, aunque la consulta sea técnicamente correcta.

---

## 2.4. Evolución de los sistemas analíticos

La analítica moderna con SQL se ejecuta sobre plataformas cada vez más potentes.

Ejemplos de plataformas y motores:

- PostgreSQL.
- Microsoft SQL Server.
- Oracle Database.
- MySQL.
- Snowflake.
- Google BigQuery.
- Amazon Redshift.
- Spark SQL.
- Trino.
- DuckDB.
- Databricks SQL.

Estos sistemas permiten procesar grandes volúmenes de datos y ejecutar consultas analíticas complejas.

La evolución de SQL ha permitido que el lenguaje no se limite a bases transaccionales tradicionales, sino que también sea utilizado en:

- Data warehouses.
- Data lakes.
- Lakehouses.
- Motores distribuidos.
- Sistemas de inteligencia de negocios.
- Plataformas de machine learning.
- Pipelines de ingeniería de datos.

---

# 3. Definición técnica de SQL para analítica de datos

SQL es un lenguaje específico de dominio utilizado para administrar, consultar y analizar datos almacenados en sistemas relacionales o compatibles con SQL.

En analítica de datos, SQL se utiliza principalmente para:

- Recuperar datasets.
- Filtrar registros.
- Transformar variables.
- Agregar estadísticas.
- Unir múltiples fuentes.
- Crear vistas analíticas.
- Preparar datos para dashboards.
- Preparar datos para modelos de machine learning.
- Validar calidad de datos.
- Construir capas de reporting.

Una consulta SQL analítica suele combinar varias operaciones:

```sql
SELECT
    customer_id,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
WHERE order_date >= '2025-01-01'
GROUP BY customer_id
ORDER BY total_revenue DESC;
```

Esta consulta filtra datos por fecha, agrupa por cliente, calcula métricas y ordena el resultado.

---

# 4. Categorías principales de comandos SQL

SQL se organiza en varias categorías funcionales.

| Categoría | Nombre completo | Propósito |
|---|---|---|
| DQL | Data Query Language | Consulta de datos. |
| DML | Data Manipulation Language | Manipulación de registros. |
| DDL | Data Definition Language | Definición de estructuras. |
| DCL | Data Control Language | Control de permisos. |
| TCL | Transaction Control Language | Gestión de transacciones. |

---

## 4.1. DQL — Data Query Language

DQL se utiliza para recuperar datos.

Comando principal:

```sql
SELECT
```

Ejemplo:

```sql
SELECT name, country
FROM customers
WHERE country = 'USA';
```

Este tipo de consulta es la base de la analítica descriptiva.

---

## 4.2. DML — Data Manipulation Language

DML permite insertar, actualizar y eliminar registros.

Ejemplos:

```sql
INSERT INTO customers VALUES (105, 'John', 'Australia');
```

```sql
UPDATE customers
SET country = 'UK'
WHERE id = 105;
```

```sql
DELETE FROM customers
WHERE id = 105;
```

En ambientes analíticos, DML suele utilizarse para cargar datos, corregir registros, construir tablas intermedias o preparar datasets derivados.

---

## 4.3. DDL — Data Definition Language

DDL permite definir y modificar estructuras de base de datos.

Ejemplos:

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    country VARCHAR(50)
);
```

```sql
ALTER TABLE customers
ADD COLUMN email VARCHAR(255);
```

```sql
DROP TABLE customers;
```

DDL es importante en ingeniería de datos porque permite construir tablas analíticas, esquemas, vistas, índices y estructuras de almacenamiento.

---

## 4.4. Funciones analíticas modernas

SQL moderno incluye características avanzadas para análisis:

- Funciones de ventana.
- Ranking.
- Particionamiento.
- Totales acumulados.
- Promedios móviles.
- Análisis temporal.
- CTE.
- Vistas.
- Subconsultas.
- Agregaciones condicionales.
- Transformaciones de datos.

Estas características convierten a SQL en una herramienta potente para análisis exploratorio, reporting y preparación de datos.

---

# 5. Flujo paso a paso para análisis de datos con SQL

## 5.1. Paso 1: Comprender el dataset

Antes de escribir consultas complejas, el analista debe comprender la estructura del dataset.

Aspectos a revisar:

- Tablas disponibles.
- Columnas existentes.
- Tipos de datos.
- Relaciones entre tablas.
- Claves primarias y foráneas.
- Calidad de datos.
- Nulos.
- Duplicados.
- Rango temporal.
- Granularidad de los registros.

Consulta inicial:

```sql
SELECT *
FROM sales
LIMIT 10;
```

Esta consulta permite inspeccionar las primeras filas del conjunto de datos.

Sin embargo, en producción es preferible evitar `SELECT *` sobre tablas grandes. Para exploración inicial puede ser aceptable, pero debe usarse con prudencia.

---

## 5.2. Paso 2: Filtrar datos

El filtrado reduce el volumen de datos y mejora el rendimiento.

Ejemplo:

```sql
SELECT *
FROM sales
WHERE order_date >= '2025-01-01';
```

Mejor práctica:

```sql
SELECT
    order_id,
    customer_id,
    order_date,
    revenue
FROM sales
WHERE order_date >= '2025-01-01';
```

Filtrar temprano ayuda a disminuir el costo de procesamiento, especialmente en tablas grandes.

---

## 5.3. Paso 3: Seleccionar columnas relevantes

Traer solo las columnas necesarias reduce memoria, ancho de red y costo computacional.

Ejemplo:

```sql
SELECT customer_id, revenue
FROM sales;
```

Este patrón es preferible a:

```sql
SELECT *
FROM sales;
```

En analítica profesional, seleccionar columnas explícitas mejora:

- Rendimiento.
- Claridad.
- Mantenibilidad.
- Seguridad.
- Control sobre datos sensibles.

---

## 5.4. Paso 4: Agregar datos

Las agregaciones permiten calcular métricas resumidas.

Ejemplo:

```sql
SELECT
    country,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY country;
```

Resultado conceptual:

| Country | Revenue   |
|---|---:|
| USA | 1,200,000 |
| UK | 850,000 |
| Canada | 500,000 |

Agregaciones frecuentes:

| Función | Uso |
|---|---|
| `SUM()` | Suma de valores. |
| `COUNT()` | Conteo de registros. |
| `AVG()` | Promedio. |
| `MIN()` | Valor mínimo. |
| `MAX()` | Valor máximo. |

---

## 5.5. Paso 5: Unir múltiples tablas

Los análisis complejos suelen requerir datos distribuidos en varias tablas.

Ejemplo:

```sql
SELECT
    customers.name,
    orders.order_id
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id;
```

Los `JOIN` permiten reconstruir información relacionada.

Tipos frecuentes:

| Tipo de JOIN | Uso |
|---|---|
| `INNER JOIN` | Devuelve coincidencias entre ambas tablas. |
| `LEFT JOIN` | Mantiene todos los registros de la tabla izquierda. |
| `RIGHT JOIN` | Mantiene todos los registros de la tabla derecha. |
| `FULL OUTER JOIN` | Mantiene todos los registros de ambas tablas. |
| `CROSS JOIN` | Genera combinaciones entre filas. |

Un mal diseño de `JOIN` puede duplicar registros y distorsionar métricas. Por eso, siempre se debe validar la cardinalidad.

---

## 5.6. Paso 6: Usar funciones analíticas

Las funciones de ventana permiten calcular métricas sobre grupos de filas sin perder el detalle original.

Ejemplo de ranking de clientes:

```sql
SELECT
    customer_id,
    SUM(revenue) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(revenue) DESC
    ) AS revenue_rank
FROM sales
GROUP BY customer_id;
```

Casos de uso:

- Ranking de clientes.
- Ranking de productos.
- Totales acumulados.
- Comparación contra periodos anteriores.
- Promedios móviles.
- Análisis de cohortes.
- Segmentación por desempeño.

Ejemplo de total acumulado:

```sql
SELECT
    order_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY order_date
    ) AS cumulative_revenue
FROM sales;
```

---

## 5.7. Paso 7: Optimizar rendimiento

Las consultas analíticas pueden volverse costosas cuando procesan grandes volúmenes de datos.

Técnicas comunes de optimización:

- Crear índices adecuados.
- Usar particionamiento.
- Limitar columnas.
- Filtrar temprano.
- Revisar planes de ejecución.
- Evitar subconsultas innecesarias.
- Reescribir consultas complejas.
- Usar CTE para mejorar legibilidad.
- Usar tablas temporales cuando conviene.
- Materializar resultados intermedios.
- Revisar cardinalidad de joins.

Ejemplo:

```sql
EXPLAIN ANALYZE
SELECT
    country,
    SUM(revenue) AS total_revenue
FROM sales
WHERE order_date >= '2025-01-01'
GROUP BY country;
```

---

# 6. Comparación de SQL con otras herramientas de análisis

| Característica | SQL | Python | Excel |
|---|---|---|---|
| Grandes volúmenes de datos | Excelente | Bueno | Limitado |
| Rendimiento | Muy alto en motores optimizados | Moderado a alto | Bajo a medio |
| Automatización | Alta | Alta | Limitada |
| Curva de aprendizaje | Moderada | Media a alta | Baja |
| Escalabilidad | Excelente | Buena | Limitada |
| Transformación de datos | Alta | Muy alta | Media |
| Visualización | Limitada o dependiente de BI | Alta | Media |
| Reproducibilidad | Alta | Alta | Baja si se trabaja manualmente |

SQL no reemplaza a Python, R o herramientas BI. En la práctica profesional, SQL suele combinarse con:

- Python.
- R.
- Power BI.
- Tableau.
- Looker.
- Apache Airflow.
- dbt.
- Spark.
- Machine learning frameworks.

Una arquitectura analítica típica puede usar SQL para extraer y transformar datos, Python para análisis avanzado o modelado, y BI para visualización.

---

# 7. Pipeline de analítica de datos con SQL

```text
Datos crudos
    ↓
Almacenamiento en base de datos
    ↓
Consultas SQL
    ↓
Transformación de datos
    ↓
Métricas analíticas
    ↓
Visualización / Reportes
    ↓
Decisiones basadas en datos
```

Este flujo representa cómo SQL se integra en procesos modernos de análisis.

En una arquitectura de datos, SQL puede aparecer en varias capas:

- Capa raw: inspección y validación inicial.
- Capa staging: limpieza básica.
- Capa silver: transformación y estandarización.
- Capa gold: métricas, agregados y modelos analíticos.
- Capa BI: vistas de consumo para dashboards.

---

# 8. Orden lógico de ejecución de una consulta SQL

Aunque una consulta se escribe comenzando con `SELECT`, el motor la interpreta conceptualmente en otro orden.

| Etapa | Acción |
|---|---|
| `FROM` | Selecciona tablas fuente. |
| `JOIN` | Combina tablas relacionadas. |
| `WHERE` | Filtra filas. |
| `GROUP BY` | Agrupa registros. |
| `HAVING` | Filtra grupos agregados. |
| `SELECT` | Define columnas de salida. |
| `ORDER BY` | Ordena resultados. |
| `LIMIT` | Limita la cantidad de filas devueltas. |

Comprender este orden ayuda a evitar errores, especialmente cuando se usan alias, agregaciones y filtros sobre métricas calculadas.

---

# 9. Ejemplos de análisis de datos con SQL

## 9.1. Ingresos por país

```sql
SELECT
    country,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY country
ORDER BY total_revenue DESC;
```

Uso analítico:

- Identificar mercados principales.
- Comparar desempeño regional.
- Priorización comercial.
- Análisis geográfico de ingresos.

---

## 9.2. Principales clientes por ingresos

```sql
SELECT
    customer_id,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;
```

Uso analítico:

- Identificar clientes de alto valor.
- Diseñar estrategias de fidelización.
- Priorizar cuentas clave.
- Analizar concentración de ingresos.

---

## 9.3. Tendencia mensual de ventas

```sql
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(revenue) AS monthly_revenue
FROM sales
GROUP BY month
ORDER BY month;
```

Uso analítico:

- Detectar estacionalidad.
- Evaluar crecimiento mensual.
- Comparar periodos.
- Preparar series temporales.

---

## 9.4. Promedio móvil mensual

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(revenue) AS monthly_revenue
    FROM sales
    GROUP BY month
)
SELECT
    month,
    monthly_revenue,
    AVG(monthly_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_months
FROM monthly_sales
ORDER BY month;
```

Uso analítico:

- Suavizar fluctuaciones.
- Detectar tendencias.
- Reducir ruido mensual.
- Apoyar decisiones de planificación.

---

## 9.5. Clientes con compras recurrentes

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) >= 3
ORDER BY total_orders DESC;
```

Uso analítico:

- Identificar clientes frecuentes.
- Segmentar fidelidad.
- Diseñar campañas de retención.
- Analizar recurrencia.

---

# 10. Aplicaciones reales de SQL para analítica

## 10.1. Finanzas

SQL se utiliza para:

- Detección de fraude.
- Monitoreo de transacciones.
- Análisis de riesgo.
- Reportes regulatorios.
- Segmentación de clientes.
- Análisis de cartera.
- Conciliación financiera.

Ejemplo de pregunta analítica:

> ¿Qué transacciones superan el patrón histórico promedio de cada cliente?

---

## 10.2. Comercio electrónico

Aplicaciones:

- Segmentación de clientes.
- Recomendaciones de productos.
- Seguimiento de desempeño de ventas.
- Análisis de abandono de carrito.
- Evaluación de campañas.
- Control de inventario.
- Cálculo de valor de vida del cliente.

Ejemplo de pregunta analítica:

> ¿Qué productos generan más ingresos por categoría y región?

---

## 10.3. Salud

Aplicaciones:

- Análisis de datos de pacientes.
- Optimización de recursos hospitalarios.
- Monitoreo de tendencias de enfermedades.
- Análisis de readmisiones.
- Seguimiento de tratamientos.
- Control de citas y servicios.

Ejemplo de pregunta analítica:

> ¿Qué áreas hospitalarias presentan mayor saturación por periodo?

---

## 10.4. Marketing

Aplicaciones:

- Medición de campañas.
- Segmentación de audiencias.
- Análisis de conversión.
- Seguimiento de embudos.
- Análisis de canales.
- Evaluación de retorno de inversión.

Ejemplo de pregunta analítica:

> ¿Qué canal de adquisición produce clientes con mayor conversión?

---

## 10.5. Operaciones de ingeniería

Aplicaciones:

- Análisis de logs de sistemas.
- Monitoreo de rendimiento.
- Métricas de infraestructura.
- Seguimiento de fallas.
- Análisis de sensores.
- Mantenimiento predictivo.
- Control de procesos.

Ejemplo de pregunta analítica:

> ¿Qué equipos presentan mayor frecuencia de eventos anómalos?

---

# 11. Errores comunes al usar SQL para analítica

## 11.1. Usar `SELECT *` sin criterio

Problema:

```sql
SELECT *
FROM large_table;
```

Este patrón puede ralentizar consultas, consumir memoria innecesaria y exponer columnas que no se necesitan.

Mejor práctica:

```sql
SELECT
    customer_id,
    order_date,
    revenue
FROM large_table;
```

---

## 11.2. Ignorar índices

Sin índices adecuados, una consulta puede requerir escaneos completos de tabla.

Esto afecta especialmente a filtros, joins y ordenamientos.

Ejemplo:

```sql
CREATE INDEX idx_sales_order_date
ON sales (order_date);
```

Los índices deben diseñarse según patrones reales de consulta, no de forma indiscriminada.

---

## 11.3. Diseñar joins deficientes

Un join incorrecto puede producir:

- Duplicación de registros.
- Pérdida de registros.
- Métricas infladas.
- Resultados inconsistentes.
- Alto costo computacional.

Buena práctica:

Antes y después de un join, validar conteos:

```sql
SELECT COUNT(*)
FROM customers;
```

```sql
SELECT COUNT(*)
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;
```

---

## 11.4. No filtrar datos

Analizar datasets muy grandes sin filtros reduce eficiencia.

Ejemplo poco recomendable:

```sql
SELECT
    customer_id,
    SUM(revenue)
FROM sales
GROUP BY customer_id;
```

Mejor alternativa, si el análisis es temporal:

```sql
SELECT
    customer_id,
    SUM(revenue)
FROM sales
WHERE order_date >= '2025-01-01'
GROUP BY customer_id;
```

---

## 11.5. Abusar de subconsultas

Las subconsultas anidadas pueden dificultar la lectura y reducir rendimiento.

Alternativa recomendada: usar CTE.

```sql
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(revenue) AS total_revenue
    FROM sales
    GROUP BY customer_id
)
SELECT *
FROM customer_revenue
WHERE total_revenue > 1000;
```

Las CTE mejoran legibilidad y facilitan depuración.

---

# 12. Desafíos y soluciones

## 12.1. Desafío: grandes volúmenes de datos

Problemas frecuentes:

- Consultas lentas.
- Costos elevados en plataformas cloud.
- Escaneos completos.
- Alto consumo de memoria.
- Tiempo excesivo de respuesta.

Soluciones:

- Particionar tablas.
- Crear índices.
- Limitar columnas.
- Filtrar rangos temporales.
- Usar tablas agregadas.
- Usar vistas materializadas.
- Procesar incrementalmente.
- Revisar planes de ejecución.

---

## 12.2. Desafío: consultas complejas

Problemas frecuentes:

- Código SQL difícil de leer.
- Subconsultas profundamente anidadas.
- Repetición de lógica.
- Dificultad para depurar.
- Errores en joins o agregaciones.

Soluciones:

- Dividir consultas en CTE.
- Usar tablas temporales.
- Nombrar claramente columnas calculadas.
- Validar resultados intermedios.
- Documentar supuestos.
- Separar pasos de limpieza, transformación y agregación.

---

## 12.3. Desafío: problemas de calidad de datos

Problemas frecuentes:

- Valores nulos.
- Duplicados.
- Fechas inconsistentes.
- Tipos de datos incorrectos.
- Códigos de categoría mal escritos.
- Llaves huérfanas.
- Registros incompletos.

Soluciones:

- Reglas de validación.
- Consultas de perfilamiento.
- Pipelines de limpieza.
- Deducción de duplicados.
- Normalización de categorías.
- Restricciones de integridad.
- Reportes de calidad de datos.

Ejemplo de validación de nulos:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS rows_with_customer_id,
    COUNT(*) - COUNT(customer_id) AS missing_customer_id
FROM sales;
```

---

# 13. Caso de estudio: analítica SQL en comercio electrónico

## 13.1. Contexto

Una tienda en línea desea analizar su desempeño de ventas para identificar productos con mejor rendimiento y optimizar decisiones comerciales.

El dataset incluye tablas como:

- `orders`.
- `customers`.
- `products`.
- `payments`.

Objetivo principal:

> Identificar los productos con mejor desempeño en unidades vendidas e ingresos generados.

---

## 13.2. Consulta analítica

```sql
SELECT
    product_id,
    SUM(quantity) AS total_units,
    SUM(revenue) AS total_sales
FROM orders
GROUP BY product_id
ORDER BY total_sales DESC;
```

Resultado conceptual:

| Product | Units Sold | Revenue |
|---|---:|---:|
| Laptop | 5,200 | 4.3M |
| Smartphone | 8,100 | 3.9M |
| Headphones | 12,500 | 2.1M |

---

## 13.3. Interpretación

Los resultados permiten:

- Ajustar inventario.
- Priorizar campañas.
- Optimizar precios.
- Identificar productos estratégicos.
- Evaluar categorías rentables.
- Mejorar la planificación de compras.
- Detectar oportunidades comerciales.

Este caso muestra cómo SQL puede transformar datos operacionales en información útil para decisiones de negocio.

---

# 14. Consejos técnicos para ingenieros y analistas

## 14.1. Usar indexación adecuada

Los índices pueden acelerar drásticamente las consultas, pero deben utilizarse con criterio.

Recomendaciones:

- Indexar columnas usadas frecuentemente en filtros.
- Indexar claves usadas en joins.
- Evitar exceso de índices en tablas con muchas escrituras.
- Medir impacto con `EXPLAIN`.
- Revisar selectividad de columnas.

---

## 14.2. Evitar `SELECT *`

Seleccionar solo los campos requeridos mejora:

- Rendimiento.
- Seguridad.
- Legibilidad.
- Consumo de memoria.
- Transferencia de datos.
- Mantenibilidad del código.

---

## 14.3. Usar funciones de ventana

Las funciones de ventana permiten análisis avanzados como:

- Rankings.
- Promedios móviles.
- Totales acumulados.
- Comparaciones por grupo.
- Cálculos por partición.
- Análisis longitudinal.

Ejemplo:

```sql
SELECT
    customer_id,
    order_date,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS customer_cumulative_revenue
FROM sales;
```

---

## 14.4. Analizar planes de ejecución

El perfilamiento de consultas ayuda a encontrar cuellos de botella.

Herramientas comunes:

- `EXPLAIN`.
- `EXPLAIN ANALYZE`.
- Logs de consultas lentas.
- Métricas del motor.
- Estadísticas de tabla.
- Monitores de rendimiento.

Ejemplo:

```sql
EXPLAIN ANALYZE
SELECT
    country,
    SUM(revenue)
FROM sales
GROUP BY country;
```

---

## 14.5. Aprender modelado de datos

Un buen diseño de esquema mejora el rendimiento y la claridad analítica.

Temas clave:

- Normalización.
- Desnormalización controlada.
- Modelo dimensional.
- Esquema estrella.
- Tablas de hechos.
- Tablas de dimensiones.
- Granularidad.
- Cardinalidad.
- Claves sustitutas.
- Integridad referencial.

En proyectos de Big Data e inteligencia de negocios, SQL es más efectivo cuando está respaldado por un buen modelo analítico.

---

# 15. Preguntas frecuentes

## 15.1. ¿SQL es suficiente para analítica de datos?

SQL cubre gran parte de las tareas de extracción, transformación, agregación y preparación de datos. Sin embargo, análisis estadístico avanzado, machine learning y visualizaciones complejas suelen requerir Python, R o herramientas especializadas.

---

## 15.2. ¿Cuánto tiempo toma aprender SQL?

Los fundamentos pueden aprenderse en pocas semanas. Dominar consultas analíticas, optimización, funciones de ventana, modelado y rendimiento puede requerir varios meses de práctica constante.

---

## 15.3. ¿SQL puede manejar Big Data?

Sí. Motores SQL modernos pueden procesar grandes volúmenes de datos, especialmente cuando se usan plataformas distribuidas, data warehouses cloud, particionamiento, formatos columnares y optimización adecuada.

---

## 15.4. ¿SQL se utiliza en machine learning?

Sí. SQL se utiliza frecuentemente para preparar datasets antes del entrenamiento de modelos. También se usa para limpieza, agregación, generación de variables y validación de datos.

---

## 15.5. ¿Qué bases de datos usan SQL?

Algunos sistemas ampliamente utilizados son:

- PostgreSQL.
- MySQL.
- Microsoft SQL Server.
- Oracle Database.
- SQLite.
- Snowflake.
- Google BigQuery.
- Amazon Redshift.
- DuckDB.

---

## 15.6. ¿Cuál es la habilidad SQL más importante para analistas?

Una de las habilidades más importantes es escribir correctamente consultas con `JOIN`, agregaciones y filtros. También son críticas las funciones de ventana y la capacidad de validar que el resultado no esté duplicado ni sesgado.

---

## 15.7. ¿SQL sigue siendo relevante?

Sí. SQL sigue siendo un estándar de facto para análisis de datos, ingeniería de datos, inteligencia de negocios, ciencia de datos y sistemas empresariales.

---

# 16. Conclusión

SQL es una de las tecnologías más importantes del ecosistema moderno de datos. Para ingenieros, analistas y científicos de datos, dominar SQL permite analizar grandes volúmenes de información de forma rápida, estructurada y eficiente.

Mediante consultas, operaciones relacionales y funciones analíticas avanzadas, SQL permite transformar datos crudos en información útil para la toma de decisiones.

Su valor no está únicamente en consultar tablas, sino en construir procesos analíticos reproducibles, eficientes y confiables.

Para un profesional de datos, SQL debe entenderse como una competencia transversal que conecta:

- Bases de datos.
- Modelado relacional.
- Ingeniería de datos.
- Inteligencia de negocios.
- Ciencia de datos.
- Machine learning.
- Arquitecturas analíticas modernas.

Dominar SQL implica saber extraer datos, transformarlos correctamente, validar resultados, optimizar rendimiento y comunicar hallazgos con rigor.

En síntesis, SQL continúa siendo una habilidad fundacional para cualquier persona que aspire a trabajar profesionalmente en analítica de datos, ingeniería de datos o ciencia de datos.

---

# 17. Síntesis académica para estudio

Para estudiantes de Big Data, ingeniería de datos o ciencia de datos, los puntos clave son:

1. SQL es esencial para trabajar con datos estructurados.
2. El modelo relacional organiza datos en tablas conectadas mediante claves.
3. El álgebra relacional proporciona la base conceptual de SQL.
4. Las agregaciones permiten construir métricas analíticas.
5. Los `JOIN` permiten integrar información de múltiples tablas.
6. Las funciones de ventana habilitan análisis avanzado sin perder granularidad.
7. La optimización es indispensable cuando los datos crecen.
8. La calidad de datos debe validarse antes de interpretar resultados.
9. SQL se integra naturalmente con Python, R, BI y pipelines de datos.
10. Un buen modelo de datos mejora la calidad y eficiencia del análisis.

---

# 18. Referencia bibliográfica

Malik, U., Goldwasser, M., & Johnston, B. (2019). *SQL for data analytics: Perform fast and efficient data analysis with the power of SQL*. Packt Publishing.
