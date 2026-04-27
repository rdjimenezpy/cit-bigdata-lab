<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional FP-UNA">
</p>

# Tutorial paso a paso: Autenticación recomendada con GitHub vía SSH
**Configuración de acceso seguro para operaciones Git sin reingreso continuo de credenciales en Windows 11 + WSL2 + Ubuntu 22.04.5 LTS**

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

- **Fecha:** 26/03/2026
- **Versión:** 1.0

---

## Nota sobre esta documentación

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia del curso básico de **Introducción a Big Data** del **Centro de Innovación TIC** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

Los pasos, comandos, rutas y salidas de consola presentados en este material fueron validados conceptualmente para un flujo de trabajo con **Git + GitHub + SSH** ejecutado desde **Windows 11 con WSL2 sobre Ubuntu 22.04.5 LTS**. No obstante, su reproducción en otros equipos puede requerir ajustes menores debido a diferencias en:

- sistema operativo y versión;
- distribución Linux utilizada dentro de WSL;
- configuración de red o políticas de firewall;
- permisos del usuario local;
- versión de Git y OpenSSH instaladas;
- y coexistencia de múltiples entornos de terminal en una misma máquina.

Por ello, ante diferencias puntuales durante la ejecución, se recomienda:

- leer cuidadosamente los mensajes del sistema;
- contrastar los pasos con la documentación oficial de GitHub;
- documentar cualquier ajuste realizado en el entorno local;
- y, si es necesario, solicitar apoyo a través de los canales oficiales de la asignatura.

Este enfoque es coherente con escenarios reales de ingeniería de datos y desarrollo de software: la autenticación segura y la configuración de repositorios rara vez ocurre bajo condiciones idénticas en todos los entornos.

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

En flujos de trabajo basados en Git y GitHub, una causa común de fricción operativa es que el repositorio remoto esté configurado con **HTTPS**, lo que puede provocar solicitudes repetidas de autenticación al ejecutar operaciones como `git pull`, `git push` o `git fetch`. Para evitar ese problema, una alternativa robusta y ampliamente utilizada es configurar la autenticación mediante **SSH**, asociando una clave pública a la cuenta de GitHub y utilizando un agente de autenticación local para administrar la clave privada.

Este tutorial describe el procedimiento recomendado para configurar **GitHub vía SSH** desde un entorno **Windows 11 + WSL2 + Ubuntu 22.04.5 LTS**, de modo que el estudiante o desarrollador pueda sincronizar su rama local con el repositorio remoto sin reingresar credenciales de GitHub en cada operación. Además de la configuración base, se incluye la conversión de la URL remota del repositorio desde **HTTPS a SSH**, la validación de la conectividad y una sección de resolución de problemas frecuentes.

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- comprender el propósito de la autenticación Git mediante SSH en GitHub;
- generar y administrar una clave SSH segura para uso personal;
- registrar la clave pública en su cuenta de GitHub;
- reconfigurar un repositorio local para operar contra el remoto usando SSH;
- validar la conectividad y el funcionamiento correcto de `git pull` y `git push` sin autenticación repetitiva.

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** Git + GitHub + OpenSSH  
**Versión objetivo:** Flujo general vigente de GitHub para autenticación SSH  
**Sistema operativo base:** Windows 11 + WSL2 + Ubuntu 22.04.5 LTS  
**Entorno de trabajo:** repositorio local ejecutado desde terminal Linux dentro de WSL  
**IDE / cliente sugerido:** Terminal Bash en WSL, Visual Studio Code, PyCharm o Git desde CLI  
**Tipo de uso:** configuración y validación de autenticación segura para sincronización Git  

### Este tutorial cubre

- verificación de claves SSH existentes;
- generación de una nueva clave SSH tipo Ed25519;
- carga de la clave en `ssh-agent`;
- registro de la clave pública en GitHub;
- prueba de conectividad con GitHub vía SSH;
- cambio de la URL remota del repositorio de HTTPS a SSH;
- validación del flujo operativo básico.

