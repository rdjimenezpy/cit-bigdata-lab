<center><h1>UNIVERSIDAD NACIONAL DE ASUNCIÓN 
     FACULTAD POLITECNICA</h1></center>
<center><h3>PROYECTO CENTRO DE INNOVACIÓN TIC, FPUNA-KOICA</center>

<center><h4>Curso Básico de Introducción a Big Data</h4></center>

<center>Prof. Ing. Richard D. Jiménez-R.</center>

### **<u>Guía de Actividad:</u> Diseño de una Base de Datos Relacional e Implementación de un Proceso ETL con Pentaho Data Integration (Kettle) y PostgreSQL.**



### Objetivo

El objetivo de esta actividad es que el estudiante analice el diseño de una base de datos relacional para almacenar un conjunto de datos específico, y luego analice la implementación de un proceso ETL con **Pentaho Data Integration** (Kettle) para cargar los datos desde un archivo *CSV* hacia la base de datos diseñada para **PostgreSQL**.



### Estructura de Directorios del Proyecto

A continuación, se detalla los directorios del proyecto con **Pentaho Data Integration** (Kettle):

**/src/**: Este es el directorio raíz que contiene todo el código fuente del proyecto. Dentro de él, puedes dividir las transformaciones y los trabajos en directorios específicos:

- **/jobs/**: Contiene los archivos `.kjb` de los jobs.
- **/transformaciones/**: Contiene los archivos `.ktr` de las transformaciones.
- **/sql/**: Para consultas SQL que se requiera ejecutar como parte del proceso de migración.
- **/config/**: Para almacenar los archivos de configuración, como archivos de propiedades (`.properties`), configuraciones de base de datos o variables de entorno.
- **/scripts/**: Scripts útiles y adicionales, como scripts de shell, python, etc., que son parte del flujo de trabajo.
- **/util/**: Para herramientas, utilidades o funciones auxiliares que no están directamente relacionadas con el flujo de trabajo principal del proceso ETL, pero que son útiles para el proyecto. 
- **README.md:** Manual de configuración e instalación del proyecto.

**/data/**: Aquí almacenas los datos de entrada y salida. Se recomienda dividirlo en subdirectorios:

- **/input/**: Archivos de datos de entrada.
- **/output/**: Resultados generados por las transformaciones.

**/logs/**: Carpeta dedicada para almacenar los logs de ejecución de las transformaciones y jobs, permitiendo el seguimiento y análisis de errores.

**/docs/**: Para documentar el proyecto, instrucciones de uso, configuración y cualquier otra información importante relacionada.

**/libs/**: Aquí puedes poner librerías externas necesarias, como drivers JDBC u otras dependencias que necesita el proyecto.

**/modelo/:** Para almacenar los diagramas y archivos fuentes de los modelos conceptuales, lógicos y físico de la base de datos. 

**/queries/:** Para almacenar las consultas SQL de utilidades de reporteria, seguimiento y monitoreos de servicios varios.



### Actividades

1. Análisis de los datos:
   - Obtener el archivo CSV proporcionado.
   - Identificar las entidades y atributos presentes en los datos.
   - Establecer las relaciones entre las entidades.
   - Definir los tipos de datos apropiados para cada atributo.
2. Análisis del diseño del modelo relacional:
   - Analizar el diagrama entidad-relación (DER) que represente la estructura de la base de datos.
   - Verificar las normalizaciones de las tablas para eliminar redundancias y anomalías.
   - Identificar en el DER las claves primarias y foráneas.
3. Análisis de la implementación de la base de datos:
   - Crear la base de datos utilizando PostgreSQL como sistema gestor de bases de datos relacional (SGBDR).
   - Crear las tablas de acuerdo al modelo de datos diseñado.
   - Crear los índices necesarios para mejorar el rendimiento de las consultas.
4. Análisis de la implementación del proceso ETL:
   - Analizar los archivos SQL, Transformation y Job del Proyecto ETL implementado en Pentaho Data Integration (Kettle):
     - Extraer los datos del archivo CSV.
     - Transformar los datos para ajustarlos al esquema de la base de datos.
     - Cargar los datos en las tablas de la base de datos.
