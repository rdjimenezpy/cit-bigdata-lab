<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# Fundamentals of Data Engineering  
## Fundamentos de Ingeniería de Datos: planificación y construcción de sistemas de datos robustos

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

En la era digital actual, los datos constituyen uno de los principales motores de innovación, toma de decisiones y ventaja competitiva. Las organizaciones modernas dependen de datos para alimentar motores de recomendación, construir modelos predictivos, generar reportes ejecutivos, optimizar operaciones, detectar fraude, mejorar servicios y automatizar procesos de negocio.

Sin embargo, los datos por sí solos no generan valor. Para que sean útiles, deben ser capturados, almacenados, transformados, gobernados y puestos a disposición de usuarios, aplicaciones, analistas, científicos de datos y sistemas operacionales. Esa responsabilidad corresponde al campo de la **ingeniería de datos**.

La ingeniería de datos combina arquitectura, software, bases de datos, sistemas distribuidos, automatización, seguridad, gobierno de datos y operaciones. Su objetivo es diseñar y construir sistemas confiables que permitan que los datos fluyan desde sus fuentes hasta los puntos donde se consumen.

La obra *Fundamentals of Data Engineering* aborda precisamente esta disciplina desde una perspectiva amplia y práctica: cómo planificar, construir y mantener sistemas de datos robustos, escalables y sostenibles.

El enfoque no se limita a una herramienta concreta. Más bien, busca explicar principios fundamentales que se mantienen vigentes aunque cambien las tecnologías: generación de datos, almacenamiento, ingesta, transformación, orquestación, gobierno, seguridad, calidad y servicio de datos.

---

# 2. ¿Qué es la ingeniería de datos?

La ingeniería de datos es la disciplina encargada de diseñar, construir, mantener y optimizar sistemas que recopilan, almacenan, procesan, transforman y entregan datos para usos analíticos u operacionales.

Un ingeniero de datos trabaja sobre la infraestructura que permite que otros perfiles puedan utilizar datos de forma confiable.

Entre los usuarios finales de los sistemas construidos por ingeniería de datos se encuentran:

- Analistas de datos.
- Científicos de datos.
- Equipos de inteligencia de negocios.
- Equipos de machine learning.
- Desarrolladores de aplicaciones.
- Áreas de negocio.
- Equipos de reporting.
- Sistemas automatizados.
- Plataformas de productos de datos.

La ingeniería de datos incluye tareas como:

- Construcción de pipelines ETL y ELT.
- Integración de fuentes heterogéneas.
- Diseño de data lakes y data warehouses.
- Modelado de datos.
- Procesamiento batch y streaming.
- Orquestación de flujos de trabajo.
- Control de calidad de datos.
- Implementación de gobierno y seguridad.
- Monitoreo de pipelines.
- Exposición de datos para analítica, BI y machine learning.

En síntesis, la ingeniería de datos crea la base técnica para que una organización pueda trabajar con datos de forma confiable, escalable y repetible.

---

# 3. Importancia de la ingeniería de datos

Las organizaciones generan datos desde múltiples fuentes:

- Logs web.
- Aplicaciones móviles.
- Sistemas CRM.
- Sistemas ERP.
- Transacciones financieras.
- Sensores IoT.
- APIs externas.
- Sistemas operacionales.
- Clickstream.
- Bases de datos transaccionales.
- Redes sociales.
- Archivos planos.
- Sistemas de terceros.

Sin una estrategia adecuada de ingeniería de datos, aparecen problemas graves:

- Datos aislados en silos.
- Inconsistencias entre sistemas.
- Indicadores contradictorios.
- Procesos manuales repetitivos.
- Retrasos en reportes.
- Fallas en flujos analíticos.
- Baja confianza en los datos.
- Riesgos de cumplimiento normativo.
- Dificultad para escalar.
- Costos innecesarios de infraestructura.

Un sistema de datos bien diseñado debe asegurar:

- Calidad.
- Escalabilidad.
- Disponibilidad.
- Rendimiento.
- Seguridad.
- Trazabilidad.
- Observabilidad.
- Gobernanza.
- Reproducibilidad.
- Facilidad de uso para usuarios finales.

La ingeniería de datos no es simplemente “mover datos”. Es construir sistemas capaces de sostener decisiones y productos basados en datos.

---

# 4. Ingeniería de datos frente a ciencia de datos