### Este tutorial no cubre

- firma de commits y tags con SSH;
- uso de claves de hardware o llaves FIDO2;
- gestión avanzada de múltiples cuentas GitHub en un mismo equipo;
- automatización corporativa con `ssh-agent` persistente a nivel sistema;
- alternativas de autenticación basadas en Git Credential Manager o personal access tokens.

---

## 4. Contexto técnico

Dentro del stack de trabajo del proyecto **CIT-BIGDATA-LAB**, Git y GitHub cumplen el papel de control de versiones, trazabilidad del código fuente, publicación de materiales técnicos y sincronización colaborativa del repositorio. En ese contexto, utilizar autenticación SSH aporta un beneficio práctico directo: evita depender de credenciales interactivas por cada operación y reduce fricción al sincronizar notebooks, scripts Python, DAGs de Airflow, documentación Markdown y otros activos del laboratorio.

Cuando el trabajo se ejecuta desde **WSL2**, es recomendable que tanto Git como la clave SSH y el agente de autenticación se gestionen desde el mismo entorno Linux. Mezclar indiscriminadamente Git ejecutado en Windows con claves almacenadas sólo en WSL —o viceversa— suele introducir errores de configuración, inconsistencias en rutas y problemas de autenticación difíciles de diagnosticar.

---

## 5. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- una cuenta activa en GitHub;
- un repositorio local ya clonado o inicializado;
- Git instalado en el entorno donde se ejecutarán los comandos;
- OpenSSH instalado y disponible desde terminal;
- acceso al menú de configuración de la cuenta GitHub;
- conexión de red que permita salida hacia GitHub.

### Verificaciones rápidas

```bash
git --version
ssh -V
uname -a
```

**Resultado esperado:**

- `git --version` debe devolver una versión instalada de Git;
- `ssh -V` debe indicar que OpenSSH está disponible;
- `uname -a` debe confirmar que el entorno actual corresponde a Linux bajo WSL, si ese es el flujo elegido.

---

## 6. Arquitectura o flujo de referencia

El flujo lógico asociado a este tutorial es el siguiente:

- el usuario trabaja en un repositorio local con Git;
- Git utiliza una URL remota SSH apuntando a GitHub;
- el cliente `ssh` presenta una clave privada local para autenticarse;
- `ssh-agent` administra la clave cargada y evita solicitarla repetidamente durante la sesión;
- GitHub valida que la clave pública correspondiente esté asociada a la cuenta del usuario;
- una vez validada la autenticación, las operaciones `pull`, `push`, `fetch` y `clone` mediante SSH quedan habilitadas.

Representación resumida del flujo:

- `Repositorio local`
- `Git remote origin (SSH)`
- `OpenSSH client`
- `ssh-agent`
- `Cuenta GitHub con clave pública registrada`
- `Repositorio remoto en GitHub`

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `OWNER/REPO` → reemplazar por el propietario y nombre real del repositorio.
- `tu_correo_github@example.com` → reemplazar por el correo asociado a la cuenta GitHub.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `Git`, `SSH`, `Bash` → tecnologías empleadas en los ejemplos.

---

## 8. Procedimiento paso a paso

### Paso 1 — Verificar si ya existen claves SSH en el entorno actual

**Objetivo del paso:** determinar si el usuario ya dispone de una clave reutilizable en `~/.ssh` y evitar generar archivos redundantes o sobrescribir claves preexistentes.

**Instrucciones:**

```bash
ls -al ~/.ssh
```

**Explicación técnica:**  
Este comando lista el contenido del directorio oculto `~/.ssh`, donde normalmente se almacenan las claves privadas, claves públicas y configuraciones del cliente SSH. Si aparecen archivos como `id_ed25519`, `id_ed25519.pub`, `id_rsa` o `config`, el entorno ya cuenta con una configuración SSH previa.

