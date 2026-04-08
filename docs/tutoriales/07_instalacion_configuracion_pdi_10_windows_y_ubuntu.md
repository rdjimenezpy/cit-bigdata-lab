<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración base de Pentaho Data Integration 10
**Instalación del cliente Kettle / Spoon en Windows y Linux Ubuntu para uso académico en laboratorios de Big Data e Ingeniería de Datos**

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

## Nota sobre esta documentación

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia de la asignatura **Electiva - Big Data** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

Los pasos, comandos, rutas, capturas o salidas de consola presentados en este material fueron validados a nivel metodológico para un entorno de laboratorio controlado. No obstante, su reproducción en otros equipos puede requerir ajustes menores debido a diferencias en:

- sistema operativo y versión;
- configuración de red;
- permisos de usuario;
- políticas de seguridad institucional;
- versión exacta del paquete instalador disponible;
- disponibilidad de Java y librerías gráficas en el entorno local;
- y características específicas del hardware o del entorno de escritorio.

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

Pentaho Data Integration (PDI), también conocido históricamente como **Kettle**, es la herramienta de integración y transformación de datos del stack Pentaho. Su cliente de escritorio principal, **Spoon**, permite diseñar transformaciones (`.ktr`) y jobs (`.kjb`) mediante una interfaz gráfica, además de ejecutar procesos de carga, limpieza, validación e integración hacia distintos destinos como PostgreSQL, DuckDB y archivos planos.

Dentro del proyecto **BIGDATA-FPUNA**, PDI se utiliza como componente de ingestión y procesamiento inicial de datos. Por ello, contar con una instalación funcional y homogénea en **Windows** y **Ubuntu** resulta clave para los laboratorios prácticos, las pruebas de concepto y el trabajo guiado en clase.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- identificar el rol de Pentaho Data Integration dentro del stack del laboratorio;
- instalar o desplegar el cliente de diseño **Spoon** a partir de un paquete local de Pentaho Data Integration 10;
- configurar una estructura base de trabajo para proyectos locales en Windows y Ubuntu;
- iniciar la herramienta correctamente y validar que el entorno quedó operativo para comenzar a construir transformaciones y jobs.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Pentaho Data Integration (PDI / Kettle / Spoon)  
**Versión objetivo:** 10.x  
**Sistema operativo base:** Windows 11 y Linux Ubuntu 22.04 LTS o superior  
**Entorno de trabajo:** repositorio local del proyecto BIGDATA-FPUNA  
**IDE / cliente sugerido:** terminal, explorador de archivos y Spoon  
**Tipo de uso:** instalación, configuración base, validación operativa y preparación del entorno de trabajo  

### Este tutorial cubre

- la preparación de directorios base de trabajo para Pentaho Data Integration;
- la instalación o despliegue del cliente Spoon a partir de un paquete ya descargado;
- la validación de arranque del cliente en Windows y Ubuntu;
- la configuración mínima inicial para comenzar a trabajar con proyectos locales.

### Este tutorial no cubre

- la instalación de Pentaho Server o Pentaho Business Analytics Server;
- la configuración avanzada de repositorios corporativos o licenciamiento empresarial;
- el desarrollo de transformaciones ETL completas;
- la instalación de plugins adicionales ni la configuración avanzada de ejecución distribuida.

---

## 4. Contexto técnico

Dentro del stack del proyecto **BIGDATA-FPUNA**, Pentaho Data Integration cumple el papel de herramienta de ingestión y transformación visual. Su ubicación natural dentro del flujo de laboratorio es la siguiente:

- **fuente de datos** → archivos CSV, Excel, TXT, APIs u otras bases;
- **Pentaho Data Integration** → limpieza, transformación, validación y carga;
- **PostgreSQL / DuckDB** → persistencia operativa y analítica;
- **Airflow / Python** → orquestación, automatización y extensiones;
- **Git / GitHub** → versionado de scripts, documentación y activos del laboratorio.

En términos prácticos, Pentaho sirve como puente entre la lógica de integración visual y la posterior automatización del pipeline. Por ello, aunque más adelante el flujo del curso incorpore Airflow y Python, la base operativa de varios laboratorios puede comenzar con Spoon.

---

## 5. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- un equipo con **Windows 11** o **Ubuntu 22.04 LTS** o superior;
- acceso local al paquete o archivo comprimido de **Pentaho Data Integration 10** proporcionado por el canal institucional, licencia correspondiente o distribución previamente descargada;
- permisos de lectura y escritura sobre la carpeta de instalación o sobre el directorio de trabajo;
- Java disponible en el sistema, si el paquete utilizado no lo incorpora de forma embebida;
- espacio libre suficiente en disco para descompresión, logs y proyectos locales;
- acceso a un entorno gráfico, ya que **Spoon** es una aplicación de escritorio.

