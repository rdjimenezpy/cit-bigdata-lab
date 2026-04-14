<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Tutorial paso a paso: {{TÍTULO DEL TUTORIAL}}
**{{Subtítulo técnico del tutorial / entorno / versión / alcance}}**

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

- **Fecha:** {{dd/mm/aaaa}}
- **Versión:** {{x.y}}

---

## Nota sobre esta documentación

Este tutorial fue elaborado y ajustado para el entorno técnico de referencia el curso básico de **Introducción a Big Data** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto y ejercicios prácticos del periodo académico **2026**.

Los pasos, comandos, rutas, capturas o salidas de consola presentados en este material fueron validados en un entorno de laboratorio controlado. No obstante, su reproducción en otros equipos puede requerir ajustes menores debido a diferencias en:

- sistema operativo y versión;
- configuración de red;
- permisos de usuario;
- políticas de seguridad institucional;
- versiones de software instaladas;
- y características específicas del hardware o del entorno local.

Por ello, ante diferencias puntuales durante la ejecución, se recomienda:

- leer cuidadosamente los mensajes del sistema;
- contrastar los pasos con la documentación oficial de la herramienta correspondiente;
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

{{Redactar un párrafo breve explicando qué herramienta, proceso o configuración se aborda en este tutorial, cuál es su propósito dentro del stack del proyecto y por qué resulta importante para la asignatura.}}

---

## 2. Objetivos

Al finalizar este tutorial, el estudiante será capaz de:

- {{Objetivo 1}}
- {{Objetivo 2}}
- {{Objetivo 3}}
- {{Objetivo 4}}

---

## 3. Alcance del tutorial

**Herramienta / componente principal:** {{nombre}}  
**Versión objetivo:** {{versión}}  
**Sistema operativo base:** {{ej. Windows 11 + WSL2 + Ubuntu 22.04.5 LTS}}  
**Entorno de trabajo:** {{ej. /opt/projects/bigdata-fpuna}}  
**IDE / cliente sugerido:** {{ej. PyCharm / DBeaver / terminal Bash}}  
**Tipo de uso:** {{instalación / configuración / despliegue / validación / administración básica}}  

### Este tutorial cubre

- {{Punto cubierto 1}}
- {{Punto cubierto 2}}
- {{Punto cubierto 3}}

### Este tutorial no cubre

- {{Punto no cubierto 1}}
- {{Punto no cubierto 2}}
- {{Punto no cubierto 3}}

---

## 4. Contexto técnico

{{Explicar brevemente dónde encaja esta herramienta o procedimiento dentro del stack del proyecto BIGDATA-FPUNA. Puede incluir su relación con PostgreSQL, DuckDB, Pentaho, Airflow, Python, Git, DBeaver, PyCharm o el flujo de trabajo del laboratorio.}}

---

## 5. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- {{Requisito previo 1}}
- {{Requisito previo 2}}
- {{Requisito previo 3}}
- {{Requisito previo 4}}

### Verificaciones rápidas

```bash
{{comando de verificación 1}}
{{comando de verificación 2}}
{{comando de verificación 3}}
```

---

## 6. Arquitectura o flujo de referencia

{{Explicar en texto o lista breve el flujo lógico asociado al tutorial. Si aplica, describir el orden de interacción entre componentes.}}

Ejemplo:

- {{Componente o etapa 1}}
- {{Componente o etapa 2}}
- {{Componente o etapa 3}}
- {{Componente o etapa 4}}

---

## 7. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno del proyecto.
- `{{valor}}` → dato que debe ser reemplazado por el usuario.
- `# comentario` → explicación breve dentro de un bloque de ejemplo.
- `SQL`, `Bash`, `Python`, `YAML`, `INI` → lenguajes o formatos utilizados en ejemplos.

---

## 8. Procedimiento paso a paso

### Paso 1 — {{Título del paso}}

**Objetivo del paso:** {{Explicar qué se busca lograr en este paso.}}

**Instrucciones:**

```bash
{{comando o bloque principal}}
```

