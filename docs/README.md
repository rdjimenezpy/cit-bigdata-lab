<p align="center">
	<img src="../assets/logos/cit-two.png" alt="Logo institucional CIT-UNA">
</p>

# README de subcarpeta: docs
**Documentación técnica, tutoriales operativos y hojas de referencia rápida del repositorio base CIT · Big Data · Lab**

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

- **Fecha:** 24/03/2026
- **Versión:** 1.0

---

## Propósito

Este documento describe el propósito, alcance, estructura y reglas básicas de uso de la subcarpeta **`docs/`**, con el fin de centralizar la documentación técnica del repositorio, facilitar la navegación académica y operativa, y orientar a docentes y estudiantes en el uso correcto de tutoriales, cheatsheets y material de apoyo documental.

---

## Alcance

**Ruta de referencia:** `docs/`  
**Tipo de contenido esperado:** documentación técnica, tutoriales, cheatsheets, guías operativas y notas de soporte  
**Nivel de uso:** general / laboratorio / soporte  
**Estado esperado de los archivos:** base / validado / en evolución  

---

## ¿Qué contiene esta subcarpeta?

En esta ubicación se almacenan archivos relacionados con:

- documentación operativa de instalación y configuración del entorno base;
- tutoriales paso a paso para herramientas del stack técnico del laboratorio;
- cheatsheets de comandos de uso frecuente;
- material textual de apoyo para clases, laboratorios y actividades reproducibles.

---

## Estructura interna esperada

```text
docs/
├── cheatsheet/
│   ├── 01_wsl2_comandos_basicos.md
│   ├── 02_ubuntu_administracion_basica.md
│   ├── 03_python_pyenv_venv.md
│   ├── 04_git_github_flujo_basico.md
│   ├── 05_postgresql_15_administracion_basica.md
│   └── 06_duckdb_comandos_esenciales.md
├── tutoriales/
│   ├── 01_instalacion_wsl2_ubuntu.md
│   ├── 02_instalacion_python_3_12_5_pyenv.md
│   ├── 03_instalacion_postgresql_15_wsl2_ubuntu.md
│   ├── 04_instalacion_postgresql_15_windows.md
│   └── 05_instalacion_duckdb_wsl2_ubuntu.md
└── README.md
```

**Descripción breve de la estructura:**

- `cheatsheet/` → hojas de referencia rápida con comandos, sintaxis y recordatorios operativos.
- `tutoriales/` → documentos paso a paso para instalación, configuración y uso base de herramientas del laboratorio.
- `README.md` → página de aterrizaje documental de la carpeta `docs/`.

---

## Convenciones de uso

- Usar nombres de archivos claros, técnicos y consistentes.
- Evitar espacios en blanco en nombres de archivos o carpetas.
- Preferir `snake_case` para archivos Markdown, SQL, YAML, JSON y scripts auxiliares.
- Mantener esta subcarpeta enfocada exclusivamente en documentación y material textual de apoyo.
- No almacenar credenciales, binarios pesados ni evidencia operativa volátil.
- Si se agregan nuevas subcarpetas relevantes, documentarlas también en este `README.md`.
- Procurar que cada documento tenga un propósito único y no duplique innecesariamente contenido ya existente.

---

## Reglas mínimas para agregar contenido

Antes de incorporar nuevos archivos a esta subcarpeta, verificar que:

1. el archivo corresponde realmente a documentación o material de apoyo del repositorio;
2. su nombre describe con claridad el contenido, la herramienta o el flujo documentado;
3. no contiene secretos, credenciales ni rutas locales sensibles;
4. no duplica documentación que ya existe en otra ubicación del proyecto;
5. el documento está alineado con la taxonomía general del repositorio y, cuando aplique, con los templates ubicados en `snippets/templates/`.

---

## Archivos o elementos recomendados

| Elemento | Obligatorio | Observación |
|---|---|---|
| `README.md` | Sí | Documento guía de la carpeta `docs/`. |
| `cheatsheet/` | Recomendado | Agrupa hojas de referencia rápida para uso operativo. |
| `tutoriales/` | Recomendado | Agrupa tutoriales paso a paso y guías de instalación/configuración. |
| `assets/` | Opcional | Solo si la documentación requiere recursos específicos locales de esta carpeta. |

---

## Qué no debería guardarse aquí

- archivos `.env`, credenciales o secretos del entorno;
- dumps, bases locales o datasets pesados de trabajo;
- capturas o evidencias temporales sin contexto documental;
- binarios o instaladores que pertenecen a otras carpetas del repositorio.

---

## Flujo de uso sugerido

```text
1. Revisar este README.md
2. Identificar si se necesita un tutorial, un cheatsheet o una guía específica
3. Entrar a la subcarpeta correspondiente
4. Mantener nombres y estructura consistentes al agregar nuevos documentos
5. Actualizar este README.md cuando cambie la estructura interna de docs/
```

---

## Relación con otras carpetas o documentos del repositorio

- README principal del proyecto: `README.md`
- Template asociado: `snippets/templates/readme_subcarpetas.md`
- Templates documentales relacionados: `snippets/templates/tutorial.md` y `snippets/templates/cheatsheet.md`
- Carpeta relacionada de recursos gráficos: `assets/`

---

## Notas de mantenimiento

- Este documento debe actualizarse cuando la subcarpeta `docs/` cambie de propósito, aumente su cobertura o incorpore nuevas líneas documentales.
- A medida que el repositorio evolucione, los subdirectorios principales de `docs/` podrán incorporar su propio `README.md` si su complejidad lo justifica.
- Este README no reemplaza la documentación técnica detallada de cada archivo; su función es servir como **página de aterrizaje documental** para este nivel del repositorio.

---

## Recomendación de uso del template

Este documento fue construido a partir del template `snippets/templates/readme_subcarpetas.md`. Debe mantenerse breve, claro y orientado a navegación.

Conviene conservar este `README.md` con estas características:

- **suficiente para orientar sin sobrecargar**;
- **alineado con la taxonomía real del repositorio**;
- **centrado en navegación, uso y mantenimiento**;
- **actualizable conforme crezcan los contenidos documentales**.

---

## Instrucciones de personalización futura

Si la carpeta `docs/` incorpora nuevas líneas documentales, conviene actualizar como mínimo:

- la sección **¿Qué contiene esta subcarpeta?**;
- la **Estructura interna esperada**;
- la relación con otras carpetas o documentos del repositorio;
- las reglas mínimas o restricciones específicas si aparecen nuevas necesidades de documentación.