Aunque ingeniería de datos y ciencia de datos están relacionadas, no cumplen la misma función.

| Aspecto | Ingeniería de datos | Ciencia de datos |
|---|---|---|
| Enfoque principal | Infraestructura, pipelines y sistemas de datos | Análisis, modelos y predicción |
| Objetivo | Entregar datos confiables y utilizables | Extraer conocimiento y construir modelos |
| Usuarios principales | Analistas, científicos de datos, BI, aplicaciones | Negocio, investigación, productos analíticos |
| Herramientas comunes | SQL, Spark, Kafka, Airflow, dbt, cloud, bases de datos | Python, R, scikit-learn, TensorFlow, notebooks |
| Resultado típico | Pipelines, data warehouses, data lakes, datasets curados | Modelos, análisis, visualizaciones, predicciones |
| Métrica crítica | Confiabilidad, latencia, calidad, escalabilidad | Precisión, interpretabilidad, impacto analítico |

La ciencia de datos depende fuertemente de la ingeniería de datos. Un modelo predictivo avanzado no sirve si los datos son incompletos, inconsistentes, tardíos o no reproducibles.

La ingeniería de datos construye el terreno sobre el cual se ejecutan la analítica, el reporting y el machine learning.

---

# 5. Definición técnica de un sistema de datos

Un sistema de datos es una combinación diseñada de capas de almacenamiento, procesamiento, transformación y acceso que permite recopilar, preparar, guardar y entregar datos a usuarios o aplicaciones.

Un sistema de datos típico incluye:

1. **Fuentes de datos**  
   Sistemas donde se originan los datos: aplicaciones, APIs, bases transaccionales, archivos, sensores o eventos.

2. **Capa de ingesta**  
   Mecanismos que capturan y transportan los datos desde las fuentes hacia la plataforma de datos.

3. **Capa de procesamiento y transformación**  
   Procesos que limpian, enriquecen, agregan, validan y estructuran los datos.

4. **Capa de almacenamiento**  
   Sistemas donde los datos se guardan: data lake, data warehouse, lakehouse, bases NoSQL, almacenamiento de objetos o bases relacionales.

5. **Capa de servicio o consumo**  
   Interfaces mediante las cuales los datos son usados por dashboards, APIs, notebooks, modelos de machine learning, aplicaciones o herramientas BI.

6. **Capas transversales**  
   Seguridad, gobierno, monitoreo, catálogo, calidad, linaje, orquestación y control de costos.

---

# 6. ETL frente a ELT

Uno de los conceptos fundamentales en ingeniería de datos es la diferencia entre ETL y ELT.

## 6.1. ETL — Extract, Transform, Load

ETL significa:

1. Extraer datos desde las fuentes.
2. Transformar los datos antes de almacenarlos en el destino.
3. Cargar los datos transformados en el sistema final.

Este enfoque fue tradicional en data warehouses clásicos, donde los datos se limpiaban y estructuraban antes de ingresar al repositorio analítico.

Ventajas:

- Mayor control antes de cargar.
- Útil para datos estructurados.
- Reduce carga de procesamiento en el destino.
- Facilita validaciones tempranas.

Limitaciones:

- Menos flexible para exploración.
- Puede ser rígido ante cambios de esquema.
- Requiere más planificación previa.

---

## 6.2. ELT — Extract, Load, Transform

ELT significa:

1. Extraer datos desde las fuentes.
2. Cargar los datos en una plataforma de almacenamiento.
3. Transformarlos dentro del destino.

Este enfoque es común en arquitecturas cloud modernas, data lakes, lakehouses y data warehouses escalables.

Ventajas:

- Mayor flexibilidad.
- Conserva datos crudos.
- Aprovecha la capacidad de cómputo del destino.
- Permite transformaciones iterativas.
- Se adapta bien a arquitecturas modernas.

Limitaciones:

- Requiere buen gobierno de datos.
- Puede generar desorden si no hay capas claras.
- El costo computacional debe controlarse.

---

## 6.3. Comparación ETL vs ELT

| Aspecto | ETL | ELT |
|---|---|---|
| Momento de transformación | Antes de cargar | Después de cargar |
| Uso tradicional | Data warehouses clásicos | Cloud, lakehouse, data lake |
| Flexibilidad | Menor | Mayor |
| Control previo | Alto | Medio a alto |
| Conservación de datos crudos | Limitada | Alta |
| Escalabilidad | Depende del motor ETL | Alta si el destino escala bien |
| Riesgo | Rigidez | Desorden sin gobernanza |

