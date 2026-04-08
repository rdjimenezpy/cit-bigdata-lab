<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: DuckDB — comandos esenciales
**Operación básica del motor, consultas rápidas, lectura de archivos y exportación de datos desde CLI**

---

## Datos institucionales

**Institución:** Universidad Nacional de Asunción  
**Unidad Académica:** Facultad Politécnica  
**Dependencia:** Centro de Innovación TIC (PK)  
**Área:** Big Data   **Nivel:** Básico  
**Curso:** Introducción a Big Data   **Enfoque:** Fundamentos y Pipelines de Datos con Python  
**Docente:** Prof. Ing. Richard D. Jiménez-R.  
**Contacto:** rjimenez@pol.una.py

---

## Autor del documento

**Prof. Ing. Richard Daniel Jiménez Riveros**  
Ingeniero en Informática  
Docente del curso *Introducción a Big Data en el Centro de Innovación TIC*  
Facultad Politécnica - Universidad Nacional de Asunción  

---

## Fecha y versión

- **Fecha:** 23/03/2026
- **Versión:** 1.0

---

## Propósito

Este documento resume de forma rápida los comandos, sintaxis, rutas, opciones y patrones de uso más frecuentes de **DuckDB**, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico en el entorno de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** DuckDB CLI + SQL  
**Versión de referencia:** DuckDB 1.4 LTS / línea 1.x  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- Tener DuckDB instalado y accesible desde terminal con el comando `duckdb`.
- Contar con permisos de lectura y escritura sobre el directorio de trabajo y los archivos de datos.
- Disponer de datasets locales de prueba en formatos como `CSV`, `Parquet` o `JSON`.
- Tener nociones básicas de SQL para ejecutar consultas, crear tablas y exportar resultados.
- Saber en qué ruta quedará almacenado el archivo `.duckdb` del laboratorio.

---

## Convenciones usadas en este documento

- `comando` → instrucción para ejecutar en terminal o consola.
- `ruta/archivo` → rutas o nombres de archivos.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro del ejemplo.

---

## Comandos esenciales

| Acción | Comando / Sintaxis | Descripción breve |
|---|---|---|
| Verificar instalación | `duckdb --version` | Muestra la versión instalada de DuckDB CLI. |
| Abrir una base existente o crear una nueva | `duckdb {{archivo.duckdb}}` | Inicia la consola sobre un archivo de base de datos local. |
| Abrir DuckDB en memoria | `duckdb` | Inicia una sesión temporal sin persistencia en archivo. |
| Listar tablas | `.tables` | Muestra las tablas disponibles en la base activa. |
| Ver esquema de una tabla | `.schema {{tabla}}` | Muestra la definición SQL de la tabla indicada. |
| Ejecutar consulta SQL directa | `duckdb {{archivo.duckdb}} -c "SELECT * FROM {{tabla}} LIMIT 5;"` | Ejecuta una consulta no interactiva desde terminal. |
| Leer CSV con autodetección | `SELECT * FROM read_csv_auto('{{ruta.csv}}');` | Carga un CSV directamente sin importar primero una tabla física. |
| Consultar Parquet directamente | `SELECT * FROM '{{ruta.parquet}}' LIMIT 10;` | Permite leer archivos Parquet como fuente directa. |
| Crear tabla a partir de consulta | `CREATE TABLE {{tabla}} AS SELECT ...;` | Persiste resultados de una consulta en una tabla nueva. |
| Describir columnas | `DESCRIBE {{tabla}};` | Muestra nombres, tipos y nulabilidad de columnas. |
| Exportar a Parquet | `COPY {{tabla}} TO '{{salida.parquet}}' (FORMAT PARQUET);` | Exporta datos a un archivo Parquet. |
| Exportar a CSV | `COPY {{tabla}} TO '{{salida.csv}}' (HEADER, DELIMITER ',');` | Exporta datos a CSV con encabezados. |
| Adjuntar otra base | `ATTACH '{{otra_base.duckdb}}' AS {{alias}};` | Conecta otra base DuckDB a la sesión actual. |
| Instalar y cargar extensión | `INSTALL httpfs; LOAD httpfs;` | Habilita acceso a archivos remotos HTTP/S3 cuando aplica. |

---

## Flujo rápido de uso

