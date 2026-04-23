## Manual de Configuración y Despliegue del Proyecto con Pentaho Data Integration (Kettle) y PostgreSQL

### 1. Prerrequisitos

- **Pentaho Data Integration (Kettle)**: Descargado e instalado en tu sistema.
- **PostgreSQL**: Instalado y configurado.
- **Java Development Kit (JDK)**: Instalado y configurado (se recomienda Java 8).
- **Driver JDBC de PostgreSQL**: Descargado y copiado en el directorio de Pentaho.



### 2. Instalación y Configuración de PostgreSQL

1. **Descarga PostgreSQL:**
   - Descarga el instalador desde [PostgreSQL](https://www.postgresql.org/download/).
2. **Instalación:**
   - Sigue las instrucciones del instalador para instalar PostgreSQL.
   - Durante la instalación, elige una contraseña para el usuario `postgres`.
3. **Creación de una conexión a la base de datos:**
   - Abre `pgAdmin` o usa `DBeaver` para conectarte a PostgreSQL.
   - Ejecuta el siguiente comando para crear una nueva base de datos:

4. **Prueba la conexión:**
- Haz clic en "Probar" para verificar que la conexión se realiza correctamente.

### 3. Instalación de Pentaho Data Integration (PDI)

1. **Descarga PDI:**
   - Descarga la versión más reciente de Pentaho Data Integration.
2. **Descomprime el archivo:**
   - Descomprime el archivo descargado en la ubicación deseada de tu sistema.
3. **Verifica la instalación:**
   - Navega al directorio de instalación y ejecuta el archivo `Spoon.bat` (Windows) o `spoon.sh` (Linux/Mac).
   - Se abrirá la interfaz gráfica de PDI (Spoon).
4. **Prueba la conexión:**

- Haz clic en "Probar" para verificar que la conexión se realiza correctamente.

5. **Configuración de Parámetros y Variables:**
	- Configura variables de entorno globales en el archivo `kettle.properties` ubicado en el directorio ~/.kettle/.