En ingeniería de datos moderna, ELT se ha vuelto más común por el crecimiento de plataformas cloud, almacenamiento barato y motores analíticos escalables.

---

# 7. Proceso paso a paso para construir un sistema de datos robusto

## 7.1. Paso 1: Definir objetivos de datos

Antes de diseñar una arquitectura, se debe entender qué problema se quiere resolver.

Preguntas clave:

- ¿Qué problema de negocio o académico se busca resolver?
- ¿Quiénes serán los usuarios finales?
- ¿Qué decisiones se tomarán con los datos?
- ¿Qué indicadores o KPI son importantes?
- ¿Cuál es la frecuencia requerida de actualización?
- ¿Qué nivel de calidad se necesita?
- ¿Qué restricciones de seguridad existen?
- ¿Qué costo es aceptable?

Ejemplo:

> Reducir la pérdida de clientes mediante el análisis de eventos de comportamiento almacenados en logs de navegación.

Resultado esperado de esta fase:

- Objetivos claros.
- Criterios de éxito.
- Alcance definido.
- Usuarios identificados.
- Métricas relevantes.

---

## 7.2. Paso 2: Identificar fuentes de datos

Una arquitectura de datos debe comenzar con un inventario de fuentes.

Fuentes posibles:

- CRM.
- ERP.
- Bases de datos OLTP.
- Archivos CSV, JSON, XML o Parquet.
- APIs externas.
- Logs de aplicaciones.
- Eventos de clickstream.
- Sensores IoT.
- Sistemas de terceros.
- Colas de mensajes.
- Streams de eventos.
- Formularios.
- Datos abiertos.

Para cada fuente debe documentarse:

- Propietario.
- Formato.
- Esquema.
- Frecuencia de actualización.
- Volumen esperado.
- Calidad conocida.
- Sensibilidad.
- Reglas de acceso.
- Retención.
- Metadatos disponibles.

Sin esta documentación, los pipelines se vuelven frágiles y difíciles de mantener.

---

## 7.3. Paso 3: Diseñar la arquitectura de datos

El diseño arquitectónico debe responder a las necesidades reales del sistema.

Decisiones principales:

- Procesamiento batch o streaming.
- Almacenamiento centralizado o federado.
- Data warehouse, data lake o lakehouse.
- Motor de procesamiento.
- Herramienta de orquestación.
- Modelo de seguridad.
- Modelo de gobierno.
- Estrategia de calidad.
- Estrategia de monitoreo.
- Política de costos.

Consideraciones técnicas:

- Escalabilidad.
- Latencia.
- Costo.
- Seguridad.
- Cumplimiento normativo.
- Facilidad de mantenimiento.
- Interoperabilidad.
- Disponibilidad.
- Recuperación ante fallos.
- Evolución del esquema.

Una arquitectura de datos no debe diseñarse solo por moda tecnológica. Debe responder a requisitos concretos.

---

## 7.4. Paso 4: Construir pipelines de ingesta

La ingesta es el proceso mediante el cual los datos se incorporan desde las fuentes hacia el sistema de datos.

Tipos frecuentes de ingesta:

| Caso de uso | Herramientas comunes |
|---|---|
| Ingesta batch | Airflow, AWS Glue, scripts Python, Sqoop |
| Ingesta streaming | Kafka, Kinesis, Pub/Sub, Flink |
| Ingesta desde APIs | Python, Airbyte, Fivetran, Meltano |
| Ingesta de archivos | SFTP, almacenamiento de objetos, conectores |
| Captura de cambios | CDC, Debezium, logs de base de datos |

Aspectos críticos:

- Manejo de errores.
- Reintentos.
- Idempotencia.
- Validación de esquema.
- Control de duplicados.
- Control de latencia.
- Registro de ejecuciones.
- Alertas.
- Trazabilidad.

Un pipeline de ingesta profesional no solo mueve datos; también registra, valida y permite detectar fallas.

---

## 7.5. Paso 5: Limpiar y transformar datos

La transformación convierte datos crudos en datos útiles.

Tareas comunes:

- Eliminar duplicados.
- Normalizar campos.
- Corregir tipos de datos.
- Manejar valores faltantes.
- Estandarizar categorías.
- Enriquecer con atributos adicionales.
- Aplicar reglas de negocio.
- Agregar métricas.
- Validar integridad.
- Crear modelos analíticos.

Herramientas comunes:

- SQL.
- Spark.
- dbt.
- Python.
- Pandas.
- Flink.
- Beam.
- Motores ELT cloud.

En una arquitectura tipo Medallion, estas transformaciones suelen organizarse en capas:

| Capa | Propósito |
|---|---|
| Raw / Bronze | Datos crudos o mínimamente procesados |
| Silver | Datos limpios, estandarizados y validados |
| Gold | Datos agregados, métricas y modelos listos para consumo |

---

## 7.6. Paso 6: Almacenar los datos

El almacenamiento debe elegirse según el tipo de uso.

Opciones frecuentes:

| Tipo de almacenamiento | Características | Ejemplos |
|---|---|---|
| Data Lake | Datos crudos, esquema flexible, bajo costo | S3, Azure Blob, GCS |
| Data Warehouse | Datos estructurados, alto rendimiento analítico | BigQuery, Snowflake, Redshift |
| Lakehouse | Combina lake y warehouse con tablas gestionadas | Delta Lake, Iceberg, Hudi |
| Base relacional | Datos estructurados y transaccionales | PostgreSQL, MySQL, SQL Server |
| NoSQL | Esquema flexible, alto volumen o baja latencia | MongoDB, Cassandra, DynamoDB |
| Streaming storage | Eventos en tiempo real | Kafka, Pulsar |

La decisión debe considerar:

- Volumen.
- Variedad.
- Velocidad.
- Latencia.
- Costo.
- Seguridad.
- Tipo de consulta.
- Herramientas consumidoras.
- Gobernanza.
- Retención.

---

## 7.7. Paso 7: Servir y visualizar datos

Los datos deben estar disponibles para usuarios y sistemas.

Formas de consumo:

- Dashboards.
- Reportes.
- APIs.
- Notebooks.
- Modelos de machine learning.
- Herramientas BI.
- Aplicaciones operacionales.
- Reverse ETL.
- Capas semánticas.
- Métricas empresariales.

Herramientas frecuentes:

- Power BI.
- Tableau.
- Looker.
- Apache Superset.
- Metabase.
- Jupyter.
- APIs REST.
- dbt Semantic Layer.

El objetivo es facilitar analítica de autoservicio sin sacrificar calidad, seguridad ni consistencia.

---

# 8. Data warehouse frente a data lake

| Característica | Data warehouse | Data lake |
|---|---|---|
| Esquema | Predefinido | Flexible |
| Modelo | Schema-on-write | Schema-on-read |
| Costo | Generalmente mayor | Generalmente menor |
| Rendimiento | Optimizado para consultas analíticas | Variable según motor y formato |
| Datos | Estructurados y curados | Crudos, semiestructurados o no estructurados |
| Uso típico | BI, dashboards, reporting | Exploración, ML, almacenamiento masivo |
| Gobierno | Más controlado | Requiere disciplina adicional |
| Usuarios | Analistas, BI, negocio | Data engineers, científicos de datos, ML |

Un data warehouse es excelente para analítica estructurada y reporting confiable. Un data lake ofrece mayor flexibilidad para almacenar datos diversos y apoyar exploración o machine learning.

En arquitecturas modernas, ambos enfoques pueden converger en el concepto de **lakehouse**.

---

# 9. Flujo típico de ingeniería de datos

```text
Fuentes de datos
      ↓
Ingesta
      ↓
Almacenamiento inicial
      ↓
Transformación y validación de calidad
      ↓
Almacenamiento analítico
      ↓
Servicio de datos
      ↓
Analítica, BI, machine learning y aplicaciones
```

También puede representarse así:

```text
+----------------+      +-------------+      +-------------+      +-------------+
| Fuente de datos| ---> |   Ingesta   | ---> | Almacenamiento| ---> | Analítica  |
+----------------+      +-------------+      +-------------+      +-------------+
                               |
                               v
                    Transformación y controles de calidad
```

Este flujo debe estar acompañado por:

- Orquestación.
- Monitoreo.
- Seguridad.
- Gobierno.
- Pruebas.
- Documentación.
- Catálogo de datos.
- Control de costos.

---

# 10. Herramientas comunes en ingeniería de datos

