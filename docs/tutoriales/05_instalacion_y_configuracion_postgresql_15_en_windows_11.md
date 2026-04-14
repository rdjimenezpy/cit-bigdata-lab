<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración de PostgreSQL 15 en Windows 11
**Sistema Operativo Windows 11 – Despliegue de PostgreSQL 15 para uso académico en laboratorios de Big Data e Ingeniería de Datos**

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

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia el curso básico de **Introducción a Big Data** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

Los pasos, comandos, rutas, capturas o salidas de consola presentados en este material fueron validados en un entorno de laboratorio controlado. No obstante, su reproducción en otros equipos puede requerir ajustes menores debido a diferencias en:

- sistema operativo y versión;
- configuración de red;
- permisos de usuario;
- políticas de seguridad institucional;
- versiones de software instaladas;
- y características específicas del hardware o del entorno local.

Por ello, ante diferencias puntuales durante la ejecución, se recomienda:

- leer cuidadosamente los mensajes del sistema;
- contrastar los pasos con la documentación oficial de la herramienta correspondiente;
- documentar cualquier ajuste realizado en el entorno local;
- y, si es necesario, solicitar apoyo a través de los canales oficiales de la asignatura.

Este enfoque forma parte del proceso formativo de la cátedra: en contextos reales de ingeniería de datos, la instalación, configuración y operación de herramientas rara vez ocurre en condiciones idénticas para todos los entornos.

---

## Tabla de contenido

