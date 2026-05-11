<p align="center">
  <img src="../../assets/logos/cit-one.png" alt="Logo institucional CIT-UNA">
</p>

# Manual profesional: {{TÍTULO DEL MANUAL}}
**{{Subtítulo técnico del manual · herramienta/proceso · versión · entorno de referencia}}**

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

- **Fecha:** {{dd/mm/aaaa}}
- **Versión:** {{x.y}}
- **Documento base ajustado:** `{{documento_base.md}}`
- **Tutorial o guía de referencia:** `{{tutorial_referencia.md}}`
- **Ruta sugerida en el repositorio:** `{{docs/.../manual.md}}`

---

## Control de cambios

| Versión | Fecha | Responsable | Descripción del cambio |
|---|---:|---|---|
| 1.0 | {{dd/mm/aaaa}} | {{autor}} | Versión inicial del manual. |
| {{x.y}} | {{dd/mm/aaaa}} | {{autor}} | {{Descripción breve del ajuste.}} |

---

## Nota sobre esta documentación

Este manual fue elaborado para el entorno técnico de referencia del curso **{{nombre_del_curso}}** del **Centro de Innovación TIC (PK)** de la **Facultad Politécnica de la Universidad Nacional de Asunción**, en el marco del desarrollo de laboratorios, pruebas de concepto, ejercicios prácticos y documentación técnica del periodo académico **{{año}}**.

El documento debe interpretarse como una guía **operativa, académica y técnica** para administrar, utilizar o diagnosticar **{{herramienta/proceso/componente}}** en un entorno controlado de laboratorio. No reemplaza la documentación oficial del fabricante o proyecto; la complementa con una estructura didáctica, comandos validados y criterios de operación profesional.

Los comandos, rutas, parámetros, capturas o salidas esperadas presentadas en este material deben ajustarse cuando cambie alguno de los siguientes elementos:

- sistema operativo;
- versión de la herramienta;
- versión de Python, Java, base de datos u otro runtime;
- rutas de instalación;
- usuario Linux o Windows utilizado;
- configuración de red;
- permisos institucionales;
- política de seguridad;
- arquitectura de despliegue;
- tipo de executor, backend, motor o proveedor externo.

> **Advertencia técnica:** este manual puede describir operaciones administrativas sensibles. Antes de ejecutar comandos destructivos, migraciones, reinicios, borrados o cambios de seguridad, validar el entorno, respaldar la configuración y confirmar que se trabaja sobre la instancia correcta.

---

## Tabla de contenido

