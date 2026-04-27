<p align="center">
  <img src="../../assets/logos/cit-two.png" alt="Logo institucional CIT-UNA">
</p>

# README de subcarpeta: {{NOMBRE_DE_LA_CARPETA}}
**{{Descripción breve y técnica del propósito de esta subcarpeta}}**

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

---

## Propósito

Este documento describe el propósito, alcance, estructura y reglas básicas de uso de la subcarpeta **`{{ruta/subcarpeta}}`**, con el fin de facilitar la navegación del repositorio, mantener consistencia documental y orientar el trabajo técnico de docentes y estudiantes.

---

## Alcance

**Ruta de referencia:** `{{ruta/subcarpeta}}`  
**Tipo de contenido esperado:** {{scripts / notebooks / datos / configuraciones / plantillas / documentación / entregables}}  
**Nivel de uso:** {{general / laboratorio / soporte / interno}}  
**Estado esperado de los archivos:** {{base / borrador / validado / en evolución}}  

---

## ¿Qué contiene esta subcarpeta?

En esta ubicación se almacenan archivos relacionados con:

- {{tipo de contenido 1}}
- {{tipo de contenido 2}}
- {{tipo de contenido 3}}
- {{tipo de contenido 4}}

---

## Estructura interna esperada

```text
{{subcarpeta}}/
├── {{archivo_o_subcarpeta_1}}
├── {{archivo_o_subcarpeta_2}}
├── {{archivo_o_subcarpeta_3}}
└── README.md
```

**Descripción breve de la estructura:**

- `{{archivo_o_subcarpeta_1}}` → {{descripción}}
- `{{archivo_o_subcarpeta_2}}` → {{descripción}}
- `{{archivo_o_subcarpeta_3}}` → {{descripción}}
- `README.md` → guía breve para entender y usar correctamente esta ubicación.

---

## Convenciones de uso

- Usar nombres de archivos claros, técnicos y consistentes.
- Evitar espacios en blanco en nombres de archivos o carpetas.
- Preferir `snake_case` para archivos Markdown, SQL, YAML, JSON y scripts auxiliares.
- Mantener esta subcarpeta enfocada en un único propósito funcional.
- No almacenar archivos temporales, binarios prescindibles o credenciales.
- Si se agregan nuevas subcarpetas relevantes, documentarlas también en este `README.md`.

---

## Reglas mínimas para agregar contenido

Antes de incorporar nuevos archivos a esta subcarpeta, verificar que:

1. el archivo pertenece realmente a este nivel del repositorio;
2. su nombre describe con claridad el contenido o propósito;
3. no contiene secretos, credenciales ni rutas locales sensibles;
4. no duplica material que ya existe en otra carpeta;
5. su formato y ubicación son consistentes con la taxonomía general del repositorio.

---

## Archivos o elementos recomendados

| Elemento | Obligatorio | Observación |
|---|---|---|
| `README.md` | Sí | Documento guía de la subcarpeta. |
| `.gitkeep` | Opcional | Útil si se necesita conservar una carpeta vacía en Git. |
| `assets/` | Opcional | Solo si esta subcarpeta realmente necesita recursos auxiliares. |
| `examples/` | Opcional | Recomendado para muestras o plantillas reutilizables. |

---

## Qué no debería guardarse aquí

- {{contenido no permitido 1}}
- {{contenido no permitido 2}}
- {{contenido no permitido 3}}
- {{contenido no permitido 4}}

---

## Flujo de uso sugerido

```text
1. Revisar este README.md
2. Identificar el tipo de archivo a agregar o consultar
3. Validar si corresponde a esta subcarpeta
4. Mantener nombres y estructura consistentes
5. Actualizar este README.md si cambia la estructura interna
```

---

## Relación con otras carpetas o documentos del repositorio

- README principal del proyecto: `README.md`
- Template asociado: `snippets/templates/readme_subcarpetas.md`
- Documento relacionado 1: `{{ruta/documento_relacionado_1}}`
- Documento relacionado 2: `{{ruta/documento_relacionado_2}}`

---

## Notas de mantenimiento

- Este documento debe actualizarse cuando la subcarpeta cambie de propósito, crezca en complejidad o incorpore nuevas capas internas.
- Si la subcarpeta evoluciona lo suficiente, conviene agregar documentación complementaria específica en archivos separados.
- Este README no sustituye la documentación técnica detallada; solo cumple la función de **página de aterrizaje documental** para este nivel del repositorio.

---

## Recomendación de uso del template

Este template debe utilizarse cuando una subcarpeta del repositorio necesite una explicación breve pero estructurada. Su objetivo no es repetir el `README.md` principal, sino documentar el propósito local de una carpeta concreta.

Conviene mantener este tipo de README con estas características:

- **breve, pero suficiente para orientar**;
- **alineado con la taxonomía del repositorio**;
- **sin teoría innecesaria**;
- **con foco en navegación, uso y mantenimiento**.

---

## Instrucciones de personalización rápida

Reemplazar los marcadores `{{...}}` por información real de la subcarpeta. En particular:

- `{{RUTA_RELATIVA_AL_LOGO}}` según la profundidad del archivo;
- `{{NOMBRE_DE_LA_CARPETA}}` por el nombre funcional del directorio;
- `{{ruta/subcarpeta}}` por la ruta relativa real;
- `{{archivo_o_subcarpeta_n}}` por los elementos más representativos;
- `{{contenido no permitido n}}` por restricciones reales si aplica.

Si la subcarpeta es muy simple, pueden omitirse secciones no críticas, pero no debería omitirse:

- **Propósito**
- **¿Qué contiene esta subcarpeta?**
- **Estructura interna esperada**
- **Relación con otras carpetas o documentos del repositorio**