5. Documentaciones del Proyecto:
   - Elaborar un informe técnico que incluya:
     - Descripción del problema y los objetivos.
     - Análisis de los datos y diseño del modelo de datos.
     - Descripción del proceso ETL implementado.
     - Código fuente de los scripts utilizados.
     - Resultados de las pruebas realizadas.
     - Conclusiones y recomendaciones.



### Herramientas

- **Almacenamiento:** Sistema de base de datos PostgreSQL.
- **Integración de datos:** Pentaho Kettkle.
- **Modelado de datos:** SQL Power Architect.
- **Cliente de base de datos:** DBeaver, PgAdmin.
- **Diagramación:** Draw.io.
- **Lenguajes de programación:** SQL, PL/PgSQL.


### Entorno de Trabajo

Instalación y configuración de herramientas en su entorno de trabajo local.

- ###### <u>Servidor de Base de Datos:</u> PostgreSQL (15.x en adelante)

`https://www.postgresql.org/download/`

`https://www.enterprisedb.com/downloads/postgres-postgresql-downloads`



- ###### <u>Cliente de Base de Datos:</u> DBeaver Community Edition

`https://dbeaver.io/download/`



- ###### <u>Modelado de Datos:</u> SQL Power Architect Community Edition (el más reciente)

`https://bestofbi.com/architect-download/`



- ###### <u>JDBC Driver en SQL Power Architect:</u> PostgreSQL JDBC Driver

`https://jdbc.postgresql.org/download/`



- ###### <u>Herramienta ETL:</u> Pentaho Data Integration (PDI) v9.4.

`https://www.hitachivantara.com/en-us/products/pentaho-plus-platform/data-integration-analytics/pentaho-community-edition.html`



- ###### Navicat Data Modeler Express (Opcional)

`https://www.navicat.com/es/products/navicat-data-modeler`



### DataSet

Datos abiertos publicados por la Secretaría de la Funció Pública (SFP), correspondiente a las nóminas de funcionarios públicos por periodo (año y mes).

- Descargar la Nómina de Funcionarios del Portal de la SFP.
- Para fines prácticos usar la nómina de funcionarios del periodo enero-2024
https://datos.sfp.gov.py/data/funcionarios/download


------------------------------

### Criterios de Evaluación (30 puntos)

- Diseño del modelo de datos (10 puntos):
  - Correcta identificación de entidades y atributos.
  - Diseño adecuado de las relaciones.
  - Normalización correcta de las tablas.
  - Definición clara de claves primarias y foráneas.
- Implementación de la base de datos (10 puntos):
  - Creación correcta de las tablas y relaciones.
  - Creación de índices adecuados.
  - Optimización del rendimiento de la base de datos.
- Implementación del proceso ETL (5 puntos):
  - Extracción correcta de los datos del archivo CSV.
  - Transformación adecuada de los datos.
  - Carga exitosa de los datos en la base de datos.
- Documentación (5 puntos):
  - Claridad y concisión en la presentación de la información.
  - Completitud de la documentación.
  - Uso correcto de la terminología técnica.


### Entrega

Cada grupo de trabajo deberá elaborar para su entrega un informe técnico en formato digital que incluya todos los elementos mencionados anteriormente.

### Consideraciones Adicionales

- Se recomienda que cada grupo de trabajo investigue sobre las mejores prácticas en el diseño de bases de datos relacionales y en la implementación de un proceso de ETL.
- Es importante que cada grupo de trabajo verifique exhaustivamente la base de datos y el proceso ETL para garantizar su correcto funcionamiento.
- Se valorará la capacidad del estudiante para resolver problemas y adaptarse a cambios en los requisitos.

---

¡Éxito en la investigación e implementación del proyecto!

**Prof. Ing. Richard Jiménez - Docente del Curso Básico de Introducción a Big Data.**