```bash
# 1) Verificar instalación y crear base local
duckdb --version
mkdir -p data/duckdb
cd data/duckdb
duckdb laboratorio.duckdb

# 2) Crear tabla desde un CSV
CREATE TABLE ventas AS
SELECT *
FROM read_csv_auto('../raw/ventas.csv');

# 3) Validar estructura y consultar datos
.tables
DESCRIBE ventas;
SELECT * FROM ventas LIMIT 10;

# 4) Exportar resultados
COPY ventas TO '../exported/ventas.parquet' (FORMAT PARQUET);
.quit
```

---

## Sintaxis frecuente

### 1. Operación básica de la CLI

```bash
duckdb --version
duckdb
duckdb laboratorio.duckdb
duckdb laboratorio.duckdb -c "SELECT current_database();"
```

```sql
.help
.tables
.schema
.schema ventas
.quit
```

### 2. Lectura directa de archivos y creación de tablas

```sql
SELECT *
FROM read_csv_auto('data/raw/ventas.csv')
LIMIT 10;

SELECT *
FROM 'data/raw/ventas.parquet'
LIMIT 10;

CREATE TABLE ventas AS
SELECT *
FROM read_csv_auto('data/raw/ventas.csv');

CREATE TABLE clientes AS
SELECT *
FROM 'data/raw/clientes.parquet';
```

### 3. Inspección, consulta y perfilado rápido

```sql
SHOW TABLES;
DESCRIBE ventas;
SUMMARIZE ventas;
SELECT COUNT(*) FROM ventas;
SELECT * FROM ventas LIMIT 20;
EXPLAIN SELECT * FROM ventas WHERE monto > 100000;
EXPLAIN ANALYZE SELECT * FROM ventas WHERE monto > 100000;
```

### 4. Exportación, copias y persistencia

```sql
COPY ventas TO 'data/exported/ventas.csv' (HEADER, DELIMITER ',');
COPY ventas TO 'data/exported/ventas.parquet' (FORMAT PARQUET);
COPY (
    SELECT categoria, SUM(monto) AS total
    FROM ventas
    GROUP BY categoria
) TO 'data/exported/resumen_categoria.parquet' (FORMAT PARQUET);
```

### 5. Adjuntar bases y extensiones comunes

```sql
ATTACH 'data/duckdb/analitica.duckdb' AS analitica;
SHOW DATABASES;
USE analitica;

INSTALL httpfs;
LOAD httpfs;

INSTALL postgres;
LOAD postgres;
```

---

## Ejemplos rápidos

### Ejemplo 1 — Crear una base de laboratorio y cargar un CSV

```bash
duckdb data/duckdb/lab.duckdb
```

```sql
CREATE TABLE funcionarios AS
SELECT *
FROM read_csv_auto('data/raw/funcionarios.csv');

SELECT COUNT(*) AS total_registros
FROM funcionarios;
```

### Ejemplo 2 — Consultar un Parquet sin importar la tabla

```bash
duckdb -c "SELECT institucion, SUM(monto) AS total FROM 'data/raw/remuneraciones.parquet' GROUP BY institucion ORDER BY total DESC LIMIT 10;"
```

### Ejemplo 3 — Exportar una consulta agregada a Parquet

```bash
duckdb data/duckdb/lab.duckdb
```

```sql
COPY (
    SELECT periodo, SUM(monto) AS total_mensual
    FROM remuneraciones
    GROUP BY periodo
    ORDER BY periodo
) TO 'data/exported/total_mensual.parquet' (FORMAT PARQUET);
```

### Ejemplo 4 — Adjuntar otra base DuckDB y consultar entre ambas

```bash
duckdb data/duckdb/lab.duckdb
```