**Explicación técnica:**  
{{Explicar qué hace el comando, por qué se ejecuta y qué efecto tiene en el entorno.}}

**Resultado esperado:**  
{{Describir la salida o estado esperado luego de este paso.}}

---

### Paso 2 — {{Título del paso}}

**Objetivo del paso:** {{Explicar qué se busca lograr en este paso.}}

**Instrucciones:**

```bash
{{comando o bloque principal}}
```

**Explicación técnica:**  
{{Explicar qué hace el comando, por qué se ejecuta y qué efecto tiene en el entorno.}}

**Resultado esperado:**  
{{Describir la salida o estado esperado luego de este paso.}}

---

### Paso 3 — {{Título del paso}}

**Objetivo del paso:** {{Explicar qué se busca lograr en este paso.}}

**Instrucciones:**

```bash
{{comando o bloque principal}}
```

**Explicación técnica:**  
{{Explicar qué hace el comando, por qué se ejecuta y qué efecto tiene en el entorno.}}

**Resultado esperado:**  
{{Describir la salida o estado esperado luego de este paso.}}

---

### Paso 4 — {{Título del paso}}

**Objetivo del paso:** {{Explicar qué se busca lograr en este paso.}}

**Instrucciones:**

```bash
{{comando o bloque principal}}
```

**Explicación técnica:**  
{{Explicar qué hace el comando, por qué se ejecuta y qué efecto tiene en el entorno.}}

**Resultado esperado:**  
{{Describir la salida o estado esperado luego de este paso.}}

---

### Paso N — {{Título del paso}}

**Objetivo del paso:** {{Explicar qué se busca lograr en este paso.}}

**Instrucciones:**

```bash
{{comando o bloque principal}}
```

**Explicación técnica:**  
{{Explicar qué hace el comando, por qué se ejecuta y qué efecto tiene en el entorno.}}

**Resultado esperado:**  
{{Describir la salida o estado esperado luego de este paso.}}

---

## 9. Validación del resultado

Al finalizar el procedimiento, verificar al menos lo siguiente:

- {{Validación 1}}
- {{Validación 2}}
- {{Validación 3}}

### Comandos de validación

```bash
{{comando de validación 1}}
{{comando de validación 2}}
{{comando de validación 3}}
```

### Evidencia esperada

{{Describir qué evidencia confirma que el procedimiento fue exitoso: salida de consola, archivo generado, servicio activo, conexión válida, script funcionando, DAG visible, etc.}}

---

## 10. Problemas frecuentes y soluciones

| Problema | Posible causa | Solución recomendada |
|---|---|---|
| {{Error 1}} | {{Causa 1}} | `{{Acción o comando}}` |
| {{Error 2}} | {{Causa 2}} | `{{Acción o comando}}` |
| {{Error 3}} | {{Causa 3}} | `{{Acción o comando}}` |
| {{Error 4}} | {{Causa 4}} | `{{Acción o comando}}` |

---

## 11. Buenas prácticas

- {{Buena práctica 1}}
- {{Buena práctica 2}}
- {{Buena práctica 3}}
- {{Buena práctica 4}}
- {{Buena práctica 5}}

---

## 12. Conclusión

{{Cerrar el documento con un párrafo breve que sintetice qué se logró, por qué este paso es importante dentro del stack del proyecto y cuál es el siguiente tutorial o componente recomendado.}}

---

## 13. Referencias

1. {{Autor u organización}}. **{{Título del recurso}}**.  
2. {{Autor u organización}}. **{{Título del recurso}}**.  
3. {{Autor u organización}}. **{{Título del recurso}}**.  
4. {{Autor u organización}}. **{{Título del recurso}}**.  

---

## Anexo opcional A — Comandos rápidos

```bash
{{comandos resumidos del tutorial}}
```

---

## Anexo opcional B — Estructura de rutas relevantes

```text
{{ruta_o_estructura}}
```

---

## Anexo opcional C — Archivos de configuración usados

### {{archivo_1}}

```ini
{{contenido_ejemplo}}
```

### {{archivo_2}}

```yaml
{{contenido_ejemplo}}
```
