<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: Git y GitHub — flujo básico de trabajo
**Instalación, configuración inicial, versionado y sincronización básica de repositorios**

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

Este documento resume de forma rápida los comandos, sintaxis, archivos, configuraciones y patrones de uso más frecuentes de **Git y GitHub**, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico dentro del repositorio base de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** Git + GitHub  
**Versión de referencia:** Git 2.x / GitHub Cloud  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- Tener **Git** instalado y operativo en el entorno local.
- Tener una cuenta activa en **GitHub**.
- Contar con acceso a terminal en **Ubuntu/WSL2** o PowerShell.
- Disponer de un repositorio local clonado o de un proyecto a inicializar.
- Tener definida una estrategia mínima de `.gitignore` para evitar subir archivos temporales, secretos o artefactos locales.

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
| Verificar instalación | `git --version` | Muestra la versión instalada de Git. |
| Configurar nombre global | `git config --global user.name "TU_NOMBRE"` | Define el nombre del autor de los commits. |
| Configurar correo global | `git config --global user.email "tu.correo@dominio.com"` | Define el correo asociado a los commits. |
| Inicializar rama principal por defecto | `git config --global init.defaultBranch main` | Establece `main` como rama inicial. |
| Clonar repositorio | `git clone git@github.com:usuario/repositorio.git` | Descarga el repositorio remoto al entorno local. |
| Ver estado actual | `git status` | Muestra archivos modificados, staged y no rastreados. |
| Crear rama de trabajo | `git checkout -b feature/nombre-cambio` | Crea y cambia a una rama nueva. |
| Preparar cambios | `git add .` | Envía los cambios al staging area. |
| Confirmar cambios | `git commit -m "feat: descripción del cambio"` | Registra un punto de control con mensaje semántico. |
| Subir rama al remoto | `git push -u origin feature/nombre-cambio` | Publica la rama en GitHub. |
| Actualizar `main` | `git pull origin main` | Trae cambios remotos y sincroniza la rama principal. |
| Rebase sobre `main` | `git rebase origin/main` | Reubica commits locales sobre la última base remota. |

---

## Flujo rápido de uso

```bash
# 1) Clonar el repositorio
git clone git@github.com:usuario/repositorio.git
cd repositorio

# 2) Actualizar rama principal
git checkout main
git pull origin main

# 3) Crear rama de trabajo
git checkout -b feature/nueva-tarea

# 4) Revisar cambios
git status
git diff

# 5) Agregar y confirmar
git add .
git commit -m "feat: implementa nueva tarea"

# 6) Subir la rama al remoto
git push -u origin feature/nueva-tarea
````

---

## Sintaxis frecuente

### 1. Configuración inicial global

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

### 2. Autenticación recomendada con GitHub vía SSH

```bash
ssh-keygen -t ed25519 -C "tu.correo@dominio.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

### 3. Operaciones frecuentes de versionado

```bash
git status
git branch
git branch -a
git log --oneline --graph --decorate --all
git diff
git diff --cached
git restore archivo.py
git restore --staged archivo.py
git commit --amend -m "feat: mensaje corregido"
```

### 4. Sincronización y actualización de ramas

```bash
git fetch origin
git checkout main
git pull origin main

git checkout feature/nombre-cambio
git rebase origin/main
git rebase --continue
git rebase --abort
```

---

## Ejemplos rápidos

### Ejemplo 1 — Instalación en Ubuntu / WSL2

```bash
sudo apt update
sudo apt install -y git
git --version
```

### Ejemplo 2 — Configuración mínima para empezar a trabajar

```bash
git config --global user.name "Richard Jiménez"
git config --global user.email "rjimenez@dominio.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global fetch.prune true
git config --global core.autocrlf input
```

### Ejemplo 3 — Flujo diario básico de trabajo

```bash
git checkout main
git pull origin main
git checkout -b feature/ajuste-readme

# trabajar...
git status
git add .
git commit -m "docs: ajusta redacción final del README"
git push -u origin feature/ajuste-readme
```

### Ejemplo 4 — Publicar un repositorio nuevo desde cero

