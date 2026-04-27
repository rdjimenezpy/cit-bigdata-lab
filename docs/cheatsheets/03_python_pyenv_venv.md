<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: Python + pyenv + venv
**Gestión de versiones de Python y creación de entornos virtuales aislados para proyectos**

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

- **Fecha:** 23/03/2026
- **Versión:** 1.0

---

## Propósito

Este documento resume de forma rápida los comandos, sintaxis, rutas, opciones y patrones de uso más frecuentes de **Python + pyenv + venv**, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico en el entorno de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** Python 3.12.x + pyenv + venv  
**Versión de referencia:** Python 3.12.5 / pyenv 2.x  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- Tener acceso a terminal en Ubuntu/WSL2.
- Tener instaladas las dependencias del sistema requeridas para compilar Python con `pyenv`.
- Tener `git` y herramientas base del sistema operativas.
- Haber configurado correctamente `pyenv` en el shell del usuario.
- Contar con permisos de escritura sobre el directorio de trabajo del proyecto.

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
| Ver versión disponible en el sistema | `python3 --version` | Verifica la versión de Python activa en el entorno actual. |
| Verificar instalación de pyenv | `pyenv --version` | Confirma que `pyenv` está instalado y accesible en el shell. |
| Listar versiones instaladas por pyenv | `pyenv versions` | Muestra versiones disponibles localmente y la actualmente seleccionada. |
| Buscar versiones instalables | `pyenv install -l` | Lista versiones que `pyenv` puede instalar. |
| Instalar una versión de Python | `pyenv install 3.12.5` | Compila e instala una versión específica de Python. |
| Fijar versión global | `pyenv global 3.12.5` | Define la versión por defecto del usuario. |
| Fijar versión local por proyecto | `pyenv local 3.12.5` | Crea/actualiza `.python-version` en el directorio actual. |
| Ver ruta del Python resuelto | `pyenv which python` | Muestra el ejecutable real que resolverá el shim de `pyenv`. |
| Refrescar shims | `pyenv rehash` | Regenera los shims después de instalar paquetes con binarios. |
| Crear entorno virtual | `python -m venv .venv` | Crea un entorno virtual aislado para el proyecto. |
| Activar entorno virtual | `source .venv/bin/activate` | Activa el entorno virtual en shells POSIX. |
| Desactivar entorno virtual | `deactivate` | Sale del entorno virtual activo. |
| Actualizar pip en el entorno | `python -m pip install --upgrade pip` | Actualiza `pip` dentro del entorno activo. |

---

## Flujo rápido de uso

```bash
# 1) Verificar pyenv y versiones disponibles
pyenv --version
pyenv versions
pyenv install -l | less

# 2) Instalar y seleccionar una versión de Python
pyenv install 3.12.5
pyenv local 3.12.5

# 3) Crear y activar el entorno virtual del proyecto
python -m venv .venv
source .venv/bin/activate
python --version
pip --version
```

---

## Sintaxis frecuente

### 1. Verificación e inspección del entorno

```bash
python3 --version
which python3
pyenv --version
pyenv root
pyenv versions
pyenv version
pyenv which python
```

### 2. Gestión de versiones con pyenv

```bash
pyenv install -l
pyenv install 3.12.5
pyenv uninstall 3.12.5
pyenv global 3.12.5
pyenv local 3.12.5
pyenv shell 3.12.5
pyenv version
pyenv rehash
```

### 3. Creación y operación de entornos virtuales con venv

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip list
python -m pip freeze > requirements.txt
deactivate
rm -rf .venv
```

---

## Ejemplos rápidos

### Ejemplo 1 — Instalar Python 3.12.5 con pyenv

```bash
sudo apt update
sudo apt install -y build-essential curl git libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev \
  libncursesw5-dev xz-utils tk-dev uuid-dev

pyenv install 3.12.5
pyenv global 3.12.5
python --version
```

### Ejemplo 2 — Fijar versión local por proyecto

```bash
cd /opt/repo/cit-bigdata-lab
pyenv local 3.12.5
cat .python-version
python --version
```

### Ejemplo 3 — Crear entorno virtual del proyecto

```bash
cd /opt/repo/cit-bigdata-lab
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip freeze
```

### Ejemplo 4 — Recrear entorno virtual limpio

```bash
deactivate 2>/dev/null || true
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Directorio raíz de pyenv | `~/.pyenv/` | Contiene binarios, plugins, versiones y shims administrados por pyenv. |
| Versiones instaladas | `~/.pyenv/versions/` | Cada versión de Python instalada por pyenv queda bajo este árbol. |
| Shims de pyenv | `~/.pyenv/shims/` | Ejecutables intermedios usados por pyenv para resolver `python`, `pip`, etc. |
| Archivo de versión local | `.python-version` | Define la versión Python activa para un proyecto o directorio. |
| Entorno virtual del proyecto | `.venv/` | Directorio recomendado para el entorno virtual local del proyecto. |
| Configuración del shell | `~/.bashrc` | Archivo donde normalmente se integra la inicialización de pyenv. |
| Dependencias del proyecto | `requirements.txt` | Lista congelada de paquetes Python instalados en el entorno. |

