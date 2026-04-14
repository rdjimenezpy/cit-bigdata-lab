<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Tutorial paso a paso: Git y GitHub — instalación, configuración y flujo básico de trabajo
**Entorno Windows 11 + WSL2 + Ubuntu 22.04.5 LTS · Versionado local y sincronización con GitHub para el laboratorio cit-bigdata-lab**

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

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia el curso básico de **Introducción a Big Data** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

Los pasos, comandos y recomendaciones aquí presentados fueron pensados para un flujo de trabajo técnico basado principalmente en **Windows 11 + WSL2 + Ubuntu 22.04.5 LTS**, utilizando Git desde la terminal Linux y sincronizando repositorios con GitHub.

No obstante, su reproducción en otros equipos puede requerir ajustes menores debido a diferencias en:

- sistema operativo y versión;
- configuración de red;
- permisos de usuario;
- políticas de seguridad institucional;
- versiones de software instaladas;
- y características específicas del hardware o del entorno local.

Por ello, ante diferencias puntuales durante la ejecución, se recomienda:

- leer cuidadosamente los mensajes del sistema;
- contrastar los pasos con la documentación oficial de Git y GitHub;
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

Git es el sistema de control de versiones distribuido más utilizado en entornos de desarrollo profesional, mientras que GitHub actúa como plataforma remota para alojar repositorios, colaborar, revisar cambios y publicar código. En el contexto del proyecto **BIGDATA-FPUNA**, Git y GitHub constituyen la base operativa para versionar scripts, documentación, configuraciones, plantillas y artefactos del laboratorio de datos.

Este tutorial tiene como propósito guiar al estudiante en la instalación de Git, su configuración inicial, la autenticación con GitHub y la ejecución de un flujo básico de trabajo con ramas, commits y sincronización remota. El objetivo no es cubrir todas las capacidades de Git, sino dejar una base correcta, reproducible y suficientemente limpia para trabajar con el repositorio del curso sin errores evitables.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- instalar Git y verificar su funcionamiento en el entorno local;
- realizar la configuración global mínima recomendada para trabajar profesionalmente con repositorios;
- autenticarse con GitHub mediante SSH;
- clonar un repositorio y ejecutar un flujo básico de trabajo con ramas, commits y push;
- identificar errores frecuentes de configuración y corregirlos sin improvisación.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Git + GitHub  
**Versión objetivo:** Git 2.x / GitHub Cloud  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Entorno de trabajo:** terminal Bash en Ubuntu/WSL2  
**IDE / cliente sugerido:** PyCharm / Visual Studio Code / terminal Bash  
**Tipo de uso:** instalación, configuración, autenticación y flujo básico de versionado  

### Este tutorial cubre

- instalación y verificación de Git;
- configuración global recomendada para un entorno académico-técnico;
- generación de clave SSH y conexión básica con GitHub;
- clonación de repositorio y flujo básico de trabajo con ramas;
- sincronización elemental entre entorno local y remoto.

### Este tutorial no cubre

- estrategias avanzadas de branching para equipos grandes;
- resolución avanzada de conflictos complejos o reescritura histórica profunda;
- integración continua, GitHub Actions, releases o automatización de despliegues.

---

## 4. Contexto técnico

Dentro del proyecto **BIGDATA-FPUNA**, Git y GitHub no son herramientas accesorias: son el mecanismo formal para versionar y controlar cambios sobre la base documental y técnica del laboratorio. Esto incluye archivos Markdown, scripts Bash y Python, definiciones SQL, configuraciones de entorno, plantillas de documentación y estructura del repositorio académico.

En un stack de trabajo que puede involucrar **WSL2**, **Python**, **PostgreSQL**, **DuckDB**, **Pentaho**, **Airflow**, **DBeaver** y documentación técnica en Markdown, el uso incorrecto de Git genera rápidamente problemas de trazabilidad, desorden de archivos, pérdida de cambios y errores de sincronización. Por eso conviene fijar desde el inicio un flujo simple pero correcto: trabajar desde una rama específica, revisar cambios antes de confirmar, escribir commits claros y sincronizar con GitHub de manera explícita.

---

