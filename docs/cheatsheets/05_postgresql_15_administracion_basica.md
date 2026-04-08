<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: PostgreSQL 15 — administración básica
**Comandos esenciales para operación, conexión, gestión inicial de bases, roles y respaldo**

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

Este documento resume de forma rápida los comandos, sintaxis, rutas, opciones y patrones de uso más frecuentes de **PostgreSQL 15**, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico en el entorno de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** PostgreSQL 15  
**Versión de referencia:** PostgreSQL 15.x  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- Tener PostgreSQL 15 instalado y el servicio operativo en el sistema.
- Contar con acceso al usuario administrador de PostgreSQL o a un rol con privilegios suficientes.
- Tener disponible la utilidad `psql` en el PATH del sistema.
- Conocer el nombre de la base de datos, el puerto y el usuario con el que se trabajará.
- Disponer de permisos del sistema para iniciar, detener o consultar el servicio si corresponde.

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
| Verificar cliente `psql` | `psql --version` | Confirma que el cliente de PostgreSQL está instalado y visible en el sistema. |
| Verificar disponibilidad del servidor | `pg_isready` | Comprueba si la instancia está aceptando conexiones. |
| Conectarse a una base | `psql -U {{usuario}} -d {{basedatos}} -h {{host}} -p {{puerto}}` | Abre una sesión interactiva contra una base específica. |
| Listar bases de datos | `\l` | Muestra las bases de datos del clúster desde `psql`. |
| Listar roles | `\du` | Muestra roles y atributos principales del clúster. |
| Listar tablas | `\dt` | Muestra tablas del esquema activo en `psql`. |
| Describir una tabla | `\d {{tabla}}` | Muestra estructura, columnas, índices y restricciones. |
| Consultar usuario actual | `SELECT current_user;` | Devuelve el rol con el que está conectada la sesión. |
| Crear base de datos | `CREATE DATABASE {{basedatos}};` | Crea una nueva base de datos. |
| Crear rol con login | `CREATE ROLE {{usuario}} WITH LOGIN PASSWORD '{{clave}}';` | Crea un rol utilizable para conexión. |
| Cambiar contraseña | `ALTER ROLE {{usuario}} WITH PASSWORD '{{nueva_clave}}';` | Actualiza la contraseña del rol indicado. |
| Respaldar una base | `pg_dump -U {{usuario}} -d {{basedatos}} > respaldo.sql` | Genera una exportación lógica simple. |
| Restaurar una base | `psql -U {{usuario}} -d {{basedatos}} -f respaldo.sql` | Ejecuta un script SQL de restauración. |

---

## Flujo rápido de uso

```bash
# 1) Verificar cliente y disponibilidad del servidor
psql --version
pg_isready

# 2) Conectarse como usuario administrador
psql -U postgres -d postgres

# 3) Crear usuario y base para laboratorio
CREATE ROLE lab_user WITH LOGIN PASSWORD 'cambiar_esta_clave';
CREATE DATABASE lab_db OWNER lab_user;
\q

# 4) Probar la conexión con el nuevo usuario
psql -U lab_user -d lab_db
```

---

## Sintaxis frecuente

### 1. Operación del servicio en Ubuntu / WSL2

```bash
# con systemd habilitado
sudo systemctl status postgresql
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql

# alternativa cuando se usa el wrapper de servicio
sudo service postgresql status
sudo service postgresql start
sudo service postgresql stop
sudo service postgresql restart
```

### 2. Conexión e inspección básica con `psql`

```bash
psql -U postgres -d postgres
psql -h localhost -p 5432 -U postgres -d postgres

\conninfo
\l
\du
\dn
\dt
\dt *.*
\d nombre_tabla
\q
```

### 3. Administración inicial de roles y bases de datos

```sql
CREATE ROLE lab_user WITH LOGIN PASSWORD 'cambiar_esta_clave';
ALTER ROLE lab_user WITH PASSWORD 'nueva_clave_segura';
ALTER ROLE lab_user CREATEDB;

CREATE DATABASE lab_db OWNER lab_user;
GRANT ALL PRIVILEGES ON DATABASE lab_db TO lab_user;

DROP DATABASE lab_db;
DROP ROLE lab_user;
```

### 4. Respaldo y restauración básicos

```bash
pg_dump -U postgres -d lab_db > lab_db_respaldo.sql
psql -U postgres -d lab_db -f lab_db_respaldo.sql

# formato personalizado
pg_dump -U postgres -Fc -d lab_db -f lab_db_respaldo.dump
pg_restore -U postgres -d lab_db lab_db_respaldo.dump
```

### 5. Verificación rápida en Windows (PowerShell)

```powershell
Get-Service postgresql*

# acceso a psql si está en el PATH
psql --version
psql -U postgres -d postgres -h localhost -p 5432
```

---

## Ejemplos rápidos

### Ejemplo 1 — Verificar que PostgreSQL está operativo en Ubuntu / WSL2

```bash
sudo systemctl status postgresql
pg_isready
psql -U postgres -d postgres -c "SELECT version();"
```

### Ejemplo 2 — Crear usuario y base de laboratorio

```bash
psql -U postgres -d postgres
```

```sql
CREATE ROLE estudiante_bd WITH LOGIN PASSWORD 'Cambiar123!';
CREATE DATABASE laboratorio_bd OWNER estudiante_bd;
GRANT ALL PRIVILEGES ON DATABASE laboratorio_bd TO estudiante_bd;
```

### Ejemplo 3 — Consultar tablas y estructura de una base

```bash
psql -U estudiante_bd -d laboratorio_bd
```

```sql
\dt
\d nombre_tabla
SELECT current_database(), current_user;
```

### Ejemplo 4 — Respaldo y restauración rápidos

