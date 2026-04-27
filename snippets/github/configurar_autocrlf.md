
# Configuración de core.autocrlf en Git:

```bash
# Ver tu configuración actual:
git config core.autocrlf
```

- `true` → convierte **LF** a **CRLF** al hacer *checkout* y **CRLF** a **LF** al hacer *commit*.

- `input` → convierte **CRLF** a **LF** solo al hacer *commit* (recomendado en entornos mixtos).

- `false` → no hace conversiones.

## Recomendación en proyectos multiplataforma (Linux/WSL + Windows):

Esto mantiene LF en el repositorio y evita que Git los convierta a CRLF en tu copia.

```bash
git config --global core.autocrlf input
```

Para forzar **LF** en todo el proyecto, añade un archivo `.gitattributes` en la raíz. Crear el archivo `.gitattributes` en la raíz del repositorio con el contenido anterior.

```text
# Forzar LF en todos los archivos de texto
* text=auto eol=lf

# Archivos Markdown y documentación siempre con LF
*.md text eol=lf
*.txt text eol=lf
*.rst text eol=lf

# Archivos Python siempre con LF
*.py text eol=lf

# Archivos de configuración
*.yml text eol=lf
*.yaml text eol=lf
*.json text eol=lf
*.toml text eol=lf
*.ini text eol=lf

# Archivos que deben mantenerse binarios (sin conversión de EOL)
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
*.zip binary
*.tar binary
*.gz binary
```

> **Por ejemplo:** Así Git siempre guardará los `.md` con **LF**.

## Normalizar los archivos ya existentes

```bash
git rm --cached -r .
git reset --hard
```

> **Beneficio:** Mantendrás LF en el repositorio, independientemente de si trabajas en Windows, WSL o Linux.