**Resultado esperado:**  
Debe mostrarse el contenido del directorio `~/.ssh`. Si no existe, el sistema puede indicar que el directorio no está disponible. Eso no representa un error crítico; simplemente significa que aún no se generó ninguna clave SSH en este entorno.

**Ya tienes tu par de claves SSH (id_ed25519 y id_ed25519.pub) en ~/.ssh**  
Te guío paso a paso para verificar y configurar tu entorno WSL/Ubuntu:

```bash
# 1. Verificar que la clave pública esté en GitHub
cat ~/.ssh/id_ed25519.pub

# 2. Configurar el cliente SSH
nano ~/.ssh/config

# 2.1. Agrega
Host github.com
  User git
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

# 3. Probar la conexión
ssh -T git@github.com

# 4. Verificar con tu repositorio
git remote -v

# 4.1. Si aparece con https://..., cámbialo a SSH:
git remote set-url origin git@github.com:rdjimenezpy/cit-bigdata-lab.git

```

---

### Paso 2 — Generar una nueva clave SSH recomendada para GitHub

**Objetivo del paso:** crear una nueva pareja de claves SSH para autenticación segura contra GitHub.

**Instrucciones:**

```bash
ssh-keygen -t ed25519 -C "tu_correo_github@example.com"
```

**Alternativa con nombre personalizado de archivo:**

```bash
ssh-keygen -t ed25519 -C "tu_correo_github@example.com" -f ~/.ssh/id_ed25519_github
```

**Explicación técnica:**  
El comando `ssh-keygen` genera una pareja de claves compuesta por una **clave privada** y una **clave pública**. El algoritmo `ed25519` es la opción recomendada en la documentación de GitHub para configuraciones modernas. El parámetro `-C` agrega una etiqueta descriptiva, normalmente un correo, que ayuda a identificar la clave posteriormente. Si el usuario trabaja con múltiples entornos o cuentas, conviene definir explícitamente un nombre de archivo con `-f`.

Durante la ejecución, el sistema solicitará:

1. la ruta de almacenamiento del archivo;
2. una **passphrase** opcional.

Se recomienda definir una passphrase segura. Luego, esa passphrase podrá ser retenida temporalmente por `ssh-agent` para evitar tener que escribirla en cada operación.

**Resultado esperado:**  
Deben generarse dos archivos en `~/.ssh`, por ejemplo:

- `~/.ssh/id_ed25519`
- `~/.ssh/id_ed25519.pub`

O bien, si se usó nombre personalizado:

- `~/.ssh/id_ed25519_github`
- `~/.ssh/id_ed25519_github.pub`

---

### Paso 3 — Iniciar el agente SSH y cargar la clave privada

**Objetivo del paso:** permitir que el sistema recuerde temporalmente la clave privada para no solicitar autenticación interactiva en cada operación Git.

