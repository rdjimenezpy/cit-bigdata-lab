<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: Administración básica del sistema en Ubuntu
**Comandos esenciales para directorios, archivos, espacio en disco, búsquedas y permisos**

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

Este documento resume de forma rápida los comandos, sintaxis, rutas, opciones y patrones de uso más frecuentes de **Ubuntu/Linux** para administración básica del sistema, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico en el entorno de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** Ubuntu / GNU Core Utilities / utilidades Linux básicas  
**Versión de referencia:** Ubuntu 22.04 LTS o superior  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio

---

## Requisitos previos

- Tener acceso a una terminal Bash en Ubuntu o WSL2.
- Conocer la diferencia básica entre archivo, directorio, ruta absoluta y ruta relativa.
- Contar con permisos suficientes para ejecutar operaciones administrativas cuando corresponda.

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
| Mostrar ubicación actual | `pwd` | Muestra la ruta del directorio actual. |
| Listar contenido | `ls -lah` | Lista archivos ocultos, permisos, propietarios y tamaños legibles. |
| Crear directorio | `mkdir -p ruta/directorio` | Crea uno o varios directorios si no existen. |
| Copiar archivo o carpeta | `cp -r origen destino` | Copia archivos o directorios de forma recursiva. |
| Mover o renombrar | `mv origen destino` | Mueve o cambia el nombre de un archivo o directorio. |
| Eliminar archivo o carpeta | `rm -rf ruta` | Elimina de forma recursiva; usar con extremo cuidado. |
| Ver tamaño de carpeta | `du -sh directorio/` | Muestra el tamaño total de un directorio. |
| Ver uso del disco | `df -h` | Muestra el uso del almacenamiento por partición. |
| Buscar archivos | `find . -name "*.txt"` | Busca archivos por nombre desde la ruta actual. |
| Buscar texto | `grep -R "texto" ruta/` | Busca coincidencias dentro de archivos. |
| Ver permisos | `ls -l` | Muestra permisos, propietario y grupo. |
| Cambiar permisos | `chmod 755 script.sh` | Ajusta permisos con modo numérico. |
| Cambiar propietario | `chown usuario:grupo archivo` | Cambia usuario y grupo propietario. |
| Ver usuario actual | `whoami` | Muestra el usuario en sesión. |

---

## Flujo rápido de uso

```bash
# 1) Ubicarse y revisar el contenido actual
pwd
ls -lah

# 2) Medir tamaño y uso de disco
du -sh .
df -h

# 3) Buscar archivos grandes o texto específico
find . -type f -name "*.log"
grep -R "ERROR" .

# 4) Revisar y ajustar permisos
ls -l
chmod +x script.sh
```

---

## Sintaxis frecuente

### 1. Directorios y archivos

```bash
pwd
ls
ls -l
ls -lah
cd /ruta/directorio
cd ..
mkdir nombre_directorio
mkdir -p ruta/a/crear
touch archivo.txt
cp archivo.txt respaldo/
cp -r directorio_origen/ directorio_destino/
mv archivo.txt nuevo_nombre.txt
mv archivo.txt destino/
rm archivo.txt
rm -r directorio/
rmdir directorio_vacio/
cat archivo.txt
less archivo.txt
head -n 20 archivo.txt
tail -n 20 archivo.txt
tail -f archivo.log
```

### 2. Tamaños, disco y búsqueda

```bash
du -sh directorio/
du -sh *
du -h --max-depth=1
du -ah | sort -rh | head -n 10
ls -lh
df -h
find . -name "*.txt"
find . -type f -size +100M
grep "texto" archivo.txt
grep -R "texto" .
ncdu .
```

### 3. Permisos, propietarios y usuarios

```bash
ls -l
chmod 644 archivo.txt
chmod 755 script.sh
chmod +x script.sh
chown usuario:grupo archivo.txt
chown -R usuario:grupo directorio/
chgrp grupo archivo.txt
id usuario
whoami
groups usuario
sudo adduser nuevo_usuario
sudo deluser usuario
sudo usermod -aG grupo usuario
```

---

## Ejemplos rápidos

### Ejemplo 1 — Crear y revisar una estructura de trabajo

```bash
mkdir -p ~/laboratorio/data/raw
cd ~/laboratorio
pwd
ls -lah
```

### Ejemplo 2 — Detectar carpetas que consumen más espacio

```bash
du -h --max-depth=1 ~/laboratorio | sort -rh
```

### Ejemplo 3 — Buscar archivos `.log` y monitorear uno en tiempo real