## 5. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- una cuenta activa en GitHub;
- acceso a una terminal en Ubuntu/WSL2 o, de forma alternativa, PowerShell en Windows;
- conexión a Internet operativa;
- permisos suficientes para instalar software en el equipo local;
- un repositorio remoto existente o una URL de repositorio para clonar.

### Verificaciones rápidas

```bash
git --version
uname -a
pwd
```

Si Git aún no está instalado, el primer comando fallará o no devolverá una versión válida. En ese caso, continuar con el procedimiento de instalación.

---

## 6. Arquitectura o flujo de referencia

El flujo lógico básico asociado a este tutorial es el siguiente:

- el estudiante trabaja en un repositorio local dentro de Ubuntu/WSL2;
- Git registra cambios, historial, ramas y estados locales del proyecto;
- GitHub actúa como remoto central para respaldo, colaboración y publicación;
- los cambios locales se confirman mediante `commit` y luego se sincronizan con `push`.

Esquema conceptual simplificado:

- **Entorno local** → edición de archivos, revisión y commits
- **Git local** → historial, ramas, staging y control de cambios
- **GitHub remoto** → respaldo, colaboración y publicación del repositorio

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `SSH` → método recomendado de autenticación entre el entorno local y GitHub.

---

## 8. Procedimiento paso a paso

### Paso 1 — Instalar Git en el entorno local

**Objetivo del paso:** disponer de una instalación funcional de Git antes de iniciar cualquier configuración o conexión con GitHub.

**Instrucciones:**

#### Opción recomendada: Ubuntu / WSL2

```bash
sudo apt update
sudo apt install -y git
git --version
```

#### Opción alternativa: Windows con winget

```powershell
winget install --id Git.Git -e --source winget
git --version
```

**Explicación técnica:**  
El comando `apt install` instala Git desde los repositorios del sistema Ubuntu. En Windows, `winget` permite una instalación automatizada desde el catálogo oficial del sistema. Para el stack del laboratorio, la mejor práctica es usar Git desde **Ubuntu/WSL2**, no desde rutas pesadas en `/mnt/c/...`, especialmente cuando el proyecto involucra Python, entornos virtuales, Docker o volúmenes considerables de archivos.

**Resultado esperado:**  
El comando `git --version` devuelve la versión instalada de Git y confirma que la herramienta está disponible en la terminal.

---

### Paso 2 — Configurar la identidad global y parámetros mínimos recomendados

**Objetivo del paso:** dejar configurada la identidad del autor de los commits y fijar parámetros razonables para el flujo de trabajo diario.

**Instrucciones:**

```bash
git config --global user.name "TU_NOMBRE"
git config --global user.email "tu.correo@dominio.com"
git config --global init.defaultBranch main
git config --global core.editor "nano"
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global push.autoSetupRemote true
git config --global --list
```

**Explicación técnica:**  
Estos parámetros establecen la identidad del usuario, definen `main` como rama inicial por defecto y activan opciones que reducen errores comunes en flujos simples. `pull.rebase=true` ayuda a mantener un historial menos ruidoso; `fetch.prune=true` limpia referencias remotas obsoletas; `push.autoSetupRemote=true` simplifica el primer `push` de nuevas ramas.

**Resultado esperado:**  
La salida de `git config --global --list` muestra la configuración recién aplicada, incluyendo nombre, correo y opciones globales principales.

---

### Paso 3 — Ajustar el tratamiento de finales de línea

**Objetivo del paso:** evitar inconsistencias de fin de línea entre Windows y Linux, un problema muy frecuente en repositorios compartidos.

**Instrucciones:**

#### Si trabajas en Ubuntu / WSL2

```bash
git config --global core.autocrlf input
```

#### Si trabajas solo en Windows nativo

```bash
git config --global core.autocrlf true
```

**Explicación técnica:**  
Windows utiliza habitualmente finales de línea `CRLF`, mientras que Linux utiliza `LF`. En un flujo basado en WSL2, `core.autocrlf=input` es la configuración más razonable porque respeta el estilo Linux y evita transformaciones innecesarias en archivos fuente, scripts y documentación técnica.

**Resultado esperado:**  
Git queda configurado para manejar los finales de línea de forma coherente con el entorno de trabajo principal.

---