**Instrucciones:**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Si se utilizó nombre personalizado:**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github
```

**Explicación técnica:**  
`ssh-agent` es un proceso que mantiene disponibles en memoria las claves privadas cargadas por el usuario. Al agregar la clave con `ssh-add`, el agente podrá reutilizarla durante la sesión actual. Si la clave posee passphrase, normalmente ésta se ingresará una sola vez cuando se agregue al agente.

Este paso es el que realmente reduce la fricción operativa: la clave sigue estando protegida, pero el usuario no tiene que reingresar la passphrase en cada `git pull` o `git push`, siempre que el agente permanezca activo.

**Resultado esperado:**  
El sistema debe mostrar el PID del agente y luego un mensaje indicando que la identidad fue agregada correctamente.

---

### Paso 4 — Verificar que la clave fue cargada en el agente

**Objetivo del paso:** confirmar que la clave privada está activa en `ssh-agent` antes de registrar la clave pública en GitHub.

**Instrucciones:**

```bash
ssh-add -l
```

**Explicación técnica:**  
Este comando lista las identidades cargadas actualmente en el agente SSH. Si la salida muestra una huella digital asociada a la ruta de la clave, significa que el agente ya la está administrando correctamente.

**Resultado esperado:**  
Debe visualizarse al menos una línea con la huella de la clave y su archivo asociado. Si el sistema indica que no hay identidades, entonces la clave no fue cargada correctamente y se debe repetir el paso anterior.

---

### Paso 5 — Obtener la clave pública para registrarla en GitHub

**Objetivo del paso:** copiar la clave pública generada para asociarla a la cuenta del usuario en GitHub.

**Instrucciones:**

```bash
cat ~/.ssh/id_ed25519.pub
```

**Alternativa para copiar al portapapeles de Windows desde WSL:**

```bash
cat ~/.ssh/id_ed25519.pub | clip.exe
```

**Si se utilizó nombre personalizado:**

```bash
cat ~/.ssh/id_ed25519_github.pub | clip.exe
```

**Explicación técnica:**  
La **clave pública** es la que debe cargarse en GitHub. A diferencia de la clave privada, esta sí puede compartirse con el servicio remoto. En entornos WSL, `clip.exe` es una forma práctica de copiar directamente el contenido al portapapeles de Windows para luego pegarlo en el navegador.

**Resultado esperado:**  
Debe visualizarse una cadena larga que inicia normalmente con `ssh-ed25519`. Ese contenido es el que se debe copiar íntegramente.

---

### Paso 6 — Registrar la clave pública en la cuenta GitHub

**Objetivo del paso:** habilitar que GitHub reconozca la clave pública asociada a la clave privada del equipo local.

**Instrucciones:**

Realizar los siguientes pasos en la interfaz web de GitHub:

1. Ingresar a **Settings**.
2. Abrir la sección **SSH and GPG keys**.
3. Seleccionar **New SSH key** o **Add SSH key**.
4. Definir un título descriptivo, por ejemplo: `Lenovo Yoga WSL2`.
5. En el campo de clave, pegar el contenido de la clave pública.
6. Confirmar la operación.

**Explicación técnica:**  
GitHub necesita almacenar la clave pública para poder verificar la autenticación SSH proveniente del cliente local. Sin este paso, aunque la clave exista en el equipo, GitHub rechazará la conexión.

**Resultado esperado:**  
La nueva clave debe aparecer listada en la sección **SSH and GPG keys** de la cuenta GitHub.

---

### Paso 7 — Probar la conectividad con GitHub vía SSH

**Objetivo del paso:** confirmar que la autenticación entre el equipo local y GitHub funciona correctamente.

**Instrucciones:**

```bash
ssh -T git@github.com
```

**Explicación técnica:**  
Este comando intenta establecer una conexión SSH contra GitHub usando el usuario técnico `git`. La opción `-T` evita solicitar un shell interactivo, ya que GitHub no ofrece acceso shell tradicional. La primera vez, el sistema puede solicitar confirmación de la huella del host remoto.

**Resultado esperado:**  
La salida debe ser similar a un mensaje de autenticación exitosa indicando que GitHub reconoció al usuario, aunque no proporciona acceso shell interactivo.

---

### Paso 8 — Revisar la URL remota actual del repositorio local

**Objetivo del paso:** identificar si el repositorio sigue utilizando HTTPS y confirmar el nombre del remoto a modificar.

**Instrucciones:**

```bash
git remote -v
```

**Explicación técnica:**  
Este comando muestra los remotos configurados en el repositorio local. Normalmente el remoto principal se denomina `origin`. Si la URL empieza con `https://github.com/...`, entonces aún no está configurado el acceso por SSH.

**Resultado esperado:**  
Debe mostrarse la lista de remotos existentes junto con sus URLs de `fetch` y `push`.

---

### Paso 9 — Cambiar la URL del remoto desde HTTPS a SSH