```bash
mkdir mi-proyecto
cd mi-proyecto
git init
git branch -M main
touch README.md
git add README.md
git commit -m "chore: inicializa repositorio"
git remote add origin git@github.com:usuario/repositorio.git
git push -u origin main
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento                            | Ruta / Nombre           | Observación                                                     |
| ----------------------------------- | ----------------------- | --------------------------------------------------------------- |
| Configuración global de Git         | `~/.gitconfig`          | Archivo donde Git almacena la configuración global del usuario. |
| Clave privada SSH                   | `~/.ssh/id_ed25519`     | No debe compartirse ni versionarse.                             |
| Clave pública SSH                   | `~/.ssh/id_ed25519.pub` | Se registra en GitHub para autenticación por SSH.               |
| Archivo de exclusiones              | `.gitignore`            | Define archivos y carpetas que no deben subirse al repositorio. |
| Documento principal del repositorio | `README.md`             | Describe propósito, estructura y forma de uso del proyecto.     |
| Carpeta del repositorio local       | `repositorio/`          | Directorio raíz del proyecto clonado o inicializado.            |

---

## Errores frecuentes y solución rápida

| Problema                              | Causa probable                                                | Solución rápida                                                                        |
| ------------------------------------- | ------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `Permission denied (publickey)`       | La clave SSH no fue cargada o no está registrada en GitHub.   | Ejecutar `ssh-add ~/.ssh/id_ed25519` y verificar con `ssh -T git@github.com`.          |
| `fatal: not a git repository`         | El comando se ejecutó fuera del directorio raíz del proyecto. | Verificar ubicación con `pwd` y entrar al repositorio correcto.                        |
| `rejected` al hacer `push`            | La rama remota tiene cambios que no existen localmente.       | Ejecutar `git fetch origin` y luego `git rebase origin/main` o `git pull origin main`. |
| Se subió un `.env` o archivo sensible | `.gitignore` incompleto o uso descuidado de `git add .`.      | Quitar del seguimiento con `git rm --cached .env` y reforzar `.gitignore`.             |
| Se trabajó directamente en `main`     | No se creó una rama antes de modificar.                       | Volver a `main`, actualizarla y crear una rama `feature/...` para el cambio.           |
| Conflictos durante `rebase`           | Dos ramas modificaron las mismas líneas.                      | Resolver archivos, usar `git add .` y continuar con `git rebase --continue`.           |
| Finales de línea inconsistentes       | Configuración incorrecta de `core.autocrlf`.                  | En WSL2 usar `git config --global core.autocrlf input`.                                |

---

## Buenas prácticas

* Trabajar siempre en ramas de trabajo y evitar cambios directos sobre `main`.
* Usar mensajes de commit semánticos y técnicamente claros.
* Mantener `.gitignore` actualizado para evitar subir secretos, cachés, logs y artefactos temporales.
* Revisar `git status` y `git diff` antes de cada commit.
* Preferir autenticación por **SSH** para un flujo más estable y profesional.
* Ejecutar `git fetch` y `git pull` antes de empezar una nueva tarea.
* Usar `git push --force-with-lease` solo cuando el flujo de rebase lo requiera, nunca `--force` a ciegas.
* Mantener el `README.md` alineado con la estructura real del repositorio.

---

## Atajos o recordatorios clave

* **Nota rápida 1:** si trabajas con WSL2, usa Git dentro de Ubuntu/WSL y evita desarrollar repositorios pesados en `/mnt/c/...`.
* **Nota rápida 2:** `git add .` no es incorrecto, pero sí peligroso si no revisas antes `git status`.
* **Nota rápida 3:** `main` debe representar una base estable; el trabajo real debe ocurrir en ramas `feature/`, `fix/`, `docs/` o `refactor/`.
* **Nota rápida 4:** antes de abrir un Pull Request, valida cambios con `git log --oneline --graph --decorate --all` y revisa el diff final.
* **Nota rápida 5:** si el remoto cambió y tu `push` falla, no improvises; primero inspecciona el estado y sincroniza correctamente.

---

## Referencias

1. Git Project. *Git Documentation*. [https://git-scm.com/doc](https://git-scm.com/doc)
2. GitHub. *GitHub Docs*. [https://docs.github.com/](https://docs.github.com/)
3. Microsoft. *Windows Subsystem for Linux Documentation*. [https://learn.microsoft.com/windows/wsl/](https://learn.microsoft.com/windows/wsl/)

---

## Relación con otros documentos del repositorio

* Documento principal del repositorio: `README.md`
* Plantilla base de estandarización: `template/cheatsheet.md`
* Archivo actual: `docs/cheatsheets/git_github_flujo_basico.md`

---

## Bloque ultra-rápido

```bash
# instalar git
sudo apt update && sudo apt install -y git

# configurar identidad
git config --global user.name "TU_NOMBRE"
git config --global user.email "tu.correo@dominio.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global fetch.prune true
git config --global core.autocrlf input

# clonar y trabajar
git clone git@github.com:usuario/repositorio.git
cd repositorio
git checkout main
git pull origin main
git checkout -b feature/nueva-tarea
git add .
git commit -m "feat: describe el cambio"
git push -u origin feature/nueva-tarea
```

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida. No sustituye una guía completa de Git, pero sí cubre el flujo mínimo correcto para instalar, configurar, versionar, sincronizar y publicar cambios en un entorno académico y técnico con buenas prácticas básicas.