1. [Introducción](#1-introducción)  
2. [Objetivos](#2-objetivos)  
3. [Alcance del manual](#3-alcance-del-manual)  
4. [Contexto técnico y operativo](#4-contexto-técnico-y-operativo)  
5. [Arquitectura o flujo de referencia](#5-arquitectura-o-flujo-de-referencia)  
6. [Entorno de referencia](#6-entorno-de-referencia)  
7. [Requisitos previos](#7-requisitos-previos)  
8. [Convenciones usadas en el documento](#8-convenciones-usadas-en-el-documento)  
9. [Preparación obligatoria antes de operar](#9-preparación-obligatoria-antes-de-operar)  
10. [Mapa general de comandos, componentes o procedimientos](#10-mapa-general-de-comandos-componentes-o-procedimientos)  
11. [Procedimientos operativos principales](#11-procedimientos-operativos-principales)  
12. [Procedimientos de administración avanzada](#12-procedimientos-de-administración-avanzada)  
13. [Validación del resultado](#13-validación-del-resultado)  
14. [Supervisión, monitoreo y diagnóstico](#14-supervisión-monitoreo-y-diagnóstico)  
15. [Consultas técnicas o comandos de inspección](#15-consultas-técnicas-o-comandos-de-inspección)  
16. [Seguridad operativa](#16-seguridad-operativa)  
17. [Problemas frecuentes y soluciones](#17-problemas-frecuentes-y-soluciones)  
18. [Buenas prácticas profesionales](#18-buenas-prácticas-profesionales)  
19. [Checklist de cierre](#19-checklist-de-cierre)  
20. [Conclusión](#20-conclusión)  
21. [Referencias](#21-referencias)  
22. [Anexo A — Cheatsheet operativo](#anexo-a--cheatsheet-operativo)  
23. [Anexo B — Comandos sensibles o destructivos](#anexo-b--comandos-sensibles-o-destructivos)  
24. [Anexo C — Plantilla rápida para nuevos manuales](#anexo-c--plantilla-rápida-para-nuevos-manuales)  

---

## 1. Introducción

{{Redactar una explicación clara sobre la herramienta, componente, proceso o conjunto de comandos que cubre el manual. Indicar qué problema resuelve, por qué es importante en ingeniería de datos y cómo se relaciona con los laboratorios del curso.}}

Un manual profesional no debe limitarse a listar comandos. Debe explicar:

- qué se administra;
- para qué sirve cada operación;
- qué efecto tiene en el sistema;
- qué evidencia confirma que funcionó;
- qué riesgos existen;
- y qué hacer cuando falla.

En el contexto de **{{curso/proyecto}}**, este manual permite que el estudiante u operador comprenda la diferencia entre ejecutar instrucciones de forma mecánica y administrar una plataforma de datos con criterio técnico.

---

## 2. Objetivos

Al finalizar este manual, el estudiante u operador será capaz de:

- {{Objetivo 1: activar/preparar correctamente el entorno de trabajo.}}
- {{Objetivo 2: ejecutar comandos o procedimientos principales de la herramienta.}}
- {{Objetivo 3: validar configuración, conectividad o estado operacional.}}
- {{Objetivo 4: diagnosticar problemas frecuentes con evidencia técnica.}}
- {{Objetivo 5: aplicar buenas prácticas de seguridad, reproducibilidad y operación.}}
- {{Objetivo 6: documentar ajustes locales o decisiones técnicas realizadas.}}

---

## 3. Alcance del manual

**Herramienta / componente principal:** {{nombre_herramienta}}  
**Versión objetivo:** {{versión}}  
**Sistema operativo base:** {{ej. Windows 11 + WSL2 + Ubuntu 22.04.5 LTS}}  
**Runtime principal:** {{ej. Python 3.12.5 / Java 17 / Node.js / otro}}  
**Base de datos / motor / servicio asociado:** {{ej. PostgreSQL 15 / DuckDB / MotherDuck / etc.}}  
**Entorno de trabajo:** `{{ruta_base}}`  
**Archivo de configuración principal:** `{{ruta_configuracion}}`  
**Archivo de entorno:** `{{ruta_env}}`  
**Alias o comando de activación:** `{{alias}}`  
**Tipo de uso:** {{administración / operación / diagnóstico / instalación / desarrollo / laboratorio}}  

### Este manual cubre

- {{Punto cubierto 1}}
- {{Punto cubierto 2}}
- {{Punto cubierto 3}}
- {{Punto cubierto 4}}
- {{Punto cubierto 5}}

### Este manual no cubre

- {{Punto no cubierto 1}}
- {{Punto no cubierto 2}}
- {{Punto no cubierto 3}}
- {{Punto no cubierto 4}}

### Perfil de usuario esperado

Este manual está orientado a:

- estudiantes de **{{curso}}**;
- instructores o auxiliares de laboratorio;
- operadores técnicos de entornos académicos;
- perfiles iniciales de ingeniería de datos;
- usuarios que necesitan una referencia reproducible para administrar **{{herramienta}}**.

---

## 4. Contexto técnico y operativo

{{Explicar dónde encaja la herramienta dentro del stack del proyecto o laboratorio. Relacionar con pipelines, ingesta, almacenamiento, transformación, orquestación, modelado, calidad de datos, visualización o despliegue, según corresponda.}}

Ejemplo de redacción:

> Dentro del stack académico de Big Data, **{{herramienta}}** cumple el rol de **{{rol_técnico}}**. Su responsabilidad no es reemplazar a las demás herramientas, sino integrarse con ellas para resolver una etapa específica del ciclo de vida de los datos.

Un flujo típico del laboratorio puede ser:

1. {{Etapa 1}}
2. {{Etapa 2}}
3. {{Etapa 3}}
4. {{Etapa 4}}
5. {{Etapa 5}}
6. {{Etapa 6}}

### Diferencias relevantes frente a versiones anteriores

| Aspecto | Versión anterior / enfoque previo | Versión objetivo / enfoque actual |
|---|---|---|
| {{Aspecto 1}} | {{Antes}} | {{Ahora}} |
| {{Aspecto 2}} | {{Antes}} | {{Ahora}} |
| {{Aspecto 3}} | {{Antes}} | {{Ahora}} |
| {{Aspecto 4}} | {{Antes}} | {{Ahora}} |

> **Regla profesional:** si una práctica fue aprendida en una versión anterior, no asumir que sigue siendo válida. Primero validar contra la versión instalada y la documentación oficial.

---

## 5. Arquitectura o flujo de referencia

{{Describir la arquitectura lógica asociada al manual. Puede ser un flujo de servicios, comandos, archivos, bases de datos, rutas o componentes.}}

```text
{{Usuario / Operador}}
        │
        ├── {{CLI / Interfaz / Script}}
        ├── {{Servicio 1}}
        ├── {{Servicio 2}}
        ├── {{Servicio 3}}
        │
        └── {{Base de datos / almacenamiento / recurso externo}}
```

### Componentes principales

| Componente | Comando / archivo / servicio | Función principal |
|---|---|---|
| {{Componente 1}} | `{{comando_o_ruta}}` | {{Descripción}} |
| {{Componente 2}} | `{{comando_o_ruta}}` | {{Descripción}} |
| {{Componente 3}} | `{{comando_o_ruta}}` | {{Descripción}} |
| {{Componente 4}} | `{{comando_o_ruta}}` | {{Descripción}} |

---

## 6. Entorno de referencia

Este manual asume el siguiente entorno de referencia:

| Elemento | Valor de referencia |
|---|---|
| Sistema operativo host | `{{Windows 11 / Linux / macOS}}` |
| Entorno Linux | `{{WSL2 Ubuntu 22.04.5 LTS / servidor Linux / otro}}` |
| Usuario del sistema | `{{usuario}}` |
| Herramienta principal | `{{herramienta}} {{versión}}` |
| Runtime | `{{Python/Java/Node/etc.}} {{versión}}` |
| Base de datos | `{{PostgreSQL/DuckDB/etc.}} {{versión}}` |
| Ruta base | `{{ruta_base}}` |
| Archivo de configuración | `{{ruta_config}}` |
| Archivo de entorno | `{{ruta_env}}` |
| Puerto principal | `{{puerto}}` |
| Alias de activación | `{{alias}}` |

### Variables de referencia

| Variable | Valor |
|---|---|
| `{{VARIABLE_1}}` | `{{valor_1}}` |
| `{{VARIABLE_2}}` | `{{valor_2}}` |
| `{{VARIABLE_3}}` | `{{valor_3}}` |
| `{{VARIABLE_4}}` | `{{valor_4}}` |

---

## 7. Requisitos previos

Antes de comenzar, verificar que se dispone de lo siguiente:

- {{Requisito 1}}
- {{Requisito 2}}
- {{Requisito 3}}
- {{Requisito 4}}
- {{Requisito 5}}

### Verificaciones rápidas

```bash
{{comando_verificacion_1}}
{{comando_verificacion_2}}
{{comando_verificacion_3}}
{{comando_verificacion_4}}
```

### Resultado esperado

```text
{{salida_esperada_1}}
{{salida_esperada_2}}
{{salida_esperada_3}}
```

### Dependencias básicas del sistema

```bash
{{comando_instalacion_dependencias}}
```

**Explicación técnica:**  
{{Explicar por qué se requieren estas dependencias y qué falla si no están instaladas.}}

---

## 8. Convenciones usadas en el documento

- `comando` → instrucción a ejecutar en terminal, consola o CLI.
- `ruta/archivo` → ruta absoluta o relativa dentro del entorno de trabajo.
- `{{valor}}` → valor que debe ser reemplazado por el usuario.
- `SQL` → sentencia a ejecutar en una base de datos.
- `INI`, `YAML`, `JSON`, `TOML`, `ENV` → formatos de configuración.
- `LAB`, `DEV`, `DES`, `PRE`, `PRO` → nombres lógicos de entornos.
- **Resultado esperado** → evidencia mínima para considerar correcto el paso.
- **Advertencia técnica** → riesgo, condición o restricción que debe leerse antes de ejecutar.

### Criterios de escritura para nuevos manuales

- Usar comandos completos, no fragmentos ambiguos.
- Explicar el propósito antes del comando.
- Incluir resultado esperado después del comando.
- Separar comandos seguros de comandos destructivos.
- Evitar credenciales reales.
- No asumir rutas, usuarios o puertos sin declararlos.
- Mantener consistencia entre título, versión, entorno, comandos y referencias.

---

## 9. Preparación obligatoria antes de operar

**Objetivo:** asegurar que el operador está ubicado en el entorno correcto antes de ejecutar comandos administrativos.

### Paso 1 — Activar entorno o cargar configuración

```bash
{{comando_activacion_entorno}}
```

### Paso 2 — Cargar variables de entorno

```bash
set -a
source {{ruta_archivo_env}}
set +a
```

### Paso 3 — Verificar binarios y rutas efectivas

```bash
which {{binario_principal}}
{{binario_principal}} --version

echo "{{VARIABLE_HOME}}=${{VARIABLE_HOME}}"
echo "{{VARIABLE_CONFIG}}=${{VARIABLE_CONFIG}}"
```

### Resultado esperado

```text
{{ruta_esperada_binario}}
{{version_esperada}}
{{ruta_home_esperada}}
{{ruta_config_esperada}}
```

> **Advertencia técnica:** si el binario no apunta al entorno esperado, detenerse. Ejecutar comandos administrativos desde el entorno equivocado puede afectar otra instalación.

---

## 10. Mapa general de comandos, componentes o procedimientos

{{Presentar una tabla general de los comandos, grupos o procedimientos principales. Esta sección debe funcionar como mapa operativo del manual.}}

| Grupo / Comando / Procedimiento | Propósito | Riesgo operativo | Uso típico |
|---|---|---:|---|
| `{{comando_1}}` | {{Descripción}} | Bajo | {{Uso}} |
| `{{comando_2}}` | {{Descripción}} | Bajo | {{Uso}} |
| `{{comando_3}}` | {{Descripción}} | Medio | {{Uso}} |
| `{{comando_4}}` | {{Descripción}} | Alto | {{Uso}} |

### Comandos de ayuda

```bash
{{binario_principal}} --help
{{binario_principal}} {{grupo}} --help
{{binario_principal}} {{grupo}} {{subcomando}} --help
```

**Criterio profesional:** antes de usar un comando nuevo, consultar su ayuda específica. Esto reduce errores y confirma opciones disponibles en la versión instalada.

---

## 11. Procedimientos operativos principales

### 11.1 {{Nombre del procedimiento 1}}

**Propósito:**  
{{Explicar qué permite hacer este procedimiento.}}

**Cuándo usarlo:**

- {{Caso 1}}
- {{Caso 2}}
- {{Caso 3}}

**Comandos:**

```bash
{{comando_1}}
{{comando_2}}
{{comando_3}}
```

**Resultado esperado:**

```text
{{salida_esperada}}
```

**Interpretación:**  
{{Explicar cómo leer la salida y qué indica éxito, advertencia o error.}}

---

### 11.2 {{Nombre del procedimiento 2}}

**Propósito:**  
{{Explicar qué permite hacer este procedimiento.}}

**Comandos:**

```bash
{{comando_1}}
{{comando_2}}
```

**Resultado esperado:**

```text
{{salida_esperada}}
```

**Errores comunes:**

| Error | Causa probable | Acción recomendada |
|---|---|---|
| `{{error_1}}` | {{causa}} | `{{comando_solucion}}` |
| `{{error_2}}` | {{causa}} | {{acción}} |

---

### 11.3 {{Nombre del procedimiento 3}}

**Propósito:**  
{{Explicar qué permite hacer este procedimiento.}}

**Comandos:**

```bash
{{comando_1}}
{{comando_2}}
```

**Resultado esperado:**

```text
{{salida_esperada}}
```

**Observación crítica:**  
{{Incluir una advertencia o criterio técnico importante.}}

---

## 12. Procedimientos de administración avanzada

### 12.1 {{Procedimiento avanzado 1}}

**Propósito:**  
{{Descripción.}}

**Nivel de riesgo:** {{Bajo / Medio / Alto}}

**Precondiciones:**

- {{Precondición 1}}
- {{Precondición 2}}
- {{Precondición 3}}

**Comandos:**

```bash
{{comando_avanzado_1}}
{{comando_avanzado_2}}
```

**Validación posterior:**

```bash
{{comando_validacion}}
```

---

### 12.2 {{Procedimiento avanzado 2}}

**Propósito:**  
{{Descripción.}}

**Comandos:**

```bash
{{comando_avanzado_1}}
{{comando_avanzado_2}}
```

**Criterio de reversión:**  
{{Explicar cómo revertir o recuperar el estado anterior si corresponde.}}

---

## 13. Validación del resultado

Al finalizar los procedimientos principales, validar al menos lo siguiente:

- {{Validación 1}}
- {{Validación 2}}
- {{Validación 3}}
- {{Validación 4}}
- {{Validación 5}}

### Comandos de validación

```bash
{{comando_validacion_1}}
{{comando_validacion_2}}
{{comando_validacion_3}}
{{comando_validacion_4}}
```

### Evidencia esperada

```text
{{evidencia_1}}
{{evidencia_2}}
{{evidencia_3}}
```

### Criterio de aceptación

El procedimiento se considera exitoso si:

- {{Criterio 1}}
- {{Criterio 2}}
- {{Criterio 3}}

---

## 14. Supervisión, monitoreo y diagnóstico

### 14.1 Verificación de procesos

```bash
{{comando_procesos_1}}
{{comando_procesos_2}}
```

### 14.2 Verificación de puertos

```bash
{{comando_puertos_1}}
{{comando_puertos_2}}
```

### 14.3 Verificación de logs

```bash
{{comando_logs_1}}
{{comando_logs_2}}
{{comando_logs_3}}
```

### 14.4 Health check o prueba funcional

```bash
{{comando_healthcheck}}
```

### Resultado esperado

```text
{{resultado_healthcheck}}
```

### Interpretación rápida

| Evidencia | Interpretación | Acción recomendada |
|---|---|---|
| {{Evidencia 1}} | {{Interpretación}} | {{Acción}} |
| {{Evidencia 2}} | {{Interpretación}} | {{Acción}} |
| {{Evidencia 3}} | {{Interpretación}} | {{Acción}} |

---

## 15. Consultas técnicas o comandos de inspección

Esta sección debe incluir comandos o consultas que ayuden a inspeccionar el estado interno de la herramienta, base de datos o servicio.

### 15.1 Consulta o inspección general

```bash
{{comando_inspeccion}}
```

### 15.2 Consulta SQL opcional

```sql
-- {{Descripción de la consulta}}
SELECT
    {{campo_1}},
    {{campo_2}},
    {{campo_3}}
FROM {{tabla}}
WHERE {{condicion}}
ORDER BY {{campo}} DESC;
```

### 15.3 Diagnóstico de duplicados, inconsistencias o errores

```sql
-- {{Descripción del diagnóstico}}
SELECT
    {{campo_agrupacion}},
    COUNT(*) AS total
FROM {{tabla}}
GROUP BY {{campo_agrupacion}}
HAVING COUNT(*) > 1
ORDER BY total DESC;
```

> **Advertencia técnica:** si se consulta una base de datos interna de una herramienta, hacerlo preferentemente en modo lectura. No ejecutar `UPDATE`, `DELETE`, `TRUNCATE` o `DROP` sobre tablas internas sin documentación oficial y respaldo previo.

---

## 16. Seguridad operativa

### 16.1 Principios mínimos

- No publicar credenciales reales en manuales, repositorios o capturas.
- No almacenar contraseñas en texto plano salvo en entornos estrictamente didácticos y controlados.
- No ejecutar comandos destructivos sin respaldo.
- No usar usuarios administradores para tareas rutinarias si existe alternativa con menor privilegio.
- No compartir archivos `.env` reales.
- No versionar secretos.
- Revisar permisos de archivos sensibles.

### 16.2 Archivos sensibles

| Archivo / recurso | Riesgo | Recomendación |
|---|---|---|
| `{{archivo_env}}` | Puede contener credenciales | Permisos `600`, excluir de Git. |
| `{{archivo_config}}` | Puede contener endpoints o claves | Revisar antes de compartir. |
| `{{logs}}` | Puede exponer rutas, tokens o errores internos | No publicar sin sanitizar. |
| `{{backup}}` | Puede contener datos sensibles | Cifrar o proteger acceso. |

### 16.3 Comandos que requieren revisión previa

| Comando | Riesgo | Revisión requerida |
|---|---|---|
| `{{comando_destructivo_1}}` | {{Riesgo}} | {{Validación previa}} |
| `{{comando_destructivo_2}}` | {{Riesgo}} | {{Validación previa}} |
| `{{comando_destructivo_3}}` | {{Riesgo}} | {{Validación previa}} |

---

## 17. Problemas frecuentes y soluciones

| Problema | Posible causa | Diagnóstico | Solución recomendada |
|---|---|---|---|
| {{Problema 1}} | {{Causa probable}} | `{{comando_diagnostico}}` | `{{comando_solucion}}` |
| {{Problema 2}} | {{Causa probable}} | `{{comando_diagnostico}}` | {{Acción}} |
| {{Problema 3}} | {{Causa probable}} | `{{comando_diagnostico}}` | {{Acción}} |
| {{Problema 4}} | {{Causa probable}} | `{{comando_diagnostico}}` | {{Acción}} |

### Procedimiento general de diagnóstico

Cuando ocurra un error:

1. Confirmar la versión instalada.
2. Confirmar el entorno activo.
3. Revisar variables de entorno.
4. Revisar logs recientes.
5. Ejecutar comando de health check.
6. Reproducir el error con el comando mínimo.
7. Documentar mensaje exacto, fecha, hora, comando y salida.
8. Aplicar solución controlada.
9. Validar nuevamente.

---

## 18. Buenas prácticas profesionales

- Mantener estructura de directorios consistente entre herramientas y versiones.
- Separar instalación, configuración, operación y diagnóstico en secciones distintas.
- Usar nombres de archivos claros y versionados.
- Incluir siempre comandos de validación.
- No ocultar advertencias técnicas relevantes.
- Evitar instrucciones ambiguas como “ejecutar lo anterior” sin comando exacto.
- Documentar diferencias entre versiones.
- Señalar explícitamente qué comandos son seguros y cuáles son sensibles.
- Mantener el manual alineado con el tutorial de instalación correspondiente.
- Verificar que las rutas del manual existan realmente en el entorno de referencia.
- Incluir referencias oficiales al final.
- Usar ejemplos académicos realistas, no ejemplos genéricos sin contexto.

### Criterios de calidad para aprobar un manual técnico

| Criterio | Cumple | Observación |
|---|:---:|---|
| Tiene datos institucionales completos | ☐ |  |
| Declara versión objetivo de la herramienta | ☐ |  |
| Declara entorno de referencia | ☐ |  |
| Incluye alcance y exclusiones | ☐ |  |
| Incluye comandos reproducibles | ☐ |  |
| Incluye resultado esperado | ☐ |  |
| Incluye advertencias de seguridad | ☐ |  |
| Incluye problemas frecuentes | ☐ |  |
| Incluye buenas prácticas | ☐ |  |
| Incluye referencias oficiales | ☐ |  |

---

## 19. Checklist de cierre

Antes de publicar o entregar este manual, verificar:

- [ ] El título coincide con la herramienta, versión y alcance.
- [ ] La fecha y versión del documento están actualizadas.
- [ ] Las rutas corresponden al entorno real.
- [ ] Los comandos fueron revisados en el entorno de referencia.
- [ ] Las salidas esperadas son coherentes con la versión usada.
- [ ] No hay credenciales reales.
- [ ] No hay referencias a versiones antiguas que generen confusión.
- [ ] Los comandos destructivos están marcados como sensibles.
- [ ] La tabla de contenido coincide con las secciones reales.
- [ ] Las referencias apuntan a documentación oficial o fuentes confiables.
- [ ] El documento puede copiarse al repositorio sin archivos auxiliares obligatorios.

---

## 20. Conclusión

{{Redactar una conclusión breve que explique qué competencia técnica queda cubierta con el manual y cuál es el siguiente paso recomendado.}}

Ejemplo:

> Con este manual, el estudiante dispone de una referencia base para operar **{{herramienta}}** de forma controlada, reproducible y técnicamente justificada. El valor principal no está solo en ejecutar comandos, sino en comprender su propósito, validar sus efectos y documentar correctamente cualquier ajuste realizado en el entorno.

Siguiente paso recomendado:

- {{Siguiente paso 1}}
- {{Siguiente paso 2}}
- {{Siguiente paso 3}}

---

## 21. Referencias

1. {{Autor o proyecto}}. **{{Título de la documentación oficial}}**.  
   {{URL}}

2. {{Autor o proyecto}}. **{{Guía de instalación / administración / CLI}}**.  
   {{URL}}

3. {{Autor o proyecto}}. **{{Release notes / changelog / referencia técnica}}**.  
   {{URL}}

4. {{Referencia interna del curso}}. **{{Nombre del tutorial relacionado}}**.  
   `{{ruta_del_documento}}`

---

## Anexo A — Cheatsheet operativo

```bash
# Activar entorno
{{comando_activar_entorno}}

# Cargar variables
set -a
source {{ruta_archivo_env}}
set +a

# Ver versión
{{binario_principal}} --version

# Ver ayuda
{{binario_principal}} --help

# Validar estado básico
{{comando_validacion_basica}}

# Ver configuración
{{comando_configuracion}}

# Ver procesos
{{comando_procesos}}

# Ver logs
{{comando_logs}}

# Ejecutar health check
{{comando_healthcheck}}
```

---

## Anexo B — Comandos sensibles o destructivos

> Esta sección debe completarse siempre que el manual incluya operaciones que puedan borrar datos, reiniciar servicios, cambiar credenciales, alterar esquemas, eliminar ejecuciones, modificar permisos o afectar disponibilidad.

| Comando | Qué hace | Riesgo | Ejecutar solo si... |
|---|---|---|---|
| `{{comando_sensible_1}}` | {{Descripción}} | Alto | {{Condición}} |
| `{{comando_sensible_2}}` | {{Descripción}} | Alto | {{Condición}} |
| `{{comando_sensible_3}}` | {{Descripción}} | Medio | {{Condición}} |

### Plantilla de confirmación previa

Antes de ejecutar un comando sensible, registrar:

```text
Fecha/hora:
Responsable:
Entorno afectado:
Comando a ejecutar:
Motivo:
Backup disponible: sí/no
Plan de reversión:
Evidencia posterior esperada:
```

---

## Anexo C — Plantilla rápida para nuevos manuales

Usar esta versión reducida cuando se necesite crear un manual corto:

```markdown
# Manual profesional: {{Título}}
**{{Subtítulo técnico}}**

## Datos institucionales

**Institución:** Universidad Nacional de Asunción  
**Unidad Académica:** Facultad Politécnica  
**Dependencia:** Centro de Innovación TIC (PK)  
**Curso:** {{Curso}}  
**Docente:** Ing. Richard D. Jiménez-R.  

## Fecha y versión

- **Fecha:** {{dd/mm/aaaa}}
- **Versión:** {{x.y}}

## 1. Introducción

{{Descripción breve.}}

## 2. Objetivos

- {{Objetivo 1}}
- {{Objetivo 2}}
- {{Objetivo 3}}

## 3. Alcance

**Herramienta:** {{herramienta}}  
**Versión:** {{versión}}  
**Entorno:** {{entorno}}  

## 4. Requisitos previos

- {{Requisito 1}}
- {{Requisito 2}}

## 5. Procedimiento

### Paso 1 — {{Título}}

```bash
{{comando}}
```

**Resultado esperado:** {{resultado}}

### Paso 2 — {{Título}}

```bash
{{comando}}
```

**Resultado esperado:** {{resultado}}

## 6. Validación

```bash
{{comando_validacion}}
```

## 7. Problemas frecuentes

| Problema | Causa | Solución |
|---|---|---|
| {{Problema}} | {{Causa}} | {{Solución}} |

## 8. Buenas prácticas

- {{Buena práctica 1}}
- {{Buena práctica 2}}

## 9. Referencias

1. {{Referencia}}
```

---

## Anexo D — Recomendación de nombre y ubicación del archivo

Para mantener consistencia documental en el repositorio del curso, se recomienda usar la siguiente convención:

```text
docs/
└── {{numero_categoria}}_{{categoria}}/
    └── {{herramienta_o_tema}}/
        ├── manual.md
        ├── tutorial_instalacion.md
        ├── tutorial_supervision.md
        └── README.md
```

Ejemplo:

```text
docs/
└── 02_herramientas/
    └── apache_airflow/
        ├── manual.md
        ├── 09_tutorial_instalacion_configuracion_apache_airflow_3_2_1.md
        ├── 10_tutorial_supervision_servicios_airflow_3_2_1_systemd.md
        └── 11_manual_comandos_airflow_cli_3_2_1.md
```