---

## Errores frecuentes y solución rápida

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `pyenv: command not found` | `pyenv` no está instalado o no fue cargado en el shell. | Revisar instalación, `~/.bashrc` y reiniciar shell con `exec "$SHELL"`. |
| `python` apunta a otra versión | La selección global/local no está definida o el shell no cargó pyenv. | Verificar con `pyenv version`, luego usar `pyenv global ...` o `pyenv local ...`. |
| Error de compilación al instalar Python | Faltan librerías de compilación en Ubuntu. | Instalar dependencias del sistema y volver a ejecutar `pyenv install`. |
| `venv` se crea con otra versión distinta | No se fijó correctamente la versión Python del proyecto. | Ejecutar `pyenv local 3.12.5` y verificar `python --version` antes de crear `.venv`. |
| `pip` instala fuera del entorno | El entorno virtual no estaba activado o se usó otro ejecutable. | Activar `.venv` y preferir `python -m pip ...` en vez de `pip` aislado. |
| El entorno virtual se subió al repositorio | `.gitignore` incompleto o uso descuidado de `git add .`. | Agregar `.venv/` al `.gitignore` y quitar seguimiento con `git rm -r --cached .venv`. |
| Binarios no aparecen tras instalar paquetes | Shims desactualizados en pyenv. | Ejecutar `pyenv rehash`. |

---

## Buenas prácticas

- Usar **pyenv** para gestionar versiones de Python y **venv** para aislar dependencias por proyecto.
- Fijar la versión local del proyecto con `.python-version` antes de crear `.venv`.
- Nombrar el entorno virtual como `.venv/` dentro de la raíz del proyecto para mantener consistencia.
- Preferir `python -m pip` frente a `pip` directo para evitar ambigüedades de intérprete.
- No versionar `.venv/`, cachés ni artefactos temporales del entorno.
- Recrear entornos virtuales desde `requirements.txt` en vez de copiar carpetas `.venv` entre máquinas.
- Verificar siempre `python --version`, `which python` y `pyenv version` antes de instalar paquetes.

---

## Atajos o recordatorios clave

- **Nota rápida 1:** `pyenv global` afecta al usuario; `pyenv local` afecta al proyecto actual.
- **Nota rápida 2:** `venv` no reemplaza a `pyenv`; cumplen funciones distintas y complementarias.
- **Nota rápida 3:** si cambias la versión Python del proyecto, conviene recrear `.venv` desde cero.
- **Nota rápida 4:** `.python-version` sí puede versionarse; `.venv/` no debe versionarse.
- **Nota rápida 5:** en repositorios académicos o colaborativos, la combinación mínima correcta suele ser `pyenv + .python-version + .venv + requirements.txt`.

---

## Referencias

1. Python Software Foundation. *venv — Creation of virtual environments*. https://docs.python.org/3/library/venv.html  
2. pyenv. *pyenv GitHub Repository / Documentation*. https://github.com/pyenv/pyenv  
3. pyenv. *pyenv-installer*. https://github.com/pyenv/pyenv-installer  

---

## Relación con otros documentos del repositorio

- Tutorial relacionado: `docs/tutoriales/02_instalacion_python_3_12_5_pyenv.md`
- Documento complementario: `README.md`
- Cheat Sheet asociado: `docs/cheatsheets/wsl2_comandos_basicos.md`

---

## Bloque ultra-rápido

```bash
# verificar pyenv
pyenv --version
pyenv versions

# instalar y fijar Python
pyenv install 3.12.5
pyenv local 3.12.5
python --version

# crear y activar entorno virtual
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip

# salir y recrear si hace falta
deactivate
rm -rf .venv
```

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida para instalar, seleccionar y validar versiones de Python con `pyenv`, y para crear y administrar entornos virtuales con `venv` dentro de prácticas de laboratorio. No sustituye al tutorial completo, pero sí cubre el flujo mínimo correcto para trabajar de forma ordenada, reproducible y consistente en proyectos técnicos y académicos.
