### Categorías de scripts y nombres sugeridos

#### 1. **Diagnóstico y revisión de datos**
Scripts que inspeccionan calidad, formatos, duplicados, nulos, outliers, etc.

- `chk_datos_fuente.sql` → revisión inicial de datos crudos
- `val_documentos_identidad.sql` → validación de documentos
- `aud_fecha_nacimiento.sql` → auditoría de fechas
- `chk_nulos_nomina.sql` → chequeo de campos críticos

#### 2. **Análisis exploratorio**
Scripts que ayudan a entender la distribución, frecuencia, correlaciones o agrupaciones.

- `eda_nomina.sql` → análisis exploratorio de la nómina
- `freq_fuente_financiamiento.sql` → frecuencia por fuente
- `dist_sexo_cargo.sql` → distribución cruzada de sexo y cargo
- `outliers_presupuestado.sql` → detección de valores extremos

#### 3. **Comparación y validación cruzada**
Scripts que comparan fuentes, detectan inconsistencias o hacen joins de validación.

- `cmp_nomina_vs_personas.sql` → comparación entre nómina y personas
- `val_match_documentos.sql` → validación de coincidencias
- `chk_datos_duplicados.sql` → chequeo de duplicados entre esquemas

#### 4. **Transformación y limpieza**
Scripts que aplican reglas de normalización, casting, regex, etc.

- `clean_documentos.sql` → limpieza de documentos
- `normalize_sexo.sql` → estandarización de sexo
- `fix_fechas.sql` → corrección de fechas inválidas

---

### Convención de nombres recomendada

```text
[prefijo_funcional]_[tema]_[detalle].sql
```

Ejemplos:
- `chk_` → chequeo
- `val_` → validación
- `eda_` → análisis exploratorio
- `cmp_` → comparación
- `clean_` → limpieza
- `fix_` → corrección

---