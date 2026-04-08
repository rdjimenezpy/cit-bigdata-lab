# Procedimiento: subir el repositorio local `cit-bigdata-lab` a GitHub desde el entorno local.

## 1) Abrir la terminal en la carpeta del proyecto

Ubícate en la raíz del repositorio local.

En **WSL / Linux**:

```bash
export REPO_ROOT=/opt/repo/cit-bigdata-lab
mkdir -p ${REPO_ROOT}
cd ${REPO_ROOT}
```

---

## 2) Verificar que estás en la carpeta correcta

```bash
pwd
ls -la
```

Debes ver archivos como `README.md`, carpetas del proyecto, etc.

---

## 3) Revisar si el repositorio ya está inicializado con Git

```bash
git status
```

#### Si responde algo como:

```bash
fatal: not a git repository
```

Entonces inicialízalo:

```bash
git init
```

---

## 4) Configurar tu identidad de Git, si todavía no lo hiciste

```bash
git config --global user.name "Prof. Richard D. Jiménez-R."
git config --global user.email "rjimenez@pol.una.py"
```

Verifica:

```bash
git config --global --list
```

---

## 5) Crear o revisar el archivo `.gitignore`

Antes de subir nada, este paso es importante. No subas basura técnica ni archivos sensibles.

Para un repositorio académico/técnico como el tuyo, como base mínima podrías usar:

```gitignore
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
.venv/
venv/
env/
...
```

Si ya tienes uno, revísalo antes de continuar.

---

## 6) Revisar qué archivos se van a subir

```bash
git status
```

Esto es clave. Verifica que no aparezcan:

* credenciales
* `.env`
* datasets pesados innecesarios
* archivos binarios grandes
* entornos virtuales
* cachés
* logs

GitHub no acepta bien repositorios desordenados. Y menos uno que será base para el equipo.

---

## 7) Agregar todos los archivos al staging

```bash
git add .
```
Nota:
- `git reset` → deshace el git add pero conserva tus cambios.
- `git checkout` -- archivo → deshace los cambios en el archivo, volviendo al commit anterior.
- `git rm --cached` directamente los quita del control de Git (como si dijeras “no quiero que este archivo esté versionado”)

---

## 8) Crear el primer commit

```bash
git commit -m "Initial commit: base cit-bigdata-lab"
```

Si no hay cambios para commitear, Git te lo dirá. En ese caso revisa `git status`.

---

## 9) Crear el repositorio vacío en GitHub

En GitHub:

1. Inicia sesión.
2. Haz clic en **New repository**.
3. Nombre: `cit-bigdata-lab`
4. Descripción: opcional
5. Elige:

   * **Public** si quieres que el equipo lo clonen directamente.
   * **Private** si aún no está listo.
6. **No marques**:

   * Add a README
   * Add .gitignore
   * Add license

Eso evita conflictos innecesarios si tu repositorio local ya tiene contenido.

Crea el repositorio.

---

## 10) Conectar tu repositorio local con GitHub

GitHub te mostrará la URL del repo. Puede ser de dos tipos:

### Opción A: HTTPS

```bash
git remote add origin https://github.com/TU_USUARIO/cit-bigdata-lab.git
```

### Opción B: SSH

```bash
git remote add origin git@github.com:TU_USUARIO/cit-bigdata-lab.git
```

Verifica:

```bash
git remote -v
```

---

## 11) Renombrar la rama principal a `main`

```bash
git branch -M main
```

---

## 12) Subir el repositorio a GitHub

```bash
git push -u origin main
```

Con eso queda enlazado y las próximas veces bastará con:

```bash
git add .
git commit -m "mensaje"
git push
```

---

# Recomendación profesional: usar SSH en vez de HTTPS

HTTPS funciona, pero SSH es más limpio para trabajo frecuente.

## Paso extra: configurar SSH en GitHub

### 1) Generar clave SSH

```bash
ssh-keygen -t ed25519 -C "tu_correo"
```

Presiona Enter para aceptar la ruta por defecto.

---

### 2) Levantar el agente SSH

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

### 3) Copiar la clave pública

```bash
cat ~/.ssh/id_ed25519.pub
```

Copia todo el contenido.

---

### 4) Agregar la clave en GitHub

En GitHub:

* Settings
* SSH and GPG keys
* New SSH key
* Pega la clave

---

### 5) Probar conexión

```bash
ssh -T git@github.com
```

Si todo está bien, luego usa:

```bash
git remote add origin git@github.com:TU_USUARIO/cit-bigdata-lab.git
```

---

# Flujo completo resumido

```bash
cd ${REPO_ROOT}/cit-bigdata-lab
git init
git config --global user.name "Prof. Richard D. Jiménez-R."
git config --global user.email "rjimenez@pol.una.py"
git add .
git commit -m "Initial commit: base cit-bigdata-lab"
git branch -M main
git remote add origin git@github.com:TU_USUARIO/cit-bigdata-lab.git
git push -u origin main
```

---

# Problemas típicos y cómo resolverlos

## 1) Error: remote origin already exists

```bash
git remote remove origin
git remote add origin git@github.com:TU_USUARIO/cit-bigdata-lab.git
```

---

## 2) Error de autenticación con HTTPS

GitHub ya no acepta usuario/contraseña normal en muchos casos. Debes usar:

* token personal, o
* SSH

Mi recomendación: SSH.

---

## 3) Error porque el repo remoto ya tiene README u otro commit

Eso pasa si creaste el repo en GitHub con contenido inicial.

Solución correcta:

```bash
git pull origin main --allow-unrelated-histories
```

Luego resuelves conflictos si aparecen y después:

```bash
git push -u origin main
```

La solución mejor sigue siendo crear el repo remoto vacío desde el principio.

---

## 4) Archivo demasiado grande

GitHub tiene límites estrictos. Revisa el tamaño de archivos:

```bash
find . -type f -size +50M
```

Y si hay archivos muy pesados, no los subas al repo normal.

---

# Cierre recomendado antes de publicar

Antes del `push`, revisa esto:

* `README.md` claro y útil
* `.gitignore` correcto
* sin credenciales ni secretos
* sin datasets pesados innecesarios
* estructura comprensible para el equipo de trabajo
* rama principal `main`
* licencia, si vas a abrir el repositorio públicamente

> **Nota**: Como será un repositorio base para el equipo de trabajo, **publicarlo sin limpiar primero `.venv`, logs, cachés, zips y secretos sería un error serio**.
