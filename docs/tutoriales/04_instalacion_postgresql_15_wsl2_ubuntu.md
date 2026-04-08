<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración de PostgreSQL 15 en WSL2/Ubuntu
**Entorno Windows 11 + WSL2 + Ubuntu 22.04.5 LTS – Despliegue de PostgreSQL 15 para uso académico en laboratorios de Big Data e Ingeniería de Datos**

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

- **Fecha:** 19/03/2026
- **Versión:** 1.0

---

## Nota sobre esta documentación

Este tutorial fue ajustado para el **entorno técnico de referencia de la cátedra**, basado en **Windows 11 + WSL2 + Ubuntu 22.04.5 LTS**, con PostgreSQL desplegado **dentro de Linux/WSL** como servicio local para laboratorios, pruebas de concepto y ensayos.

Eso tiene una implicancia práctica importante: **el procedimiento principal recomendado en este documento no es instalar PostgreSQL “nativamente” en Windows**, sino instalarlo en **Ubuntu bajo WSL2**, porque esa estrategia es más coherente con el stack reproducible del curso y con el flujo de trabajo posterior usando Bash, Python, Git, Airflow, DBeaver y herramientas de ingeniería de datos.

Las rutas, mensajes de consola, nombres de paquetes y salidas pueden variar levemente según:

- la versión exacta de Windows y WSL,
- el estado de `systemd`,
- la versión de Ubuntu,
- la configuración de red local,
- políticas institucionales del equipo,
- y paquetes previamente instalados.

En caso de necesitar apoyo adicional para reproducir el tutorial, el estudiante deberá contactar con el docente o utilizar los canales oficiales de la asignatura.

---

## 1. Introducción

**PostgreSQL** es un sistema gestor de bases de datos relacional y objeto-relacional, ampliamente utilizado en entornos académicos, empresariales y de ingeniería de datos. En este proyecto cumple un rol clave como **motor OLTP** para la capa operacional del pipeline, donde se modelan y administran datos estructurados que luego serán extraídos, transformados y cargados hacia capas analíticas.

En el contexto de la asignatura **Electiva - Big Data**, PostgreSQL no se estudia como una herramienta aislada, sino como parte de un flujo técnico mayor que incluye:

- preparación del entorno de laboratorio,
- diseño de esquemas relacionales,
- carga e integración de datos,
- consultas SQL y PL/pgSQL,
- interacción con herramientas ETL,
- y articulación con motores analíticos y orquestadores.

Por eso este tutorial no se limita a “instalar PostgreSQL”: también busca que el estudiante comprenda **cómo desplegarlo, verificarlo, administrarlo y dejarlo en una condición operativa adecuada para el resto del stack**.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- Instalar **PostgreSQL 15** en **Ubuntu 22.04.5 LTS** ejecutado sobre **WSL2**.
- Comprender la diferencia entre la instalación por defecto de Ubuntu y la instalación de una versión específica usando el repositorio oficial de PostgreSQL.
- Verificar el estado del servicio y del clúster instalado.
- Acceder al servidor local usando `psql`.
- Configurar una contraseña para el usuario administrador `postgres`.
- Crear un usuario y una base de datos inicial para laboratorios.
- Administrar el servicio con `systemd`.
- Deshabilitar el arranque automático cuando convenga trabajar con un modelo de inicio manual bajo demanda.
- Conectarse desde herramientas cliente como **DBeaver** usando `localhost`.

---

## 3. Rol de PostgreSQL dentro del stack del proyecto

Dentro del stack técnico del proyecto `BIGDATA-FPUNA`, PostgreSQL 15 se utilizará principalmente para:

- **capa transaccional (OLTP)** del proyecto;
- definición de tablas operacionales;
- carga inicial y staging controlado;
- validaciones SQL;
- funciones y procedimientos en **PL/pgSQL**;
- fuente o destino intermedio de procesos ETL/ELT;
- soporte a ejercicios de modelado relacional y administración de bases de datos.

