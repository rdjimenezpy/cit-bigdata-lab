<p align="center">
	<img src="../../assets/logos/cit-one.png" alt="Logo corporativo CIT-UNA">
</p>

# 📎 Cheat Sheet: WSL2 — comandos básicos
**Instalación, administración inicial y operaciones frecuentes en Windows Subsystem for Linux**

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

Este documento resume de forma rápida los comandos, sintaxis, rutas, opciones y patrones de uso más frecuentes de **WSL2 (Windows Subsystem for Linux)**, con fines de apoyo práctico para laboratorios, ejercicios, pruebas de concepto y desarrollo técnico en el entorno de la asignatura.

---

## Alcance

**Herramienta / Tecnología:** Windows Subsystem for Linux 2 (WSL2)  
**Versión de referencia:** WSL para Windows 11 / Windows 10 compatible  
**Entorno de referencia:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Nivel de uso:** básico / intermedio  

---

## Requisitos previos

- Tener Windows 11 o una versión compatible de Windows 10 con soporte para WSL2.
- Ejecutar PowerShell o CMD con privilegios administrativos para tareas de instalación o configuración inicial.
- Contar con virtualización habilitada y soporte del entorno para ejecutar WSL2.
- Tener conexión a Internet para instalar, actualizar o descargar distribuciones.

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
| Instalar WSL | `wsl --install` | Instala WSL y la distribución predeterminada de Linux. |
| Ver estado | `wsl --status` | Muestra el estado general de WSL y la configuración predeterminada. |
| Ver versión | `wsl --version` | Muestra la versión de WSL y sus componentes. |
| Listar distribuciones instaladas | `wsl -l -v` | Lista distribuciones, estado de ejecución y versión WSL usada. |
| Listar distribuciones disponibles | `wsl -l -o` | Muestra distribuciones disponibles para instalar. |
| Instalar una distribución específica | `wsl --install -d Ubuntu-22.04` | Instala una distribución concreta. |
| Establecer versión por defecto | `wsl --set-default-version 2` | Define WSL2 como versión predeterminada para nuevas instalaciones. |
| Cambiar versión de una distro | `wsl --set-version Ubuntu-22.04 2` | Convierte una distribución a WSL2. |
| Establecer distro predeterminada | `wsl --set-default Ubuntu-22.04` | Define la distribución predeterminada. |
| Abrir WSL | `wsl` | Inicia la distribución predeterminada. |
| Abrir una distro específica | `wsl -d Ubuntu-22.04` | Inicia la distribución indicada. |
| Detener WSL completo | `wsl --shutdown` | Apaga todas las distribuciones y la VM de WSL. |
| Terminar una distro | `wsl --terminate Ubuntu-22.04` | Detiene solo la distribución indicada. |
| Actualizar WSL | `wsl --update` | Actualiza WSL a la versión más reciente disponible. |
| Exportar distro | `wsl --export Ubuntu-22.04 backup.tar` | Exporta la distribución a un archivo tar. |
| Importar distro | `wsl --import UbuntuLab D:\WSL\UbuntuLab backup.tar --version 2` | Importa una distribución desde backup. |
| Desregistrar distro | `wsl --unregister UbuntuLab` | Elimina una distribución registrada en WSL. |

---

## Flujo rápido de uso

```bash
# 1) Verificar estado general
wsl --status
wsl --version

# 2) Listar distribuciones
wsl -l -v
wsl -l -o

# 3) Instalar o iniciar Ubuntu
wsl --install -d Ubuntu-22.04
wsl -d Ubuntu-22.04

# 4) Apagar completamente WSL cuando sea necesario
wsl --shutdown
```

---

## Sintaxis frecuente

### 1. Instalación y preparación inicial

```bash
wsl --install
wsl --install -d Ubuntu-22.04
wsl --set-default-version 2
wsl --status
wsl --version
```

### 2. Gestión de distribuciones

```bash
wsl -l -v
wsl -l -o
wsl --set-default Ubuntu-22.04
wsl --set-version Ubuntu-22.04 2
wsl -d Ubuntu-22.04
wsl --distribution Ubuntu-22.04 --user root
```

### 3. Operación, parada y mantenimiento

```bash
wsl --shutdown
wsl --terminate Ubuntu-22.04
wsl --update
wsl --help
```

### 4. Respaldo y migración básica

```bash
wsl --exported Ubuntu-22.04 ubuntu2204_backup.tar
wsl --import UbuntuLab D:\WSL\UbuntuLab ubuntu2204_backup.tar --version 2
wsl --unregister UbuntuLab
```

---

## Ejemplos rápidos

### Ejemplo 1 — Verificar el entorno WSL instalado

```bash
wsl --status
wsl --version
wsl -l -v
```

### Ejemplo 2 — Instalar Ubuntu 22.04 y usar WSL2

```bash
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
wsl -d Ubuntu-22.04
```

### Ejemplo 3 — Reiniciar completamente WSL cuando algo queda colgado

```bash
wsl --shutdown
wsl
```

### Ejemplo 4 — Ingresar a Ubuntu como usuario root desde PowerShell

