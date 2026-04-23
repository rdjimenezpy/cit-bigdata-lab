

<center><h1>UNIVERSIDAD NACIONAL DE ASUNCIÓN 
     FACULTAD POLITECNICA</h1></center>
<center><h3>PROYECTO CENTRO DE INNOVACIÓN TIC, FPUNA-KOICA</center>

<center><h4>Curso Básico de Introducción a Big Data</h4></center>

<center>Prof. Ing. Richard D. Jiménez-R.</center>



### <u>Guía Didáctica</u>: "Análisis, Diseño, Desarrollo e Implementación de un Data Warehouse para el Cubo de Remuneraciones con Pentaho y PostgreSQL"

------

#### **Objetivo General**

Desarrollar un Data Warehouse (DW) para el análisis de las remuneraciones de los funcionarios públicos utilizando **Pentaho Data Integration (Kettle)** para los procesos de ETL y **PostgreSQL** como base de datos para el centro de datos.

------

### **Fases del Proyecto**

La guía se estructura en cuatro fases principales:

1. **Análisis de Requerimientos**.
2. **Diseño del Data Warehouse.**
3. **Desarrollo y ETL con Pentaho**.
4. **Implementación y Visualización.**

------

## **Fase 1: Análisis de Requerimientos**

### **Actividad 1: Identificación de Fuentes de Datos**

- **Objetivo**: Definir y documentar las fuentes de datos que alimentarán el cubo de remuneraciones.

- Tareas:

  - Revisar las bases de datos existentes (Ej. SQL Server, archivos CSV).
  - Consultar a los stakeholders sobre los datos clave que desean analizar (salarios, horas extras, bonos, descuentos, etc.).
  - Crear una lista de campos relevantes: empleado, departamento, fecha, monto de salario, etc.

  Herramientas

  : Documentos de requisitos, reuniones con stakeholders.

### **Actividad 2: Definición de Indicadores Clave**

- **Objetivo**: Identificar los indicadores clave de rendimiento (KPIs) relacionados con remuneraciones.

- **Tareas**:

  - Definir métricas como **salario promedio**, **salario total por departamento**, **costos de nómina**, etc.
  - Documentar dimensiones para análisis: tiempo, departamento, nivel jerárquico.

  **Herramientas**: Documentación de KPIs, plantillas de requisitos.

------

## **Fase 2: Diseño del Data Warehouse**

### **Actividad 3: Modelado Dimensional**

- **Objetivo**: Diseñar el modelo dimensional para el cubo de remuneraciones.

- Tareas:

  - Crear un **diagrama de esquema estrella** que incluya una **tabla de hechos** (remuneraciones) y varias **tablas de dimensiones** (empleado, departamento, tiempo).
  - Diseñar atributos para las tablas de dimensiones, como:
    - **Dim_Empleado**: Nombre, ID, Cargo.
    - **Dim_Departamento**: Nombre, Ubicación.
    - **Dim_Tiempo**: Fecha, Mes, Año.

  Herramientas: ERD (Entity Relationship Diagram) para diseño de esquema, software de modelado como Lucidchart o Draw.io.

### **Actividad 4: Diseño del Proceso ETL**

- **Objetivo**: Definir el flujo de extracción, transformación y carga (ETL).

- **Tareas**:

  - Crear el flujo ETL para extraer datos desde las fuentes identificadas (Ej. base de datos relacional, CSV).
  - Definir las transformaciones necesarias: limpieza de datos, conversión de tipos de datos, cálculo de indicadores.
  - Planificar la carga incremental o completa del Data Warehouse.

  **Herramientas**: **Pentaho Spoon** para diseñar el flujo de ETL, diagramas de flujo.

------

## **Fase 3: Desarrollo y ETL con Pentaho**

### **Actividad 5: Configuración de PostgreSQL**

- **Objetivo**: Preparar la base de datos PostgreSQL para el Data Warehouse.

- **Tareas**:

  - Instalar PostgreSQL.
  - Crear las tablas de hechos y dimensiones diseñadas.
  - Definir índices para optimizar el rendimiento de las consultas.

  **Herramientas**: **PostgreSQL** y **pgAdmin**.

### **Actividad 6: Creación del Proceso ETL con Pentaho**

- **Objetivo**: Desarrollar el flujo ETL en Pentaho Kettle.

- **Tareas**:

  - Crear **transformaciones ETL** en **Pentaho Spoon** para extraer los datos de las fuentes.
  - Aplicar transformaciones de datos: conversión de fechas, cálculo de totales, agrupaciones.
  - Cargar los datos transformados en las tablas de hechos y dimensiones en PostgreSQL.

  **Pasos clave**:

  - **Extracción**: Conectar Pentaho a las fuentes de datos (archivos CSV, bases de datos).
  - **Transformación**: Aplicar las reglas de negocio y validaciones.
  - **Carga**: Insertar los datos en PostgreSQL.

  **Herramientas**: **Pentaho Spoon**, **pgAdmin** para monitorear las tablas de PostgreSQL.

### **Actividad 7: Pruebas del Proceso ETL**

- **Objetivo**: Validar la precisión del proceso ETL.

- **Tareas**:

  - Ejecutar el proceso ETL y verificar la correcta transformación y carga de los datos.
  - Revisar la consistencia de los datos cargados en las tablas de PostgreSQL.
  - Comparar los datos de origen con los datos cargados en el DW.

  **Herramientas**: **Pentaho Spoon**, SQL en **pgAdmin**.

------

## **Fase 4: Implementación y Visualización**

### **Actividad 8: Creación de Consultas SQL para el Cubo de Remuneraciones**

- **Objetivo**: Desarrollar consultas SQL para analizar los datos de remuneraciones.

- Tareas:

  - Crear consultas para obtener el salario total, salario promedio, y otros indicadores por departamento, fecha o empleado.
  - Implementar agrupaciones y cálculos de KPI usando SQL en PostgreSQL.

  Herramientas: pgAdmin, PostgreSQL.

### **Actividad 9: Generación de Reportes con Pentaho Reporting o BI Tools**

- **Objetivo**: Presentar los datos de remuneraciones de manera visual para el análisis.

- **Tareas**:

  - Utilizar **Pentaho Reporting** para generar reportes sobre las métricas definidas (ej. salario promedio por departamento).
  - Opcionalmente, integrar otras herramientas como **Tableau** o **Power BI** para crear dashboards interactivos.

  **Herramientas**: **Pentaho Report Designer**, **Tableau** o **Power BI**.

------

## **Fase 5: Mantenimiento y Optimización**

### **Actividad 10: Programación de ETL y Optimización del Rendimiento**

- **Objetivo**: Automatizar y optimizar los procesos ETL.

- **Tareas**:

  - Programar la ejecución automática del ETL con **Pentaho Kitchen** para cargas periódicas.
  - Revisar la performance de las consultas y optimizar índices en PostgreSQL.
  - Documentar el proceso para futuras mejoras.

  **Herramientas**: **Pentaho Kitchen**, **pgAdmin**, análisis de rendimiento SQL.

------

### **Recursos y Herramientas Recomendadas**

- **Pentaho Data Integration (Kettle)**: Herramienta para el proceso ETL.
- **PostgreSQL**: Base de datos para el Data Warehouse.
- **pgAdmin**: Interfaz gráfica para la administración de PostgreSQL.
- **Pentaho Report Designer**: Para la generación de informes.

------

### **Evaluación y Conclusiones**

Al finalizar estas actividades, los participantes habrán diseñado, desarrollado e implementado un Data Warehouse para el análisis de remuneraciones, empleando herramientas de código abierto como Pentaho y PostgreSQL.