### Verificaciones rápidas

#### Ubuntu

```bash
uname -a
java -version
pwd
ls -lah
```

#### Windows PowerShell

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
java -version
Get-Location
```

> **Nota:** si `java -version` no responde correctamente, debe resolverse primero la disponibilidad de Java antes de continuar con la validación final del cliente.

---

## 6. Arquitectura o flujo de referencia

El flujo lógico asociado a este tutorial es el siguiente:

- obtener el paquete local de Pentaho Data Integration 10;
- descomprimir o instalar el cliente según el formato disponible;
- ubicar la carpeta operativa de **data-integration**;
- iniciar el cliente mediante `Spoon.bat` en Windows o `spoon.sh` en Ubuntu;
- validar que el entorno abre correctamente y que el usuario puede crear un proyecto local de trabajo.

Ejemplo:

- paquete local de PDI 10
- carpeta operativa `data-integration`
- cliente gráfico Spoon
- proyecto local ETL / laboratorio
- conexión futura hacia PostgreSQL, DuckDB u otros destinos

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `Bash`, `PowerShell`, `INI` → lenguajes o formatos utilizados en ejemplos.

---

## 8. Procedimiento paso a paso

### Paso 1 — Preparar la ubicación de instalación y trabajo

**Objetivo del paso:** definir una ubicación clara y ordenada para Pentaho Data Integration y para los proyectos del laboratorio.

**Instrucciones:**

#### Windows (PowerShell)

```powershell
# Crear estructura sugerida para laboratorio
New-Item -ItemType Directory -Force -Path "C:\tools\pentaho" | Out-Null
New-Item -ItemType Directory -Force -Path "C:\workspace\bigdata-fpuna\etl\pentaho" | Out-Null
```

#### Ubuntu (Bash)

```bash
# Crear estructura sugerida para laboratorio
mkdir -p "$HOME/tools/pentaho"
mkdir -p "$HOME/workspace/bigdata-fpuna/etl/pentaho"
```

**Explicación técnica:**  
Separar la carpeta del software de la carpeta de proyectos evita mezclar binarios del cliente con archivos del laboratorio. Esta distinción simplifica mantenimiento, reinstalación, respaldo y versionado.

**Resultado esperado:**  
Existen directorios específicos para la herramienta y para el trabajo práctico del curso.

---

### Paso 2 — Copiar o descomprimir el paquete de Pentaho Data Integration 10

**Objetivo del paso:** dejar disponible en disco la carpeta operativa del cliente PDI.

**Instrucciones:**

#### Caso A — Si se dispone de un archivo `.zip`

##### Windows (PowerShell)

```powershell
# Ajustar el nombre del archivo según el paquete real disponible
Expand-Archive -Path "C:\ruta\al\archivo\pdi-ce-10.zip" -DestinationPath "C:\tools\pentaho" -Force
```

##### Ubuntu (Bash)

```bash
# Ajustar el nombre del archivo según el paquete real disponible
unzip ~/Descargas/pdi-ce-10.zip -d "$HOME/tools/pentaho"
```

#### Caso B — Si se dispone de un instalador o binario autoextraíble

- ejecutar el instalador desde una unidad local;
- seleccionar una ruta simple y sin caracteres problemáticos;
- completar el proceso según el asistente disponible;
- verificar al final la ubicación donde quedó la carpeta `data-integration`.

**Explicación técnica:**  
La documentación oficial de Pentaho para la serie 10.2 contempla métodos de instalación y despliegue diferentes según producto, sistema operativo y modalidad de distribución. En entornos académicos, lo más habitual para uso de Spoon es trabajar con una carpeta local ya descomprimida o instalada que contenga el cliente de diseño.  

**Resultado esperado:**  
Existe una carpeta operativa que contiene, entre otros archivos, los scripts `Spoon.bat`, `Kitchen`, `Pan` o `spoon.sh`, según el sistema operativo y el paquete utilizado.

---

### Paso 3 — Identificar la carpeta operativa `data-integration`

**Objetivo del paso:** localizar el directorio exacto desde el cual se inicia el cliente Spoon.

**Instrucciones:**

#### Windows (PowerShell)

```powershell
Get-ChildItem -Path "C:\tools\pentaho" -Recurse -Filter "Spoon.bat"
```

#### Ubuntu (Bash)

```bash
find "$HOME/tools/pentaho" -type f \( -name "spoon.sh" -o -name "Spoon.sh" \)
```

**Explicación técnica:**  
En la documentación oficial de PDI, el cliente se inicia desde la carpeta de instalación correspondiente al diseño de datos. En Windows, la referencia operativa habitual es `Spoon.bat`; en Linux, `spoon.sh`. Según el paquete, estos archivos pueden estar dentro de una ruta similar a `design-tools/data-integration/` o directamente dentro de `data-integration/`.

**Resultado esperado:**  
Se identifica la ruta exacta de inicio del cliente.

---

### Paso 4 — Preparar permisos y arranque en Ubuntu

**Objetivo del paso:** asegurar que el script de arranque en Linux puede ejecutarse correctamente.

**Instrucciones:**

```bash
cd "$HOME/tools/pentaho/{{carpeta_pdi}}/data-integration"
chmod +x spoon.sh
chmod +x kitchen.sh
chmod +x pan.sh
ls -lah spoon.sh
```

**Explicación técnica:**  
En Ubuntu, luego de descomprimir un paquete, los permisos ejecutables pueden no quedar correctamente aplicados. Sin ellos, el sistema no permitirá iniciar Spoon desde terminal.

**Resultado esperado:**  
Los scripts principales quedan marcados como ejecutables.

---

### Paso 5 — Iniciar el cliente Spoon en Windows

**Objetivo del paso:** validar el arranque del cliente gráfico en entorno Windows.

**Instrucciones:**

#### Desde Explorador de archivos

- navegar hasta la carpeta donde se encuentra `Spoon.bat`;
- hacer doble clic sobre el archivo.

#### Desde PowerShell

```powershell
Set-Location "C:\tools\pentaho\{{carpeta_pdi}}\data-integration"
.\Spoon.bat
```

**Explicación técnica:**  
La documentación oficial de Pentaho indica que el cliente PDI puede iniciarse en Windows mediante `Spoon.bat`. Este script prepara variables internas, opciones Java y el entorno requerido para abrir la interfaz gráfica.

**Resultado esperado:**  
Se abre la ventana del cliente Pentaho Data Integration / Spoon.

---

### Paso 6 — Iniciar el cliente Spoon en Ubuntu

**Objetivo del paso:** validar el arranque del cliente gráfico en Linux Ubuntu.

**Instrucciones:**

```bash
cd "$HOME/tools/pentaho/{{carpeta_pdi}}/data-integration"
./spoon.sh
```

**Explicación técnica:**  
La documentación oficial de Pentaho indica que en Linux el cliente se inicia mediante `spoon.sh`. Además, Pentaho documenta opciones de script y variables como `KETTLE_HOME`, `KETTLE_DIR` y `PENTAHO_DI_JAVA_OPTIONS`, útiles para personalizaciones posteriores. Si aparecen advertencias relacionadas con GTK o WebKit, deben evaluarse según el entorno antes de avanzar con configuraciones más profundas.

**Resultado esperado:**  
Se abre la interfaz gráfica de Spoon en Ubuntu.

---

### Paso 7 — Definir un `KETTLE_HOME` de trabajo para el laboratorio

**Objetivo del paso:** separar la configuración del usuario respecto de la carpeta binaria de Pentaho.

**Instrucciones:**

#### Windows (PowerShell, sesión actual)

```powershell
$env:KETTLE_HOME = "C:\workspace\bigdata-fpuna\etl\pentaho\kettle-home"
New-Item -ItemType Directory -Force -Path $env:KETTLE_HOME | Out-Null
$env:KETTLE_HOME
```

#### Ubuntu (Bash, sesión actual)

```bash
exported KETTLE_HOME="$HOME/workspace/bigdata-fpuna/etl/pentaho/kettle-home"
mkdir -p "$KETTLE_HOME"
echo "$KETTLE_HOME"
```

**Explicación técnica:**  
Pentaho documenta la variable `KETTLE_HOME` como el directorio donde se ubican configuraciones específicas del usuario. Definirla explícitamente mejora trazabilidad y evita dispersar archivos ocultos de configuración en ubicaciones menos controladas.

**Resultado esperado:**  
Existe una carpeta de configuración de usuario separada y reutilizable para el laboratorio.

---

### Paso 8 — Crear una carpeta base de proyectos ETL

**Objetivo del paso:** disponer de una estructura inicial para almacenar transformaciones, jobs y recursos del curso.

**Instrucciones:**

#### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path "C:\workspace\bigdata-fpuna\etl\pentaho\proyectos" | Out-Null
New-Item -ItemType Directory -Force -Path "C:\workspace\bigdata-fpuna\etl\pentaho\logs" | Out-Null
New-Item -ItemType Directory -Force -Path "C:\workspace\bigdata-fpuna\etl\pentaho\samples" | Out-Null
```