**Objetivo del paso:** reemplazar la URL remota actual por una URL compatible con autenticación SSH.

**Instrucciones:**

```bash
git remote set-url origin git@github.com:OWNER/REPO.git
```

**Ejemplo real de formato:**

```bash
git remote set-url origin git@github.com:prof-rjimenez/cit-bigdata-lab.git
```

**Explicación técnica:**  
`git remote set-url` modifica la URL asociada a un remoto existente. En este caso, se sustituye la URL HTTPS por la forma SSH `git@github.com:OWNER/REPO.git`. A partir de ese momento, las futuras operaciones Git contra `origin` usarán el canal SSH.

**Resultado esperado:**  
No siempre habrá salida visible si el comando se ejecuta correctamente. La validación debe hacerse repitiendo `git remote -v`.

---

### Paso 10 — Verificar que el remoto quedó configurado con SSH

**Objetivo del paso:** confirmar que el repositorio local ya apunta al remoto SSH correcto.

**Instrucciones:**

```bash
git remote -v
```

**Explicación técnica:**  
Se vuelve a listar la configuración de remotos para verificar que tanto `fetch` como `push` utilicen la URL SSH recién configurada.

**Resultado esperado:**  
La salida debe ser similar a:

```text
origin  git@github.com:OWNER/REPO.git (fetch)
origin  git@github.com:OWNER/REPO.git (push)
```

---

### Paso 11 — Ejecutar una prueba real de sincronización

**Objetivo del paso:** validar el comportamiento operativo del repositorio con la nueva autenticación SSH.

**Instrucciones:**

```bash
git pull
git push
```

**Explicación técnica:**  
Estas operaciones ejercitan el flujo real de lectura y escritura contra el remoto. Si la clave está correctamente cargada, la clave pública fue registrada en GitHub y el remoto está configurado con SSH, entonces Git no debería solicitar credenciales de GitHub por HTTPS.

**Resultado esperado:**  
Las operaciones deben ejecutarse usando SSH. Si la rama local no tiene cambios para subir o descargar, el sistema simplemente indicará que el repositorio ya está actualizado o que no hay cambios pendientes.

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- existe una clave SSH válida en `~/.ssh`;
- `ssh-agent` tiene la clave cargada;
- la cuenta GitHub contiene la clave pública registrada;
- `ssh -T git@github.com` responde con autenticación exitosa;
- `git remote -v` muestra URLs del tipo `git@github.com:OWNER/REPO.git`;
- `git pull` y `git push` ya no dependen de autenticación HTTPS repetitiva.

### Comandos de validación

```bash
ls -al ~/.ssh
ssh-add -l
ssh -T git@github.com
git remote -v
```

### Evidencia esperada

La evidencia de éxito debe incluir, como mínimo:

- presencia de archivos de clave en `~/.ssh`;
- al menos una identidad cargada en `ssh-agent`;
- mensaje de autenticación exitosa desde GitHub;
- y URL remota del repositorio configurada con prefijo `git@github.com:`.

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| `Permission denied (publickey)` | La clave privada no está cargada en el agente o la clave pública no fue agregada en GitHub | `ssh-add ~/.ssh/id_ed25519` y verificar la clave en GitHub |
| `Could not open a connection to your authentication agent` | `ssh-agent` no fue iniciado en la sesión actual | `eval "$(ssh-agent -s)"` |
| `fatal: No such remote 'origin'` | El remoto indicado no existe con ese nombre | Verificar con `git remote -v` y ajustar el nombre correcto |
| Git sigue solicitando credenciales | El remoto aún está en HTTPS | Ejecutar `git remote set-url origin git@github.com:OWNER/REPO.git` |
| `Host key verification failed` | El host cambió o la huella guardada no coincide | Revisar `~/.ssh/known_hosts` y validar la huella oficial de GitHub antes de corregir |
| La red bloquea el puerto 22 | Restricciones de firewall o red corporativa | Configurar SSH sobre el puerto 443 en `~/.ssh/config` |