### Paso 4 — Configurar autenticación con GitHub mediante SSH

**Objetivo del paso:** habilitar una forma estable y profesional de autenticación entre el equipo local y GitHub.

**Instrucciones:**

```bash
ssh-keygen -t ed25519 -C "tu.correo@dominio.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

**Explicación técnica:**  
`ssh-keygen` crea un par de claves; la privada queda en el equipo local y la pública debe registrarse en GitHub. El agente SSH mantiene la clave disponible para futuras conexiones. El comando `ssh -T git@github.com` valida que la autenticación está operativa. Si GitHub reconoce la clave, la conexión devolverá un mensaje de autenticación exitosa.

**Resultado esperado:**  
La clave pública se visualiza correctamente con `cat ~/.ssh/id_ed25519.pub`, se registra en GitHub y la prueba SSH devuelve una confirmación satisfactoria.

---

### Paso 5 — Clonar el repositorio y revisar el remoto

**Objetivo del paso:** obtener una copia local del repositorio para comenzar a trabajar bajo control de versiones.

**Instrucciones:**

#### Clonado recomendado por SSH

```bash
git clone git@github.com:usuario/repositorio.git
cd repositorio
git remote -v
```

#### Alternativa por HTTPS

```bash
git clone https://github.com/usuario/repositorio.git
cd repositorio
git remote -v
```

**Explicación técnica:**  
`git clone` descarga todo el historial del repositorio remoto y crea una copia local enlazada al remoto `origin`. La revisión posterior con `git remote -v` confirma la URL remota asociada al repositorio. En el entorno del laboratorio conviene ubicar el repositorio dentro del sistema de archivos Linux, por ejemplo en `~/workspace/` o `~/projects/`.

**Resultado esperado:**  
El repositorio queda disponible localmente y `git remote -v` muestra el remoto `origin` configurado con la URL correspondiente.

---

### Paso 6 — Ejecutar el flujo básico de trabajo con ramas

**Objetivo del paso:** trabajar correctamente sin modificar directamente `main`, dejando un historial mínimo pero limpio.

**Instrucciones:**

```bash
git checkout main
git pull origin main
git checkout -b feature/nombre-cambio
git status
git diff
git add .
git commit -m "feat: describe el cambio realizado"
git push -u origin feature/nombre-cambio
```

**Explicación técnica:**  
Primero se actualiza `main` para partir de una base reciente. Luego se crea una rama de trabajo específica. `git status` y `git diff` sirven para inspeccionar el estado antes de confirmar cambios. `git add .` mueve archivos al staging area; `git commit` registra un punto de control local; `git push -u` publica la rama y la vincula con el remoto.

Ejemplos de nombres de rama razonables:

```text
feature/etl-ingesta-clientes
fix/correccion-transformacion-fechas
docs/actualiza-readme
refactor/reorganiza-estructura-dags
```

Ejemplos de mensajes de commit útiles:

```text
feat: agrega pipeline inicial de ingestión
fix: corrige parseo de fechas en transformación silver
docs: actualiza guía de instalación del laboratorio
refactor: separa utilidades comunes de ingestión
```

**Resultado esperado:**  
La rama queda creada, los cambios confirmados localmente y el remoto en GitHub recibe la nueva rama con el commit realizado.

---

### Paso 7 — Mantener la rama sincronizada con `main`

**Objetivo del paso:** reducir conflictos y evitar que la rama de trabajo quede desfasada respecto a la rama principal.

**Instrucciones:**

```bash
git fetch origin
git checkout feature/nombre-cambio
git rebase origin/main
```

Si aparecen conflictos:

```bash
git status
git add .
git rebase --continue
```

Si el rebase debe cancelarse:

```bash
git rebase --abort
```

**Explicación técnica:**  
`git fetch` trae referencias remotas actualizadas sin modificar directamente la rama actual. Luego `git rebase origin/main` reubica los commits locales sobre la versión más reciente de `main`. Este patrón suele producir un historial más limpio que el merge durante el trabajo diario, aunque exige atención cuando aparecen conflictos.

**Resultado esperado:**  
La rama de trabajo queda actualizada sobre la base más reciente de `main` y lista para continuar el desarrollo o abrir un Pull Request.

---

## 9. Validación del resultado

Al finalizar el procedimiento, conviene verificar los siguientes puntos:

- Git responde correctamente con `git --version`.
- La identidad global está configurada con `git config --global --list`.
- La autenticación SSH con GitHub funciona con `ssh -T git@github.com`.
- El repositorio fue clonado correctamente y tiene remoto `origin` válido.
- Existe una rama de trabajo creada para la tarea.
- Al menos un commit fue generado y publicado en GitHub.

Comandos útiles de validación:

```bash
git status
git branch -a
git log --oneline --graph --decorate --all
git remote -v
ssh -T git@github.com
```

Interpretación mínima esperada:

- `git status` no debe mostrar errores estructurales;
- `git branch -a` debe listar la rama local y la rama remota correspondiente;
- `git log --oneline --graph --decorate --all` debe mostrar una secuencia de commits coherente;
- `ssh -T git@github.com` debe confirmar autenticación exitosa.

---

## 10. Problemas frecuentes y soluciones

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `git: command not found` | Git no está instalado o no quedó disponible en el PATH. | Reinstalar Git y volver a ejecutar `git --version`. |
| `Permission denied (publickey)` | La clave SSH no está cargada o no fue registrada en GitHub. | Ejecutar `ssh-add ~/.ssh/id_ed25519` y verificar la clave pública registrada. |
| `fatal: not a git repository` | El comando se ejecutó fuera del directorio del repositorio. | Verificar ubicación con `pwd` y entrar al directorio correcto. |
| `rejected` al hacer `push` | El remoto tiene cambios que no existen localmente. | Ejecutar `git fetch origin` y luego sincronizar con `rebase` o `pull`. |
| Finales de línea inconsistentes | Configuración incorrecta de `core.autocrlf`. | En WSL2 usar `git config --global core.autocrlf input`. |
| Se subió un archivo sensible | `.gitignore` incompleto o uso descuidado de `git add .`. | Quitar el archivo del seguimiento con `git rm --cached archivo` y corregir `.gitignore`. |
| Se trabajó directamente en `main` | No se creó una rama antes de comenzar. | Crear una rama desde el estado actual o rehacer el flujo correctamente antes de seguir. |

---

## 11. Buenas prácticas

- Trabajar siempre desde **Ubuntu/WSL2** si el resto del stack del laboratorio también se ejecuta allí.
- Evitar desarrollar repositorios técnicos pesados dentro de `/mnt/c/...`.
- No hacer cambios directos en `main` salvo casos muy controlados.
- Revisar siempre `git status` y `git diff` antes de confirmar cambios.
- Escribir mensajes de commit claros, semánticos y técnicamente útiles.
- Mantener un `.gitignore` coherente con el proyecto para no subir secretos, logs, entornos virtuales ni cachés.
- Preferir autenticación por SSH frente a flujos improvisados por HTTPS con credenciales manuales.
- No usar `git push --force` sin entender exactamente el impacto.
- Antes de abrir un Pull Request, validar el historial con `git log --oneline --graph --decorate --all`.

---

## 12. Conclusión

Un flujo básico de Git bien configurado evita una gran cantidad de errores innecesarios en el trabajo diario del laboratorio. Instalar Git correctamente, fijar la identidad global, configurar SSH y trabajar mediante ramas no es un formalismo: es el mínimo operativo para mantener trazabilidad, control y orden técnico dentro del repositorio.

En el contexto de **BIGDATA-FPUNA**, este tutorial deja estable la base para que el estudiante pueda clonar, modificar, documentar y versionar el proyecto sin contaminar la rama principal ni perder visibilidad sobre sus cambios. Desde aquí ya es posible avanzar a prácticas de laboratorio más específicas, donde Git dejará de ser “una herramienta aparte” y pasará a ser parte natural del flujo técnico del proyecto.

---

## 13. Referencias

1. Git Project. *Git Documentation*. https://git-scm.com/doc  
2. GitHub. *GitHub Docs*. https://docs.github.com/  
3. Microsoft. *Windows Subsystem for Linux Documentation*. https://learn.microsoft.com/windows/wsl/  
4. Pro Git Book. *Pro Git*. https://git-scm.com/book/en/v2  