#### Ubuntu (Bash)

```bash
mkdir -p "$HOME/workspace/bigdata-fpuna/etl/pentaho/proyectos"
mkdir -p "$HOME/workspace/bigdata-fpuna/etl/pentaho/logs"
mkdir -p "$HOME/workspace/bigdata-fpuna/etl/pentaho/samples"
```

**Explicación técnica:**  
Separar proyectos, muestras y logs favorece un trabajo más ordenado desde el inicio. Además, esta estructura puede alinearse más adelante con el versionado del repositorio y con la ejecución de procesos por línea de comandos usando `Pan` o `Kitchen`.

**Resultado esperado:**  
Se cuenta con una estructura base ordenada para desarrollar ejercicios y laboratorios.

---

### Paso 9 — Realizar la validación funcional mínima

**Objetivo del paso:** comprobar que Pentaho quedó listo para uso básico.

**Instrucciones:**

Una vez abierto Spoon:

1. seleccionar la modalidad de trabajo local si aparece una ventana inicial de repositorio;
2. crear una transformación vacía;
3. guardar el archivo de prueba dentro de la carpeta `proyectos`;
4. cerrar y volver a abrir Spoon;
5. verificar que el archivo de prueba pueda reabrirse correctamente.

**Explicación técnica:**  
No basta con que la ventana abra. La validación mínima real consiste en comprobar que el usuario puede trabajar con archivos locales, guardar recursos y volver a abrirlos sin error.

