### Guía de Instalación y Configuración: Despliegue de un Data Warehouse en PostgreSQL con Pentaho Data Integration

Esta guía describe el proceso para instalar y configurar las herramientas necesarias para desplegar un Data Warehouse en **PostgreSQL** y realizar la integración de datos mediante **Pentaho Data Integration (PDI)**.

---

### **Requisitos Previos**
1. **Sistema Operativo**: Linux (Ubuntu) o Windows.
2. **Java JDK**: Requisito para Pentaho (Java 8 o superior).
3. **PostgreSQL**: Base de datos para almacenar el Data Warehouse.
4. **Pentaho Data Integration**: Herramienta ETL para extraer, transformar y cargar datos.

---

## **Paso 1: Instalación de PostgreSQL**

### **1.1 Instalación en Ubuntu**
1. Actualizar los repositorios:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```
2. Instalar PostgreSQL:
   ```bash
   sudo apt install postgresql postgresql-contrib
   ```
3. Iniciar el servicio PostgreSQL:
   ```bash
   sudo systemctl start postgresql
   ```
4. Verificar el estado del servicio:
   ```bash
   sudo systemctl status postgresql
   ```

### **1.2 Instalación en Windows**
1. Descargar el instalador de PostgreSQL desde [postgresql.org](https://www.postgresql.org/download/).
2. Ejecutar el instalador y seguir las instrucciones:
   - Configurar la contraseña del usuario `postgres`.
   - Instalar las herramientas adicionales, como **pgAdmin**.
3. Verificar la instalación accediendo a **pgAdmin** y conectándose al servidor local.

### **1.3 Creación de la Base de Datos para el Data Warehouse**
1. Conectar a PostgreSQL como usuario `postgres`:
   ```bash
   sudo -i -u postgres
   psql
   ```
2. Crear una nueva base de datos para el Data Warehouse:
   ```sql
   CREATE DATABASE dw_remuneraciones;
   ```
3. Crear un usuario para la base de datos (si no existe):
   ```sql
   CREATE USER dw_user WITH PASSWORD 'password123';
   ```
4. Otorgar permisos al usuario:
   ```sql
   GRANT ALL PRIVILEGES ON DATABASE dw_remuneraciones TO dw_user;
   ```

---

## **Paso 2: Instalación de Pentaho Data Integration (Kettle)**

### **2.1 Instalación en Ubuntu**
1. Descargar **Pentaho Data Integration** (PDI) desde la página oficial de **Hitachi Vantara**:
   - [Descargar Pentaho](https://sourceforge.net/projects/pentaho/files/Pentaho%209.3/client-tools/)
   ```bash
   wget https://sourceforge.net/projects/pentaho/files/Pentaho%209.3/client-tools/pdi-ce-9.3.0.0-428.zip
   ```
2. Descomprimir el archivo:
   ```bash
   unzip pdi-ce-9.3.0.0-428.zip -d /opt/pentaho
   ```
3. Dar permisos de ejecución al archivo **Spoon.sh**:
   ```bash
   chmod +x /opt/pentaho/data-integration/Spoon.sh
   ```

### **2.2 Instalación en Windows**
1. Descargar el paquete desde el enlace anterior.
2. Descomprimir el archivo en una carpeta de tu elección (ej. `C:\Pentaho`).
3. Navegar a la carpeta **data-integration** y ejecutar **Spoon.bat**.

### **2.3 Configuración Inicial de Pentaho**
1. Verificar que **Java** esté correctamente instalado:
   ```bash
   java -version
   ```
   - Si no está instalado, descargar e instalar **JDK 8** o superior desde [Java SE](https://www.oracle.com/java/technologies/javase-jdk8-downloads.html).

2. Ejecutar **Spoon** (interfaz gráfica de Pentaho):
   - En Ubuntu:
     ```bash
     ./Spoon.sh
     ```
   - En Windows, ejecutar **Spoon.bat**.

---

## **Paso 3: Configuración de PostgreSQL en Pentaho Data Integration**

### **3.1 Descargar el Driver JDBC de PostgreSQL**
1. Descargar el controlador **JDBC** para PostgreSQL desde [jdbc.postgresql.org](https://jdbc.postgresql.org/download.html).
2. Copiar el archivo **postgresql-xx.x.x.jar** a la carpeta de Pentaho:
   - En Ubuntu:
     ```bash
     sudo cp postgresql-xx.x.x.jar /opt/pentaho/data-integration/lib/
     ```
   - En Windows, copiar el archivo a la carpeta **lib** en `C:\Pentaho\data-integration\lib`.

### **3.2 Crear una Conexión a PostgreSQL desde Pentaho**
1. Abrir **Pentaho Spoon**.
2. Crear una nueva **transformación**.
3. Hacer clic derecho en el área de trabajo y seleccionar **Database Connection**.
4. Configurar la conexión:
   - **Name**: PostgreSQL_DW
   - **Connection Type**: PostgreSQL
   - **Host Name**: `localhost` o la dirección IP del servidor PostgreSQL.
   - **Database Name**: `dw_remuneraciones`.
   - **Port**: 5432.
   - **Username**: `dw_user`.
   - **Password**: `password123`.
5. Probar la conexión para asegurarse de que funciona correctamente.

---

## **Paso 4: Diseño y Creación del Proceso ETL**

### **4.1 Extracción de Datos**
1. Crear una nueva **transformación** en **Pentaho Spoon**.
2. Añadir un paso de entrada:
   - **Table Input**: Si la fuente de datos es otra base de datos.
   - **CSV File Input**: Si los datos provienen de un archivo CSV.
3. Configurar el paso de entrada para conectarse a la fuente de datos y extraer la información necesaria (ej. salarios, empleados).

### **4.2 Transformación de Datos**
1. Añadir pasos de transformación:
   - **Select Values**: Para seleccionar columnas específicas.
   - **Filter Rows**: Para filtrar datos no deseados.
   - **Join Rows**: Para combinar datos de diferentes fuentes.

### **4.3 Carga de Datos en PostgreSQL**
1. Añadir un paso de **Table Output** para cargar los datos transformados en la base de datos PostgreSQL.
2. Configurar la conexión a PostgreSQL creada anteriormente.
3. Seleccionar la tabla de destino donde se cargarán los datos (ej. tabla de hechos o dimensiones).
4. Ejecutar la transformación y verificar que los datos se carguen correctamente en PostgreSQL.

---

## **Paso 5: Programación y Automatización del ETL**

### **5.1 Crear un Trabajo en Pentaho Spoon**
1. Crear un nuevo **Job** en **Pentaho Spoon** para orquestar la ejecución de las transformaciones.
2. Añadir pasos para:
   - **Iniciar la transformación ETL**.
   - Enviar notificaciones por correo en caso de errores o finalización.
3. Probar el trabajo manualmente para asegurarse de que funciona correctamente.

### **5.2 Programar el Trabajo con Pentaho Kitchen**
1. Usar **Pentaho Kitchen** para programar la ejecución del trabajo.
   - En Ubuntu:
     ```bash
     ./Kitchen.sh -file="/opt/pentaho/data-integration/jobs/etl_dw_remuneraciones.kjb"
     ```
   - En Windows, ejecutar **Kitchen.bat** con la ruta del archivo de trabajo.

2. Utilizar el **cron** de Linux o el **Programador de tareas** de Windows para automatizar la ejecución del trabajo ETL de manera periódica (diaria, semanal, etc.).

---

## **Paso 6: Validación y Visualización**

### **6.1 Validación del Data Warehouse**
1. Verificar la consistencia de los datos cargados en PostgreSQL comparándolos con las fuentes originales.
2. Ejecutar consultas SQL en PostgreSQL para asegurar que los datos estén limpios y organizados correctamente en las tablas de hechos y dimensiones.

### **6.2 Creación de Informes con Pentaho Reporting**
1. Utilizar **Pentaho Report Designer** para crear informes que visualicen las métricas clave (salario promedio, total de remuneraciones por departamento, etc.).
2. Conectar **Pentaho Reporting** a la base de datos PostgreSQL y generar gráficos y reportes interactivos.

---

### **Conclusión**
Siguiendo esta guía, habrás instalado y configurado PostgreSQL como Data Warehouse y Pentaho Data Integration para gestionar los procesos ETL. Esta infraestructura permitirá automatizar la integración y análisis de datos, proporcionando una solución robusta y escalable para la toma de decisiones basada en datos.