```bash
wsl --distribution Ubuntu-22.04 --user root
```

### Ejemplo 5 — Respaldar una distribución antes de hacer cambios mayores

```bash
wsl --exported Ubuntu-22.04 D:\Backups\ubuntu2204_lab.tar
```

---

## Rutas, archivos o ubicaciones relevantes

| Elemento | Ruta / Nombre | Observación |
|---|---|---|
| Comando de acceso desde Windows | `wsl.exe` | Ejecutable accesible desde PowerShell o CMD. |
| Sistema de archivos Linux desde Windows | `\\wsl$\` | Permite acceder a archivos de las distribuciones desde el Explorador. |
| Perfil del usuario Linux | `/home/{{usuario}}/` | Ubicación recomendada para proyectos Linux dentro de WSL. |
| Configuración global de WSL | `%UserProfile%\.wslconfig` | Archivo opcional para parámetros globales de WSL2. |
| Configuración local de una distro | `/etc/wsl.conf` | Archivo interno de la distribución para ajustes locales. |
| Disco virtual de una distro | `ext4.vhdx` | Archivo base de almacenamiento de la distribución WSL2. |

---

## Errores frecuentes y solución rápida

| Problema | Causa probable | Solución rápida |
|---|---|---|
| `WSL is not installed` | WSL no está instalado o no se completó la configuración. | Ejecutar `wsl --install` en PowerShell como administrador y reiniciar si corresponde. |
| La distribución figura en versión 1 | No se cambió a WSL2 o faltan requisitos del entorno. | Ejecutar `wsl --set-version {{distro}} 2` y verificar compatibilidad del sistema. |
| Una distro queda congelada | Sesión colgada o proceso interno bloqueado. | Ejecutar `wsl --terminate {{distro}}` o `wsl --shutdown`. |
| No arranca una distro importada | Ruta inválida, backup defectuoso o importación incompleta. | Verificar ruta de destino, archivo `.tar` y volver a importar. |
| El almacenamiento crece demasiado | Acumulación de paquetes, logs o artefactos dentro de la distro. | Limpiar Linux desde dentro de la distro y considerar exportar/importar o compactar según procedimiento controlado. |
| Se trabaja sobre `/mnt/c/...` y el rendimiento es bajo | Proyecto pesado ubicado en sistema de archivos Windows. | Mover el proyecto a `/home/{{usuario}}/` dentro del sistema Linux. |
| `Permission denied` al operar archivos Linux desde Windows | Mezcla de permisos entre Windows y Linux. | Preferir trabajo desde terminal Linux y mantener ownership correcto dentro de la distro. |

---

## Buenas prácticas

- Instalar y usar preferentemente **WSL2**, no WSL1, para laboratorios modernos de datos.
- Mantener los proyectos técnicos dentro del sistema de archivos Linux, por ejemplo en `/home/{{usuario}}/proyectos/`.
- Usar `wsl --shutdown` cuando necesites reiniciar limpio el entorno o liberar recursos.
- Exportar la distribución antes de cambios grandes, migraciones o experimentos delicados.
- Evitar borrar o mover manualmente archivos internos de la distro desde Windows sin entender su impacto.
- Mantener separado el uso de PowerShell/CMD para administración de WSL y Bash para administración de Linux.

---

## Atajos o recordatorios clave

- **Nota rápida 1:** `wsl -l -v` es el comando más útil para verificar rápidamente qué distribuciones existen y en qué versión están.
- **Nota rápida 2:** `wsl --shutdown` apaga todo WSL; no solo una terminal.
- **Nota rápida 3:** `\\wsl$\` sirve para acceder desde Windows a archivos Linux, pero no debe sustituir una estrategia correcta de trabajo dentro de `/home`.
- **Nota rápida 4:** para instalar una distribución específica, primero conviene listar opciones con `wsl -l -o`.
- **Nota rápida 5:** exportar antes de experimentar es mucho mejor que intentar recuperar una distro dañada después.

---

## Referencias

1. Microsoft Learn. *Comandos básicos para WSL*. https://learn.microsoft.com/es-es/windows/wsl/basic-commands
2. Microsoft Learn. *What is Windows Subsystem for Linux?*. https://learn.microsoft.com/windows/wsl/about
3. Microsoft Learn. *How to install Linux on Windows with WSL*. https://learn.microsoft.com/windows/wsl/install

---

## Relación con otros documentos del repositorio

- Tutorial relacionado: `docs/tutoriales/01_instalacion_wsl2_ubuntu.md`
- Documento complementario: `docs/cheatsheets/ubuntu_administracion_basica.md`
- Cheat Sheet asociado: `docs/cheatsheets/python_pyenv_venv.md`

---

## Recomendación de uso

Este Cheat Sheet debe usarse como referencia operativa rápida durante laboratorios y prácticas. No sustituye el tutorial completo de instalación de WSL2, pero sí concentra los comandos más útiles para verificar estado, instalar distribuciones, cambiar versiones, iniciar, detener, respaldar e importar entornos WSL.
