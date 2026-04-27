<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# Tutorial paso a paso: Instalación y configuración de Python 3.12.5 con pyenv en Ubuntu sobre WSL2
**Entorno WSL2 – Ubuntu 22.04.5 LTS – Instalación de Python 3.12.5 mediante pyenv para uso académico en laboratorios de Big Data e Ingeniería de Datos**

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

- **Fecha:** 19/03/2026
- **Versión:** 1.0

---

## Nota sobre esta documentación

Este tutorial fue ajustado a partir de una versión preliminar utilizada en pruebas de concepto del entorno académico de laboratorio del curso. Los pasos están orientados a una instalación de **Python 3.12.5** sobre **Ubuntu 22.04.5 LTS ejecutándose en WSL2**, dentro de un entorno Windows moderno y con enfoque de trabajo reproducible para ingeniería de datos.

Aunque el procedimiento es estable y apropiado para laboratorios académicos, no todos los equipos responden exactamente igual. Diferencias en versión de WSL, librerías del sistema, políticas de red, permisos o dependencias de compilación pueden requerir ajustes menores. Si aparece un error, no conviene improvisar correcciones: primero hay que identificar la causa técnica y contrastarla con la documentación oficial.

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
14. [Anexo A — Comandos básicos de gestión](#anexo-a--comandos-básicos-de-gestión)  
15. [Anexo B — Recomendación para trabajar con PyCharm](#anexo-b--recomendación-para-trabajar-con-pycharm)  

---

## 1. Introducción

En esta asignatura, **Python** será una de las herramientas base del stack tecnológico. Se utilizará para automatización, pruebas, scripts auxiliares, validación de datos, integración con APIs, desarrollo de utilitarios de apoyo para ETL/ELT y trabajo con librerías analíticas.

La instalación se realizará con **pyenv**, no reemplazando el Python del sistema. Esta decisión es importante porque Ubuntu depende de su Python nativo para varios componentes internos. Romper ese Python por intentar “actualizarlo a mano” es un error clásico y completamente evitable.

El objetivo no es simplemente “tener Python instalado”, sino dejar una base técnica limpia, versionable y reproducible para laboratorios, pruebas de concepto y desarrollo del proyecto del curso.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante podrá:

- Instalar **Python 3.12.5** en Ubuntu sobre WSL2 sin alterar el Python del sistema.
- Instalar y configurar **pyenv** para gestionar versiones de Python.
- Seleccionar una versión global o local de Python según el proyecto.
- Crear y activar entornos virtuales con `venv`.
- Verificar la instalación y aplicar buenas prácticas básicas de mantenimiento.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Python 3.12.5 gestionado con `pyenv`  
**Versión objetivo:** Python 3.12.5  
**Sistema operativo base:** Ubuntu 22.04.5 LTS sobre WSL2  
**Entorno de trabajo:** `/opt/repo/cit-bigdata-lab`  
**IDE / cliente sugerido:** terminal Bash y PyCharm  
**Tipo de uso:** instalación, configuración y validación inicial de entorno Python  

### Este tutorial cubre

- la instalación de Python 3.12.5 usando `pyenv` sin alterar el Python del sistema;
- la configuración básica de `pyenv` y el uso de versiones globales y locales;
- la creación y activación de un entorno virtual base para el repositorio del laboratorio.

### Este tutorial no cubre

- la instalación de librerías específicas del proyecto más allá de las herramientas base del entorno;
- la administración avanzada de múltiples entornos con complementos externos de `pyenv`;
- la configuración detallada de herramientas del stack como PostgreSQL, DuckDB, Pentaho o Airflow.

---

## 4. Contexto técnico

Dentro del stack técnico del repositorio **cit-bigdata-lab**, Python cumple el rol de lenguaje base para automatización, scripting, validación, integración y soporte operativo de distintos componentes del laboratorio. Su instalación correcta condiciona el uso posterior de utilitarios, pruebas, scripts auxiliares, clientes CLI y herramientas complementarias del flujo de ingeniería de datos.

En este contexto, `pyenv` se utiliza para desacoplar el Python del proyecto respecto del Python nativo de Ubuntu. Esa separación evita errores frecuentes en entornos WSL2 y permite una base más limpia, controlable y reproducible para el trabajo académico y técnico.

---

## 5. Requisitos previos

Antes de comenzar, asegúrate de cumplir lo siguiente:

- WSL2 instalado y operativo.
- Ubuntu configurado correctamente.
- Conectividad a Internet desde Ubuntu.
- Usuario con permisos `sudo`.
- Terminal Bash funcional.

### Verificaciones rápidas

```bash
lsb_release -a
uname -r
whoami
python3 --version
```

---

## 6. Arquitectura o flujo de referencia

El flujo lógico de este tutorial puede resumirse de la siguiente manera:

- preparar Ubuntu y validar prerequisitos del entorno;
- instalar dependencias de compilación necesarias para `pyenv`;
- instalar y configurar `pyenv` en la shell del usuario;
- compilar e instalar Python 3.12.5;
- definir la versión global o local según el proyecto;
- crear un entorno virtual base para el repositorio de trabajo;
- validar el intérprete activo y dejar listo el entorno para tutoriales posteriores.

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `bash`, `text` → lenguajes o formatos utilizados en ejemplos.

---

## 8. Procedimiento paso a paso

### Paso 1 — Verificar el entorno base

**Objetivo del paso:** confirmar que el entorno Ubuntu sobre WSL2 está operativo antes de instalar o compilar nuevas versiones de Python.

**Instrucciones:**

```bash
lsb_release -a
uname -r
whoami
python3 --version
```

**Explicación técnica:**  
Estas verificaciones permiten confirmar distribución, kernel, usuario activo y versión actual del Python del sistema antes de intervenir el entorno.

**Resultado esperado:**  
El sistema debe responder correctamente a los comandos y mostrar un entorno Ubuntu funcional sobre WSL2.

---

### Paso 2 — Considerar la recomendación técnica previa

Ubuntu 22.04 ya incluye un **Python del sistema**. Ese intérprete no debe reemplazarse ni eliminarse.

#### No hagas esto

- no cambies enlaces simbólicos del sistema para forzar `python3` a otra versión;
- no sobrescribas binarios del sistema;
- no instales paquetes globales con `sudo pip install`;
- no mezcles indiscriminadamente Python del sistema con Python de proyecto.

#### Sí conviene hacer esto

- instalar Python 3.12.5 mediante `pyenv`;
- usar `pyenv` para definir la versión activa;
- usar `venv` para aislar dependencias por proyecto.

---

### Paso 3 — Actualizar Ubuntu

**Objetivo del paso:** dejar el sistema base actualizado antes de instalar dependencias de compilación.

**Instrucciones:**

```bash
sudo apt update
sudo apt upgrade -y
```

**Explicación técnica:**  
Esto sincroniza los índices de paquetes y aplica actualizaciones del sistema necesarias para reducir problemas posteriores de compilación o dependencias.

**Resultado esperado:**  
Ubuntu debe quedar actualizado sin errores críticos en `apt`.

---

### Paso 4 — Instalar dependencias de compilación

`pyenv` instala la mayoría de las versiones de Python compilando desde código fuente. Por eso, antes de instalar Python 3.12.5, conviene preparar el entorno con librerías y herramientas de compilación.

**Instrucciones:**

```bash
sudo apt install -y \
  build-essential \
  curl \
  git \
  wget \
  make \
  ca-certificates \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libffi-dev \
  liblzma-dev \
  libncurses5-dev \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  llvm \
  libxml2-dev \
  libxmlsec1-dev
```

Verificación rápida:

```bash
git --version
curl --version
```

**Explicación técnica:**  
Estas librerías y herramientas son necesarias para compilar Python correctamente y habilitar módulos frecuentes como SSL, SQLite, readline, compresión y soporte criptográfico.

**Resultado esperado:**  
Las dependencias deben instalarse sin errores y `git` y `curl` deben responder correctamente.

---

### Paso 5 — Instalar pyenv

Instala `pyenv` con el método recomendado por su documentación oficial:

```bash
curl -fsSL https://pyenv.run | bash
```

**Explicación técnica:**  
Este script instala `pyenv` en el home del usuario, sin reemplazar el Python del sistema ni introducir cambios globales agresivos.

**Resultado esperado:**  
Debe crearse el directorio `~/.pyenv` con la estructura base de la herramienta.

---

### Paso 6 — Configurar pyenv en Bash

En Ubuntu y otras distribuciones basadas en Debian, conviene agregar la configuración tanto en `~/.bashrc` como en `~/.profile` para evitar problemas de precedencia en `PATH`.

#### 6.1 Agregar configuración a `~/.bashrc`

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
```

#### 6.2 Agregar configuración a `~/.profile`

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init - bash)"' >> ~/.profile
```

#### 6.3 Recargar la shell

```bash
exec "$SHELL"
```

**Explicación técnica:**  
Estas líneas agregan `pyenv` al `PATH` y habilitan su inicialización automática al abrir nuevas sesiones de terminal.

**Resultado esperado:**  
La shell debe recargarse y reconocer `pyenv` como comando disponible.

---

### Paso 7 — Verificar pyenv

```bash
pyenv --version
pyenv root
```

Si el comando no responde, la configuración del shell quedó mal o no se recargó correctamente.

**Explicación técnica:**  
Esta validación confirma que la herramienta fue instalada y que la shell está resolviendo correctamente su binario.

**Resultado esperado:**  
Debe mostrarse la versión de `pyenv` y la ruta raíz de instalación bajo el home del usuario.

---

### Paso 8 — Instalar Python 3.12.5

Listar versiones disponibles de la rama 3.12:

```bash
pyenv install --list | grep 3.12
```

Instalar la versión requerida:

```bash
pyenv install 3.12.5
```

> La compilación puede tardar varios minutos. No es un error si tarda; compilar Python lleva tiempo.

**Explicación técnica:**  
`pyenv` compila la versión seleccionada desde código fuente y la deja disponible para ser activada luego de la instalación.

**Resultado esperado:**  
Python 3.12.5 debe quedar disponible dentro del árbol de versiones gestionado por `pyenv`.

---

### Paso 9 — Definir Python 3.12.5 como versión global del usuario

```bash
pyenv global 3.12.5
pyenv rehash
```

**Explicación técnica:**  
Esto establece Python 3.12.5 como intérprete activo por defecto para el usuario y actualiza los shims administrados por `pyenv`.

**Resultado esperado:**  
La versión activa del usuario debe pasar a ser 3.12.5.

---

### Paso 10 — Verificar la versión activa

```bash
python --version
python3 --version
which python
which python3
pyenv version
pyenv versions
```

Salida esperada aproximada:

- `Python 3.12.5`
- ruta bajo `~/.pyenv/shims/`
- versión activa `3.12.5`

**Explicación técnica:**  
Estas comprobaciones permiten confirmar que los comandos `python` y `python3` resuelven contra la versión administrada por `pyenv`.

**Resultado esperado:**  
Debe observarse Python 3.12.5 como versión efectiva y rutas vinculadas a `~/.pyenv/shims/`.

---

### Paso 11 — Usar versiones globales y locales por proyecto

#### 11.1 Versión global

La versión global aplica por defecto a tu usuario en todas las terminales, salvo que un proyecto defina otra versión.

```bash
pyenv global 3.12.5
```

#### 11.2 Versión local por proyecto

Dentro de un directorio de proyecto, puedes fijar la versión con un archivo `.python-version`.

Ejemplo:

```bash
mkdir -p /opt/repo/cit-bigdata-lab
cd /opt/repo/cit-bigdata-lab
pyenv local 3.12.5
```

Verifica:

```bash
cat .python-version
pyenv version
```

Esto es particularmente útil si gestionarás el repositorio desde **PyCharm**, porque cada proyecto puede declarar explícitamente qué versión debe usar.

---

### Paso 12 — Crear y usar un entorno virtual

Una vez que Python 3.12.5 esté activo mediante `pyenv`, crea un entorno virtual para el proyecto.

#### Paso 1. Ir al directorio del proyecto

```bash
cd /opt/repo/cit-bigdata-lab
```

#### Paso 2. Crear el entorno virtual

```bash
python -m venv .venv
```

#### Paso 3. Activarlo

```bash
source .venv/bin/activate
```

Cuando el entorno está activo, el prompt suele mostrar el nombre del entorno al inicio.

#### Paso 4. Verificar la ruta del intérprete activo

```bash
which python
python --version
pip --version
```

La ruta debe apuntar a algo similar a:

```text
/opt/repo/cit-bigdata-lab/.venv/bin/python
```

#### Paso 5. Actualizar herramientas base del entorno

```bash
python -m pip install --upgrade pip setuptools wheel
```

#### Paso 6. Salir del entorno

```bash
deactivate
```

---

## 9. Validación del resultado

Ejecuta la siguiente secuencia:

```bash
pyenv --version
pyenv versions
pyenv version
python --version
pip --version
python -c "import sys; print(sys.executable)"
```

Si todo quedó correcto, deberías confirmar al menos lo siguiente:

- `pyenv` responde correctamente;
- Python activo: `3.12.5`;
- la ruta del intérprete apunta a `~/.pyenv/shims/python` o al `.venv` del proyecto, según corresponda.

### Evidencia esperada

La evidencia mínima de éxito consiste en observar una versión activa `3.12.5`, una instalación funcional de `pyenv`, y un intérprete resuelto correctamente hacia `~/.pyenv/shims/` o hacia el `.venv` del proyecto cuando el entorno virtual está activado.

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `pyenv: command not found` | La configuración del shell no fue agregada correctamente o no se recargó la sesión. | `tail -n 20 ~/.bashrc && tail -n 20 ~/.profile && exec "$SHELL"` |
| La compilación de Python falla | Faltan dependencias de compilación requeridas por `pyenv`. | `sudo apt update && sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev tk-dev xz-utils && pyenv install 3.12.5` |
| `python --version` no muestra 3.12.5 | La versión global no quedó aplicada o los shims no se actualizaron. | `pyenv version && pyenv which python && pyenv global 3.12.5 && pyenv rehash && exec "$SHELL"` |
| `pip` instala paquetes fuera del entorno esperado | Se está usando el intérprete equivocado o el entorno virtual no está activo. | `which python && which pip && python -m pip --version` |
| Un paquete falla porque espera `setuptools` | Python 3.12 ya no incluye `setuptools` por defecto en `venv`. | `python -m pip install setuptools` |

### Desarrollo detallado de los problemas del documento original

#### Problema A. `pyenv: command not found`

Verifica si las líneas fueron agregadas correctamente:

```bash
tail -n 20 ~/.bashrc
tail -n 20 ~/.profile
```

Recarga la shell:

```bash
exec "$SHELL"
```

Verifica que `~/.pyenv` exista:

```bash
ls -la ~/.pyenv
```

#### Problema B. La compilación de Python falla

Reinstala dependencias y vuelve a intentar:

```bash
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libffi-dev liblzma-dev tk-dev xz-utils
pyenv install 3.12.5
```

#### Problema C. `python --version` no muestra 3.12.5

```bash
pyenv version
pyenv which python
pyenv global 3.12.5
pyenv rehash
exec "$SHELL"
```

#### Problema D. `pip` instala paquetes fuera del entorno esperado

Antes de instalar cualquier paquete, verifica:

```bash
which python
which pip
python -m pip --version
```

Si las rutas no apuntan al entorno virtual o a `~/.pyenv/shims`, estás trabajando con el intérprete equivocado.

#### Problema E. Un paquete falla porque espera `setuptools`

Desde Python 3.12, `venv` ya no incluye `setuptools` por defecto. Si un paquete lo requiere explícitamente, instálalo manualmente dentro del entorno:

```bash
python -m pip install setuptools
```

---

## 11. Buenas prácticas

- Trabaja dentro del filesystem Linux, no en `/mnt/c/...`, especialmente para proyectos técnicos con muchas dependencias.
- Usa una versión de Python gestionada por `pyenv`, no el Python del sistema para tus proyectos.
- Usa un entorno virtual por proyecto.
- No uses `sudo pip install` dentro de tus proyectos.
- Mantén `pip` actualizado dentro del entorno virtual.
- Registra dependencias del proyecto cuando corresponda, por ejemplo con `requirements.txt` o `pyproject.toml`.
- Verifica siempre la ruta del intérprete activo con `which python` antes de instalar paquetes.

---

## 12. Conclusión

Con esta instalación ya queda preparada la base de Python del entorno de trabajo para el curso. Este componente será utilizado en tutoriales posteriores para instalación de herramientas, automatización, pruebas, desarrollo de scripts auxiliares y soporte al pipeline de datos del proyecto.

El siguiente paso lógico, una vez validado Python, es continuar con la instalación y configuración de herramientas del stack como Git, PostgreSQL, DuckDB, Pentaho Data Integration o Apache Airflow, según la secuencia de despliegue definida para el repositorio.

---

## 13. Referencias

1. Python Software Foundation. [*Python 3.12 Documentation*](https://docs.python.org/3.12/).
2. Python Software Foundation. [*venv — Creation of virtual environments*](https://docs.python.org/3.12/library/venv.html).
3. Python Software Foundation. [*What’s New In Python 3.12*](https://docs.python.org/3/whatsnew/3.12.html).
4. pyenv. [*pyenv official repository and documentation*](https://github.com/pyenv/pyenv).
5. Microsoft. [*Windows Subsystem for Linux documentation*](https://learn.microsoft.com/windows/wsl/).

---

## Anexo A — Comandos básicos de gestión

### A.1 Comandos de Python

```bash
python --version
python -c "import sys; print(sys.version)"
python -c "import sys; print(sys.executable)"
```

### A.2 Comandos de pip

```bash
pip --version
pip list
pip freeze
pip install <paquete>
pip uninstall <paquete>
```

### A.3 Comandos de pyenv

```bash
pyenv --version
pyenv versions
pyenv version
pyenv which python
pyenv global 3.12.5
pyenv local 3.12.5
pyenv shell 3.12.5
pyenv rehash
pyenv uninstall 3.12.5
```

---

## Anexo B — Recomendación para trabajar con PyCharm

Si vas a usar **PyCharm** para gestionar este repositorio, la práctica correcta es:

- abrir el proyecto desde la ruta Linux del repositorio;
- configurar como intérprete del proyecto el Python ubicado en `.venv/bin/python`;
- evitar usar intérpretes del sistema o de Windows para proyectos que viven dentro de WSL.

### Ruta recomendada del proyecto

```text
/opt/repo/cit-bigdata-lab
```

### Ruta recomendada del intérprete del proyecto

```text
/opt/repo/cit-bigdata-lab/.venv/bin/python
```