**Resultado esperado:**  
El cliente funciona correctamente y permite comenzar a construir transformaciones y jobs locales.

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- la carpeta operativa de Pentaho quedó accesible en disco;
- `Spoon.bat` o `spoon.sh` inicia el cliente gráfico sin fallos críticos;
- el usuario puede guardar y abrir un archivo local de transformación o job;
- existe una carpeta de trabajo separada para proyectos y configuración de laboratorio.

### Comandos de validación

#### Ubuntu

```bash
find "$HOME/tools/pentaho" -type f \( -name "spoon.sh" -o -name "Spoon.sh" \)
echo "$KETTLE_HOME"
ls -lah "$HOME/workspace/bigdata-fpuna/etl/pentaho"
```

#### Windows PowerShell

```powershell
Get-ChildItem -Path "C:\tools\pentaho" -Recurse -Filter "Spoon.bat"
$env:KETTLE_HOME
Get-ChildItem "C:\workspace\bigdata-fpuna\etl\pentaho"
```

### Evidencia esperada

La evidencia mínima satisfactoria es una combinación de los siguientes elementos:

- localización correcta del script de arranque;
- apertura exitosa de Spoon;
- creación o guardado de un archivo `.ktr` o `.kjb` en la carpeta del laboratorio;
- ausencia de errores bloqueantes al iniciar la herramienta.

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `java: command not found` | Java no está instalado o no está en el `PATH`. | Instalar o corregir Java y volver a validar con `java -version`. |
| `Permission denied` al ejecutar `spoon.sh` | El script no tiene permiso de ejecución. | `chmod +x spoon.sh kitchen.sh pan.sh` |
| Spoon no abre en Ubuntu con advertencias GTK/WebKit | Faltan dependencias gráficas o el entorno no está completamente preparado. | Revisar librerías gráficas del sistema y relanzar desde terminal para inspeccionar el error real. |
| La ventana abre y se cierra inmediatamente | Ruta incorrecta, Java incompatible o archivos incompletos del paquete. | Verificar que el paquete se descomprimió completo y lanzar desde terminal para revisar mensajes. |
| No se encuentra `Spoon.bat` o `spoon.sh` | Se descomprimió un paquete distinto o en otra ruta. | Reubicar la carpeta correcta e identificar la ruta con `find` o `Get-ChildItem -Recurse`. |
| Se mezclan archivos del software con los del proyecto | Instalación y trabajo se hicieron en la misma carpeta. | Separar `tools/pentaho` de `workspace/bigdata-fpuna/etl/pentaho`. |
| No se guardan configuraciones donde corresponde | `KETTLE_HOME` no fue definido y se usa la ubicación por defecto. | Definir `KETTLE_HOME` explícitamente para el laboratorio. |