```sql
ATTACH 'data/duckdb/catalogo.duckdb' AS catalogo;
SHOW DATABASES;
SELECT *
FROM catalogo.productos
LIMIT 10;
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Ejecutable principal | `duckdb` | Cliente CLI de DuckDB para sesiones interactivas o ejecución directa. |
| Base local del laboratorio | `data/duckdb/lab.duckdb` | Archivo persistente recomendado para prácticas del repositorio. |
| Datos crudos de entrada | `data/raw/` | Carpeta sugerida para CSV, JSON, Parquet u otras fuentes locales. |
| Exportaciones analíticas | `data/exported/` | Carpeta sugerida para salidas generadas desde consultas DuckDB. |
| Base adjunta secundaria | `data/duckdb/catalogo.duckdb` | Ejemplo de otra base que puede conectarse con `ATTACH`. |
| Carpeta temporal de trabajo | `/tmp/` | Útil para pruebas rápidas o archivos intermedios en Ubuntu/WSL2. |
| Archivo SQL reutilizable | `scripts/sql/{{consulta}}.sql` | Ubicación sugerida para guardar consultas SQL del laboratorio. |

---

## Errores frecuentes y solución rápida

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `duckdb: command not found` | DuckDB no está instalado o no está en el PATH. | Verificar instalación y exponer el binario en el PATH del sistema. |
| No se crea el archivo `.duckdb` | La ruta destino no existe o no hay permisos de escritura. | Crear el directorio previamente y validar permisos sobre la carpeta. |
| `No files found that match the pattern` | La ruta al CSV o Parquet está mal escrita o el archivo no existe. | Confirmar con `ls`, revisar rutas relativas y usar comillas simples correctas. |
| Error al leer CSV | Delimitador, encoding o cabecera inconsistentes. | Probar `read_csv_auto(...)` o definir parámetros explícitos en `read_csv(...)`. |
| `Catalog Error: Table ... does not exist` | La tabla no fue creada o se está consultando en otra base/esquema. | Verificar con `.tables`, `SHOW TABLES` o revisar la base adjunta activa. |
| `IO Error` al exportar | La carpeta de salida no existe o está protegida. | Crear la carpeta destino antes de ejecutar `COPY`. |
| Extensión no disponible | No se instaló o cargó la extensión requerida. | Ejecutar `INSTALL nombre_extension;` y luego `LOAD nombre_extension;`. |
| Confusión entre sesión en memoria y archivo persistente | Se abrió DuckDB sin especificar archivo. | Iniciar con `duckdb nombre.duckdb` cuando se necesite persistencia. |

---

## Buenas prácticas

- Trabajar con una base `.duckdb` persistente para laboratorios que requieran continuidad entre sesiones.
- Mantener separadas las carpetas de entrada (`data/raw/`) y salida (`data/export/`) para evitar sobrescribir fuentes originales.
- Usar `read_csv_auto()` y lectura directa de Parquet para exploración inicial, pero crear tablas persistentes cuando el laboratorio lo requiera.
- Guardar consultas reutilizables en archivos `.sql` dentro del repositorio en vez de depender solo del historial interactivo.
- Exportar resultados relevantes en `Parquet` cuando se busque eficiencia analítica y portabilidad.
- Verificar siempre tipos de datos con `DESCRIBE` o `SUMMARIZE` antes de modelar transformaciones posteriores.
- Evitar usar la sesión en memoria para ejercicios que luego deban documentarse o repetirse en clase.

---

## Atajos o recordatorios clave

- **Nota rápida 1:** abrir `duckdb` sin archivo crea una sesión temporal; cerrar la consola implica perder ese estado.
- **Nota rápida 2:** DuckDB permite consultar `CSV` y `Parquet` directamente sin proceso ETL previo para exploración básica.
- **Nota rápida 3:** `COPY (...) TO ...` es una de las formas más rápidas de materializar resultados analíticos.
- **Nota rápida 4:** `ATTACH` sirve para trabajar con varias bases en una misma sesión sin mover datos innecesariamente.
- **Nota rápida 5:** para laboratorio académico, conviene estandarizar la base principal en `data/duckdb/lab.duckdb`.

---

## Referencias

1. DuckDB Foundation. *DuckDB Documentation*. https://duckdb.org/docs/stable/  
2. DuckDB Foundation. *CLI Client Documentation*. https://duckdb.org/docs/stable/clients/cli/overview.html  
3. DuckDB Foundation. *Data Import and Export Documentation*. https://duckdb.org/docs/stable/data/overview  

---

## Relación con otros documentos del repositorio

- Tutorial relacionado: `tutorial_06_instalacion_y_configuracion_duckdb_en_ubuntu_wsl2.md`
- Documento complementario: `cheatsheet_postgresql_15_administracion_basica.md`
- Cheat Sheet asociado: `cheatsheet_python_pyenv_venv.md`

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida durante laboratorios y prácticas guiadas. No sustituye un tutorial completo de instalación o modelado, pero sí cubre el conjunto mínimo de comandos y patrones necesarios para abrir bases, cargar archivos, inspeccionar estructuras, consultar datos y exportar resultados con DuckDB de forma consistente dentro del repositorio base.