### Configuración alternativa para redes que bloquean el puerto 22

Si el entorno no permite conexiones SSH salientes por el puerto 22, agregar el siguiente bloque en `~/.ssh/config`:

```sshconfig
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

Luego volver a probar la conectividad:

```bash
ssh -T git@github.com
```

---

## 11. Buenas prácticas

- utilizar `ed25519` como algoritmo por defecto para nuevas claves SSH, salvo restricciones específicas del entorno;
- definir una passphrase robusta para proteger la clave privada;
- trabajar con Git y SSH desde un único entorno consistente, preferentemente WSL si el repositorio se opera desde Linux;
- no compartir nunca la clave privada ni copiarla a ubicaciones inseguras;
- asignar títulos descriptivos a las claves cargadas en GitHub para poder auditarlas y revocarlas con facilidad;
- usar nombres de archivo personalizados cuando se administran múltiples cuentas o múltiples contextos;
- validar siempre el remoto con `git remote -v` antes de asumir que el repositorio ya quedó en SSH;
- retirar claves antiguas o no utilizadas de la cuenta GitHub para reducir superficie de riesgo.

---

## 12. Conclusión

Mediante este procedimiento se configuró un esquema de autenticación recomendado con GitHub vía SSH, orientado a reducir la fricción operativa en el uso cotidiano de Git y a mantener un nivel razonable de seguridad en el acceso al repositorio remoto. Este ajuste resulta especialmente útil en entornos de laboratorio, desarrollo y docencia donde la sincronización de ramas, scripts y documentación ocurre con frecuencia. Como paso siguiente recomendado, se puede complementar esta configuración con un tutorial de **buenas prácticas Git para trabajo por ramas**, incluyendo `clone`, `branch`, `checkout`, `pull`, `push`, `merge`, `rebase` y convenciones de commits.

---

## 13. Referencias

1. GitHub Docs. **Connecting to GitHub with SSH**. https://docs.github.com/en/authentication/connecting-to-github-with-ssh  
2. GitHub Docs. **Checking for existing SSH keys**. https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys  
3. GitHub Docs. **Generating a new SSH key and adding it to the ssh-agent**. https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent  
4. GitHub Docs. **Adding a new SSH key to your GitHub account**. https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account  
5. GitHub Docs. **Testing your SSH connection**. https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection  
6. GitHub Docs. **Managing remote repositories**. https://docs.github.com/en/get-started/git-basics/managing-remote-repositories  
7. GitHub Docs. **Using SSH over the HTTPS port**. https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port  
8. GitHub Docs. **Why is Git always asking for my credentials?**. https://docs.github.com/en/get-started/git-basics/why-is-git-always-asking-for-my-credentials  

---

## Anexo opcional A — Comandos rápidos

```bash
# 1) Verificar si ya existen claves
ls -al ~/.ssh

# 2) Generar nueva clave SSH
ssh-keygen -t ed25519 -C "tu_correo_github@example.com"

# 3) Iniciar el agente y cargar la clave
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 4) Copiar la clave pública
cat ~/.ssh/id_ed25519.pub | clip.exe

# 5) Probar conectividad
ssh -T git@github.com

# 6) Ver remoto actual
git remote -v

# 7) Cambiar remoto HTTPS -> SSH
git remote set-url origin git@github.com:OWNER/REPO.git

# 8) Verificar cambio
git remote -v

# 9) Probar sincronización
git pull
git push
```

---

## Anexo opcional B — Estructura de rutas relevantes

```text
~/.ssh/
├── id_ed25519
├── id_ed25519.pub
├── config
└── known_hosts
```

---

## Anexo opcional C — Archivos de configuración usados

### `~/.ssh/config`

```sshconfig
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

### Remoto SSH esperado

```text
git@github.com:OWNER/REPO.git
```
