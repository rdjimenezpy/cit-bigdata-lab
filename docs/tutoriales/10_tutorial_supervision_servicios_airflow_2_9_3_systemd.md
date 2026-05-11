<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# 📘Tutorial paso a paso: Configuración de Apache Airflow 2.9.3 como servicios systemd  
**Webserver – Scheduler – Triggerer**  
**Entorno WSL / Ubuntu 22.04 – Instalación en /opt/airflow/airflow_2.9.3**

---

## Institución  
Facultad Politécnica – Universidad Nacional de Asunción  
Centro de Innovación CIT Paraguay–Corea. [Sitio oficial del CIT](https://cit.pol.una.py/)

## Curso  
Introducción a Big Data (nivel básico) – Orquestación y Arquitectura de Pipelines  

## Autor  
Richard D. Jiménez-R.
Ingeniero en Informática – Arquitecto y Analista de Datos  

## Contacto
rjimenez@pol.una.py

## Fecha y versión
* Fecha: 16/01/2026
* Versión: 1.0

---

🗒️ **Nota sobre esta documentación:**

Este procedimiento está basado en una instalación real y funcional de **Apache Airflow 2.9.3** en **Ubuntu 22.04** bajo **WSL2**, utilizando **PostgreSQL 15** y entornos virtuales gestionados con **pyenv** y el interprete de **Python 12.3.5**.  

Dependiendo del entorno, usuario o políticas de seguridad, pueden requerirse ajustes menores para reproducir este manual en su máquina local.

Al finalizar este manual, habrás implementado una arquitectura de servicios profesional, robusta y alineada con las mejores prácticas de **DevOps** para la gestión de flujos de trabajo con Apache Airflow.

En caso de necesitar apoyo adicional para reproducir el tutorial, el estudiante deberá contactar con el profesor del curso o solicitar ayuda a través de los canales disponibles del mismo.

---

## 1. Introducción

En una instalación profesional de Apache Airflow, **no es recomendable** ejecutar los componentes críticos (webserver, scheduler, triggerer) de forma manual desde la terminal.  
Para entornos reales —incluso académicos con vocación productiva— se requiere:

- Arranque automático al iniciar el sistema.
- Reinicio controlado ante fallos.
- Supervisión centralizada de logs.
- Manejo correcto de señales y procesos hijos.

Todo esto se logra utilizando **systemd**, el gestor de servicios estándar en la mayoría de las distribuciones Linux modernas.

Este manual explica **paso a paso** cómo integrar Apache Airflow 2.9.3 con systemd, utilizando **archivos reales** del entorno desplegado en `/opt/airflow/airflow_2.9.3`.

---

## 2. ¿Qué es systemd?

**systemd** es el sistema de inicialización y gestor de servicios de Linux.  
Sus responsabilidades principales son:

- Iniciar servicios al arrancar el sistema.
- Reiniciarlos si fallan.
- Gestionar dependencias.
- Centralizar logs (`journald`).
- Enviar señales controladas a procesos.

En términos simples:  
> *systemd es el “director de orquesta” de los procesos del sistema.*

---

## 3. Conceptos básicos de systemd (para principiantes)

### Servicio (service unit)
Un **servicio** es un proceso de larga duración, definido mediante un archivo `.service`.

Ejemplo:
```text
airflow2-webserver.service
```

### Comandos básicos de `systemctl`

| Comando                                    | Descripción                                                                                                                       |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `systemctl list-units --type=service`      | Lista todos los servicios cargados actualmente y su estado (activos, inactivos, fallidos).                                        |
| `systemctl list-unit-files --type=service` | Muestra todos los archivos de unidad de servicio instalados en el sistema y su configuración (enabled, disabled, static, masked). |
| `systemctl status nombre_servicio`         | Muestra el estado detallado de un servicio específico (logs, PID, estado actual).                                                 |
| `systemctl is-active nombre_servicio`      | Verifica si un servicio está activo.                                                                                              |
| `systemctl is-enabled nombre_servicio`     | Verifica si un servicio está habilitado para iniciar al arranque.                                                                 |
| `systemctl is-failed nombre_servicio`      | Verifica si un servicio ha fallado.                                                                                               |

### Comandos de administración de servicios

| Comando                             | Acción                                                                         |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| `systemctl start nombre_servicio`   | Inicia un servicio inmediatamente.                                             |
| `systemctl stop nombre_servicio`    | Detiene un servicio en ejecución.                                              |
| `systemctl restart nombre_servicio` | Reinicia un servicio (útil tras cambios de configuración).                     |
| `systemctl reload nombre_servicio`  | Recarga la configuración sin detener el servicio (si el servicio lo soporta).  |
| `systemctl enable nombre_servicio`  | Habilita un servicio para que arranque automáticamente con el sistema.         |
| `systemctl disable nombre_servicio` | Deshabilita el arranque automático del servicio.                               |
| `systemctl mask nombre_servicio`    | Bloquea un servicio para que no pueda iniciarse ni manualmente ni al arranque. |
| `systemctl unmask nombre_servicio`  | Desbloquea un servicio previamente enmascarado.                                |

### Comandos de diagnóstico y monitoreo

|Comando|Uso|
|---|---|
|`systemctl list-units --failed`|Lista los servicios que han fallado.|
|`journalctl -u nombre_servicio`|Muestra los registros (logs) de un servicio específico.|
|`journalctl -xe`|Muestra los últimos eventos y errores del sistema con detalle.|
|`systemctl show nombre_servicio`|Muestra todas las propiedades y metadatos de un servicio.|

Comando útiles para que lo uses como referencia en tus entornos de laboratorio

```bash
# Para filtrar los servicios en **systemctl** que comienzan con un patrón específico (por ejemplo, `airflow*`)
systemctl list-units --type=service 'airflow*'

# Esto te mostrará si están enabled, disabled, static o masked
systemctl list-unit-files --type=service 'airflow*'

# Deshabilita el arranque automático del servicio.
sudo systemctl disable airflow2-triggerer.service airflow2-scheduler@.service airflow2-webserver.service
```

---

## 4. Enfoque de la instalación Airflow + systemd

Cada componente de Airflow se gestiona como **un servicio independiente**:

- `airflow2-webserver`
- `airflow2-scheduler`
- `airflow2-triggerer`

Todos:

- Usan **el binario del venv**
- Comparten variables de entorno
- Apuntan a `/opt/airflow/airflow_2.9.3`
- Registran logs en **journald**

---

## 5. Variables de entorno globales para systemd

Crear el archivo:

```bash
sudo nano /etc/default/airflow2.env
```

Contenido:

```bash
AIRFLOW_HOME=/opt/airflow/airflow_2.9.3
AIRFLOW_CONFIG=/opt/airflow/airflow_2.9.3/configs/airflow.cfg
PYTHONUNBUFFERED=1

## Opcionales: útiles para webserver (mapean a [core], [loggin], [webserver] en airflow.cfg)
# [logging]
#AIRFLOW__LOGGING__BASE_LOG_FOLDER=/opt/airflow/airflow_2.9.3/logs

# [webserver]
#AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080
#AIRFLOW__WEBSERVER__WORKERS=4
#AIRFLOW__WEBSERVER__WORKER_CLASS=sync
#AIRFLOW__WEBSERVER__WEB_SERVER_WORKER_TIMEOUT=120
#AIRFLOW__WEBSERVER__EXPOSE_CONFIG=True
```
Guardar y cerrar.
Este archivo será utilizado por **todos los servicios**.

---

## 6. Servicio systemd – Webserver

Archivo:

```bash
sudo nano /etc/systemd/system/airflow2-webserver.service
```

Conetenido:

```ini
# === /etc/systemd/system/airflow2-webserver.service ===

[Unit]
Description=Airflow-2.9.3 Webserver daemon
After=network.target

# Limita reintentos: 3 fallos consecutivos en 120s -> queda en failed
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=richard
Group=richard
EnvironmentFile=/etc/default/airflow2.env
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Pre-chequeo: si el metastore no responde, falla rápido y systemd reintenta
ExecStartPre=/opt/airflow/airflow_2.9.3/venv/bin/airflow db check
ExecStartPre=/opt/airflow/airflow_2.9.3/venv/bin/airflow db check-migrations

# Arranque: usa SIEMPRE el binario del venv
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow webserver

# Parada ordenada - Manejo más robusto de procesos hijos
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=60
SendSIGKILL=yes
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID

# Política de reinicio: reintenta ante fallo, con espera
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=143
TimeoutStartSec=120

# Límites y entorno (seguridad y recursos)
UMask=0027
LimitNOFILE=65536
LimitNPROC=65536

# Carpeta efímera en /run gestionada por systemd
RuntimeDirectory=airflow2-web
RuntimeDirectoryMode=0755

# Logging: por defecto a journald; puedes hacer journalctl -u airflow2-webserver -f
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow2-webserver
LogLevelMax=debug

# Mejor manejo de OOM (Out Of Memory)
OOMScoreAdjust=-300

[Install]
WantedBy=multi-user.target
```

---

## 7. Servicio systemd – Scheduler

Archivo:

```bash
sudo nano /etc/systemd/system/airflow2-scheduler.service
```

Contenido:

```ini
# === /etc/systemd/system/airflow2-scheduler.service ===

[Unit]
Description=Airflow-2.9.3 Scheduler daemon
After=network.target

# Limita reintentos: 3 fallos consecutivos en 120s -> queda en failed
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=richard
Group=richard
EnvironmentFile=/etc/default/airflow2.env
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Arranque: usa SIEMPRE el binario del venv (sin bash/source)
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow scheduler

# Parada ordenada - Manejo más robusto de procesos hijos
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

# Política de reinicio: reintenta ante fallo, con espera
Restart=on-failure
RestartSec=30s
RestartPreventExitStatus=143
TimeoutStartSec=180s

# Límites del sistema para manejar múltiples procesos
LimitNOFILE=65536
LimitNPROC=65536

# Carpeta efímera en /run gestionada por systemd
RuntimeDirectory=airflow2-scheduler
RuntimeDirectoryMode=0755

# Logging: por defecto a journald; puedes hacer journalctl -u airflow2-scheduler -f
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow2-scheduler
LogLevelMax=debug

# Mejor manejo de OOM (Out Of Memory)
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

---

## 8. Servicio systemd – Triggerer

Archivo:

```bash
sudo nano /etc/systemd/system/airflow2-triggerer.service
```

Contenido:

```ini
# === /etc/systemd/system/airflow2-triggerer.service ===

[Unit]
Description=Airflow-2.9.3 Triggerer daemon
After=network.target

# Limita reintentos: 3 fallos consecutivos en 120s -> queda en failed
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=richard
Group=richard
EnvironmentFile=/etc/default/airflow2.env
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Arranque: usa SIEMPRE el binario del venv
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow triggerer

# Parada ordenada - Manejo más robusto de procesos hijos
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
ExecStop=/bin/kill -TERM $MAINPID
SendSIGKILL=yes

# Política de reinicio: reintenta ante fallo, con espera
Restart=on-failure
RestartSec=30s
TimeoutStartSec=120s

# Carpeta efímera en /run gestionada por systemd
RuntimeDirectory=airflow2-triggerer
RuntimeDirectoryMode=0755

# Logging: por defecto a journald; puedes hacer journalctl -u airflow2-triggerer -f
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow2-triggerer
LogLevelMax=debug

# Mejor manejo de procesos hijos
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
```

---

## 9. Recargar systemd y verificar sintaxis

```bash
sudo systemctl daemon-reload

sudo systemctl cat airflow2-webserver.service
sudo systemctl cat airflow2-scheduler.service
sudo systemctl cat airflow2-triggerer.service
```

---

## 10. Habilitar y arrancar servicios

```bash
sudo systemctl enable --now airflow2-webserver.service
sudo systemctl enable --now airflow2-scheduler.service
sudo systemctl enable --now airflow2-triggerer.service
```

Ver estado:

```bash
systemctl status airflow2-webserver --no-pager
systemctl status airflow2-scheduler --no-pager
systemctl status airflow2-triggerer --no-pager
```

---

## 11. Supervisión y logs con journalctl

### Webserver

```bash
journalctl -u airflow2-webserver -f
journalctl -u airflow2-webserver -f --since "2 minutes ago"
journalctl -u airflow2-webserver -e -n 100
```

Health check:

```bash
curl -f http://localhost:8080/health || echo "Webserver no responde"
```

### Scheduler

```bash
journalctl -u airflow2-scheduler -f
journalctl -u airflow2-scheduler --priority=3 --since "today"
```

### Triggerer

```bash
journalctl -u airflow2-triggerer -f
```

---

## 12. Gestión avanzada de servicios

Comando de supervisión de servicios airflow (`webserver` / `scheduler` / `triggerer`) con **SystemD**.

### Iniciar

```bash
sudo systemctl start airflow2-webserver
sudo systemctl start airflow2-scheduler
sudo systemctl start airflow2-triggerer

sudo systemctl start airflow2-triggerer airflow2-scheduler airflow2-webserver
```

### Reinicios

```bash
sudo systemctl restart airflow2-webserver
sudo systemctl restart airflow2-scheduler
sudo systemctl restart airflow2-triggerer
```

### Detener

```bash
sudo systemctl stop airflow2-webserver
sudo systemctl stop airflow2-scheduler
sudo systemctl stop airflow2-triggerer

sudo systemctl stop airflow2-triggerer airflow2-scheduler airflow2-webserver
```

### Envío de señales

```bash
sudo systemctl kill airflow2-webserver -s HUP
sudo systemctl kill airflow2-scheduler -s SIGINT
sudo systemctl kill airflow2-triggerer -s SIGKILL
```

### Resetear fallos

```bash
sudo systemctl reset-failed airflow2-triggerer
```

### Estados

```bash
systemctl status airflow2-webserver --no-pager
```

### Logs

```bash
# [webserver]
journalctl -u airflow2-webserver -f
journalctl -u airflow2-webserver -f --since "2 minutes ago"  # Seguir logs en tiempo real
journalctl -u airflow2-webserver -e -n 100
```

## 13. Verificaciones de procesos y puertos

```bash
ps aux | grep airflow
pgrep -af airflow
```

Puerto 8080:

```bash
sudo lsof -i :8080
sudo ss -tuln | grep :8080
```

---

## 14. Airflow Multi-Entorno: Gestionando Múltiples Configs de Airflow con Plantillas de Systemd

En entornos de producción reales, es común que un administrador de datos necesite gestionar múltiples instancias de **Apache Airflow** (Desarrollo, Pre-producción y Producción) en un mismo servidor. Tradicionalmente, esto implicaría duplicar archivos de configuración de `systemd`, lo que genera un caos de mantenimiento y aumenta el riesgo de errores humanos.

Este manual aborda la implementación de **Instanced Units** (Unidades con Plantilla) de `systemd`, identificadas por el símbolo `@`. Esta técnica permite utilizar un **único archivo de servicio maestro** para levantar infinitas instancias personalizadas.

### ¿Qué aprenderás?

A lo largo de esta guía, transformaremos un servicio estático en una plantilla dinámica que utiliza el especificador `%i`. Este parámetro permite que, al ejecutar un comando como `systemctl start airflow2-webserver@des`, el sistema automáticamente:

1. Identifique el entorno solicitado (**des**, **pre**, **pro**).
2. Cargue el archivo de configuración específico (ej. `airflow_des.cfg`).
3. Aísle los logs y procesos de manera independiente.

### Beneficios clave:

- **Mantenibilidad:** Un solo cambio en la plantilla afecta a todos los entornos simultáneamente.
- **Escalabilidad:** Añadir un nuevo entorno es tan simple como crear un archivo `.cfg` y ejecutar un comando de inicio.
- **Seguridad y Control:** Permite validar migraciones y estados de base de datos de forma aislada antes de que el servicio principal arranque.

### Paso 1. Renombrar el archivo de servicio
Debes renombrar tu archivo actual de `airflow2-webserver.service` a `airflow2-webserver@.service`. El símbolo `@` es la clave: indica a **systemd** que este servicio acepta un argumento.

- `webserver`
```bash
sudo nano /etc/systemd/system/airflow2-webserver@.service
```

- `scheduler`
```bash
sudo nano /etc/systemd/system/airflow2-scheduler@.service
```

- `triggerer`
```bash
sudo nano /etc/systemd/system/airflow2-triggerer@.service
```

### Paso 2. Modificar el contenido del servicio
En el archivo, utilizaremos el especificador `%i`, que **systemd** reemplazará por el texto que escribas después del `@` al ejecutar el comando.

- `airflow2-webserver@.service`

```ini
# === /etc/systemd/system/airflow2-webserver@.service ===

[Unit]
Description=Airflow-2.9.3 Webserver daemon (Entorno: %i)
After=network.target

[Service]
Type=simple
User=richard
Group=richard
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Definimos la variable AIRFLOW_CONFIG dinámicamente según el parámetro %i
# Si pasas 'dev', buscará airflow_dev.cfg
Environment="AIRFLOW_CONFIG=/opt/airflow/airflow_2.9.3/configs/airflow_%i.cfg"
Environment=AIRFLOW_HOME=/opt/airflow/airflow_2.9.3
Environment=PYTHONUNBUFFERED=1

# Pre-chequeo: usamos la variable de entorno ya definida
ExecStartPre=/opt/airflow/airflow_2.9.3/venv/bin/airflow db check
ExecStartPre=/opt/airflow/airflow_2.9.3/venv/bin/airflow db check-migrations

# Arranque
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow webserver

# ... (resto de tu configuración de KillMode, Restart, etc. se mantiene igual) ...

[Install]
WantedBy=multi-user.target
```

- `airflow2-scheduler@.service`

```ini
# === /etc/systemd/system/airflow2-scheduler@.service ===

[Unit]
Description=Airflow-2.9.3 Scheduler daemon (Entorno: %i)
After=network.target

# Limita reintentos: 3 fallos consecutivos en 120s -> queda en failed
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=richard
Group=richard
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Definimos la variable AIRFLOW_CONFIG dinámicamente según el parámetro %i
# Si pasas 'dev', buscará airflow_dev.cfg
Environment="AIRFLOW_CONFIG=/opt/airflow/airflow_2.9.3/configs/airflow_%i.cfg"
Environment=AIRFLOW_HOME=/opt/airflow/airflow_2.9.3
Environment=PYTHONUNBUFFERED=1

# Arranque: usa SIEMPRE el binario del venv (sin bash/source)
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow scheduler

# Parada ordenada - Manejo más robusto de procesos hijos
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
SendSIGKILL=yes

# Política de reinicio: reintenta ante fallo, con espera
Restart=on-failure
RestartSec=30s
RestartPreventExitStatus=143
TimeoutStartSec=180s

# Límites del sistema para manejar múltiples procesos
LimitNOFILE=65536
LimitNPROC=65536

# Carpeta efímera en /run gestionada por systemd
RuntimeDirectory=airflow2-scheduler
RuntimeDirectoryMode=0755

# Logging: por defecto a journald; puedes hacer journalctl -u airflow2-scheduler -f
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow2-scheduler
LogLevelMax=debug

# Mejor manejo de OOM (Out Of Memory)
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

- `airflow2-triggerer@.service`

```ini
# === /etc/systemd/system/airflow2-triggerer@.service ===

[Unit]
Description=Airflow-2.9.3 Triggerer daemon (Entorno: %i)
After=network.target

# Limita reintentos: 3 fallos consecutivos en 120s -> queda en failed
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
User=richard
Group=richard
WorkingDirectory=/opt/airflow/airflow_2.9.3

# Definimos la variable AIRFLOW_CONFIG dinámicamente según el parámetro %i
# Si pasas 'dev', buscará airflow_dev.cfg
Environment="AIRFLOW_CONFIG=/opt/airflow/airflow_2.9.3/configs/airflow_%i.cfg"
Environment=AIRFLOW_HOME=/opt/airflow/airflow_2.9.3
Environment=PYTHONUNBUFFERED=1

# Arranque: usa SIEMPRE el binario del venv
ExecStart=/opt/airflow/airflow_2.9.3/venv/bin/airflow triggerer

# Parada ordenada - Manejo más robusto de procesos hijos
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=90s
ExecStop=/bin/kill -TERM $MAINPID
SendSIGKILL=yes

# Política de reinicio: reintenta ante fallo, con espera
Restart=on-failure
RestartSec=30s
TimeoutStartSec=120s

# Carpeta efímera en /run gestionada por systemd
RuntimeDirectory=airflow2-triggerer
RuntimeDirectoryMode=0755

# Logging
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=airflow2-triggerer
LogLevelMax=debug

# Mejor manejo de procesos hijos
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
```

### 3. Recargar systemd y verificar sintaxis

```bash
# Recargar cambios en el .service
sudo systemctl daemon-reload

# Verificar contenido de archivos
sudo systemctl cat airflow2-webserver@.service
sudo systemctl cat airflow2-scheduler@.service
sudo systemctl cat airflow2-triggerer@.service
```

---

### 4. Habilitar y arrancar servicios modo manual

```bash
# [webserver]

# Para el entorno del curso big data (basico) del cit
sudo systemctl disable --now airflow2-webserver@cit

# Para el entorno de development branch
sudo systemctl disable --now airflow2-webserver@dev

# Para el entorno de desarrollo
sudo systemctl disable --now airflow2-webserver@des

# Para el entorno de pre-producción
sudo systemctl disable --now airflow2-webserver@pre

# Para el entorno de producción
sudo systemctl disable --now airflow2-webserver@pro

# [scheduler]
sudo systemctl disable --now airflow2-scheduler@cit
sudo systemctl disable --now airflow2-scheduler@dev
sudo systemctl disable --now airflow2-scheduler@des
sudo systemctl disable --now airflow2-scheduler@pre
sudo systemctl disable --now airflow2-scheduler@pro

# [triggerer]
sudo systemctl disable --now airflow2-triggerer@cit
sudo systemctl disable --now airflow2-triggerer@dev
sudo systemctl disable --now airflow2-triggerer@des
sudo systemctl disable --now airflow2-triggerer@pre
sudo systemctl disable --now airflow2-triggerer@pro
```

### 5. Supervisión de servicios

```bash
# [webserver]
sudo systemctl status airflow2-webserver@des --no-pager
sudo systemctl start airflow2-webserver@des
sudo systemctl stop airflow2-webserver@des

sudo journalctl -xeu airflow2-webserver@des

# [scheduler]
sudo systemctl status airflow2-scheduler@des --no-pager
sudo systemctl start airflow2-scheduler@des
sudo systemctl restart airflow2-scheduler@des
sudo systemctl stop airflow2-scheduler@des

sudo journalctl -xeu airflow2-scheduler@des

# [triggerer]
sudo systemctl status airflow2-triggerer@des --no-pager
sudo systemctl start airflow2-triggerer@des
sudo systemctl restart airflow2-triggerer@des
sudo systemctl stop airflow2-triggerer@des
```

### 6. Cómo administrar los entornos

Una vez guardado el archivo, debes recargar **systemd** y podrás manejar cada entorno de forma independiente:

- **Para el entorno de Desarrollo:** `sudo systemctl start airflow2-webserver@dev`
- **Para el entorno de Producción:** `sudo systemctl start airflow2-webserver@pro`
- **Para ver el estado de un entorno específico:** `systemctl status airflow2-webserver@des`

### Puntos clave de esta configuración:

1. **Variable `AIRFLOW_CONFIG`**: Airflow prioriza esta variable de entorno sobre el archivo por defecto. Al definir `Environment="AIRFLOW_CONFIG=.../airflow_%i.cfg"`, cada instancia leerá exactamente el archivo que corresponde al parámetro.
2. **Aislamiento**: Podrías incluso tener varios corriendo al mismo tiempo (siempre que en sus archivos `.cfg` respectivos tengan configurados **puertos diferentes** para el webserver, por ejemplo: 8080, 8081, etc.).
3. **El caso especial de `airflow.cfg`**: Para tu archivo "base" (el que no tiene sufijo), podrías iniciarlo como `airflow2-webserver@default` y renombrar el archivo a `airflow_default.cfg`, o simplemente crear un enlace simbólico.

### Recomendación adicional: `AIRFLOW_HOME`

Si cada entorno tiene sus propios DAGs y bases de datos, lo más limpio es que cada uno tenga su propio `AIRFLOW_HOME`. Podrías añadir esta línea debajo de la definición de `AIRFLOW_CONFIG`:

```bash
Environment="AIRFLOW_HOME=/opt/airflow/airflow_2.9.3/%i"
```

Esto requeriría que tengas carpetas llamadas `/opt/airflow/airflow_2.9.3/dev`, `/opt/airflow/airflow_2.9.3/pro`, etc.

---
## 15. Conclusión

Con esta configuración:

- Airflow queda **integrado de forma nativa** al sistema.
- Los servicios son **robustos, supervisados y auto-reiniciables**.
- Los logs están centralizados en `journald`.
- La arquitectura es **escalable y profesional**.

Este es el punto donde Airflow deja de ser “un proceso en una terminal” y pasa a comportarse como **un servicio serio de plataforma de datos**.