---

## 11. Buenas prácticas

- Mantener separadas la carpeta del software y la carpeta de trabajo del laboratorio.
- Evitar instalar Pentaho dentro del repositorio Git para no versionar binarios innecesarios.
- Definir `KETTLE_HOME` cuando se quiera controlar mejor la configuración y los artefactos de usuario.
- Ejecutar Spoon desde terminal ante cualquier problema para inspeccionar mensajes reales de error.
- No asumir que todos los paquetes de Pentaho 10 traen exactamente la misma estructura; validar siempre la ubicación real de `data-integration`.
- Usar rutas simples, sin caracteres problemáticos ni espacios innecesarios, especialmente en Windows.
- Documentar cualquier plugin o driver JDBC adicional incorporado al entorno.
- Mantener una copia limpia del paquete original para reinstalaciones rápidas.

---

## 12. Conclusión

Con este procedimiento queda preparado un entorno base de **Pentaho Data Integration 10** para uso académico tanto en **Windows** como en **Ubuntu**. El resultado esperado no es solo una instalación pasiva del software, sino un cliente **Spoon** funcional, con estructura de trabajo organizada y listo para integrarse con los siguientes componentes del stack, especialmente **PostgreSQL**, **DuckDB**, **Git** y, más adelante, **Airflow** y **Python** dentro de los laboratorios del proyecto BIGDATA-FPUNA.

Como siguiente paso recomendado, conviene documentar y estandarizar:

- la creación de un primer proyecto ETL local;
- la configuración de conexiones JDBC hacia PostgreSQL;
- la organización de transformaciones y jobs dentro del repositorio;
- y la ejecución de procesos por línea de comandos con `Pan` y `Kitchen`.

---

## 13. Referencias

1. Pentaho. **Install Pentaho Data Integration and Analytics 10.2**.  
2. Pentaho. **Pentaho Data Integration 10.2**.  
3. Pentaho. **Starting the PDI client**.  
4. Pentaho. **Startup script options**.  

---

## Anexo opcional A — Comandos rápidos

### Ubuntu

```bash
mkdir -p "$HOME/tools/pentaho"
mkdir -p "$HOME/workspace/bigdata-fpuna/etl/pentaho"
unzip ~/Descargas/pdi-ce-10.zip -d "$HOME/tools/pentaho"
find "$HOME/tools/pentaho" -type f \( -name "spoon.sh" -o -name "Spoon.sh" \)
cd "$HOME/tools/pentaho/{{carpeta_pdi}}/data-integration"
chmod +x spoon.sh kitchen.sh pan.sh
exported KETTLE_HOME="$HOME/workspace/bigdata-fpuna/etl/pentaho/kettle-home"
mkdir -p "$KETTLE_HOME"
./spoon.sh
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path "C:\tools\pentaho" | Out-Null
New-Item -ItemType Directory -Force -Path "C:\workspace\bigdata-fpuna\etl\pentaho" | Out-Null
Expand-Archive -Path "C:\ruta\al\archivo\pdi-ce-10.zip" -DestinationPath "C:\tools\pentaho" -Force
Get-ChildItem -Path "C:\tools\pentaho" -Recurse -Filter "Spoon.bat"
$env:KETTLE_HOME = "C:\workspace\bigdata-fpuna\etl\pentaho\kettle-home"
New-Item -ItemType Directory -Force -Path $env:KETTLE_HOME | Out-Null
Set-Location "C:\tools\pentaho\{{carpeta_pdi}}\data-integration"
.\Spoon.bat
```

---

## Anexo opcional B — Estructura de rutas relevantes

```text
bigdata-fpuna/
├── docs/
├── etl/
│   └── pentaho/
│       ├── kettle-home/
│       ├── logs/
│       ├── proyectos/
│       └── samples/
└── ...

# Instalación sugerida fuera del repositorio
Windows:
C:\tools\pentaho\{{carpeta_pdi}}\data-integration\Spoon.bat

Ubuntu:
$HOME/tools/pentaho/{{carpeta_pdi}}/data-integration/spoon.sh
```

---

## Anexo opcional C — Archivos de configuración usados

### Variables de entorno de sesión en Ubuntu

```bash
exported KETTLE_HOME="$HOME/workspace/bigdata-fpuna/etl/pentaho/kettle-home"
```

### Variables de entorno de sesión en PowerShell

```powershell
$env:KETTLE_HOME = "C:\workspace\bigdata-fpuna\etl\pentaho\kettle-home"
```