```bash
find ~/laboratorio -type f -name "*.log"
tail -f ~/laboratorio/logs/proceso.log
```

### Ejemplo 4 — Ajustar permisos de ejecución a un script

```bash
ls -l script_etl.sh
chmod +x script_etl.sh
ls -l script_etl.sh
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Directorio personal del usuario | `~` | Punto de partida habitual para trabajo académico y pruebas locales. |
| Configuración del shell | `~/.bashrc` | Define alias, variables y personalizaciones de sesión. |
| Directorio temporal | `/tmp/` | Se usa para archivos temporales; no debe asumirse persistencia. |
| Logs del sistema | `/var/log/` | Ubicación estándar de registros del sistema y servicios. |
| Configuraciones del sistema | `/etc/` | Contiene archivos de configuración global. |
| Directorio de trabajo recomendado | `/opt/repo/cit-bigdata-lab/` | Ruta sugerida para laboratorios y prácticas del repositorio base. |

---

## Errores frecuentes y solución rápida

| Problema | Comando o contexto relacionado | Solución rápida |
|---|---|---|
| `Permission denied` | `cat`, `cp`, `rm`, `chmod`, `chown` | Verificar permisos con `ls -l` y usar `sudo` solo si corresponde. |
| `No such file or directory` | `cd`, `cp`, `mv`, `rm` | Confirmar la ruta con `pwd` y listar contenido con `ls -lah`. |
| `Directory not empty` | `rmdir directorio/` | Usar `rm -r directorio/` solo si realmente quieres borrar su contenido. |
| `Operation not permitted` | `chown`, `chmod`, archivos protegidos | Ejecutar con privilegios adecuados o revisar propiedad del archivo. |
| Disco lleno | `df -h` muestra poco espacio libre | Inspeccionar consumo con `du -h --max-depth=1` y depurar archivos pesados. |
| `command not found: ncdu` | `ncdu .` | Instalar la herramienta con `sudo apt install ncdu`. |

---

## Buenas prácticas

- Ejecutar primero `pwd` y `ls -lah` antes de borrar, mover o cambiar permisos.
- Preferir `cp -r` y `mv` sobre operaciones destructivas hasta confirmar el resultado.
- Usar `rm -rf` solo cuando el alcance esté completamente validado.
- Revisar consumo de disco periódicamente con `du` y `df`, especialmente en laboratorios con datasets.
- Aplicar `chmod` y `chown` de manera precisa; cambiar permisos sin criterio es una mala práctica.
- Evitar trabajar como `root` para tareas ordinarias.

---

## Atajos o recordatorios clave

- **Nota rápida 1:** `ls -lah` es más útil que `ls` cuando necesitas contexto real de archivos, tamaños y permisos.
- **Nota rápida 2:** `du` mide tamaño de carpetas; `df` mide ocupación del sistema de archivos. No sirven para exactamente lo mismo.
- **Nota rápida 3:** `rmdir` elimina solo directorios vacíos; `rm -r` elimina contenido completo.
- **Nota rápida 4:** `chmod +x` habilita ejecución, pero no corrige un script mal escrito ni un shebang incorrecto.
- **Nota rápida 5:** antes de usar `sudo rm -rf`, revisa dos veces la ruta exacta.

---

## Referencias

1. Ubuntu. *Ubuntu Server Guide and Documentation*. https://ubuntu.com/server/docs
2. GNU Project. *Coreutils Manual*. https://www.gnu.org/software/coreutils/manual/
3. GNU Project. *Finding Files (Findutils)*. https://www.gnu.org/software/findutils/manual/html_node/find_html/

---

## Relación con otros documentos del repositorio

- Documento principal del repositorio: `README.md`
- Plantilla base de estandarización: `template/cheatsheet.md`
- Cheat Sheet asociado: `docs/cheatsheets/git_github_flujo_basico.md`

---

## Bloque ultra-rápido

```bash
# ubicación y contenido
pwd
ls -lah

# tamaños y disco
du -sh .
du -h --max-depth=1
df -h

# búsqueda
find . -type f -name "*.txt"
grep -R "texto" .

# permisos y propiedad
ls -l
chmod +x script.sh
chown usuario:grupo archivo.txt
```

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida para navegación de directorios, gestión de archivos, inspección de espacio en disco, búsqueda y administración básica de permisos en Ubuntu. No reemplaza un tutorial completo de Linux, pero sí cubre el conjunto mínimo útil para prácticas de laboratorio y soporte técnico inicial.