En términos simples:

- **PostgreSQL**: motor relacional operacional.
- **DuckDB**: motor analítico/OLAP.
- **Pentaho Data Integration**: integración y transformación.
- **Apache Airflow**: orquestación.
- **Python**: automatización, utilitarios y pruebas.
- **DBeaver**: administración y consulta interactiva.

---

## 4. ¿Por qué instalar PostgreSQL dentro de WSL2 y no directamente en Windows?

Para esta cátedra, la decisión técnica recomendada es usar **PostgreSQL dentro de Ubuntu/WSL2** por estas razones:

1. **Coherencia con el resto del stack**  
   El proyecto usa herramientas que viven mejor en un entorno Linux o híbrido Linux-first: Bash, Python, Airflow, Git, utilitarios CLI y automatización.

2. **Reproducibilidad**  
   Resulta más fácil documentar y replicar el entorno entre estudiantes cuando la instalación se hace sobre una base común (`Ubuntu 22.04.5 LTS`).

3. **Mayor cercanía a entornos reales**  
   En ingeniería de datos, muchos despliegues y automatizaciones ocurren en servidores Linux o contenedores.

4. **Separación más clara entre host y laboratorio**  
   Windows queda como sistema anfitrión; Ubuntu/WSL concentra la capa técnica del laboratorio.

5. **Mejor integración con tutoriales posteriores**  
   Esto simplifica la continuidad con Python, Airflow, scripts Bash, conexiones locales y automatización.

**Conclusión técnica:**  
Para este repositorio y para la secuencia pedagógica del curso, **la instalación principal soportada es PostgreSQL 15 en Ubuntu sobre WSL2**.

---

## 5. Requisitos previos

Antes de comenzar, verifica que ya dispones de lo siguiente:

- **Windows 11** operativo.
- **WSL2** instalado y funcional.
- **Ubuntu 22.04.5 LTS** instalado en WSL.
- Usuario Linux con permisos `sudo`.
- Conectividad a Internet.
- Espacio suficiente en disco para paquetes y datos.
- Conocimientos básicos de terminal Linux.

### Verificaciones rápidas

Ejecuta en **PowerShell**:

```powershell
wsl --status
wsl --version
wsl -l -v
```

Ejecuta dentro de **Ubuntu**:

```bash
uname -a
lsb_release -a
whoami
```

---

## 6. Consideraciones técnicas antes de instalar

### 6.1 Instalación por repositorio de Ubuntu vs repositorio oficial PGDG

Ubuntu incluye PostgreSQL en sus repositorios, pero normalmente “congela” una versión para cada release. Eso significa que:

- `sudo apt install postgresql` instala **la versión empaquetada por Ubuntu** para esa distribución;
- si necesitas una **versión exacta**, como **PostgreSQL 15**, conviene instalarla desde el **repositorio oficial PGDG**.

Para fines del curso, **no se recomienda depender del metapaquete genérico** `postgresql`, porque en el futuro podría resolver a otra versión si cambias de distribución o repositorio.

La estrategia correcta aquí es:

- registrar el repositorio oficial;
- instalar explícitamente `postgresql-15` y `postgresql-client-15`.

### 6.2 systemd en WSL

El control de servicios con `systemctl` dentro de WSL requiere que **systemd** esté habilitado. Si ya seguiste el tutorial de WSL del repositorio, probablemente esto ya esté resuelto. Si no, verifica primero.

---

## 7. Paso 1 — Verificar si `systemd` está habilitado en WSL

Dentro de Ubuntu, ejecuta:

```bash
systemctl --version
```

Si el comando responde correctamente, continúa.

Si obtienes errores relacionados con que el sistema no fue iniciado con `systemd`, habilítalo editando `/etc/wsl.conf`:

```bash
sudo nano /etc/wsl.conf
```

Agrega este contenido:

```ini
[boot]
systemd=true
```

Guarda el archivo y luego, desde **PowerShell**, apaga WSL:

```powershell
wsl --shutdown
```

Vuelve a abrir Ubuntu y verifica otra vez:

```bash
systemctl --version
```

---

## 8. Paso 2 — Actualizar el sistema e instalar dependencias base

Actualiza índices y paquetes:

```bash
sudo apt update
sudo apt upgrade -y
```

Instala dependencias mínimas necesarias para registrar el repositorio oficial de PostgreSQL:

```bash
sudo apt install -y curl ca-certificates
```

> En este punto no conviene instalar todavía el paquete `postgresql` genérico, porque queremos controlar la versión exacta.

---

## 9. Paso 3 — Registrar el repositorio oficial de PostgreSQL (PGDG)

### Opción recomendada para laboratorio: configuración manual y explícita

Crea el directorio esperado para la clave del repositorio:

```bash
sudo install -d /usr/share/postgresql-common/pgdg
```

Descarga la clave oficial:

```bash
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
```

Carga el `VERSION_CODENAME` de Ubuntu y registra el repositorio:

```bash
. /etc/os-release
sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
```

Actualiza nuevamente la lista de paquetes:

```bash
sudo apt update
```

### Verificación opcional del archivo de repositorio

```bash
cat /etc/apt/sources.list.d/pgdg.list
```

Deberías observar algo conceptualmente equivalente a:

```text
deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt jammy-pgdg main
```

---

## 10. Paso 4 — Instalar PostgreSQL 15 y cliente

Ahora instala la versión exacta requerida para el curso:

```bash
sudo apt install -y postgresql-15 postgresql-client-15
```

### Qué instala este paso

- `postgresql-15`: servidor PostgreSQL 15
- `postgresql-client-15`: cliente `psql` y utilitarios asociados

### Verificar versión del cliente

```bash
psql --version
```

Salida esperada aproximada:

```text
psql (PostgreSQL) 15.x
```

---

## 11. Paso 5 — Verificar servicio y clúster instalado

Consulta el estado del servicio:

```bash
sudo systemctl status postgresql
```

También verifica los clústeres administrados por `postgresql-common`:

```bash
pg_lsclusters
```

Salida esperada aproximada:

```text
Ver Cluster Port Status Owner    Data directory               Log file
15  main    5432 online postgres /var/lib/postgresql/15/main ...
```

### Comandos operativos básicos del servicio

```bash
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl status postgresql
```

---

## 12. Paso 6 — Acceder por primera vez al servidor

En Ubuntu, el usuario `postgres` suele autenticarse localmente por mecanismo `peer`. Por eso, la forma correcta de ingresar por primera vez es:

```bash
sudo -u postgres psql
```

Una vez dentro, puedes verificar la versión del servidor:

```sql
SELECT version();
```

Consultar base actual:

```sql
SELECT current_database();
```

Consultar usuario actual:

```sql
SELECT current_user;
```

Salir de `psql`:

```sql
\q
```

---

## 13. Paso 7 — Asignar contraseña al usuario administrador `postgres`

Aunque para administración local puedes usar `sudo -u postgres psql`, conviene definir una contraseña para conexiones cliente desde herramientas externas como DBeaver.

Ingresa a `psql` como superusuario:

```bash
sudo -u postgres psql
```

Ejecuta:

```sql
ALTER USER postgres WITH PASSWORD 'postgres';
```

> **Advertencia técnica:**  
> Usar la contraseña `postgres` es aceptable solo en un **entorno académico local** y controlado.  
> En cualquier entorno compartido, expuesto a red o con información sensible, debes usar una contraseña robusta.

Verifica que el cambio se aplicó y sal:

```sql
\q
```

---

## 14. Paso 8 — Crear usuario y base de datos para laboratorios

No es buena práctica trabajar siempre con el superusuario `postgres`. Para laboratorios del proyecto, crea un usuario propio y una base inicial.

Ingresa otra vez:

```bash
sudo -u postgres psql
```

Ejemplo:

```sql
CREATE ROLE bigdata_user WITH LOGIN PASSWORD 'bigdata123';
CREATE DATABASE bigdata_lab OWNER bigdata_user;
```

Otorga permisos útiles sobre la base recién creada:

```sql
GRANT ALL PRIVILEGES ON DATABASE bigdata_lab TO bigdata_user;
```

Salir:

```sql
\q
```

### Verificar conexión con el nuevo usuario

Desde Ubuntu:

```bash
psql -h localhost -U bigdata_user -d bigdata_lab
```

Dentro de `psql`, verifica:

```sql
SELECT current_user, current_database();
```

Salir:

```sql
\q
```

---

## 15. Paso 9 — Probar conexión desde Windows con DBeaver

Una ventaja práctica de WSL2 es que, en el modo de red estándar, los servicios Linux suelen ser accesibles desde Windows mediante `localhost`.

### Parámetros sugeridos para DBeaver

- **Host:** `localhost`
- **Puerto:** `5432`
- **Base de datos:** `bigdata_lab` o `postgres`
- **Usuario:** `bigdata_user` o `postgres`
- **Contraseña:** la que hayas configurado

### Verificación rápida desde Linux

Antes de abrir DBeaver, confirma que PostgreSQL esté corriendo:

```bash
sudo systemctl status postgresql
```

Si está detenido:

```bash
sudo systemctl start postgresql
```

---

## 16. Paso 10 — Deshabilitar arranque automático en WSL (opcional pero recomendado)

En un laboratorio académico, PostgreSQL no necesita levantarse cada vez que arrancas Ubuntu. Si prefieres un entorno más liviano, deshabilita el inicio automático:

```bash
sudo systemctl disable postgresql
```

A partir de ese momento, deberás iniciarlo manualmente cuando lo necesites:

```bash
sudo systemctl start postgresql
```

Y detenerlo cuando termines:

```bash
sudo systemctl stop postgresql
```

### ¿Cuándo conviene esto?

- cuando quieres reducir consumo de memoria,
- cuando no usas PostgreSQL todo el tiempo,
- cuando quieres un control más explícito del estado del laboratorio.

### ¿Cuándo no conviene?

- si olvidas iniciar el servicio y luego “parece” que algo está roto;
- si necesitas que otros componentes del stack dependan de PostgreSQL al arrancar.

---

## 17. Comandos esenciales de administración rápida

### Estado y servicio

```bash
sudo systemctl status postgresql
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl enable postgresql
sudo systemctl disable postgresql
```

### Acceso y verificación

```bash
psql --version
pg_lsclusters
sudo -u postgres psql
sudo -u postgres psql -c "SELECT version();"
```

### Conexión a base específica

```bash
psql -h localhost -U bigdata_user -d bigdata_lab
```

### Listado dentro de `psql`

```sql
\l
\du
\dt
\conninfo
```

---

## 18. Estructura de rutas relevantes

Estas son algunas rutas importantes en una instalación típica con `postgresql-common` en Ubuntu:

```text
/etc/postgresql/15/main/           # Configuración del clúster
/var/lib/postgresql/15/main/       # Datos del clúster
/var/log/postgresql/               # Logs
/etc/postgresql/15/main/pg_hba.conf
/etc/postgresql/15/main/postgresql.conf
```

> **No edites archivos de configuración sin entender el impacto.**  
> En este punto del curso basta con conocer su ubicación. La edición de `postgresql.conf` y `pg_hba.conf` puede quedar para un tutorial posterior de administración y seguridad.

---

## 19. Problemas frecuentes y cómo resolverlos

### 19.1 `systemctl` no funciona en WSL

**Causa probable:** `systemd` no está habilitado.  
**Acción:** revisa la sección 7 y vuelve a configurar `/etc/wsl.conf`.

---

### 19.2 `psql: command not found`

**Causa probable:** el cliente no se instaló correctamente.  
**Acción:**