1. [Introducción](#1-introducción)  
2. [Objetivos](#2-objetivos)  
3. [Alcance del tutorial](#3-alcance-del-tutorial)  
4. [Contexto técnico](#4-contexto-técnico)  
5. [Requisitos previos](#5-requisitos-previos)  
6. [Arquitectura o flujo de referencia](#6-arquitectura-o-flujo-de-referencia)  
7. [Convenciones usadas en el documento](#7-convenciones-usadas-en-el-documento)  
8. [Procedimiento paso a paso](#8-procedimiento-paso-a-paso)  
9. [Validación del resultado](#9-validación-del-resultado)  
10. [Problemas frecuentes y soluciones](#10-problemas-frecuentes-y-soluciones)  
11. [Buenas prácticas](#11-buenas-prácticas)  
12. [Conclusión](#12-conclusión)  
13. [Referencias](#13-referencias)  

---

## 1. Introducción

Este tutorial forma parte del material práctico del curso **Introducción a Big Data (nivel básico)** del **Centro de Innovación TIC (CIT)**. Su propósito es guiarte, paso a paso, en la **instalación y configuración de PostgreSQL 15** en dos entornos habituales de trabajo: **Windows 11** y **Ubuntu 22.04 LTS bajo WSL2**.

A lo largo del material aprenderás:

- Qué componentes se instalan en PostgreSQL (servidor, herramientas de cliente y utilitarios).
- Dos alternativas de instalación en **Windows 11**:  
  - **Instalador oficial (GUI)**: ideal para comprender el proceso y personalizar la instalación.  
  - **Winget (CLI)**: útil para automatizar instalaciones y replicar entornos de forma rápida.
- Instalación y validación de PostgreSQL 15 en **Ubuntu 22.04 (WSL2)** mediante APT.
- Gestión del servicio de PostgreSQL usando **systemd** (iniciar, detener, reiniciar, ver estado).
- Una práctica de administración importante para entornos de laboratorio: **evitar que PostgreSQL arranque automáticamente al iniciar WSL**, habilitando un modelo de arranque **manual bajo demanda** para reducir consumo de recursos.

Al finalizar, tendrás un PostgreSQL 15 funcional y comprenderás cómo administrarlo correctamente en escenarios reales de aprendizaje y desarrollo, estableciendo una base sólida para los laboratorios posteriores del curso (modelado, ingesta, consultas SQL y preparación de datos).

---

## 2. Objetivos

Instalar y configurar PostgreSQL 15 tanto en **Windows 11** como en **Ubuntu 22.04** bajo **WSL2**, cubriendo dos métodos de instalación en Windows (instalador gráfico y Winget) y la gestión del servicio en Ubuntu con `systemd`. Al final, obtendrás un servidor PostgreSQL 15 funcional en ambos entornos, con conocimientos para administrarlo adecuadamente.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** PostgreSQL 15  
**Versión objetivo:** PostgreSQL 15  
**Sistema operativo base:** Windows 11  
**Entorno de trabajo:** laboratorio local del estudiante sobre Windows 11  
**IDE / cliente sugerido:** PowerShell, CMD, `psql` y pgAdmin 4  
**Tipo de uso:** instalación, configuración y validación operativa básica  

### Este tutorial cubre

- la instalación de PostgreSQL 15 en Windows 11 mediante instalador gráfico oficial;
- la instalación de PostgreSQL 15 en Windows 11 mediante `winget`;
- la verificación básica del servicio y de la conectividad local con `psql` y pgAdmin 4.

### Este tutorial no cubre

- hardening avanzado del servidor PostgreSQL en Windows;
- tuning de rendimiento, replicación, alta disponibilidad o respaldos automatizados;
- administración profunda de archivos de configuración y operación en producción.

---

## 4. Contexto técnico

Dentro del stack del proyecto **BIGDATA-FPUNA**, PostgreSQL cumple el rol de **motor de base de datos relacional/OLTP** para prácticas de modelado, consultas SQL, administración de objetos de base de datos y preparación de información que luego podrá integrarse con otros componentes del laboratorio.

En este contexto, la instalación en Windows 11 resulta útil cuando el estudiante necesita:

- disponer de una instancia local rápida para prácticas introductorias;
- utilizar herramientas cliente como **pgAdmin 4** y **psql**;
- comparar este despliegue con la instalación en **Ubuntu/WSL2**;
- y comprender diferencias entre una instalación asistida por interfaz gráfica y una automatizada por CLI.

---

## 5. Requisitos previos

- **Windows 11** actualizado con acceso de administrador:
    - Windows **Package Manager (`winget`)** instalado (viene de fábrica en Windows 11).
    - Conexión a Internet para descargar los paquetes.
- **Subsistema de Windows para Linux (WSL2)** con **Ubuntu 22.04 LTS** instalado y funcionando. Si aún no lo tienes, puedes instalarlo abriendo PowerShell como administrador y ejecutando: `wsl --install -d Ubuntu-22.04`. (Reinicia tras la instalación de WSL y Ubuntu).
- **Permisos de superusuario (sudo)** en Ubuntu WSL para instalar paquetes.
- Conocimientos básicos de Terminal en Windows (*Command Prompt/Powershell*) y en Linux (*bash*).

> _Nota:_ Asegúrate de que WSL2 esté habilitado y funcionando correctamente en Windows (puedes verificar con `wsl -l -v`). También conviene actualizar el sistema Ubuntu antes de iniciar (`sudo apt update && sudo apt upgrade -y`). En Windows, mantén **UAC (User Account Control)** habilitado ya que el instalador y `winget` solicitarán permisos de administrador.

### Verificaciones rápidas

```powershell
winget --version
wsl -l -v
```

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 6. Arquitectura o flujo de referencia

El flujo lógico asociado a este tutorial puede resumirse así:

- **Windows 11** actúa como entorno anfitrión donde se instala PostgreSQL 15.
- El estudiante puede usar **instalador gráfico oficial** o **winget** según el nivel de personalización requerido.
- Una vez instalado, **PostgreSQL Server** queda ejecutándose como servicio de Windows.
- La validación inicial se realiza con **pgAdmin 4** o con **psql** desde terminal.
- Posteriormente, esta base puede integrarse con ejercicios del stack académico y compararse con despliegues equivalentes sobre **Ubuntu/WSL2**.

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `postgres` → usuario administrador por defecto de PostgreSQL.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `bash`, `powershell` → lenguajes o formatos utilizados en ejemplos.

---

## 8. Procedimiento paso a paso

### Paso 1 — Instalar PostgreSQL 15 mediante el instalador oficial (gráfico)

**Objetivo del paso:** realizar una instalación guiada de PostgreSQL 15 en Windows 11 con opciones configurables durante el asistente.

#### Método 1: Instalación con el instalador oficial (gráfico)

1. **Descargar el instalador:** Navega al sitio oficial de PostgreSQL y descarga el instalador para Windows. En la página de descarga de PostgreSQL, haz clic en *“Download the installer”* para la versión **15** (esto redirige al instalador proporcionado por EnterpriseDB). El archivo será algo como `postgresql-15.x-windows-x64.exe` de ~300MB. [Windows installers](https://www.postgresql.org/download/windows/#:~:text=Interactive%20installer%20by%20EDB)
2. **Ejecutar el instalador:** Localiza el archivo `.exe` descargado, haz doble clic y concede permisos de administrador si lo solicita. Aparecerá el asistente de configuración de PostgreSQL (*Setup Wizard*).
    - Pulsa **Next** en la pantalla de bienvenida.
    - **Directorio de instalación:** Elige la carpeta donde se instalará PostgreSQL (por defecto `C:\Program Files\PostgreSQL\15\`). Puedes dejar la ruta predeterminada. Pulsa Next.
    - **Componentes:** Selecciona los componentes a instalar. Por defecto se instalan:
        - **PostgreSQL Server** (servidor de base de datos)
        - **pgAdmin 4** (herramienta gráfica de administración)
        - **Stack Builder** (gestor de módulos adicionales)
        - **Command Line Tools** (herramientas de línea de comandos como `psql`)
        Es recomendable dejar la selección por defecto. Pulsa Next.
    - **Directorio de datos:** El instalador te preguntará dónde guardar los datos de la base de datos. Por defecto usará una ruta como `C:\Program Files\PostgreSQL\15\data`. Deja la opción predeterminada a menos que necesites ubicar los datos en otra unidad. Pulsa Next.
    - **Contraseña del superusuario:** Ingresa una contraseña para el usuario **postgres** (usuario administrador por defecto de PostgreSQL). Debes introducir la contraseña dos veces para confirmarla. _Es importante recordar esta contraseña_, pues la necesitarás para acceder al servidor posteriormente. (En entornos de desarrollo, usar la contraseña por defecto "postgres" es común, pero **no** lo hagas en entornos de producción por seguridad). Pulsa Next.
    - **Puerto de conexión:** Elige el puerto TCP/IP que usará PostgreSQL. El valor por defecto es **5432**, que suele ser adecuado en la mayoría de los casos. Si no tienes otro servicio usando ese puerto, déjalo en 5432. Pulsa Next.
    - **Configuración regional:** Selecciona la **locale** o configuración regional para la base de datos. Por defecto tomará la locale del sistema (ej. **“Default locale”**); esto afecta el ordenamiento (collation) y formato regional de datos. Puedes dejar la opción predeterminada. Pulsa Next.
3. **Iniciar la instalación:** Revisa el resumen de opciones elegidas y haz clic en **Install** para comenzar. El instalador copiará archivos y configurará el servicio de PostgreSQL. Espera a que finalice.
4. **Finalizar y primer arranque:** Al terminar, el instalador puede ofrecer lanzar **Stack Builder** (un asistente para descargar complementos adicionales). Puedes **omitir/cerrar Stack Builder** en este momento, no es necesario para la instalación básica. Al cerrar el instalador, PostgreSQL habrá quedado instalado _y el servicio iniciado automáticamente_ en Windows (se crea un servicio de Windows para PostgreSQL).
5. **Verificación:** PostgreSQL 15 ya está ejecutándose en tu PC. Para comprobarlo:
    - Abre la aplicación **pgAdmin 4** (instalada junto con PostgreSQL). Te pedirá establecer una contraseña maestra para pgAdmin al abrirla por primera vez (esta _no_ es la de postgres, sino una clave para cifrar tus credenciales guardadas en pgAdmin). Luego podrás conectar al servidor local usando el usuario `postgres` y la contraseña que definiste en el paso anterior.
    - Alternativamente, prueba la herramienta de línea de comandos **psql**. Abre una consola (CMD/PowerShell) y ejecuta:

```bash
"C:\Program Files\PostgreSQL\15\bin\psql" -U postgres
```

> Esto abrirá la consola `psql` y te pedirá la contraseña; ingresa la contraseña de `postgres` que configuraste. Si todo salió bien, entrarás al prompt de PostgreSQL (`postgres=#`). Escribe `\q` para salir.

- Si el comando anterior no funciona, asegúrate de incluir la ruta correcta a `psql.exe` o agrega dicha ruta al **Path** del sistema para poder ejecutar `psql` desde cualquier terminal. Para agregar **psql** al Path en Windows, ve a _Sistema > Configuración avanzada del sistema > Variables de entorno_, edita la variable `Path` y añade la ruta `C:\Program Files\PostgreSQL\15\bin\`. Abre una nueva terminal y ahora simplemente `psql -U postgres` debería funcionar.

**Resultado esperado:** PostgreSQL 15 queda instalado mediante el asistente oficial, con servicio activo en Windows y posibilidad de conexión mediante `pgAdmin 4` o `psql`.

---

### Paso 2 — Instalar PostgreSQL 15 con Winget (Windows Package Manager)

**Objetivo del paso:** desplegar PostgreSQL 15 de forma automatizada desde terminal usando el gestor de paquetes nativo de Windows.

#### Método 2: Instalación con Winget (Windows Package Manager)

**Winget** permite instalar software desde la línea de comandos rápidamente. En Windows 11, abre **PowerShell** o **Terminal** como _administrador_ (clic derecho > “Ejecutar como administrador”). Luego ejecuta el siguiente comando para instalar PostgreSQL 15:

```bash
winget install --id=PostgreSQL.PostgreSQL.15 -e
```

Este comando descargará e instalará PostgreSQL 15 automáticamente en modo silencioso (sin interfaz gráfica). **Winget** utilizará la configuración predeterminada del instalador oficial:

- **Ruta de instalación:** `C:\Program Files\PostgreSQL\15\` (por defecto).
- **Contraseña del usuario postgres:** será la predeterminada **postgres** (Winget no solicita interactivamente una contraseña, así que asigna la estándar “postgres”).
- **Componentes:** se instalan los mismos componentes por defecto (servidor, pgAdmin, Stack Builder, etc.).
- **Puerto:** 5432 (por defecto).

Durante el proceso, Winget mostrará el progreso de descarga del instalador oficial y su ejecución desatendida. Es posible que Windows pida confirmación UAC para permitir la instalación. Al finalizar, verás un mensaje de éxito (“Successfully installed”). **PostgreSQL 15 quedará instalado y el servicio iniciado automáticamente en Windows**, igual que con el método gráfico.

**Verificación:** Puedes verificar la instalación usando `psql` o pgAdmin como en el método anterior. Recuerda que en este caso la contraseña del superusuario `postgres` es **“postgres”** (cambio recomendado inmediatamente si planeas habilitar accesos remotos o entorno multiusuario). Para conectarte con `psql`, ejecuta en PowerShell:

```bash
psql -U postgres -h localhost
```

y cuando pida contraseña, ingresa `postgres`. También puedes abrir **pgAdmin 4** (busca en el menú inicio) e iniciar sesión con usuario `postgres` y contraseña `postgres`.

**Comparativa de métodos:** Ambos métodos instalan la misma versión de PostgreSQL, pero tienen diferencias:

- El **instalador gráfico** brinda mayor control y personalización: permite elegir la carpeta de instalación, setear una contraseña específica, cambiar puerto u omitir componentes antes de instalar. Es útil si necesitas configurar parámetros *custom* durante la instalación.
- La instalación por **Winget** es rápida y automatizada: ideal para **scripting** o despliegues repetibles. Se ejecuta con opciones por defecto en _modo desatendido_, usando ubicación estándar, puerto 5432 y contraseña _postgres_ sin preguntar. Requiere luego ajustar manualmente lo que quieras personalizar (por ejemplo, cambiar la contraseña por defecto por seguridad).
- En resumen: si prefieres facilidad y rapidez, Winget es conveniente; si necesitas ajustes finos durante la instalación, usa el instalador gráfico. _Ambos métodos son válidos y dejan PostgreSQL listo para usar_. Puedes consultar la documentación oficial de PostgreSQL sobre instalación en Windows para más detalles.

**Resultado esperado:** PostgreSQL 15 queda instalado de forma automatizada, con configuración predeterminada y posibilidad de validación inmediata desde consola o cliente gráfico.

---

## 9. Validación del resultado

Para considerar exitoso el procedimiento, deberían poder verificarse los siguientes puntos:

- PostgreSQL 15 aparece instalado en Windows 11.
- El servicio de PostgreSQL se encuentra iniciado automáticamente tras la instalación.
- `psql` permite conectarse localmente con el usuario `postgres`.
- **pgAdmin 4** detecta y administra la instancia local.
- El puerto `5432` queda disponible para conexiones locales, salvo que se haya configurado otro explícitamente.

Comandos de validación rápida:

```powershell
psql -U postgres -h localhost
```

```bash
"C:\Program Files\PostgreSQL\15\bin\psql" -U postgres
```

---

## 10. Problemas frecuentes y soluciones

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `psql` no se reconoce como comando | La ruta de binarios no fue agregada al `Path` | Ejecutar `psql` con ruta completa o agregar `C:\Program Files\PostgreSQL\15\bin\` al `Path` |
| No recuerda la contraseña del usuario `postgres` | La clave definida durante la instalación no fue documentada | Reinstalar o aplicar recuperación de acceso según corresponda |
| `winget` no está disponible | Windows Package Manager no está instalado o no está actualizado | Verificar `winget --version` y actualizar desde Microsoft Store si corresponde |
| El puerto 5432 está ocupado | Otro servicio usa el puerto predeterminado | Reinstalar o reconfigurar PostgreSQL con otro puerto disponible |
| pgAdmin abre pero no conecta | Credenciales incorrectas o servicio detenido | Verificar usuario, contraseña y estado del servicio |

---

## 11. Buenas prácticas

- Preferir el instalador gráfico cuando se requiera personalización durante el despliegue.
- Usar `winget` cuando se busque rapidez, repetibilidad y automatización básica.
- Cambiar la contraseña por defecto del usuario `postgres` si se utilizó la instalación por `winget`.
- Registrar la ruta instalada y el puerto configurado para facilitar prácticas posteriores.
- Mantener alineado este entorno con el resto de los tutoriales del repositorio para evitar inconsistencias entre Windows y WSL2.

---

## 12. Conclusión

A esta altura, has instalado **PostgreSQL 15** tanto en **Windows 11** como en **Ubuntu 22.04 (WSL)**. En Windows aprendiste dos métodos (_instalador gráfico_ y `winget`) y en Ubuntu instalaste vía _APT_ añadiendo el repositorio oficial. Además, configuraste el servicio PostgreSQL en WSL para administrarlo con `systemd` y opcionalmente evitar el inicio automático. Ya puedes usar PostgreSQL 15 en ambos entornos para tus prácticas de Big Data. En el tutorial siguiente, continuaremos con la instalación de una extensión útil para anonimizar datos.

---

## 13. Referencias

1. [Windows installers](https://www.postgresql.org/download/windows/#:~:text=Interactive%20installer%20by%20EDB)
2. [Installing PostgreSQL for development and testing on Microsoft Windows](https://www.enterprisedb.com/docs/dev-guides/deploy/windows/#:~:text=the%20initial%20configuration%20looks%20like,installs%20both%20StackBuilder%20and%20pgAdmin)
3. [The Complete Guide to Setting Up Postgresql on Windows 11 and WSL2](https://dev.to/kubona_my/the-complete-guide-to-setting-up-postgresql-on-windows-11-and-wsl2-4fam#:~:text=Set%20Port%20Number%3A%20default%20is,5432)