```bash
pg_dump -U postgres -d laboratorio_bd > laboratorio_bd.sql
createdb -U postgres laboratorio_bd_restore
psql -U postgres -d laboratorio_bd_restore -f laboratorio_bd.sql
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Cliente interactivo | `psql` | Herramienta principal para conectarse y administrar PostgreSQL desde consola. |
| Archivo principal de configuración | `/etc/postgresql/15/main/postgresql.conf` | Ruta típica en Ubuntu/Debian para parámetros del servidor. |
| Configuración de autenticación | `/etc/postgresql/15/main/pg_hba.conf` | Define método de autenticación, origen y reglas de acceso. |
| Directorio de datos | `/var/lib/postgresql/15/main/` | Ubicación típica del clúster de datos en Ubuntu/Debian. |
| Binarios en Windows | `C:\Program Files\PostgreSQL\15\bin\` | Ruta habitual donde se ubican `psql`, `pg_dump`, `pg_restore`, etc. |
| Puerto por defecto | `5432` | Puerto TCP estándar de PostgreSQL. |
| Base administrativa | `postgres` | Base común para tareas de conexión y administración inicial. |

---

## Errores frecuentes y solución rápida

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `psql: command not found` | Cliente no instalado o no incluido en PATH. | Verificar instalación y PATH; en Windows usar la carpeta `bin` de PostgreSQL. |
| `connection refused` | El servicio no está iniciado o el puerto/host no corresponde. | Iniciar PostgreSQL y validar puerto, host y firewall. |
| `password authentication failed` | Contraseña incorrecta o regla de autenticación no coincide. | Verificar credenciales y revisar `pg_hba.conf` si aplica. |
| `role does not exist` | Se intentó conectar con un usuario no creado en el clúster. | Crear el rol con `CREATE ROLE ... LOGIN` o usar uno existente. |
| `database does not exist` | La base aún no fue creada o el nombre está mal escrito. | Validar con `\l` y crearla con `CREATE DATABASE`. |
| `permission denied` sobre objetos | El rol no tiene privilegios suficientes. | Otorgar permisos con `GRANT` o conectarse con un rol administrador. |
| `CREATE DATABASE cannot run inside a transaction block` | El comando se ejecutó dentro de una transacción explícita. | Ejecutar `CREATE DATABASE` fuera de `BEGIN ... COMMIT`. |
| Restauración incompleta | Se restauró sobre una base incorrecta o vacía de forma parcial. | Revisar destino, formato del dump y mensajes de error del proceso. |

---

## Buenas prácticas

- Usar un rol administrativo solo para instalación, configuración y tareas de administración; para laboratorios conviene usar roles de trabajo separados.
- Verificar siempre conectividad con `pg_isready`, `psql` y `\conninfo` antes de diagnosticar problemas complejos.
- Evitar trabajar todo el tiempo con `postgres`; crear bases y roles específicos para cada laboratorio o proyecto.
- Mantener respaldos lógicos antes de cambios importantes en estructura, datos o configuración.
- Revisar `pg_hba.conf` y `postgresql.conf` antes de exponer la instancia a otras máquinas o redes.
- Documentar puerto, usuario, base y rutas relevantes del entorno para no improvisar durante las prácticas.
- Probar restauraciones, no solo backups; un respaldo que nunca se valida tiene valor limitado.

---

## Atajos o recordatorios clave

- **Nota rápida 1:** `\l`, `\du`, `\dt` y `\d nombre_tabla` resuelven gran parte de la inspección diaria en `psql`.
- **Nota rápida 2:** en Ubuntu/Debian la autenticación local del usuario `postgres` suele resolverse con `sudo -u postgres psql`.
- **Nota rápida 3:** `CREATE ROLE` define usuarios/roles a nivel de clúster, no solo de una base de datos.
- **Nota rápida 4:** `CREATE DATABASE` no se ejecuta dentro de transacciones explícitas.
- **Nota rápida 5:** `pg_dump` hace respaldo lógico; no reemplaza a una estrategia completa de backup físico o alta disponibilidad.

---

## Referencias

1. PostgreSQL Global Development Group. *PostgreSQL 15 Documentation*. https://www.postgresql.org/docs/15/  
2. PostgreSQL Global Development Group. *psql — PostgreSQL interactive terminal*. https://www.postgresql.org/docs/15/app-psql.html  
3. PostgreSQL Global Development Group. *pg_ctl — initialize, start, stop, or control a PostgreSQL server*. https://www.postgresql.org/docs/15/app-pg-ctl.html  
4. PostgreSQL Global Development Group. *SQL Commands*. https://www.postgresql.org/docs/15/sql-commands.html  

---

## Relación con otros documentos del repositorio

- Tutorial relacionado: `docs/tutoriales/04_instalacion_postgresql_15_wsl2_ubuntu.md`
- Tutorial relacionado: `docs/tutoriales/05_instalacion_postgresql_15_windows.md`
- Documento complementario: `README.md`
- Cheat Sheet asociado: `docs/cheatsheets/wsl2_comandos_basicos.md`

---

## Bloque ultra-rápido

```bash
# verificar servicio y cliente
pg_isready
psql --version

# conectarse como administrador
psql -U postgres -d postgres

# inspección rápida dentro de psql
\l
\du
\dt
\conninfo

# backup y restore simples
pg_dump -U postgres -d lab_db > lab_db.sql
psql -U postgres -d lab_db -f lab_db.sql
```

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida para tareas básicas de operación, conexión, inspección, creación de bases, gestión de roles y respaldo lógico en PostgreSQL 15. No sustituye al tutorial completo de instalación y configuración, pero sí cubre el conjunto mínimo de acciones que conviene tener a mano durante prácticas de laboratorio y ejercicios técnicos.