| Categoría | Herramientas |
|---|---|
| Ingesta | Kafka, Flink, Airbyte, Fivetran, Meltano |
| Orquestación | Airflow, Prefect, Dagster |
| Almacenamiento | S3, GCS, Azure Blob, Snowflake, BigQuery, PostgreSQL |
| Procesamiento | Spark, Beam, Flink, SQL, dbt |
| BI y visualización | Power BI, Tableau, Looker, Superset, Metabase |
| Monitoreo | Datadog, Prometheus, Grafana |
| Calidad de datos | Great Expectations, Soda, dbt tests |
| Catálogo y gobierno | DataHub, Amundsen, Collibra |
| Formatos | Parquet, Avro, ORC, JSON, CSV |
| Lakehouse | Delta Lake, Apache Iceberg, Apache Hudi |

La herramienta correcta depende del contexto. No existe una pila universal válida para todos los casos.

---

# 11. Ejemplos prácticos

## 11.1. Pipeline de analítica de clientes

Objetivo:

> Almacenar y analizar acciones de usuarios en un sitio web.

Flujo:

1. Capturar eventos de navegación con Kafka.
2. Procesar y limpiar eventos con Spark.
3. Almacenar datos crudos en un data lake.
4. Agregar métricas y cargarlas en un data warehouse.
5. Visualizar indicadores en Power BI.

Resultado esperado:

- Dashboard diario de usuarios activos.
- Métricas de conversión.
- Análisis de comportamiento.
- Identificación de segmentos.
- Seguimiento de eventos críticos.

---

## 11.2. Detección de fraude en tiempo real

Objetivo:

> Detectar transacciones fraudulentas en tiempo real.

Arquitectura conceptual:

1. Capturar transacciones como eventos.
2. Enviar eventos a Kafka.
3. Procesar flujos con Flink.
4. Aplicar reglas o modelos de riesgo.
5. Guardar resultados en una base operativa.
6. Enviar alertas a sistemas de monitoreo.

Herramientas posibles:

- Kafka.
- Flink.
- MongoDB.
- Redis.
- Modelos de machine learning.
- Servicios de alertas.

Resultado esperado:

- Detección temprana de transacciones sospechosas.
- Reducción de pérdidas.
- Respuesta operativa más rápida.
- Monitoreo continuo.

---

# 12. Aplicaciones reales

## 12.1. Salud

La ingeniería de datos permite integrar:

- Registros médicos.
- Resultados de laboratorio.
- Datos de sensores.
- Datos administrativos.
- Información de pacientes.
- Sistemas hospitalarios.

Aplicaciones:

- Análisis de resultados clínicos.
- Optimización de recursos.
- Seguimiento de pacientes.
- Analítica epidemiológica.
- Apoyo a modelos predictivos.

---

## 12.2. Finanzas

Los bancos y entidades financieras usan sistemas de datos para:

- Analizar transacciones.
- Detectar fraude.
- Cumplir regulaciones.
- Evaluar riesgo.
- Monitorear carteras.
- Generar reportes regulatorios.

En este sector, seguridad, trazabilidad y consistencia son críticas.

---

## 12.3. Comercio electrónico

Aplicaciones:

- Recomendaciones de productos.
- Segmentación de clientes.
- Pronóstico de inventario.
- Análisis de comportamiento.
- Optimización de campañas.
- Seguimiento de ventas.

La calidad y velocidad de los datos impacta directamente en decisiones comerciales.

---

## 12.4. Telecomunicaciones

Aplicaciones:

- Análisis de logs de red.
- Predicción de abandono de clientes.
- Optimización de servicios.
- Monitoreo de uso.
- Detección de fallas.
- Planeamiento de infraestructura.

---

# 13. Errores comunes en ingeniería de datos

## 13.1. Ignorar la documentación

La falta de documentación genera confusión sobre:

- Esquemas.
- Reglas de negocio.
- Origen de datos.
- Transformaciones.
- Propietarios.
- Frecuencia de actualización.
- Significado de métricas.

Consecuencia:

- Baja confianza.
- Duplicación de trabajo.
- Errores de interpretación.
- Dificultad para mantener pipelines.

---

## 13.2. Sobrediseñar demasiado temprano

Un error frecuente es construir arquitecturas excesivamente complejas antes de validar necesidades reales.

Problemas:

- Mayor costo.
- Mayor dificultad operativa.
- Curva de aprendizaje innecesaria.
- Baja velocidad de entrega.
- Mantenimiento difícil.

Alternativa:

- Construir pipelines mínimos viables.
- Validar con usuarios.
- Iterar gradualmente.
- Escalar cuando exista evidencia.

---

## 13.3. Descuidar el monitoreo

Un pipeline sin observabilidad puede fallar silenciosamente.

Deben monitorearse:

- Tiempo de ejecución.
- Volumen procesado.
- Errores.
- Latencia.
- Calidad de datos.
- Cambios de esquema.
- Costos.
- Disponibilidad.
- Reintentos.
- Alertas.

---

## 13.4. Manejo deficiente de errores

Los errores no controlados pueden producir:

- Datos incompletos.
- Duplicados.
- Corrupción de datasets.
- Pérdida de confianza.
- Fallos en reportes.
- Decisiones incorrectas.

Buenas prácticas:

- Registrar errores.
- Implementar reintentos.
- Usar colas de errores.
- Diseñar procesos idempotentes.
- Validar datos antes y después de transformar.
- Generar alertas automáticas.

---

# 14. Desafíos y soluciones

## 14.1. Problemas de calidad de datos

Desafío:

> Datos incorrectos generan conclusiones incorrectas.

Problemas frecuentes:

- Nulos inesperados.
- Duplicados.
- Tipos incorrectos.
- Esquemas cambiantes.
- Datos fuera de rango.
- Llaves huérfanas.
- Registros incompletos.

Soluciones:

- Pruebas automatizadas.
- Validaciones de esquema.
- Reglas de calidad.
- Alertas.
- Perfilamiento de datos.
- Auditoría.
- Documentación de reglas.
- Monitoreo de métricas de calidad.

---

## 14.2. Alto volumen y alto throughput

Desafío:

> Los sistemas pueden degradarse bajo cargas elevadas.

Soluciones:

- Procesamiento distribuido.
- Kafka para eventos.
- Flink o Spark Streaming para flujos.
- Particionamiento.
- Escalado horizontal.
- Procesamiento incremental.
- Compresión.
- Formatos columnares.
- Separación de cómputo y almacenamiento.

---

## 14.3. Seguridad y cumplimiento

Desafío:

> La exposición indebida de datos puede generar brechas de seguridad y sanciones regulatorias.

Soluciones:

- Control de acceso basado en roles.
- Cifrado en tránsito y en reposo.
- Auditoría.
- Enmascaramiento de datos.
- Clasificación de información sensible.
- Principio de mínimo privilegio.
- Gestión de secretos.
- Backups.
- Políticas de retención.

---

# 15. Caso de estudio: modernización de datos en una empresa

## 15.1. Contexto

Una empresa enfrenta crecimiento acelerado de datos. Sus sistemas heredados son lentos, aislados y carecen de monitoreo.

Problemas principales:

- Datos en silos.
- Reportes lentos.
- Baja disponibilidad.
- Costos crecientes.
- Poca trazabilidad.
- Dificultad para analítica de autoservicio.

---

## 15.2. Enfoque de modernización

Acciones posibles:

1. Migrar almacenamiento a la nube.
2. Implementar Kafka para ingesta en tiempo real.
3. Usar Airflow para orquestación.
4. Adoptar Snowflake o un data warehouse cloud para analítica.
5. Establecer monitoreo y alertas.
6. Crear dashboards de autoservicio.
7. Documentar datos y métricas.
8. Implementar controles de calidad.

---

## 15.3. Resultados esperados

Una modernización bien diseñada puede lograr:

- Entrega de datos más rápida.
- Reducción de costos de infraestructura.
- Mayor autonomía de equipos de negocio.
- Mejor calidad de datos.
- Mayor trazabilidad.
- Mayor capacidad analítica.
- Mejor cumplimiento de seguridad.

La ficha consultada menciona resultados como entrega de datos 60% más rápida y reducción de costos de infraestructura del 30%, como ejemplo conceptual de impacto.

---

# 16. Consejos técnicos para ingenieros de datos

## 16.1. Comenzar por calidad

La calidad debe incorporarse desde el inicio. No debe agregarse al final como un parche.

Prácticas recomendadas:

- Validar esquemas.
- Controlar nulos.
- Verificar rangos.
- Detectar duplicados.
- Medir frescura.
- Registrar métricas de calidad.
- Automatizar pruebas.