```bash
sudo apt install -y postgresql-client-15
psql --version
```

---

### 19.3 `connection to server on socket ... failed`

**Causa probable:** el servicio está detenido.  
**Acción:**

```bash
sudo systemctl start postgresql
sudo systemctl status postgresql
```

---

### 19.4 Error de autenticación al conectarte con usuario no `postgres`

**Causa probable:** contraseña incorrecta o usuario/base no creados.  
**Acción:** vuelve a crear o verificar el rol desde `sudo -u postgres psql`.

---

### 19.5 DBeaver no conecta desde Windows

**Checklist mínimo:**

- PostgreSQL está iniciado.
- Estás usando `localhost`.
- El puerto es `5432`.
- La contraseña es correcta.
- El usuario tiene permisos sobre la base.

---

## 20. Buenas prácticas para el curso

- Instala **versiones explícitas** y no paquetes genéricos cuando el laboratorio requiere reproducibilidad.
- Evita trabajar todo con el superusuario `postgres`.
- Usa nombres claros para bases y roles de laboratorio.
- Mantén PostgreSQL detenido cuando no lo necesites, si trabajas en WSL con recursos limitados.
- Documenta en tu repositorio los comandos usados y cualquier ajuste especial que hayas tenido que aplicar.
- No hardcodees credenciales reales en scripts versionados en GitHub.
- Usa DBeaver como cliente de consulta, pero aprende también a resolver tareas con `psql`.

---

## 21. Resultado esperado

Al finalizar correctamente este tutorial, debes tener:

- PostgreSQL 15 instalado en Ubuntu bajo WSL2.
- Cliente `psql` funcional.
- Servicio controlable mediante `systemctl`.
- Usuario `postgres` con contraseña definida.
- Base de datos de laboratorio creada.
- Conexión exitosa desde terminal y, opcionalmente, desde DBeaver en Windows.
- Entorno listo para continuar con:
  - modelado relacional,
  - scripts SQL,
  - funciones PL/pgSQL,
  - Pentaho Data Integration,
  - y orquestación posterior con Airflow.

---

## 22. Conclusión

Este tutorial deja resuelta una pieza fundamental del stack: **la base de datos operacional del proyecto**. Y eso no es un detalle menor. Sin una instalación correcta de PostgreSQL, los tutoriales posteriores de modelado, integración, consultas, automatización y calidad de datos quedan frágiles o directamente no funcionan.

La mejora más importante frente a versiones más generales del documento es esta:

- el tutorial queda **alineado con el stack real del curso**;
- evita mezclar innecesariamente instalación nativa en Windows con despliegue en Linux;
- se centra en una ruta reproducible;
- y deja explícitas las decisiones de administración que en un laboratorio sí importan: versión fija, `systemd`, clúster, usuario, base y política de arranque.

---

## 23. Referencias

1. PostgreSQL Global Development Group. [**Linux downloads (Ubuntu)**](https://www.postgresql.org/download/linux/ubuntu/).  
   Documentación oficial sobre instalación en Ubuntu y uso del repositorio PGDG.

2. PostgreSQL Wiki. [**APT Repository for Debian and Ubuntu**](https://wiki.postgresql.org/wiki/Apt).  
   Documentación oficial mantenida por la comunidad PostgreSQL sobre el repositorio `apt.postgresql.org`.

3. Microsoft Learn. [**Advanced settings configuration in WSL**](https://learn.microsoft.com/en-us/windows/wsl/wsl-config).  
   Documentación oficial sobre `wsl.conf` y habilitación de `systemd` en WSL.

4. Microsoft Learn. [**Accessing network applications with WSL**](https://learn.microsoft.com/en-us/windows/wsl/networking).  
   Referencia oficial sobre acceso desde Windows a servicios expuestos dentro de Linux/WSL mediante `localhost`.

5. PostgreSQL. [**Windows installers**](https://www.postgresql.org/download/windows/).  
   Referencia oficial del instalador EDB para Windows.  