---

## 16.2. Diseñar de forma modular

Un pipeline modular es más fácil de mantener.

Ventajas:

- Reutilización.
- Depuración más simple.
- Mejor escalabilidad.
- Menor acoplamiento.
- Cambios más controlados.
- Mayor claridad.

---

## 16.3. Automatizar todo lo repetible

La automatización reduce errores humanos.

Automatizar:

- Ejecuciones.
- Validaciones.
- Pruebas.
- Alertas.
- Despliegues.
- Documentación.
- Reprocesamientos.
- Monitoreo.

Herramientas útiles:

- Airflow.
- Prefect.
- Dagster.
- CI/CD.
- dbt.
- Great Expectations.
- GitHub Actions.

---

## 16.4. Mantenerse actualizado

La ingeniería de datos evoluciona rápidamente.

Áreas relevantes:

- Lakehouse.
- Data mesh.
- Streaming.
- Orquestación moderna.
- Observabilidad.
- DataOps.
- FinOps.
- Gobernanza.
- Calidad de datos.
- Plataformas cloud.
- Formatos abiertos como Parquet, Iceberg, Delta y Hudi.

---

## 16.5. Colaborar con stakeholders

Un sistema técnicamente elegante puede fracasar si no responde a necesidades reales.

El ingeniero de datos debe entender:

- Qué necesita el negocio.
- Qué decisiones se tomarán.
- Qué datos son críticos.
- Qué nivel de latencia se requiere.
- Qué calidad es aceptable.
- Qué restricciones existen.
- Quién consumirá los datos.

---

# 17. Preguntas frecuentes

## 17.1. ¿Qué habilidades se necesitan para ser ingeniero de datos?

Habilidades principales:

- SQL.
- Python o Scala.
- Bases de datos.
- Modelado de datos.
- Sistemas distribuidos.
- Spark o motores similares.
- Cloud computing.
- ETL y ELT.
- Orquestación.
- Seguridad.
- Gobierno de datos.
- Monitoreo.
- Git y buenas prácticas de software.

---

## 17.2. ¿Es necesario saber machine learning?

No es estrictamente necesario. Machine learning pertenece más al campo de ciencia de datos o ingeniería de machine learning.

Sin embargo, un ingeniero de datos suele colaborar con equipos de ML, por lo que conviene entender:

- Preparación de datasets.
- Feature engineering.
- Calidad de datos para modelos.
- Entrenamiento batch.
- Inferencia.
- Monitoreo de datos.
- Reproducibilidad.

---

## 17.3. ¿Cuál es la diferencia entre data lake y data warehouse?

Un data lake almacena datos crudos o semiestructurados con esquema flexible. Un data warehouse almacena datos estructurados, modelados y optimizados para consultas analíticas.

| Concepto | Data lake | Data warehouse |
|---|---|---|
| Estado de datos | Crudos o diversos | Curados y estructurados |
| Flexibilidad | Alta | Media |
| Rendimiento BI | Variable | Alto |
| Gobierno | Requiere disciplina | Más controlado |
| Uso típico | Exploración, ML, almacenamiento masivo | BI, reporting, métricas oficiales |

---

## 17.4. ¿Qué tan importante es la nube en ingeniería de datos?

La nube es muy importante en sistemas modernos porque facilita:

- Escalabilidad.
- Elasticidad.
- Almacenamiento barato.
- Servicios gestionados.
- Procesamiento distribuido.
- Reducción de administración de infraestructura.
- Despliegue rápido.
- Integración con herramientas analíticas.

Aun así, no todos los casos requieren nube. La elección debe considerar costo, seguridad, soberanía de datos, latencia y capacidades del equipo.

---

## 17.5. ¿Qué es orquestación?

La orquestación es el proceso de programar, coordinar, ejecutar y monitorear flujos de trabajo de datos de extremo a extremo.

Ejemplo:

```text
Extraer datos → Validar → Transformar → Cargar → Probar calidad → Notificar
```

Herramientas comunes:

- Apache Airflow.
- Prefect.
- Dagster.
- Luigi.

La orquestación permite controlar dependencias, horarios, reintentos, fallos y monitoreo.

---

## 17.6. ¿Cómo se asegura la calidad de datos?

Mediante:

- Validaciones automáticas.
- Reglas de esquema.
- Pruebas de datos.
- Monitoreo de frescura.
- Control de duplicados.
- Verificación de rangos.
- Alertas.
- Perfilamiento.
- Documentación.
- Linaje.

La calidad debe formar parte del pipeline, no depender de revisión manual posterior.

---

## 17.7. ¿La ingeniería de datos incluye datos en tiempo real?

Sí. Las arquitecturas streaming permiten procesar datos en tiempo real o casi real.

Herramientas comunes:

- Kafka.
- Flink.
- Spark Streaming.
- Kinesis.
- Pub/Sub.
- Pulsar.

Casos de uso:

- Fraude.
- Monitoreo IoT.
- Logs.
- Recomendaciones.
- Alertas operativas.
- Analítica de comportamiento.

---

# 18. Relación con el ciclo de vida de ingeniería de datos

El libro original de Reis y Housley se centra en el ciclo de vida de la ingeniería de datos. Este ciclo no debe confundirse con el ciclo de vida completo de los datos.

El ciclo de vida de ingeniería de datos se concentra en las etapas donde el ingeniero de datos tiene responsabilidad directa:

1. Generación de datos.
2. Almacenamiento.
3. Ingesta.
4. Transformación.
5. Servicio de datos.

Estas etapas están atravesadas por dimensiones transversales:

- Seguridad.
- Gestión de datos.
- DataOps.
- Arquitectura de datos.
- Orquestación.
- Ingeniería de software.

Este enfoque es importante porque desplaza la atención desde herramientas aisladas hacia principios duraderos.

---

# 19. Síntesis académica para estudio

Para estudiantes de Big Data, ingeniería de datos o ciencia de datos, los puntos clave son:

1. La ingeniería de datos construye la infraestructura que permite usar datos de forma confiable.
2. El valor no está solo en mover datos, sino en entregar datos de calidad para decisiones.
3. ETL transforma antes de cargar; ELT transforma después de cargar.
4. Un sistema de datos debe diseñarse según objetivos, usuarios, volumen, latencia, seguridad y costo.
5. La ingesta puede ser batch, streaming, basada en APIs, archivos o captura de cambios.
6. La transformación debe limpiar, estandarizar, enriquecer y validar datos.
7. El almacenamiento puede organizarse como data lake, warehouse, lakehouse, base relacional o NoSQL.
8. La orquestación permite controlar dependencias, horarios, errores y reintentos.
9. La calidad de datos debe automatizarse.
10. El monitoreo y la observabilidad son obligatorios en sistemas profesionales.
11. La seguridad y el gobierno son capas transversales, no tareas secundarias.
12. Una arquitectura simple y evolutiva suele ser mejor que una arquitectura sobrediseñada.
13. Los sistemas de datos modernos deben considerar costos, escalabilidad y mantenimiento.
14. La ingeniería de datos habilita BI, analítica avanzada, machine learning y productos de datos.
15. Las herramientas cambian, pero los principios del ciclo de vida de datos permanecen.

---

# 20. Conclusión

La ingeniería de datos es una disciplina esencial para cualquier organización que quiera aprovechar datos de manera seria, confiable y escalable. Su objetivo es construir sistemas que conviertan datos crudos, dispersos y heterogéneos en activos disponibles para análisis, decisiones y productos digitales.

*Fundamentals of Data Engineering* plantea una visión amplia y estructurada del campo, enfocada en principios más que en herramientas específicas. Esta perspectiva es especialmente valiosa porque las tecnologías cambian constantemente, mientras que los problemas fundamentales permanecen: generación, almacenamiento, ingesta, transformación, servicio, seguridad, gobierno y operación.

Para un estudiante o profesional de Big Data, dominar ingeniería de datos implica comprender tanto la arquitectura como la implementación. No basta con conocer herramientas como Airflow, Spark, Kafka, dbt o Snowflake. También es necesario saber cuándo usarlas, qué problema resuelven, qué costos introducen y cómo se integran en una arquitectura sostenible.

En síntesis, una buena ingeniería de datos debe entregar datos confiables, oportunos, seguros y comprensibles. Sin esa base, la analítica, el machine learning y la inteligencia de negocios pierden solidez.

---

# 21. Referencias bibliográficas en formato APA 7.ª edición

Reis, J., & Housley, M. (2022). *Fundamentals of data engineering: Plan and build robust data systems*. O’Reilly Media.
